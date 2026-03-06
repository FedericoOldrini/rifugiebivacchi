/// Entry point per screenshot automatici.
///
/// Bypassa completamente Firebase, geolocalizzazione e onboarding.
/// Usa i provider REALI in `testMode: true` con dati fake iniettati
/// tramite i metodi `setXxxForTest()`.
///
/// Uso:
///   flutter test integration_test/screenshot_test.dart \
///       --dart-define=SCREENSHOT_MODE=true
///
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';
import 'data/screenshot_data.dart';
import 'utils/screenshot_mode.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/rifugi_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/passaporto_provider.dart';
import 'providers/preferiti_provider.dart';
import 'providers/filtro_provider.dart';
import 'screens/home_screen.dart';
import 'screens/donations_screen.dart';

// ============================================================
// Screenshot App — entry point
// ============================================================

class ScreenshotApp extends StatelessWidget {
  const ScreenshotApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Crea i provider reali in testMode
    final rifugiProvider = RifugiProvider(testMode: true);
    rifugiProvider.setRifugiForTest(fakeRifugi());

    final authProvider = AuthProvider(testMode: true);
    authProvider.setFakeUser(
      uid: 'screenshot-user-001',
      displayName: 'Marco Rossi',
      email: 'marco.rossi@example.com',
    );

    final passaportoProvider = PassaportoProvider(testMode: true);
    passaportoProvider.setCheckInsForTest(fakeCheckIns());

    final preferitiProvider = PreferitiProvider(testMode: true);
    preferitiProvider.setPreferitiForTest(fakePreferiti());

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RifugiProvider>.value(value: rifugiProvider),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<PassaportoProvider>.value(
          value: passaportoProvider,
        ),
        ChangeNotifierProvider<PreferitiProvider>.value(
          value: preferitiProvider,
        ),
        ChangeNotifierProvider<FiltroProvider>(create: (_) => FiltroProvider()),
      ],
      child: MaterialApp(
        title: 'Rifugi e Bivacchi',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('it'),
        theme: AppTheme.lightTheme(AppSeason.summer),
        darkTheme: AppTheme.darkTheme(AppSeason.summer),
        themeMode: ThemeMode.light, // Forza light per screenshot
        home: const HomeScreen(),
        routes: {'/donations': (context) => const DonationsScreen()},
      ),
    );
  }
}

// ============================================================
// Entry point main()
// ============================================================

Future<void> main() async {
  // Non inizializzare WidgetsFlutterBinding qui:
  // quando chiamato dall'integration test, il binding è già stato
  // inizializzato come IntegrationTestWidgetsFlutterBinding.
  // Chiamare WidgetsFlutterBinding.ensureInitialized() dopo causerebbe
  // un conflitto. Il binding è comunque inizializzato da runApp().

  // Attiva la modalità screenshot per saltare Geolocator e altri
  // servizi che mostrano dialog nativi non gestibili dal test.
  ScreenshotMode.enabled = true;

  await initializeDateFormatting('it_IT', null);
  runApp(const ScreenshotApp());
}

// Dati fake importati da lib/data/screenshot_data.dart:
// fakeRifugi(), fakeCheckIns(), fakePreferiti()
