/// Flag globale per la modalità screenshot.
///
/// Quando attivo, il codice dell'app salta operazioni che interferiscono
/// con la cattura automatica degli screenshot (es. richieste permessi
/// nativi, geolocalizzazione, analytics, ecc.).
///
/// Attivato da `main_screenshot.dart` prima di `runApp()`.
/// In produzione rimane sempre `false`.
library;

class ScreenshotMode {
  ScreenshotMode._();

  /// `true` solo quando l'app gira per la cattura screenshot automatica.
  static bool enabled = false;
}
