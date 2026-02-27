import 'package:flutter/material.dart';
import '../../models/rifugio.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';

/// Sezione descrizione del rifugio e descrizione del sito/posizione.
class DescriptionSection extends StatelessWidget {
  final Rifugio rifugio;

  const DescriptionSection({super.key, required this.rifugio});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Descrizione principale
        if (rifugio.descrizione != null && rifugio.descrizione!.isNotEmpty) ...[
          Text(
            rifugio.descrizione!,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
        ],

        // Descrizione del sito/posizione
        if (rifugio.siteDescription != null &&
            rifugio.siteDescription!.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.place,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.position,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rifugio.siteDescription!,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
