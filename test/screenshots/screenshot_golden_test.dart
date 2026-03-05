/// Golden test per generare screenshot dell'App Store.
///
/// Genera screenshot individuali per ogni schermata e device,
/// pronti per la pipeline di overlay e upload.
///
/// Eseguire con:
///   flutter test --update-goldens --tags=screenshots test/screenshots/
///
/// I golden file vengono salvati in:
///   test/screenshots/goldens/screenshots/<screen_name>.<device_name>.png
///
/// Esempio output (30 file = 5 schermate × 6 device):
///   01_lista_rifugi.iPhone_6_9.png
///   01_lista_rifugi.iPhone_6_7.png
///   01_lista_rifugi.iPhone_6_5.png
///   01_lista_rifugi.iPhone_5_5.png
///   01_lista_rifugi.iPad_Pro_13.png
///   01_lista_rifugi.iPad_Pro_12_9.png
///   02_mappa.iPhone_6_9.png
///   ... (etc.)
///
@Tags(['screenshots'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:rifugi_bivacchi/l10n/app_localizations.dart';
import 'package:rifugi_bivacchi/models/rifugio.dart';
import 'package:rifugi_bivacchi/models/rifugio_checkin.dart';
import 'package:rifugi_bivacchi/providers/auth_provider.dart';
import 'package:rifugi_bivacchi/providers/filtro_provider.dart';
import 'package:rifugi_bivacchi/providers/passaporto_provider.dart';
import 'package:rifugi_bivacchi/providers/preferiti_provider.dart';
import 'package:rifugi_bivacchi/providers/rifugi_provider.dart';
import 'package:rifugi_bivacchi/screens/home_screen.dart';
import 'package:rifugi_bivacchi/screens/passaporto_screen.dart';
import 'package:rifugi_bivacchi/theme/app_theme.dart';
import 'package:rifugi_bivacchi/providers/theme_provider.dart';

// ============================================================
// Device definitions per App Store
// ============================================================

/// Device definitions con pixel density corretta per ogni formato App Store.
///
/// I golden file vengono generati alla dimensione logica (dp).
/// Il tool Python `generate_screenshots.py` li ridimensionerà
/// alla risoluzione fisica (pixel) per lo store.
const _devices = <Device>[
  Device(name: 'iPhone_6_9', size: Size(440, 956), devicePixelRatio: 3.0),
  Device(name: 'iPhone_6_7', size: Size(430, 932), devicePixelRatio: 3.0),
  Device(name: 'iPhone_6_5', size: Size(414, 896), devicePixelRatio: 3.0),
  Device(name: 'iPhone_5_5', size: Size(414, 736), devicePixelRatio: 3.0),
  Device(name: 'iPad_Pro_13', size: Size(1032, 1376), devicePixelRatio: 2.0),
  Device(name: 'iPad_Pro_12_9', size: Size(1024, 1366), devicePixelRatio: 2.0),
];

// ============================================================
// Dati fake
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
    municipality: "Cortina d'Ampezzo",
    status: 'aperto',
    petAccess: true,
    familiesChildrenAccess: true,
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
    region: "Valle d'Aosta",
    province: 'Aosta',
    status: 'aperto',
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

// ============================================================
// Helper: wrappa un widget con il contesto completo dell'app
// ============================================================

/// Crea il MultiProvider con tutti i provider fake configurati.
Widget _buildScreenWrapper({required Widget child}) {
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
      ChangeNotifierProvider<PreferitiProvider>.value(value: preferitiProvider),
      ChangeNotifierProvider<FiltroProvider>(create: (_) => FiltroProvider()),
    ],
    child: MaterialApp(
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
      themeMode: ThemeMode.light,
      home: child,
      routes: {
        '/donations': (context) =>
            const Scaffold(body: Center(child: Text('Donazioni'))),
      },
    ),
  );
}

// ============================================================
// Placeholder per la schermata mappa (GoogleMaps = platform view)
// ============================================================

/// Widget placeholder per la schermata mappa.
///
/// GoogleMaps è una platform view (nativa) che non può essere
/// renderizzata nei golden test. Questo widget riproduce
/// l'aspetto della schermata mappa con un placeholder stilizzato.
class _MapScreenPlaceholder extends StatelessWidget {
  const _MapScreenPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Sfondo mappa stilizzato
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFE8F0E8), // Verde chiaro (prati)
                  const Color(0xFFF0F4E8), // Verde-giallino
                  const Color(0xFFF5F1E8), // Beige (pianura)
                ],
              ),
            ),
          ),
          // Marker finti sulla mappa
          ..._buildFakeMarkers(context),
          // Pulsanti sovrapposti (come la vera mappa)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Column(
              children: [
                _MapButton(icon: Icons.my_location, onPressed: () {}),
                const SizedBox(height: 8),
                _MapButton(icon: Icons.layers_outlined, onPressed: () {}),
              ],
            ),
          ),
          // Legenda in basso
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surface.withAlpha(230),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(30),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home, size: 14, color: colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Rifugio',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.cabin, size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    'Bivacco',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.cottage, size: 14, color: Colors.brown),
                  const SizedBox(width: 4),
                  Text(
                    'Malga',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFakeMarkers(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Posizioni relative sulla "mappa"
    final positions = [
      Offset(size.width * 0.3, size.height * 0.25),
      Offset(size.width * 0.6, size.height * 0.20),
      Offset(size.width * 0.5, size.height * 0.35),
      Offset(size.width * 0.2, size.height * 0.50),
      Offset(size.width * 0.7, size.height * 0.45),
      Offset(size.width * 0.4, size.height * 0.60),
      Offset(size.width * 0.8, size.height * 0.30),
      Offset(size.width * 0.15, size.height * 0.70),
    ];
    final rifugi = _fakeRifugi();

    return List.generate(positions.length.clamp(0, rifugi.length), (i) {
      final pos = positions[i];
      final rifugio = rifugi[i];
      return Positioned(
        left: pos.dx - 14,
        top: pos.dy - 28,
        child: _FakeMarker(tipo: rifugio.tipo),
      );
    });
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MapButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

class _FakeMarker extends StatelessWidget {
  final String tipo;

  const _FakeMarker({required this.tipo});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData icon;
    switch (tipo.toLowerCase()) {
      case 'bivacco':
        color = Colors.orange;
        icon = Icons.cabin;
      case 'malga':
        color = Colors.brown;
        icon = Icons.cottage;
      default:
        color = Theme.of(context).colorScheme.primary;
        icon = Icons.home;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        // Punta del marker
        CustomPaint(
          size: const Size(10, 6),
          painter: _MarkerTrianglePainter(color),
        ),
      ],
    );
  }
}

class _MarkerTrianglePainter extends CustomPainter {
  final Color color;
  _MarkerTrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================
// Schermata dettaglio semplificata (senza GoogleMaps/Weather)
// ============================================================

/// Versione semplificata del dettaglio rifugio per golden test.
///
/// Elimina GoogleMaps (platform view) e WeatherWidget (HTTP)
/// mantenendo il layout visivo principale.
class _DettaglioScreenForGolden extends StatelessWidget {
  final Rifugio rifugio;

  const _DettaglioScreenForGolden({required this.rifugio});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header hero con nome rifugio
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                rifugio.nome,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [colorScheme.primary, colorScheme.primaryContainer],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.landscape,
                    size: 100,
                    color: Colors.white.withAlpha(80),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.star, color: Colors.amber[400]),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chips tipo e stato
                  Row(
                    children: [
                      Chip(
                        avatar: Icon(_getIconForType(rifugio.tipo), size: 18),
                        label: Text(_getLabelForType(rifugio.tipo)),
                      ),
                      if (rifugio.status != null) ...[
                        const SizedBox(width: 8),
                        Chip(
                          label: Text(rifugio.status!),
                          backgroundColor: colorScheme.primaryContainer,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Placeholder mappa (rettangolo stilizzato)
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0E8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.map, size: 40, color: colorScheme.primary),
                          const SizedBox(height: 8),
                          Text(
                            '${rifugio.latitudine.toStringAsFixed(4)}, ${rifugio.longitudine.toStringAsFixed(4)}',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Descrizione
                  if (rifugio.descrizione != null) ...[
                    Text(
                      'Descrizione',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rifugio.descrizione!,
                      style: TextStyle(
                        fontSize: 15,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informazioni',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (rifugio.altitudine != null)
                            _InfoRow(
                              icon: Icons.terrain,
                              label: 'Altitudine',
                              value: '${rifugio.altitudine!.toInt()} m',
                            ),
                          if (rifugio.postiLetto != null)
                            _InfoRow(
                              icon: Icons.bed,
                              label: 'Posti letto',
                              value: '${rifugio.postiLetto}',
                            ),
                          if (rifugio.operatore != null)
                            _InfoRow(
                              icon: Icons.group,
                              label: 'Gestore',
                              value: rifugio.operatore!,
                            ),
                          if (rifugio.region != null)
                            _InfoRow(
                              icon: Icons.location_on,
                              label: 'Regione',
                              value: rifugio.region!,
                            ),
                          if (rifugio.province != null)
                            _InfoRow(
                              icon: Icons.map,
                              label: 'Provincia',
                              value: rifugio.province!,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Servizi
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Servizi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (rifugio.ristorante == true)
                                Chip(
                                  avatar: const Icon(
                                    Icons.restaurant,
                                    size: 18,
                                  ),
                                  label: const Text('Ristorante'),
                                ),
                              if (rifugio.wifi == true)
                                Chip(
                                  avatar: const Icon(Icons.wifi, size: 18),
                                  label: const Text('Wi-Fi'),
                                ),
                              if (rifugio.elettricita == true)
                                Chip(
                                  avatar: const Icon(Icons.bolt, size: 18),
                                  label: const Text('Elettricità'),
                                ),
                              if (rifugio.pagamentoPos == true)
                                Chip(
                                  avatar: const Icon(
                                    Icons.credit_card,
                                    size: 18,
                                  ),
                                  label: const Text('POS'),
                                ),
                              if (rifugio.defibrillatore == true)
                                Chip(
                                  avatar: const Icon(
                                    Icons.medical_services,
                                    size: 18,
                                  ),
                                  label: const Text('Defibrillatore'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contatti
                  if (rifugio.telefono != null || rifugio.email != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contatti',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (rifugio.telefono != null)
                              _InfoRow(
                                icon: Icons.phone,
                                label: 'Telefono',
                                value: rifugio.telefono!,
                              ),
                            if (rifugio.email != null)
                              _InfoRow(
                                icon: Icons.email,
                                label: 'Email',
                                value: rifugio.email!,
                              ),
                          ],
                        ),
                      ),
                    ),

                  // Check-in button
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Registra visita'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'bivacco':
        return Icons.cabin;
      case 'malga':
        return Icons.cottage;
      default:
        return Icons.home;
    }
  }

  String _getLabelForType(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'bivacco':
        return 'Bivacco';
      case 'malga':
        return 'Malga';
      default:
        return 'Rifugio';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Widget inline per il profilo (evita il doppio AppBar)
// ============================================================

/// ProfiloScreen senza il proprio Scaffold/AppBar, per poterlo
/// incapsulare nello scaffold della HomeScreen.
class _ProfiloScreenInline extends StatelessWidget {
  const _ProfiloScreenInline();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          if (authProvider.isAuthenticated && user != null) {
            return _buildAuthenticatedProfile(context, user);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAuthenticatedProfile(BuildContext context, dynamic user) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Avatar e info utente
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: Text(
                      user.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (user.displayName != null)
                    Text(
                      user.displayName!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  if (user.email != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      user.email!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sezione Passaporto dei Rifugi
          Consumer<PassaportoProvider>(
            builder: (context, passaportoProvider, child) {
              final rifugiVisitati =
                  passaportoProvider.checkInsByRifugio.length;
              return Card(
                child: ListTile(
                  leading: Icon(
                    Icons.card_travel,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Passaporto dei Rifugi'),
                  subtitle: Text('$rifugiVisitati rifugi visitati'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Sezione Preferiti
          Consumer2<PreferitiProvider, RifugiProvider>(
            builder: (context, preferitiProvider, rifugiProvider, child) {
              final preferiti = preferitiProvider.preferiti;
              final rifugiPreferiti = rifugiProvider.rifugi
                  .where((r) => preferiti.contains(r.id))
                  .toList();

              return Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.star, color: Colors.amber[700]),
                      title: const Text('Rifugi preferiti'),
                      subtitle: Text('${preferiti.length} rifugi'),
                      trailing: preferiti.isEmpty
                          ? null
                          : const Icon(Icons.chevron_right),
                    ),
                    if (rifugiPreferiti.isNotEmpty) ...[
                      const Divider(height: 1),
                      ...rifugiPreferiti
                          .take(3)
                          .map(
                            (rifugio) => ListTile(
                              dense: true,
                              leading: Icon(
                                rifugio.tipo == 'rifugio'
                                    ? Icons.home
                                    : rifugio.tipo == 'bivacco'
                                    ? Icons.cabin
                                    : Icons.cottage,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              title: Text(
                                rifugio.nome,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: rifugio.altitudine != null
                                  ? Text('${rifugio.altitudine!.toInt()} m')
                                  : null,
                              trailing: Icon(
                                Icons.chevron_right,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                            ),
                          ),
                      if (rifugiPreferiti.length > 3)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '...e altri ${rifugiPreferiti.length - 3}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Sezione Itinerari
          Card(
            child: ListTile(
              leading: Icon(
                Icons.route,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('I miei itinerari'),
              subtitle: const Text('Prossimamente'),
              trailing: const Icon(Icons.lock_outline),
              enabled: false,
            ),
          ),
          const SizedBox(height: 24),

          // Logout
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout),
              label: const Text('Esci'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget per la schermata Profilo completa con AppBar e NavigationBar,
/// simulando la HomeScreen con il tab Profilo selezionato.
class _ProfiloScreenFull extends StatelessWidget {
  const _ProfiloScreenFull();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.landscape, size: 28),
            SizedBox(width: 8),
            Text('Rifugi e Bivacchi'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: const _ProfiloScreenInline(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_outlined),
            selectedIcon: Icon(Icons.list),
            label: 'Lista',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mappa',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profilo',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// GOLDEN TESTS — Output: un file PNG per device per schermata
// ============================================================

void main() {
  setUpAll(() async {
    await initializeDateFormatting('it_IT', null);
  });

  // --------------------------------------------------------
  // 01 - Lista Rifugi (HomeScreen tab 0)
  // --------------------------------------------------------
  testGoldens('01_lista_rifugi', (tester) async {
    await tester.pumpWidgetBuilder(
      _buildScreenWrapper(child: const HomeScreen()),
    );

    await multiScreenGolden(
      tester,
      'screenshots/01_lista_rifugi',
      devices: _devices,
      deviceSetup: (device, tester) async {
        await tester.pump();
        await tester.pumpAndSettle();
      },
    );
  });

  // --------------------------------------------------------
  // 02 - Mappa (placeholder)
  // --------------------------------------------------------
  testGoldens('02_mappa', (tester) async {
    await tester.pumpWidgetBuilder(
      _buildScreenWrapper(child: const _MapScreenPlaceholder()),
    );

    await multiScreenGolden(
      tester,
      'screenshots/02_mappa',
      devices: _devices,
      deviceSetup: (device, tester) async {
        await tester.pump();
        await tester.pumpAndSettle();
      },
    );
  });

  // --------------------------------------------------------
  // 03 - Dettaglio Rifugio (semplificato, senza platform views)
  // --------------------------------------------------------
  testGoldens('03_dettaglio_rifugio', (tester) async {
    final rifugio = _fakeRifugi().first; // Rifugio Auronzo

    await tester.pumpWidgetBuilder(
      _buildScreenWrapper(child: _DettaglioScreenForGolden(rifugio: rifugio)),
    );

    await multiScreenGolden(
      tester,
      'screenshots/03_dettaglio_rifugio',
      devices: _devices,
      deviceSetup: (device, tester) async {
        await tester.pump();
        await tester.pumpAndSettle();
      },
    );
  });

  // --------------------------------------------------------
  // 04 - Profilo (con AppBar + NavigationBar, tab Profilo)
  // --------------------------------------------------------
  testGoldens('04_profilo', (tester) async {
    await tester.pumpWidgetBuilder(
      _buildScreenWrapper(child: const _ProfiloScreenFull()),
    );

    await multiScreenGolden(
      tester,
      'screenshots/04_profilo',
      devices: _devices,
      deviceSetup: (device, tester) async {
        await tester.pump();
        await tester.pumpAndSettle();
      },
    );
  });

  // --------------------------------------------------------
  // 05 - Passaporto dei Rifugi
  // --------------------------------------------------------
  testGoldens('05_passaporto', (tester) async {
    await tester.pumpWidgetBuilder(
      _buildScreenWrapper(child: const PassaportoScreen()),
    );

    await multiScreenGolden(
      tester,
      'screenshots/05_passaporto',
      devices: _devices,
      deviceSetup: (device, tester) async {
        await tester.pump();
        await tester.pumpAndSettle();
      },
    );
  });
}
