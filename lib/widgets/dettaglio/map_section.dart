import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/rifugio.dart';
import '../../utils/screenshot_mode.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';

/// Mappa Google Maps con marker del rifugio.
class MapSection extends StatelessWidget {
  final Rifugio rifugio;
  final void Function(GoogleMapController controller) onMapCreated;

  const MapSection({
    super.key,
    required this.rifugio,
    required this.onMapCreated,
  });

  String _buildMarkerSnippet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final parts = <String>[];

    // Tipo
    final tipo = rifugio.tipo == 'rifugio'
        ? l10n.rifugio
        : rifugio.tipo == 'bivacco'
        ? l10n.bivacco
        : l10n.malga;
    parts.add(tipo);

    // Altitudine
    if (rifugio.altitudine != null) {
      parts.add(l10n.altitudeValue(rifugio.altitudine!.toInt()));
    }

    // Posti letto
    if (rifugio.postiLetto != null && rifugio.postiLetto! > 0) {
      parts.add('🛏️ ${l10n.bedsShort(rifugio.postiLetto!)}');
    }

    return parts.join(' • ');
  }

  Set<Marker> _createMarker(BuildContext context) {
    final hue = rifugio.tipo == 'rifugio'
        ? BitmapDescriptor.hueAzure
        : rifugio.tipo == 'bivacco'
        ? BitmapDescriptor.hueOrange
        : BitmapDescriptor.hueGreen;

    return {
      Marker(
        markerId: MarkerId(rifugio.id),
        position: LatLng(rifugio.latitudine, rifugio.longitudine),
        infoWindow: InfoWindow(
          title: rifugio.nome,
          snippet: _buildMarkerSnippet(context),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        // In ScreenshotMode, non montiamo GoogleMap per evitare crash:
        // GMSServices non è inizializzato (skippato in AppDelegate.swift).
        child: ScreenshotMode.enabled
            ? _buildPlaceholder(context)
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(rifugio.latitudine, rifugio.longitudine),
                  zoom: 13,
                ),
                markers: _createMarker(context),
                onMapCreated: onMapCreated,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
      ),
    );
  }

  /// Placeholder statico per la mappa in screenshot mode.
  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: const Color(0xFFE8F0E8),
      child: Stack(
        children: [
          // Griglia leggera per dare l'idea di una mappa
          Positioned.fill(child: CustomPaint(painter: _MapGridPainter())),
          // Marker al centro
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  color: theme.colorScheme.primary,
                  size: 36,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    rifugio.nome,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple grid painter that gives a map-like appearance.
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD0DDD0)
      ..strokeWidth = 0.5;
    // Draw subtle grid lines
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
