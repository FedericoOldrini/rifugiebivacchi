import 'package:flutter/material.dart';
import '../../models/rifugio.dart';
import 'helpers.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';

/// Sezione servizi e accessibilità del rifugio.
class ServicesSection extends StatelessWidget {
  final Rifugio rifugio;

  const ServicesSection({super.key, required this.rifugio});

  bool _hasServices() {
    return rifugio.postiLetto != null ||
        rifugio.ristorante == true ||
        rifugio.wifi == true ||
        rifugio.elettricita == true ||
        rifugio.pagamentoPos == true ||
        rifugio.defibrillatore == true ||
        rifugio.hotWater == true ||
        rifugio.showers == true ||
        rifugio.insideWater == true;
  }

  bool _hasAccessibility() {
    return rifugio.carAccess == true ||
        rifugio.mountainBikeAccess == true ||
        rifugio.disabledAccess == true ||
        rifugio.disabledWc == true ||
        rifugio.familiesChildrenAccess == true ||
        rifugio.petAccess == true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Servizi
        if (_hasServices()) ...[
          SectionTitle(title: l10n.services),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  if (rifugio.postiLetto != null && rifugio.postiLetto! > 0)
                    ServiceChip(
                      icon: Icons.bed,
                      label: l10n.bedsCount(rifugio.postiLetto!),
                    ),
                  if (rifugio.ristorante == true)
                    ServiceChip(
                      icon: Icons.restaurant,
                      label: rifugio.restaurantSeats != null
                          ? l10n.restaurantWithSeats(rifugio.restaurantSeats!)
                          : l10n.restaurant,
                    ),
                  if (rifugio.wifi == true)
                    ServiceChip(icon: Icons.wifi, label: l10n.wifi),
                  if (rifugio.elettricita == true)
                    ServiceChip(
                      icon: Icons.electrical_services,
                      label: l10n.electricity,
                    ),
                  if (rifugio.pagamentoPos == true)
                    ServiceChip(icon: Icons.credit_card, label: l10n.pos),
                  if (rifugio.defibrillatore == true)
                    ServiceChip(
                      icon: Icons.favorite,
                      label: l10n.defibrillator,
                    ),
                  if (rifugio.hotWater == true)
                    ServiceChip(icon: Icons.hot_tub, label: l10n.hotWater),
                  if (rifugio.showers == true)
                    ServiceChip(icon: Icons.shower, label: l10n.showers),
                  if (rifugio.insideWater == true)
                    ServiceChip(
                      icon: Icons.water_drop,
                      label: l10n.insideWater,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Accessibilità
        if (_hasAccessibility()) ...[
          SectionTitle(title: l10n.accessibility),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  if (rifugio.carAccess == true)
                    ServiceChip(icon: Icons.directions_car, label: l10n.car),
                  if (rifugio.mountainBikeAccess == true)
                    ServiceChip(icon: Icons.pedal_bike, label: l10n.mtb),
                  if (rifugio.disabledAccess == true)
                    ServiceChip(icon: Icons.accessible, label: l10n.disabled),
                  if (rifugio.disabledWc == true)
                    ServiceChip(icon: Icons.wc, label: l10n.disabledWc),
                  if (rifugio.familiesChildrenAccess == true)
                    ServiceChip(
                      icon: Icons.family_restroom,
                      label: l10n.families,
                    ),
                  if (rifugio.petAccess == true)
                    ServiceChip(icon: Icons.pets, label: l10n.pets),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Gestione
        if (rifugio.propertyName != null || rifugio.owner != null) ...[
          SectionTitle(title: l10n.management),
          const SizedBox(height: 12),
          if (rifugio.propertyName != null)
            InfoRow(
              icon: Icons.business,
              label: l10n.manager,
              value: rifugio.propertyName!,
            ),
          if (rifugio.owner != null)
            InfoRow(
              icon: Icons.account_balance,
              label: l10n.property,
              value: rifugio.owner!,
            ),
          if (rifugio.regionalType != null)
            InfoRow(
              icon: Icons.category,
              label: l10n.type,
              value: rifugio.regionalType!,
            ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}
