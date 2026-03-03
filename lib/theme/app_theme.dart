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

  const _SeasonPalette({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondary,
    required this.secondaryLight,
    required this.secondaryDark,
    required this.tertiary,
  });
}

class AppTheme {
  // ──────────────────────────────────────────────
  // Colore branded fisso (usato per passaporto, share card, ecc.)
  // Indipendente dalla stagione — identità visiva dell'app.
  // ──────────────────────────────────────────────
  static const Color deepTeal = Color(0xFF2C5F5D);

  // ──────────────────────────────────────────────
  // Palette stagionali
  // ──────────────────────────────────────────────

  /// 🌸 Primavera — Verde prato, rosa fiori di montagna, cielo azzurro tenue
  static const _spring = _SeasonPalette(
    primary: Color(0xFF4A7C59), // Verde prato alpino
    primaryLight: Color(0xFF6B9E7A), // Verde chiaro
    primaryDark: Color(0xFF2D5A3A), // Verde scuro
    secondary: Color(0xFFC2729C), // Rosa rododendro
    secondaryLight: Color(0xFFD499B8),
    secondaryDark: Color(0xFF8E4A6E),
    tertiary: Color(0xFF6B9DBF), // Azzurro cielo primaverile
  );

  /// ☀️ Estate — Teal profondo, azzurro-grigio, grigio roccia (tema originale)
  static const _summer = _SeasonPalette(
    primary: Color(0xFF2C5F5D), // Verde-azzurro scuro (deepTeal originale)
    primaryLight: Color(0xFF3D7A77), // Verde-azzurro medio
    primaryDark: Color(0xFF1A3F3D), // Verde-azzurro molto scuro
    secondary: Color(0xFF4A6B7C), // Azzurro-grigio saturo (slateBlue originale)
    secondaryLight: Color(0xFF607D8B),
    secondaryDark: Color(0xFF2C3E47),
    tertiary: Color(0xFF5A6C72), // Grigio freddo (coolGray originale)
  );

  /// 🍂 Autunno — Arancione caldo, marrone terra, rosso foliage dei larici
  static const _autumn = _SeasonPalette(
    primary: Color(0xFFA0522D), // Marrone-arancio caldo (sienna)
    primaryLight: Color(0xFFC4713E), // Arancione caldo
    primaryDark: Color(0xFF6E3720), // Marrone scuro
    secondary: Color(0xFFB8860B), // Oro antico (larici dorati)
    secondaryLight: Color(0xFFD4A937),
    secondaryDark: Color(0xFF7A5A08),
    tertiary: Color(0xFF8B6F5E), // Marrone grigio (terra)
  );

  /// ❄️ Inverno — Blu ghiaccio, grigio freddo, bianco-azzurro neve
  static const _winter = _SeasonPalette(
    primary: Color(0xFF4A6FA5), // Blu montano freddo
    primaryLight: Color(0xFF6B8FC2), // Azzurro ghiaccio
    primaryDark: Color(0xFF2E4A73), // Blu scuro notte
    secondary: Color(0xFF7A8FA6), // Grigio-azzurro (cielo invernale)
    secondaryLight: Color(0xFF9BB0C4),
    secondaryDark: Color(0xFF4E6478),
    tertiary: Color(0xFF6E7B86), // Grigio pietra freddo
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
