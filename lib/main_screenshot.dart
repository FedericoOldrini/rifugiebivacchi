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
import 'theme/app_theme.dart';
import 'providers/rifugi_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/passaporto_provider.dart';
import 'providers/preferiti_provider.dart';
import 'providers/filtro_provider.dart';
import 'models/rifugio.dart';
import 'models/rifugio_checkin.dart';
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
    rifugiProvider.setRifugiForTest(_fakeRifugi());

    final authProvider = AuthProvider(testMode: true);
    authProvider.setFakeUser(
      uid: 'screenshot-user-001',
      displayName: 'Marco Rossi',
      email: 'marco.rossi@example.com',
    );

    final passaportoProvider = PassaportoProvider(testMode: true);
    passaportoProvider.setCheckInsForTest(_fakeCheckIns());

    final preferitiProvider = PreferitiProvider(testMode: true);
    preferitiProvider.setPreferitiForTest(_fakePreferiti());

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
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
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
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it_IT', null);
  runApp(const ScreenshotApp());
}

// ============================================================
// Dati fake per screenshot
// ============================================================

List<Rifugio> _fakeRifugi() => [
  Rifugio(
    id: 'rif001',
    nome: 'Rifugio Auronzo',
    descrizione: 'Ai piedi delle Tre Cime di Lavaredo',
    latitudine: 46.6117,
    longitudine: 12.2944,
    altitudine: 2320,
    tipo: 'rifugio',
    operatore: 'CAI Auronzo',
    telefono: '+39 0435 39002',
    email: 'info@rifugioauronzo.it',
    postiLetto: 122,
    ristorante: true,
    wifi: true,
    elettricita: true,
    pagamentoPos: true,
    region: 'Veneto',
    province: 'Belluno',
    municipality: 'Auronzo di Cadore',
    valley: 'Val di Landro',
    status: 'aperto',
    familiesChildrenAccess: true,
    immagine: 'asset:assets/screenshots_images/auronzo.jpg',
    imageUrls: ['asset:assets/screenshots_images/auronzo.jpg'],
  ),
  Rifugio(
    id: 'rif002',
    nome: 'Rifugio Locatelli',
    descrizione: 'Panorama sulle Tre Cime di Lavaredo',
    latitudine: 46.6283,
    longitudine: 12.3100,
    altitudine: 2405,
    tipo: 'rifugio',
    operatore: 'CAI Padova',
    telefono: '+39 0474 972002',
    postiLetto: 80,
    ristorante: true,
    wifi: false,
    elettricita: true,
    region: 'Trentino-Alto Adige',
    province: 'Bolzano',
    status: 'aperto',
    immagine: 'asset:assets/screenshots_images/locatelli.jpg',
    imageUrls: ['asset:assets/screenshots_images/locatelli.jpg'],
  ),
  Rifugio(
    id: 'rif003',
    nome: 'Rifugio Zsigmondy-Comici',
    descrizione: 'Nel cuore delle Dolomiti di Sesto',
    latitudine: 46.6319,
    longitudine: 12.3028,
    altitudine: 2224,
    tipo: 'rifugio',
    operatore: 'CAI Alto Adige',
    postiLetto: 50,
    ristorante: true,
    region: 'Trentino-Alto Adige',
    province: 'Bolzano',
    valley: 'Alta Pusteria',
    status: 'aperto',
    immagine: 'asset:assets/screenshots_images/zsigmondy.jpg',
    imageUrls: ['asset:assets/screenshots_images/zsigmondy.jpg'],
  ),
  Rifugio(
    id: 'rif004',
    nome: 'Bivacco Fanton',
    descrizione: 'Bivacco in alta quota nel gruppo del Sorapiss',
    latitudine: 46.5064,
    longitudine: 12.2042,
    altitudine: 2700,
    tipo: 'bivacco',
    postiLetto: 8,
    ristorante: false,
    wifi: false,
    elettricita: false,
    region: 'Veneto',
    province: 'Belluno',
    status: 'aperto',
    immagine: 'asset:assets/screenshots_images/fanton.jpg',
    imageUrls: ['asset:assets/screenshots_images/fanton.jpg'],
  ),
  Rifugio(
    id: 'rif005',
    nome: 'Rifugio Pedrotti',
    descrizione: 'Affacciato sulle Dolomiti di Brenta',
    latitudine: 46.1793,
    longitudine: 10.8872,
    altitudine: 2491,
    tipo: 'rifugio',
    operatore: 'SAT Trento',
    telefono: '+39 0461 948115',
    postiLetto: 120,
    ristorante: true,
    wifi: true,
    elettricita: true,
    pagamentoPos: true,
    defibrillatore: true,
    region: 'Trentino-Alto Adige',
    province: 'Trento',
    municipality: 'San Lorenzo Dorsino',
    valley: 'Val di Brenta',
    status: 'aperto',
    familiesChildrenAccess: true,
    hotWater: true,
    showers: true,
    immagine: 'asset:assets/screenshots_images/pedrotti.png',
    imageUrls: ['asset:assets/screenshots_images/pedrotti.png'],
  ),
  Rifugio(
    id: 'rif006',
    nome: 'Rifugio Tuckett',
    descrizione: 'Nel cuore delle Dolomiti di Brenta',
    latitudine: 46.1911,
    longitudine: 10.8792,
    altitudine: 2272,
    tipo: 'rifugio',
    operatore: 'SAT Trento',
    postiLetto: 80,
    ristorante: true,
    elettricita: true,
    region: 'Trentino-Alto Adige',
    province: 'Trento',
    status: 'aperto',
    immagine: 'asset:assets/screenshots_images/pian_fiacconi.jpg',
    imageUrls: ['asset:assets/screenshots_images/pian_fiacconi.jpg'],
  ),
  Rifugio(
    id: 'rif007',
    nome: 'Rifugio Ponti',
    descrizione: 'Immerso nelle Alpi Lepontine',
    latitudine: 46.1400,
    longitudine: 8.1200,
    altitudine: 2559,
    tipo: 'rifugio',
    operatore: 'CAI Verbania',
    postiLetto: 40,
    ristorante: true,
    region: 'Piemonte',
    province: 'Verbania',
    status: 'aperto',
    immagine: 'asset:assets/screenshots_images/selvata.jpg',
    imageUrls: ['asset:assets/screenshots_images/selvata.jpg'],
  ),
  Rifugio(
    id: 'rif008',
    nome: 'Malga Federa',
    descrizione: 'Vista spettacolare sulla Croda da Lago',
    latitudine: 46.4678,
    longitudine: 12.0617,
    altitudine: 1966,
    tipo: 'malga',
    operatore: 'Privato',
    postiLetto: 20,
    ristorante: true,
    wifi: true,
    elettricita: true,
    region: 'Veneto',
    province: 'Belluno',
    municipality: 'Cortina d\'Ampezzo',
    status: 'aperto',
    petAccess: true,
    familiesChildrenAccess: true,
    immagine: 'asset:assets/screenshots_images/federa.jpg',
    imageUrls: ['asset:assets/screenshots_images/federa.jpg'],
  ),
  Rifugio(
    id: 'rif009',
    nome: 'Rifugio Brentei',
    descrizione: 'Punto di partenza per le vie delle Dolomiti di Brenta',
    latitudine: 46.1628,
    longitudine: 10.8750,
    altitudine: 2182,
    tipo: 'rifugio',
    operatore: 'SAT Trento',
    postiLetto: 96,
    ristorante: true,
    elettricita: true,
    region: 'Trentino-Alto Adige',
    province: 'Trento',
    status: 'aperto',
    immagine: 'asset:assets/screenshots_images/brentei.jpg',
    imageUrls: ['asset:assets/screenshots_images/brentei.jpg'],
  ),
  Rifugio(
    id: 'rif010',
    nome: 'Bivacco Gervasutti',
    descrizione: 'Bivacco futuristico sul Monte Bianco',
    latitudine: 45.8547,
    longitudine: 6.9433,
    altitudine: 2835,
    tipo: 'bivacco',
    postiLetto: 12,
    ristorante: false,
    wifi: false,
    elettricita: true,
    region: 'Valle d\'Aosta',
    province: 'Aosta',
    status: 'aperto',
    immagine: 'asset:assets/screenshots_images/coldai.jpg',
    imageUrls: ['asset:assets/screenshots_images/coldai.jpg'],
  ),
];

List<RifugioCheckIn> _fakeCheckIns() => [
  RifugioCheckIn(
    id: 'ci001',
    rifugioId: 'rif001',
    rifugioNome: 'Rifugio Auronzo',
    rifugioLat: 46.6117,
    rifugioLng: 12.2944,
    altitudine: 2320,
    dataVisita: DateTime(2025, 8, 15),
  ),
  RifugioCheckIn(
    id: 'ci002',
    rifugioId: 'rif002',
    rifugioNome: 'Rifugio Locatelli',
    rifugioLat: 46.6283,
    rifugioLng: 12.3100,
    altitudine: 2405,
    dataVisita: DateTime(2025, 8, 16),
  ),
  RifugioCheckIn(
    id: 'ci003',
    rifugioId: 'rif005',
    rifugioNome: 'Rifugio Pedrotti',
    rifugioLat: 46.1793,
    rifugioLng: 10.8872,
    altitudine: 2491,
    dataVisita: DateTime(2025, 7, 22),
  ),
  RifugioCheckIn(
    id: 'ci004',
    rifugioId: 'rif010',
    rifugioNome: 'Bivacco Gervasutti',
    rifugioLat: 45.8547,
    rifugioLng: 6.9433,
    altitudine: 2835,
    dataVisita: DateTime(2025, 9, 3),
  ),
  RifugioCheckIn(
    id: 'ci005',
    rifugioId: 'rif001',
    rifugioNome: 'Rifugio Auronzo',
    rifugioLat: 46.6117,
    rifugioLng: 12.2944,
    altitudine: 2320,
    dataVisita: DateTime(2025, 9, 10),
    note: 'Seconda visita, giornata stupenda!',
  ),
  RifugioCheckIn(
    id: 'ci006',
    rifugioId: 'rif009',
    rifugioNome: 'Rifugio Brentei',
    rifugioLat: 46.1628,
    rifugioLng: 10.8750,
    altitudine: 2182,
    dataVisita: DateTime(2025, 7, 28),
  ),
];

List<String> _fakePreferiti() => [
  'rif001',
  'rif002',
  'rif005',
  'rif008',
  'rif010',
];
