import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

/// Palette di colori per una singola stagione (colori base da cui derivare light e dark).
class _SeasonPalette {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color secondary;
  final Color secondaryLight;
  final Color secondaryDark;
  final Color tertiary;

  /// Colore "brand" usato per sfondi scuri dei widget di condivisione (share card, passaporto, dialog).
  final Color brand;

  /// Variante più chiara del brand, per gradienti.
  final Color brandLight;

  /// Colore "successo" per badge CHECK-IN e icone di conferma.
  final Color success;

  const _SeasonPalette({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondary,
    required this.secondaryLight,
    required this.secondaryDark,
    required this.tertiary,
    required this.brand,
    required this.brandLight,
    required this.success,
  });
}

class AppTheme {
  // ──────────────────────────────────────────────
  // Colore branded fisso (usato per passaporto, share card, ecc.)
  // ──────────────────────────────────────────────
  /// @deprecated Usare [brandColorFor] per colore stagionale nei widget share.
  static const Color deepTeal = Color(0xFF2C5F5D);

  // ──────────────────────────────────────────────
  // Colori semantici fissi (non variano con la stagione)
  // ──────────────────────────────────────────────

  /// Colore per stellina preferiti — amber caldo costante.
  static const Color favoriteColor = Color(0xFFFFA000); // Colors.amber[700]

  // ──────────────────────────────────────────────
  // Colori brand stagionali (per widget di condivisione)
  // ──────────────────────────────────────────────

  /// Colore brand principale per la stagione data (sfondo share widget, passaporto, dialog).
  static Color brandColorFor(AppSeason season) => _paletteFor(season).brand;

  /// Colore brand chiaro per gradienti nei widget di condivisione.
  static Color brandColorLightFor(AppSeason season) =>
      _paletteFor(season).brandLight;

  /// Colore "successo" per badge CHECK-IN e icone conferma, adattato alla stagione.
  static Color successColorFor(AppSeason season) => _paletteFor(season).success;

  // ──────────────────────────────────────────────
  // Palette stagionali
  // ──────────────────────────────────────────────

  /// 🌸 Primavera — Rosa fiori di montagna, lavanda, verde tenero
  /// Palette fresca e luminosa ispirata ai rododendri e ai prati alpini in fiore.
  static const _spring = _SeasonPalette(
    primary: Color(0xFF9B5E8C), // Malva-rosa rododendro alpino
    primaryLight: Color(0xFFB87FAA), // Rosa lavanda chiaro
    primaryDark: Color(0xFF6D3F62), // Malva scuro
    secondary: Color(0xFF6A9B5E), // Verde prato tenero primaverile
    secondaryLight: Color(0xFF8AB87F),
    secondaryDark: Color(0xFF4A6D42),
    tertiary: Color(0xFF7BA4C7), // Azzurro cielo primaverile
    brand: Color(0xFF6D3F62), // Malva scuro per share widget
    brandLight: Color(0xFF8C5A7E), // Malva medio per gradienti
    success: Color(0xFF6A9B5E), // Verde prato per badge check-in
  );

  /// ☀️ Estate — Verde alpino, sole dorato, grigio roccia calda
  /// Palette ispirata ai prati verdi e ai boschi estivi in alta quota.
  /// Richiama il colore originale dell'app (deepTeal 0xFF2C5F5D).
  static const _summer = _SeasonPalette(
    primary: Color(0xFF2C5F5D), // Verde teal alpino (tema originale)
    primaryLight: Color(0xFF3A7A77), // Verde teal luminoso
    primaryDark: Color(0xFF1E4240), // Verde teal scuro
    secondary: Color(0xFFD4A017), // Giallo sole dorato
    secondaryLight: Color(0xFFE6B830),
    secondaryDark: Color(0xFF9A7410),
    tertiary: Color(0xFF7B8C8D), // Grigio roccia calda
    brand: Color(0xFF1E4240), // Verde teal scuro per share widget
    brandLight: Color(0xFF2C5F5D), // Verde teal per gradienti
    success: Color(0xFF27AE60), // Verde fresco estivo per badge check-in
  );

  /// 🍂 Autunno — Arancione caldo, marrone terra, rosso foliage dei larici
  /// Palette calda ispirata ai larici dorati e ai boschi autunnali alpini.
  static const _autumn = _SeasonPalette(
    primary: Color(0xFFA0522D), // Marrone-arancio caldo (sienna)
    primaryLight: Color(0xFFC4713E), // Arancione caldo
    primaryDark: Color(0xFF6E3720), // Marrone scuro
    secondary: Color(0xFFB8860B), // Oro antico (larici dorati)
    secondaryLight: Color(0xFFD4A937),
    secondaryDark: Color(0xFF7A5A08),
    tertiary: Color(0xFF8B6F5E), // Marrone grigio (terra)
    brand: Color(0xFF5C3317), // Marrone scuro caldo per share widget
    brandLight: Color(0xFF7A4A2A), // Marrone medio per gradienti
    success: Color(0xFF8B6F2A), // Oro scuro per badge check-in
  );

  /// ❄️ Inverno — Blu ghiaccio, grigio freddo, bianco-azzurro neve
  /// Palette fredda e pulita ispirata alle Alpi innevate e al cielo invernale.
  static const _winter = _SeasonPalette(
    primary: Color(0xFF4A6FA5), // Blu montano freddo
    primaryLight: Color(0xFF6B8FC2), // Azzurro ghiaccio
    primaryDark: Color(0xFF2E4A73), // Blu scuro notte
    secondary: Color(0xFF7A8FA6), // Grigio-azzurro (cielo invernale)
    secondaryLight: Color(0xFF9BB0C4),
    secondaryDark: Color(0xFF4E6478),
    tertiary: Color(0xFF6E7B86), // Grigio pietra freddo
    brand: Color(0xFF2E4A73), // Blu notte per share widget
    brandLight: Color(0xFF3D5F8A), // Blu medio per gradienti
    success: Color(0xFF5B8DB8), // Azzurro ghiaccio per badge check-in
  );

  /// Mappa stagione → palette.
  static _SeasonPalette _paletteFor(AppSeason season) {
    switch (season) {
      case AppSeason.spring:
        return _spring;
      case AppSeason.summer:
        return _summer;
      case AppSeason.autumn:
        return _autumn;
      case AppSeason.winter:
        return _winter;
      case AppSeason.auto:
        // Non dovrebbe mai arrivare qui (il provider risolve auto → stagione reale)
        return _summer;
    }
  }

  // ──────────────────────────────────────────────
  // Tema chiaro
  // ──────────────────────────────────────────────

  static ThemeData lightTheme(AppSeason season) {
    final p = _paletteFor(season);

    final colorScheme = ColorScheme.light(
      // Primary
      primary: p.primary,
      onPrimary: Colors.white,
      primaryContainer: _lighten(p.primaryLight, 0.35),
      onPrimaryContainer: _darken(p.primary, 0.4),

      // Secondary
      secondary: p.secondary,
      onSecondary: Colors.white,
      secondaryContainer: _lighten(p.secondaryLight, 0.35),
      onSecondaryContainer: _darken(p.secondary, 0.4),

      // Tertiary
      tertiary: p.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: _lighten(p.tertiary, 0.40),
      onTertiaryContainer: _darken(p.tertiary, 0.4),

      // Error
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      errorContainer: const Color(0xFFF9DEDC),
      onErrorContainer: const Color(0xFF410E0B),

      // Surface
      surface: const Color(0xFFF2F5F6),
      onSurface: const Color(0xFF1A1F21),
      surfaceContainerHighest: const Color(0xFFCDD5D8),
      surfaceContainerHigh: const Color(0xFFE5EAEC),
      surfaceContainer: const Color(0xFFECF0F1),
      surfaceContainerLow: const Color(0xFFF8FAFB),
      surfaceContainerLowest: Colors.white,
      onSurfaceVariant: const Color(0xFF3E4547),

      // Outline
      outline: const Color(0xFF6C7578),
      outlineVariant: const Color(0xFFBDC5C8),

      // Shadow & Scrim
      shadow: Colors.black,
      scrim: Colors.black,

      // Inverse
      inverseSurface: const Color(0xFF2E3436),
      onInverseSurface: const Color(0xFFEFF2F3),
      inversePrimary: _lighten(p.primary, 0.30),

      surfaceTint: p.primary,
    );

    return _buildThemeData(colorScheme, p);
  }

  // ──────────────────────────────────────────────
  // Tema scuro
  // ──────────────────────────────────────────────

  static ThemeData darkTheme(AppSeason season) {
    final p = _paletteFor(season);

    final colorScheme = ColorScheme.dark(
      // Primary — toni luminosi per leggibilità su sfondo scuro
      primary: _lighten(p.primary, 0.30),
      onPrimary: _darken(p.primary, 0.5),
      primaryContainer: _darken(p.primary, 0.15),
      onPrimaryContainer: _lighten(p.primaryLight, 0.35),

      // Secondary
      secondary: _lighten(p.secondary, 0.30),
      onSecondary: _darken(p.secondary, 0.5),
      secondaryContainer: _darken(p.secondary, 0.20),
      onSecondaryContainer: _lighten(p.secondaryLight, 0.35),

      // Tertiary
      tertiary: _lighten(p.tertiary, 0.30),
      onTertiary: _darken(p.tertiary, 0.45),
      tertiaryContainer: _darken(p.tertiary, 0.20),
      onTertiaryContainer: _lighten(p.tertiary, 0.40),

      // Error
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),

      // Surface
      surface: const Color(0xFF191D1E),
      onSurface: const Color(0xFFE1E3E4),
      surfaceContainerHighest: const Color(0xFF3A3F41),
      surfaceContainerHigh: const Color(0xFF2E3335),
      surfaceContainer: const Color(0xFF252829),
      surfaceContainerLow: const Color(0xFF1D2021),
      surfaceContainerLowest: const Color(0xFF0E1112),
      onSurfaceVariant: const Color(0xFFC1C7C9),

      // Outline
      outline: const Color(0xFF8B9194),
      outlineVariant: const Color(0xFF414749),

      // Shadow & Scrim
      shadow: Colors.black,
      scrim: Colors.black,

      // Inverse
      inverseSurface: const Color(0xFFE1E3E4),
      onInverseSurface: const Color(0xFF2E3436),
      inversePrimary: p.primary,

      surfaceTint: _lighten(p.primary, 0.30),
    );

    return _buildThemeData(colorScheme, p);
  }

  // ──────────────────────────────────────────────
  // Costruzione ThemeData condivisa
  // ──────────────────────────────────────────────

  static ThemeData _buildThemeData(ColorScheme colorScheme, _SeasonPalette p) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 3,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: colorScheme.surfaceTint,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.brightness == Brightness.light
            ? p.secondary
            : colorScheme.primaryContainer,
        foregroundColor: colorScheme.brightness == Brightness.light
            ? Colors.white
            : colorScheme.onPrimaryContainer,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: colorScheme.secondaryContainer,
        backgroundColor: colorScheme.surface,
        elevation: 3,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        labelStyle: TextStyle(color: colorScheme.onSurface),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 3,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Utility colori
  // ──────────────────────────────────────────────

  /// Schiarisce un colore mescolandolo con bianco.
  static Color _lighten(Color color, double amount) {
    return Color.lerp(color, Colors.white, amount) ?? color;
  }

  /// Scurisce un colore mescolandolo con nero.
  static Color _darken(Color color, double amount) {
    return Color.lerp(color, Colors.black, amount) ?? color;
  }
}
