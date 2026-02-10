import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';
import 'donations_screen.dart';
import '../services/onboarding_service.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.appInfo,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.version),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.information),
            subtitle: Text(l10n.appDescription),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: l10n.appTitle,
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(
                  Icons.landscape,
                  size: 48,
                  color: Color(0xFF2D5016),
                ),
                children: [
                  Text(l10n.appAboutDescription),
                ],
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.privacyAndPermissions,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(l10n.locationPermissions),
            subtitle: Text(l10n.locationPermissionsDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.locationPermissions),
                  content: Text(l10n.locationPermissionsDialog),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.ok),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacy),
            subtitle: Text(l10n.privacyDesc),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(l10n.privacy),
                  content: Text(l10n.privacyDialog),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.ok),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.help,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(l10n.reviewOnboarding),
            subtitle: Text(l10n.reviewOnboardingDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await OnboardingService.resetOnboarding();
              
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const OnboardingScreen(),
                  ),
                );
              }
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.supportProject,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_outlined, color: Colors.red),
            title: Text(l10n.supportUs),
            subtitle: Text(l10n.supportUsDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DonationsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: Text(l10n.rateApp),
            subtitle: Text(l10n.rateAppDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final inAppReview = InAppReview.instance;
              if (await inAppReview.isAvailable()) {
                await inAppReview.requestReview();
              } else {
                // Fallback: apri la pagina dello store
                await inAppReview.openStoreListing(
                  appStoreId: '', // Inserisci il tuo App Store ID
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.rateAppThanks),
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              l10n.madeWithLove,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
