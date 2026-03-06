/// Integration test per cattura screenshot su simulatore iOS reale.
///
/// Naviga le 5 schermate principali dell'app. Ad ogni punto screenshot,
/// stampa un marker nel log e attende, permettendo allo script host
/// (`tools/capture_screenshots.sh`) di catturare il display del simulatore
/// con `xcrun simctl io screenshot`.
///
/// Uso (tramite script wrapper):
///   tools/capture_screenshots.sh <simulator-id>
///
/// Uso diretto (senza cattura screenshot):
///   flutter test integration_test/screenshot_test.dart -d <simulator-id>
///
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rifugi_bivacchi/main_screenshot.dart' as app;
import 'package:rifugi_bivacchi/utils/screenshot_mode.dart';

/// Marker prefix usato dallo script host per riconoscere i punti screenshot.
const _marker = 'SCREENSHOT_READY';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Store Screenshots', () {
    testWidgets(
      'Cattura le 5 schermate per App Store',
      (tester) async {
        // Lancia l'app in modalità screenshot
        await app.main();
        debugPrint('DEBUG: ScreenshotMode.enabled = ${ScreenshotMode.enabled}');
        await _settleApp(tester);

        // ── 1. Lista Rifugi ──────────────────────────────────────────────
        await _settleApp(tester, frames: 5);
        await _signalScreenshot('01_lista_rifugi');

        // ── 2. Mappa ─────────────────────────────────────────────────────
        await _tapIcon(tester, Icons.map_outlined, fallback: Icons.map);
        await _settleApp(tester, frames: 10);
        await _signalScreenshot('02_mappa');

        // ── 3. Dettaglio Rifugio ─────────────────────────────────────────
        await _tapIcon(tester, Icons.list_outlined, fallback: Icons.list);
        await _settleApp(tester, frames: 5);

        final firstCard = find.text('Capanna Margherita');
        expect(firstCard, findsWidgets);
        await tester.tap(firstCard.first);
        await _settleApp(tester, frames: 10);
        await _signalScreenshot('03_dettaglio_rifugio');

        // Torna indietro
        final backButton = find.byType(BackButton);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton.first);
        } else {
          final arrowBack = find.byIcon(Icons.arrow_back);
          if (arrowBack.evaluate().isNotEmpty) {
            await tester.tap(arrowBack.first);
          } else {
            Navigator.of(tester.element(find.byType(Scaffold).last)).pop();
          }
        }
        await _settleApp(tester, frames: 5);

        // ── 4. Profilo ───────────────────────────────────────────────────
        await _tapIcon(tester, Icons.person_outline, fallback: Icons.person);
        await _settleApp(tester, frames: 5);
        await _signalScreenshot('04_profilo');

        // ── 5. Passaporto dei Rifugi ─────────────────────────────────────
        final passaportoButton = find.textContaining('Passaporto');
        if (passaportoButton.evaluate().isNotEmpty) {
          await tester.tap(passaportoButton.first);
          await _settleApp(tester, frames: 5);
          await _signalScreenshot('05_passaporto');
        } else {
          final hikingIcon = find.byIcon(Icons.hiking);
          if (hikingIcon.evaluate().isNotEmpty) {
            await tester.tap(hikingIcon.first);
            await _settleApp(tester, frames: 5);
            await _signalScreenshot('05_passaporto');
          } else {
            fail(
              'Impossibile trovare il pulsante Passaporto nella schermata Profilo',
            );
          }
        }

        debugPrint('SCREENSHOT_DONE');
      },
      // 5 screenshot × (2s attesa + settling) + build/init → serve più tempo
      timeout: const Timeout(Duration(minutes: 3)),
    );
  });
}

/// Segnala allo script host che lo screenshot è pronto per la cattura.
/// Stampa il marker e attende 2 secondi per dare tempo a simctl.
Future<void> _signalScreenshot(String name) async {
  debugPrint('$_marker:$name');
  // Pausa per permettere allo script host di catturare il display.
  // Lo script monitora lo stdout per il marker e lancia simctl.
  await Future<void>.delayed(const Duration(seconds: 2));
}

/// Pump ripetuto per far avanzare il rendering.
/// Non usiamo pumpAndSettle() perché l'app ha animazioni continue
/// (Google Maps tiles, CircularProgressIndicator, etc.) che non terminano mai.
Future<void> _settleApp(WidgetTester tester, {int frames = 10}) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

/// Tap su un'icona, con fallback se non trovata.
Future<void> _tapIcon(
  WidgetTester tester,
  IconData primary, {
  required IconData fallback,
}) async {
  final primaryFinder = find.byIcon(primary);
  if (primaryFinder.evaluate().isNotEmpty) {
    await tester.tap(primaryFinder.first);
  } else {
    final fallbackFinder = find.byIcon(fallback);
    expect(
      fallbackFinder,
      findsWidgets,
      reason: 'Né $primary né $fallback trovati',
    );
    await tester.tap(fallbackFinder.first);
  }
}
