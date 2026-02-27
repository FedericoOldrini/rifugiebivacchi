import 'package:flutter/material.dart';
import '../../models/rifugio.dart';
import 'helpers.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';

/// Sezione informazioni principali: altitudine, localita, comune, valle, regione, anno, coordinate.
class InfoSection extends StatelessWidget {
  final Rifugio rifugio;

  const InfoSection({super.key, required this.rifugio});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: l10n.informazioni),
        const SizedBox(height: 12),
        if (rifugio.altitudine != null)
          InfoRow(
            icon: Icons.terrain,
            label: l10n.altitude,
            value: '${rifugio.altitudine!.toInt()} m s.l.m.',
          ),
        if (rifugio.locality != null)
          InfoRow(
            icon: Icons.location_city,
            label: l10n.locality,
            value: rifugio.locality!,
          ),
        if (rifugio.municipality != null)
          InfoRow(
            icon: Icons.business,
            label: l10n.municipality,
            value: rifugio.municipality!,
          ),
        if (rifugio.valley != null)
          InfoRow(
            icon: Icons.landscape,
            label: l10n.valley,
            value: rifugio.valley!,
          ),
        if (rifugio.region != null)
          InfoRow(
            icon: Icons.map,
            label: l10n.region,
            value:
                '${rifugio.region!}${rifugio.province != null ? ' (${rifugio.province})' : ''}',
          ),
        if (rifugio.buildYear != null)
          InfoRow(
            icon: Icons.calendar_today,
            label: l10n.buildYear,
            value: rifugio.buildYear.toString(),
          ),
        InfoRow(
          icon: Icons.location_on,
          label: l10n.coordinates,
          value:
              '${rifugio.latitudine.toStringAsFixed(4)}, ${rifugio.longitudine.toStringAsFixed(4)}',
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
