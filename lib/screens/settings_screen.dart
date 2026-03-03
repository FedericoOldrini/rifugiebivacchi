import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../services/analytics_service.dart';
import 'donations_screen.dart';
import '../services/onboarding_service.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = '${info.version} (${info.buildNumber})';
      });
    }
  }

  IconData _seasonIcon(AppSeason season) {
    switch (season) {
      case AppSeason.spring:
        return Icons.local_florist;
      case AppSeason.summer:
        return Icons.wb_sunny;
      case AppSeason.autumn:
        return Icons.eco;
      case AppSeason.winter:
        return Icons.ac_unit;
      case AppSeason.auto:
        return Icons.auto_awesome;
    }
  }

  String _seasonLabel(AppLocalizations l10n, AppSeason season) {
    switch (season) {
      case AppSeason.auto:
        return l10n.seasonAuto;
      case AppSeason.spring:
        return l10n.seasonSpring;
      case AppSeason.summer:
        return l10n.seasonSummer;
      case AppSeason.autumn:
        return l10n.seasonAutumn;
      case AppSeason.winter:
        return l10n.seasonWinter;
    }
  }

  IconData _themeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  String _themeModeLabel(AppLocalizations l10n, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.themeModeSystem;
      case ThemeMode.light:
        return l10n.themeModeLight;
      case ThemeMode.dark:
        return l10n.themeModeDark;
    }
  }

  void _showSeasonPicker(
    BuildContext context,
    AppLocalizations l10n,
    ThemeProvider themeProvider,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.seasonTheme,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ...AppSeason.values.map((season) {
                final isSelected = themeProvider.season == season;
                return ListTile(
                  leading: Icon(
                    _seasonIcon(season),
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(_seasonLabel(l10n, season)),
                  subtitle: season == AppSeason.auto
                      ? Text(l10n.seasonAutoDesc)
                      : null,
                  trailing: isSelected
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    themeProvider.setSeason(season);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showThemeModePicker(
    BuildContext context,
    AppLocalizations l10n,
    ThemeProvider themeProvider,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final modes = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.themeMode,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ...modes.map((mode) {
                final isSelected = themeProvider.themeMode == mode;
                return ListTile(
                  leading: Icon(
                    _themeModeIcon(mode),
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(_themeModeLabel(l10n, mode)),
                  trailing: isSelected
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    themeProvider.setThemeMode(mode);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          // --- Sezione Aspetto ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.appearance,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.outline,
              ),
            ),
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return Column(
                children: [
                  ListTile(
                    leading: Icon(_seasonIcon(themeProvider.effectiveSeason)),
                    title: Text(l10n.seasonTheme),
                    subtitle: Text(_seasonLabel(l10n, themeProvider.season)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        _showSeasonPicker(context, l10n, themeProvider),
                  ),
                  ListTile(
                    leading: Icon(_themeModeIcon(themeProvider.themeMode)),
                    title: Text(l10n.themeMode),
                    subtitle: Text(
                      _themeModeLabel(l10n, themeProvider.themeMode),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        _showThemeModePicker(context, l10n, themeProvider),
                  ),
                ],
              );
            },
          ),
          const Divider(),
          // --- Sezione Informazioni App ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.appInfo,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.outline,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.version),
            subtitle: Text(_appVersion),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.information),
            subtitle: Text(l10n.appDescription),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: l10n.appTitle,
                applicationVersion: _appVersion,
                applicationIcon: Icon(
                  Icons.landscape,
                  size: 48,
                  color: colorScheme.primary,
                ),
                children: [Text(l10n.appAboutDescription)],
              );
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.privacyAndPermissions,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.outline,
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.outline,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(l10n.reviewOnboarding),
            subtitle: Text(l10n.reviewOnboardingDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              AnalyticsService.instance.logReviewOnboarding();
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.outline,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.favorite_outlined, color: colorScheme.error),
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
              AnalyticsService.instance.logRateApp();
              final inAppReview = InAppReview.instance;
              if (await inAppReview.isAvailable()) {
                await inAppReview.requestReview();
              } else {
                // Fallback: apri la pagina dello store
                await inAppReview.openStoreListing(appStoreId: '6740241514');
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.rateAppThanks)));
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
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
