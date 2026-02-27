import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';
import '../providers/rifugi_provider.dart';
import '../screens/dettaglio_rifugio_screen.dart';

/// Mappa offline basata su OpenStreetMap con caching dei tile
class OfflineMapScreen extends StatefulWidget {
  const OfflineMapScreen({super.key});

  @override
  State<OfflineMapScreen> createState() => _OfflineMapScreenState();
}

class _OfflineMapScreenState extends State<OfflineMapScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _isLoading = true;

  static const LatLng _defaultCenter = LatLng(45.4642, 9.1900);

  @override
  void initState() {
    super.initState();
    _initFMTC();
    _getCurrentLocation();
  }

  Future<void> _initFMTC() async {
    try {
      await FMTCObjectBoxBackend().initialise();

      // Crea store per i tile se non esiste
      final store = FMTCStore('osmTiles');
      await store.manage.create();
    } catch (_) {
      // FMTC potrebbe non essere disponibile su tutte le piattaforme
    }
  }

  Future<void> _getCurrentLocation() async {
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

      _mapController.move(LatLng(position.latitude, position.longitude), 10);
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Color _getMarkerColor(String tipo) {
    switch (tipo) {
      case 'rifugio':
        return Colors.blue[600]!;
      case 'bivacco':
        return Colors.orange[700]!;
      default:
        return Colors.green[700]!;
    }
  }

  IconData _getMarkerIcon(String tipo) {
    switch (tipo) {
      case 'bivacco':
        return Icons.cabin;
      case 'malga':
        return Icons.cottage;
      default:
        return Icons.home;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RifugiProvider>(
      builder: (context, provider, child) {
        final userPos = provider.userPosition ?? _currentPosition;
        final center = userPos != null
            ? LatLng(userPos.latitude, userPos.longitude)
            : _defaultCenter;

        // Filtra rifugi entro 50km se abbiamo la posizione
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

        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: userPos != null ? 10 : 8,
                maxZoom: 18,
                minZoom: 5,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.rifugibivacchi.app',
                  tileProvider: FMTCTileProvider(
                    stores: const {'osmTiles': null},
                  ),
                  maxZoom: 18,
                ),
                MarkerLayer(
                  markers: [
                    // User position marker
                    if (userPos != null)
                      Marker(
                        point: LatLng(userPos.latitude, userPos.longitude),
                        width: 24,
                        height: 24,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Rifugi markers
                    ...rifugi.map(
                      (rifugio) => Marker(
                        point: LatLng(rifugio.latitudine, rifugio.longitudine),
                        width: 36,
                        height: 36,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DettaglioRifugioScreen(rifugio: rifugio),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getMarkerColor(rifugio.tipo),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              _getMarkerIcon(rifugio.tipo),
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.7),
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
                      _LegendItem(
                        color: Colors.blue[600]!,
                        label: AppLocalizations.of(context)!.legendRifugi,
                      ),
                      const SizedBox(width: 12),
                      _LegendItem(
                        color: Colors.orange[700]!,
                        label: AppLocalizations.of(context)!.legendBivacchi,
                      ),
                      const SizedBox(width: 12),
                      _LegendItem(
                        color: Colors.green[700]!,
                        label: AppLocalizations.of(context)!.legendMalghe,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Pulsante posizione
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.small(
                heroTag: 'locateMe',
                onPressed: () {
                  if (userPos != null) {
                    _mapController.move(
                      LatLng(userPos.latitude, userPos.longitude),
                      13,
                    );
                  }
                },
                child: const Icon(Icons.my_location),
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
