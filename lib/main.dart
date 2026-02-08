import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'providers/rifugi_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/passaporto_provider.dart';
import 'providers/preferiti_provider.dart';
import 'providers/filtro_provider.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/donations_screen.dart';
import 'services/onboarding_service.dart';

Future<void> main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Inizializza il locale italiano per le date
    await initializeDateFormatting('it_IT', null);

    // Inizializza Firebase
    // NOTA: Richiede configurazione Firebase (vedi FIREBASE_SETUP.md)
    try {
      await Firebase.initializeApp();
      
      // Configura Crashlytics
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };
      
      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      
    } catch (e) {
      print('Errore inizializzazione Firebase: $e');
      print('L\'app funzionerà comunque, ma senza autenticazione.');
    }

    runApp(const MyApp());
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RifugiProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PassaportoProvider()),
        ChangeNotifierProvider(create: (_) => PreferitiProvider()),
        ChangeNotifierProvider(create: (_) => FiltroProvider()),
      ],
      child: MaterialApp(
        title: 'Rifugi e Bivacchi',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Segue le impostazioni di sistema
        home: const AppInitializer(),
        routes: {
          '/donations': (context) => const DonationsScreen(),
        },
      ),
    );
  }
}

/// Widget che controlla se mostrare l'onboarding o la home
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final shouldShow = await OnboardingService.shouldShowOnboarding();

    if (mounted) {
      setState(() {
        _showOnboarding = shouldShow;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Mostra uno splash screen durante il caricamento
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hiking, size: 80, color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                'Rifugi e Bivacchi',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      );
    }

    return _showOnboarding ? const OnboardingScreen() : const HomeScreen();
  }
}
