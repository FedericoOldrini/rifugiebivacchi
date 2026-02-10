import 'dart:io';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

/// Script Flutter Driver per catturare screenshot automaticamente
/// 
/// Uso:
/// 1. Avvia l'app in modalità profiling: flutter run --profile --flavor dev -t test_driver/app.dart
/// 2. In un'altra finestra: flutter drive --driver=test_driver/screenshot_test.dart
/// 
/// Gli screenshot vengono salvati in: test_driver/screenshots/

void main() {
  group('Screenshot Generator', () {
    late FlutterDriver driver;
    
    // Directory per salvare screenshot
    final screenshotDir = Directory('test_driver/screenshots');
    
    setUpAll(() async {
      // Crea directory screenshot se non esiste
      if (!await screenshotDir.exists()) {
        await screenshotDir.create(recursive: true);
      }
      
      // Connetti al driver
      driver = await FlutterDriver.connect();
      
      // Aspetta che l'app sia pronta
      await driver.waitUntilFirstFrameRasterized();
      await Future.delayed(const Duration(seconds: 3));
    });
    
    tearDownAll(() async {
      await driver.close();
    });
    
    /// Cattura screenshot e lo salva
    Future<void> takeScreenshot(String name) async {
      print('📸 Cattura screenshot: $name');
      
      // Aspetta che l'animazione si completi
      await Future.delayed(const Duration(milliseconds: 500));
      
      final pixels = await driver.screenshot();
      final file = File('${screenshotDir.path}/$name.png');
      await file.writeAsBytes(pixels);
      
      print('   ✅ Salvato: ${file.path}');
    }
    
    test('Screenshot 1: Home - Lista Rifugi', () async {
      print('\n🏠 Screenshot 1: Lista Rifugi');
      
      // Assicurati di essere sulla home
      await driver.waitFor(find.text('Rifugi'));
      
      // Aspetta caricamento dati
      await Future.delayed(const Duration(seconds: 2));
      
      // Cattura screenshot
      await takeScreenshot('01_lista_rifugi');
    });
    
    test('Screenshot 2: Mappa', () async {
      print('\n🗺️  Screenshot 2: Mappa');
      
      // Vai al tab mappa
      final mapTab = find.byValueKey('map_tab');
      await driver.tap(mapTab);
      
      // Aspetta caricamento mappa
      await Future.delayed(const Duration(seconds: 3));
      
      // Cattura screenshot
      await takeScreenshot('02_mappa');
    });
    
    test('Screenshot 3: Dettaglio Rifugio', () async {
      print('\n🏔️  Screenshot 3: Dettaglio Rifugio');
      
      // Torna alla lista
      final listTab = find.byValueKey('list_tab');
      await driver.tap(listTab);
      await Future.delayed(const Duration(seconds: 1));
      
      // Tocca il primo rifugio (o uno specifico)
      final firstRifugio = find.byType('RifugioCard');
      await driver.tap(firstRifugio);
      
      // Aspetta caricamento dettaglio
      await Future.delayed(const Duration(seconds: 2));
      
      // Cattura screenshot
      await takeScreenshot('03_dettaglio');
      
      // Torna indietro
      await driver.tap(find.pageBack());
      await Future.delayed(const Duration(milliseconds: 500));
    });
    
    test('Screenshot 4: Ricerca e Filtri', () async {
      print('\n🔍 Screenshot 4: Ricerca e Filtri');
      
      // Apri filtri
      final filterButton = find.byValueKey('filter_button');
      await driver.tap(filterButton);
      
      // Aspetta apertura filtri
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Cattura screenshot
      await takeScreenshot('04_ricerca_filtri');
      
      // Chiudi filtri
      await driver.tap(find.pageBack());
      await Future.delayed(const Duration(milliseconds: 500));
    });
    
    test('Screenshot 5: Passaporto', () async {
      print('\n📖 Screenshot 5: Passaporto');
      
      // Apri drawer o naviga a passaporto
      final menuButton = find.byValueKey('menu_button');
      await driver.tap(menuButton);
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Tocca voce passaporto
      final passaportoButton = find.text('Passaporto');
      await driver.tap(passaportoButton);
      
      // Aspetta caricamento passaporto
      await Future.delayed(const Duration(seconds: 2));
      
      // Cattura screenshot
      await takeScreenshot('05_passaporto');
    });
    
    test('Riepilogo', () async {
      print('\n✅ Screenshot completati!');
      print('📁 Directory: ${screenshotDir.path}');
      print('');
      print('🎨 Prossimi passi:');
      print('   1. Esegui: python3 tools/add_overlays.py');
      print('   2. Gli screenshot finali saranno in: screenshots/final/');
    });
  });
}
