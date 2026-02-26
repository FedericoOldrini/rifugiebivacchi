// Integration test per catturare screenshot automatici dell'app.
//
// Usa ScreenshotApp da main_screenshot.dart con provider reali
// in testMode: true e dati fake iniettati.
//
// Esecuzione:
//   flutter test integration_test/screenshot_test.dart -d <device_id>
//
// Gli screenshot vengono salvati nella directory di lavoro del test runner.
// Per screenshot deterministici, usare un simulatore con dimensioni note.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rifugi_bivacchi/main_screenshot.dart';

/// Attende che tutte le immagini di rete visibili siano state caricate.
///
/// Esegue pump ripetuti fino a quando non ci sono più
/// [CircularProgressIndicator] visibili (usati come placeholder
/// da [CachedNetworkImage]) o fino al timeout.
Future<void> waitForImages(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    await tester.pump(const Duration(milliseconds: 500));
    // Se non ci sono più spinner, le immagini sono caricate (o in errore)
    final spinners = find.byType(CircularProgressIndicator);
    if (spinners.evaluate().isEmpty) break;
  }
  // Un ultimo pumpAndSettle per animazioni residue
  await tester.pumpAndSettle();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Store Screenshots', () {
    testWidgets('Screenshot 1 — Lista Rifugi', (tester) async {
      await tester.pumpWidget(const ScreenshotApp());
      await tester.pumpAndSettle();

      // La schermata iniziale è la lista rifugi (tab 0)
      // Verifica che la lista sia visibile
      expect(find.text('Rifugio Auronzo'), findsOneWidget);

      // Attendi che le thumbnail delle card siano caricate
      await waitForImages(tester);

      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('01_lista_rifugi');
    });

    testWidgets('Screenshot 2 — Mappa', (tester) async {
      await tester.pumpWidget(const ScreenshotApp());
      await tester.pumpAndSettle();

      // Naviga al tab Mappa (indice 1)
      final mappaTab = find.byIcon(Icons.map_outlined);
      expect(mappaTab, findsOneWidget);
      await tester.tap(mappaTab);
      await tester.pumpAndSettle();

      // Attendi che Google Maps carichi le tile e i marker
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('02_mappa');
    });

    testWidgets('Screenshot 3 — Dettaglio Rifugio', (tester) async {
      await tester.pumpWidget(const ScreenshotApp());
      await tester.pumpAndSettle();

      // Tap sul primo rifugio nella lista per aprire il dettaglio
      final rifugioCard = find.text('Rifugio Auronzo');
      expect(rifugioCard, findsOneWidget);
      await tester.tap(rifugioCard);
      await tester.pumpAndSettle();

      // Verifica che siamo nella schermata dettaglio
      // Il titolo nell'AppBar del dettaglio contiene il nome
      expect(find.text('Ai piedi delle Tre Cime di Lavaredo'), findsOneWidget);

      // Attendi che la hero image e la galleria siano caricate
      await waitForImages(tester);

      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('03_dettaglio_rifugio');
    });

    testWidgets('Screenshot 5 — Passaporto dei Rifugi', (tester) async {
      await tester.pumpWidget(const ScreenshotApp());
      await tester.pumpAndSettle();

      // Naviga al tab Profilo (indice 2)
      final profiloTab = find.byIcon(Icons.person_outline);
      expect(profiloTab, findsOneWidget);
      await tester.tap(profiloTab);
      await tester.pumpAndSettle();

      // Tap sul "Passaporto dei Rifugi" nel profilo
      final passaportoTile = find.byIcon(Icons.card_travel);
      expect(passaportoTile, findsOneWidget);
      await tester.tap(passaportoTile);
      await tester.pumpAndSettle();

      // Verifica che siamo nella schermata passaporto
      // Il passaporto mostra i check-in raggruppati
      expect(find.text('Rifugio Auronzo'), findsWidgets);

      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('05_passaporto');
    });

    testWidgets('Screenshot 4 — Profilo Utente', (tester) async {
      await tester.pumpWidget(const ScreenshotApp());
      await tester.pumpAndSettle();

      // Naviga al tab Profilo (indice 2)
      final profiloTab = find.byIcon(Icons.person_outline);
      expect(profiloTab, findsOneWidget);
      await tester.tap(profiloTab);
      await tester.pumpAndSettle();

      // Verifica che il profilo mostra i dati dell'utente fake
      expect(find.text('Marco Rossi'), findsOneWidget);

      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('04_profilo');
    });
  });
}
