import 'package:flutter_driver/driver_extension.dart';
import 'package:rifugi_bivacchi/main.dart' as app;

/// Entry point per Flutter Driver
/// 
/// Questo file viene usato quando avvii l'app con Flutter Driver per testing

void main() {
  // Abilita l'estensione Flutter Driver
  enableFlutterDriverExtension();
  
  // Avvia l'app
  app.main();
}
