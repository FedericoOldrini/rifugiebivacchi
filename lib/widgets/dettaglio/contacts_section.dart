import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/rifugio.dart';
import 'helpers.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';

/// Sezione contatti, pulsante navigazione e pulsante donazioni.
class ContactsSection extends StatelessWidget {
  final Rifugio rifugio;

  const ContactsSection({super.key, required this.rifugio});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchMaps(double lat, double lng) async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasContacts =
        rifugio.telefono != null ||
        rifugio.email != null ||
        rifugio.sitoWeb != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contatti
        if (hasContacts) ...[
          SectionTitle(title: l10n.contacts),
          const SizedBox(height: 12),
          if (rifugio.telefono != null)
            ContactButton(
              icon: Icons.phone,
              label: rifugio.telefono!,
              onTap: () => _launchPhone(rifugio.telefono!),
            ),
          if (rifugio.email != null)
            ContactButton(
              icon: Icons.email,
              label: rifugio.email!,
              onTap: () => _launchEmail(rifugio.email!),
            ),
          if (rifugio.sitoWeb != null)
            ContactButton(
              icon: Icons.language,
              label: l10n.website,
              onTap: () => _launchUrl(rifugio.sitoWeb!),
            ),
          const SizedBox(height: 24),
        ],

        // Pulsante navigazione
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () =>
                _launchMaps(rifugio.latitudine, rifugio.longitudine),
            icon: const Icon(Icons.directions),
            label: Text(l10n.openInGoogleMaps),
          ),
        ),
        const SizedBox(height: 12),

        // Pulsante donazioni
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/donations');
            },
            icon: const Icon(Icons.favorite),
            label: Text(l10n.supportDevelopment),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }
}
