import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/rifugi_provider.dart';
import '../models/rifugio.dart';
import '../services/clustering_service.dart';
import '../screens/dettaglio_rifugio_screen.dart';
import 'dart:ui' as ui;

class MappaRifugiScreen extends StatefulWidget {
  const MappaRifugiScreen({super.key});

  @override
  State<MappaRifugiScreen> createState() => _MappaRifugiScreenState();
}

class _MappaRifugiScreenState extends State<MappaRifugiScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  double _currentZoom = 10.0;

  // Centro Italia come posizione di default (se non si riesce a ottenere la posizione)
  static const LatLng _defaultCenter = LatLng(45.4642, 9.1900); // Milano

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      // Muovi la camera alla posizione corrente
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          10,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createMarkersWithClustering(List<Rifugio> rifugi) async {
    final clusters = ClusteringService.clusterRifugi(rifugi, _currentZoom);
    final Set<Marker> markers = {};

    for (final cluster in clusters) {
      if (cluster.isMultiple) {
        // Crea marker cluster
        final icon = await _getClusterBitmap(cluster.count);
        markers.add(
          Marker(
            markerId: MarkerId('cluster_${cluster.center.latitude}_${cluster.center.longitude}'),
            position: cluster.center,
            icon: icon,
            onTap: () {
              // Zoom per espandere il cluster
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(
                  cluster.center,
                  _currentZoom + 2,
                ),
              );
            },
            infoWindow: InfoWindow(
              title: '${cluster.count} rifugi in questa zona',
              snippet: 'Tocca per espandere',
            ),
          ),
        );
      } else {
        // Marker singolo
        final rifugio = cluster.singleRifugio;
        final hue = _getMarkerHue(rifugio.tipo);
        
        markers.add(
          Marker(
            markerId: MarkerId(rifugio.id),
            position: LatLng(rifugio.latitudine, rifugio.longitudine),
            icon: BitmapDescriptor.defaultMarkerWithHue(hue),
            infoWindow: InfoWindow(
              title: rifugio.nome,
              snippet: _buildMarkerSnippet(rifugio),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DettaglioRifugioScreen(rifugio: rifugio),
                ),
              );
            },
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  double _getMarkerHue(String tipo) {
    switch (tipo) {
      case 'rifugio':
        return BitmapDescriptor.hueAzure; // Blu per rifugi
      case 'bivacco':
        return BitmapDescriptor.hueOrange; // Arancione per bivacchi
      default:
        return BitmapDescriptor.hueGreen; // Verde per malghe
    }
  }

  Future<BitmapDescriptor> _getClusterBitmap(int count) async {
    final size = count < 10 ? 90 : count < 100 ? 100 : 110;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = Theme.of(context).primaryColor;

    // Disegna cerchio
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2,
      paint,
    );

    // Disegna bordo bianco
    paint
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2 - 2,
      paint,
    );

    // Disegna testo
    final textPainter = TextPainter(
      text: TextSpan(
        text: count.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: count < 10 ? 32 : count < 100 ? 28 : 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  String _buildMarkerSnippet(Rifugio rifugio) {
    final parts = <String>[];

    // Tipo
    final tipo = rifugio.tipo == 'rifugio'
        ? 'Rifugio'
        : rifugio.tipo == 'bivacco'
        ? 'Bivacco'
        : 'Malga';
    parts.add(tipo);

    // Altitudine
    if (rifugio.altitudine != null) {
      parts.add('${rifugio.altitudine!.toInt()} m');
    }

    // Posti letto
    if (rifugio.postiLetto != null && rifugio.postiLetto! > 0) {
      parts.add('🛏️ ${rifugio.postiLetto}');
    }

    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RifugiProvider>(
      builder: (context, provider, child) {
        // Usa la posizione del provider se disponibile
        final userPos = provider.userPosition ?? _currentPosition;

        // Filtra rifugi vicini se abbiamo la posizione (entro 50km)
        final rifugi = userPos != null
            ? provider.rifugi.where((rifugio) {
                final distance =
                    Geolocator.distanceBetween(
                      userPos.latitude,
                      userPos.longitude,
                      rifugio.latitudine,
                      rifugio.longitudine,
                    ) /
                    1000;
                return distance <= 50; // Mostra solo rifugi entro 50km
              }).toList()
            : provider.rifugi;

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: userPos != null
                    ? LatLng(userPos.latitude, userPos.longitude)
                    : _defaultCenter,
                zoom: userPos != null ? 10 : 8,
              ),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
              mapType: MapType.terrain,
              onMapCreated: (controller) {
                _mapController = controller;
                // Crea marker iniziali
                _createMarkersWithClustering(rifugi);
              },
              onCameraMove: (position) {
                _currentZoom = position.zoom;
              },
              onCameraIdle: () {
                // Aggiorna i marker quando la camera si ferma
                _createMarkersWithClustering(rifugi);
              },
            ),
            if (_isLoading)
              Container(
                color: Colors.white.withValues(alpha: 0.7),
                child: const Center(child: CircularProgressIndicator()),
              ),
            // Legenda
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LegendItem(color: Colors.blue[600]!, label: 'Rifugi'),
                      const SizedBox(width: 12),
                      _LegendItem(
                        color: Colors.orange[700]!,
                        label: 'Bivacchi',
                      ),
                      const SizedBox(width: 12),
                      _LegendItem(color: Colors.green[700]!, label: 'Malghe'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on, color: color, size: 20),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
