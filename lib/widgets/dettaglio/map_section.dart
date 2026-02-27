import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/rifugio.dart';
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
      parts.add('${rifugio.altitudine!.toInt()} m s.l.m.');
    }

    // Posti letto
    if (rifugio.postiLetto != null && rifugio.postiLetto! > 0) {
      parts.add('🛏️ ${rifugio.postiLetto} posti');
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
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
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
}
