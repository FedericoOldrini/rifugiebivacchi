import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';
import '../providers/rifugi_provider.dart';
import '../models/rifugio.dart';
import '../services/clustering_service.dart';
import '../screens/dettaglio_rifugio_screen.dart';
import '../screens/offline_map_screen.dart';
import '../widgets/map_legend.dart';
import '../utils/screenshot_mode.dart';
import 'dart:ui' as ui;

class MappaRifugiScreen extends StatefulWidget {
  const MappaRifugiScreen({super.key});

  @override
  State<MappaRifugiScreen> createState() => _MappaRifugiScreenState();
}

class _MappaRifugiScreenState extends State<MappaRifugiScreen> {
  bool _useOfflineMap = false;
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  double _currentZoom = 10.0;

  // Cache dei BitmapDescriptor per marker singoli (evita ricrearli ogni volta)
  final Map<String, BitmapDescriptor> _markerIconCache = {};

  static const LatLng _defaultCenter = LatLng(45.4642, 9.1900);

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
    // In modalità screenshot, salta completamente Geolocator per evitare
    // il dialog nativo dei permessi di localizzazione che blocca
    // la cattura automatica degli screenshot.
    if (ScreenshotMode.enabled) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoading = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          10,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ──────────────────────────────────────────────
  // Marker singoli personalizzati (con icona)
  // ──────────────────────────────────────────────

  Future<BitmapDescriptor> _getCustomMarkerIcon(String tipo) async {
    if (_markerIconCache.containsKey(tipo)) {
      return _markerIconCache[tipo]!;
    }

    const double size = 44;
    const double iconSize = 20;
    final color = MapMarkerStyle.colorForTipo(tipo);
    final iconData = MapMarkerStyle.iconForTipo(tipo);

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    // Ombra
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(
      const Offset(size / 2, size / 2 + 1.5),
      size / 2 - 3,
      shadowPaint,
    );

    // Cerchio pieno colorato
    final fillPaint = Paint()..color = color;
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 3,
      fillPaint,
    );

    // Bordo bianco sottile
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 3.5,
      borderPaint,
    );

    // Icona al centro
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: iconData.fontFamily,
          package: iconData.fontPackage,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final descriptor = BitmapDescriptor.bytes(bytes!.buffer.asUint8List());

    _markerIconCache[tipo] = descriptor;
    return descriptor;
  }

  // ──────────────────────────────────────────────
  // Marker cluster (compatti e moderni)
  // ──────────────────────────────────────────────

  Future<BitmapDescriptor> _getClusterBitmap(int count) async {
    // Dimensioni più piccole e proporzionate
    final double size = count < 10
        ? 48
        : count < 50
        ? 54
        : 60;
    final color = MapMarkerStyle.clusterColor(count);

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final center = Offset(size / 2, size / 2);
    final radius = size / 2 - 2;

    // Anello esterno semi-trasparente (alone)
    final haloPaint = Paint()..color = color.withValues(alpha: 0.2);
    canvas.drawCircle(center, radius, haloPaint);

    // Cerchio interno pieno
    final innerRadius = radius - 5;
    final fillPaint = Paint()..color = color;
    canvas.drawCircle(center, innerRadius, fillPaint);

    // Bordo bianco sottile
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, innerRadius, borderPaint);

    // Testo numerico
    final fontSize = count < 10
        ? 16.0
        : count < 100
        ? 14.0
        : 12.0;
    final textPainter = TextPainter(
      text: TextSpan(
        text: count.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  // ──────────────────────────────────────────────
  // Creazione marker con clustering
  // ──────────────────────────────────────────────

  Future<void> _createMarkersWithClustering(List<Rifugio> rifugi) async {
    final clusters = ClusteringService.clusterRifugi(rifugi, _currentZoom);
    final Set<Marker> markers = {};

    // Cattura le stringhe localizzate prima delle operazioni async
    final l10n = AppLocalizations.of(context)!;

    for (final cluster in clusters) {
      if (cluster.isMultiple) {
        final icon = await _getClusterBitmap(cluster.count);
        markers.add(
          Marker(
            markerId: MarkerId(
              'cluster_${cluster.center.latitude}_${cluster.center.longitude}',
            ),
            position: cluster.center,
            icon: icon,
            anchor: const Offset(0.5, 0.5),
            onTap: () {
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(cluster.center, _currentZoom + 2),
              );
            },
            infoWindow: InfoWindow(
              title:
                  '${cluster.count} ${l10n.nRifugiInAreaCount(cluster.count)}',
              snippet: l10n.tapToExpand,
            ),
          ),
        );
      } else {
        final rifugio = cluster.singleRifugio;
        final icon = await _getCustomMarkerIcon(rifugio.tipo);

        markers.add(
          Marker(
            markerId: MarkerId(rifugio.id),
            position: LatLng(rifugio.latitudine, rifugio.longitudine),
            icon: icon,
            anchor: const Offset(0.5, 0.5),
            infoWindow: InfoWindow(
              title: rifugio.nome,
              snippet: _buildMarkerSnippet(rifugio),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DettaglioRifugioScreen(rifugio: rifugio),
                ),
              );
            },
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  String _buildMarkerSnippet(Rifugio rifugio) {
    final parts = <String>[];

    final tipo = rifugio.tipo == 'rifugio'
        ? AppLocalizations.of(context)!.rifugio
        : rifugio.tipo == 'bivacco'
        ? AppLocalizations.of(context)!.bivacco
        : AppLocalizations.of(context)!.malga;
    parts.add(tipo);

    if (rifugio.altitudine != null) {
      parts.add('${rifugio.altitudine!.toInt()} m');
    }

    if (rifugio.postiLetto != null && rifugio.postiLetto! > 0) {
      parts.add('🛏️ ${rifugio.postiLetto}');
    }

    return parts.join(' · ');
  }

  // ──────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────

  // ──────────────────────────────────────────────
  // Screenshot Mode — mappa statica senza GoogleMap
  // ──────────────────────────────────────────────

  /// In ScreenshotMode usa un Google Maps Static API image per evitare
  /// che il GoogleMap widget istanzi CLLocationManager (trigger popup).
  Widget _buildScreenshotMap(BuildContext context, List<Rifugio> rifugi) {
    // Crea marker visivi finti sopra un'immagine statica di mappa.
    // Centra sulle Dolomiti / Alpi centrali con zoom adeguato.
    return Stack(
      children: [
        // Sfondo: immagine statica via Google Maps Static API
        Positioned.fill(
          child: Image.asset(
            'assets/screenshots_images/map_placeholder.png',
            fit: BoxFit.cover,
            errorBuilder: (_, error, stackTrace) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Center(
                child: Icon(
                  Icons.map,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),

        // Legenda compatta centrata in alto
        const Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: Center(child: MapLegend()),
        ),

        // Marker finti posizionati casualmente per effetto visivo
        ..._buildFakeMarkers(context, rifugi),

        // Pulsante "la mia posizione"
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: 'locateMe',
            onPressed: () {},
            child: const Icon(Icons.my_location),
          ),
        ),

        // Toggle mappa offline
        Positioned(
          bottom: 16,
          left: 16,
          child: FloatingActionButton.small(
            heroTag: 'toggleMap',
            onPressed: () {},
            tooltip: AppLocalizations.of(context)!.mapOffline,
            child: const Icon(Icons.download_outlined),
          ),
        ),
      ],
    );
  }

  /// Genera marker visivi decorativi per lo screenshot della mappa.
  List<Widget> _buildFakeMarkers(BuildContext context, List<Rifugio> rifugi) {
    // Posizioni relative (frazioni della larghezza/altezza dello schermo)
    // distribuite per sembrare marker reali su una mappa alpina.
    const positions = [
      (0.35, 0.25),
      (0.65, 0.20),
      (0.20, 0.40),
      (0.50, 0.35),
      (0.75, 0.45),
      (0.30, 0.55),
      (0.60, 0.50),
      (0.45, 0.65),
      (0.80, 0.60),
      (0.25, 0.72),
    ];

    final screenSize = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    final widgets = <Widget>[];

    for (int i = 0; i < positions.length && i < rifugi.length; i++) {
      final (relX, relY) = positions[i];
      final tipo = rifugi[i].tipo;
      final color = MapMarkerStyle.colorForTipo(tipo);
      final iconData = MapMarkerStyle.iconForTipo(tipo);

      widgets.add(
        Positioned(
          left: screenSize.width * relX - 16,
          top: screenSize.height * relY - 16,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.surface, width: 2),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(iconData, color: colorScheme.onPrimary, size: 16),
          ),
        ),
      );
    }

    // Aggiungi un cluster marker per realismo
    widgets.add(
      Positioned(
        left: screenSize.width * 0.52 - 20,
        top: screenSize.height * 0.42 - 20,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: MapMarkerStyle.clusterColor(15),
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.surface.withValues(alpha: 0.9),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '15',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );

    return widgets;
  }

  // ──────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_useOfflineMap) {
      return Stack(
        children: [
          const OfflineMapScreen(),
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton.small(
              heroTag: 'toggleMap',
              onPressed: () => setState(() => _useOfflineMap = false),
              tooltip: AppLocalizations.of(context)!.mapGoogle,
              child: const Icon(Icons.map_outlined),
            ),
          ),
        ],
      );
    }

    return Consumer<RifugiProvider>(
      builder: (context, provider, child) {
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
                return distance <= 50;
              }).toList()
            : provider.rifugi;

        // In ScreenshotMode, non montiamo il GoogleMap widget per evitare
        // che il Google Maps SDK (binario chiuso) istanzi CLLocationManager
        // e triggeri il popup dei permessi di localizzazione.
        if (ScreenshotMode.enabled) {
          return _buildScreenshotMap(context, provider.rifugi);
        }

        return Stack(
          children: [
            // Mappa
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: userPos != null
                    ? LatLng(userPos.latitude, userPos.longitude)
                    : _defaultCenter,
                zoom: userPos != null ? 10 : 8,
              ),
              markers: _markers,
              myLocationEnabled: !ScreenshotMode.enabled,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              mapType: MapType.terrain,
              padding: const EdgeInsets.only(top: 48),
              onMapCreated: (controller) {
                _mapController = controller;
                _createMarkersWithClustering(rifugi);
              },
              onCameraMove: (position) {
                _currentZoom = position.zoom;
              },
              onCameraIdle: () {
                _createMarkersWithClustering(rifugi);
              },
            ),

            // Loading overlay
            if (_isLoading)
              Container(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.7),
                child: const Center(child: CircularProgressIndicator()),
              ),

            // Legenda compatta centrata in alto
            const Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(child: MapLegend()),
            ),

            // Pulsante "la mia posizione"
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.small(
                heroTag: 'locateMe',
                onPressed: () {
                  if (userPos != null) {
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(userPos.latitude, userPos.longitude),
                        13,
                      ),
                    );
                  }
                },
                child: const Icon(Icons.my_location),
              ),
            ),

            // Toggle mappa offline
            Positioned(
              bottom: 16,
              left: 16,
              child: FloatingActionButton.small(
                heroTag: 'toggleMap',
                onPressed: () => setState(() => _useOfflineMap = true),
                tooltip: AppLocalizations.of(context)!.mapOffline,
                child: const Icon(Icons.download_outlined),
              ),
            ),
          ],
        );
      },
    );
  }
}
