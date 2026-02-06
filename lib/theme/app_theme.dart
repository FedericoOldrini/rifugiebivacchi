import 'package:flutter/material.dart';

class AppTheme {
  // Schema colori: Grigio-Verde-Azzurro più scuri e saturi
  static const Color deepTeal = Color(0xFF2C5F5D);         // Verde-azzurro scuro principale
  static const Color lightTeal = Color(0xFF3D7A77);        // Verde-azzurro medio
  static const Color darkTeal = Color(0xFF1A3F3D);         // Verde-azzurro molto scuro
  
  static const Color slateBlue = Color(0xFF4A6B7C);        // Azzurro-grigio saturo
  static const Color lightSlate = Color(0xFF607D8B);       // Azzurro-grigio chiaro
  static const Color darkSlate = Color(0xFF2C3E47);        // Azzurro-grigio scuro
  
  static const Color charcoalGray = Color(0xFF3A4A4F);     // Grigio carbone
  static const Color lightGray = Color(0xFFCDD5D8);        // Grigio chiaro azzurrato
  static const Color darkGray = Color(0xFF252D30);         // Grigio molto scuro
  static const Color coolGray = Color(0xFF5A6C72);         // Grigio freddo saturo

  static ThemeData get lightTheme {
    // Material 3 ColorScheme con palette Grigio-Verde-Azzurro scura e satura
    final colorScheme = ColorScheme.light(
      // Primary: Verde-Azzurro scuro
      primary: deepTeal,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFB2D4D2),
      onPrimaryContainer: Color(0xFF0D1D1C),
      
      // Secondary: Azzurro-Grigio
      secondary: slateBlue,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFD0DDE5),
      onSecondaryContainer: Color(0xFF1A2328),
      
      // Tertiary: Grigio freddo
      tertiary: coolGray,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFDCE4E8),
      onTertiaryContainer: Color(0xFF1F2628),
      
      // Error
      error: Color(0xFFB3261E),
      onError: Colors.white,
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410E0B),
      
      // Surface: Toni freddi e scuri
      surface: Color(0xFFF2F5F6),
      onSurface: Color(0xFF1A1F21),
      surfaceContainerHighest: lightGray,
      surfaceContainerHigh: Color(0xFFE5EAEC),
      surfaceContainer: Color(0xFFECF0F1),
      surfaceContainerLow: Color(0xFFF8FAFB),
      surfaceContainerLowest: Colors.white,
      onSurfaceVariant: Color(0xFF3E4547),
      
      // Outline
      outline: Color(0xFF6C7578),
      outlineVariant: Color(0xFFBDC5C8),
      
      // Shadow & Scrim
      shadow: Colors.black,
      scrim: Colors.black,
      
      // Inverse
      inverseSurface: Color(0xFF2E3436),
      onInverseSurface: Color(0xFFEFF2F3),
      inversePrimary: Color(0xFF94C4C1),
      
      surfaceTint: deepTeal,
    );
    
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: slateBlue,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        labelStyle: TextStyle(
          color: colorScheme.onSurface,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 3,
      ),
      
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    // Material 3 ColorScheme Dark con palette Grigio-Verde-Azzurro scura e satura
    final colorScheme = ColorScheme.dark(
      // Primary: Verde-Azzurro luminoso per il dark mode
      primary: Color(0xFF94C4C1),
      onPrimary: Color(0xFF003735),
      primaryContainer: Color(0xFF1E4D4B),
      onPrimaryContainer: Color(0xFFB2D4D2),
      
      // Secondary: Azzurro-Grigio luminoso
      secondary: Color(0xFFB3C8D6),
      onSecondary: Color(0xFF1D3440),
      secondaryContainer: Color(0xFF334B58),
      onSecondaryContainer: Color(0xFFD0DDE5),
      
      // Tertiary: Grigio freddo luminoso
      tertiary: Color(0xFFB8C5CA),
      onTertiary: Color(0xFF23292C),
      tertiaryContainer: Color(0xFF3A4448),
      onTertiaryContainer: Color(0xFFDCE4E8),
      
      // Error
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      
      // Surface: Toni scuri con sottotoni freddi
      surface: Color(0xFF191D1E),
      onSurface: Color(0xFFE1E3E4),
      surfaceContainerHighest: Color(0xFF3A3F41),
      surfaceContainerHigh: Color(0xFF2E3335),
      surfaceContainer: Color(0xFF252829),
      surfaceContainerLow: Color(0xFF1D2021),
      surfaceContainerLowest: Color(0xFF0E1112),
      onSurfaceVariant: Color(0xFFC1C7C9),
      
      // Outline
      outline: Color(0xFF8B9194),
      outlineVariant: Color(0xFF414749),
      
      // Shadow & Scrim
      shadow: Colors.black,
      scrim: Colors.black,
      
      // Inverse
      inverseSurface: Color(0xFFE1E3E4),
      onInverseSurface: Color(0xFF2E3436),
      inversePrimary: Color(0xFF2C5F5D),
      
      surfaceTint: Color(0xFF94C4C1),
    );
    
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        labelStyle: TextStyle(
          color: colorScheme.onSurface,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 3,
      ),
      
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
