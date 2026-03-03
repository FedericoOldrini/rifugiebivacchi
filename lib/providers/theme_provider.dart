import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

/// Le stagioni disponibili come tema.
enum AppSeason {
  auto, // Segue la stagione corrente
  spring, // Primavera
  summer, // Estate
  autumn, // Autunno
  winter, // Inverno
}

/// Provider per la gestione del tema stagionale e della modalità chiaro/scuro.
class ThemeProvider extends ChangeNotifier {
  // Chiavi SharedPreferences
  static const String _keySeason = 'theme_season';
  static const String _keyThemeMode = 'theme_mode';

  AppSeason _season = AppSeason.auto;
  ThemeMode _themeMode = ThemeMode.system;

  AppSeason get season => _season;
  ThemeMode get themeMode => _themeMode;

  /// La stagione effettiva usata per i colori (risolve `auto` nella stagione corrente).
  AppSeason get effectiveSeason {
    if (_season == AppSeason.auto) {
      return _currentCalendarSeason();
    }
    return _season;
  }

  /// Il tema chiaro basato sulla stagione effettiva.
  ThemeData get lightTheme => AppTheme.lightTheme(effectiveSeason);

  /// Il tema scuro basato sulla stagione effettiva.
  ThemeData get darkTheme => AppTheme.darkTheme(effectiveSeason);

  /// Determina la stagione corrente in base al mese.
  /// Emisfero nord (Alpi italiane):
  /// - Primavera: marzo, aprile, maggio
  /// - Estate: giugno, luglio, agosto
  /// - Autunno: settembre, ottobre, novembre
  /// - Inverno: dicembre, gennaio, febbraio
  AppSeason _currentCalendarSeason() {
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) return AppSeason.spring;
    if (month >= 6 && month <= 8) return AppSeason.summer;
    if (month >= 9 && month <= 11) return AppSeason.autumn;
    return AppSeason.winter;
  }

  /// Imposta la stagione del tema.
  void setSeason(AppSeason season) {
    if (_season == season) return;
    _season = season;
    notifyListeners();
    _persist();
  }

  /// Imposta la modalità chiaro/scuro/sistema.
  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    _persist();
  }

  /// Carica le preferenze salvate.
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final seasonIndex = prefs.getInt(_keySeason);
    if (seasonIndex != null && seasonIndex < AppSeason.values.length) {
      _season = AppSeason.values[seasonIndex];
    }

    final themeModeIndex = prefs.getInt(_keyThemeMode);
    if (themeModeIndex != null && themeModeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeModeIndex];
    }

    notifyListeners();
  }

  /// Persiste le preferenze.
  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySeason, _season.index);
    await prefs.setInt(_keyThemeMode, _themeMode.index);
  }
}
