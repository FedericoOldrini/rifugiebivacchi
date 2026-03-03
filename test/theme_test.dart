import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rifugi_bivacchi/theme/app_theme.dart';
import 'package:rifugi_bivacchi/providers/theme_provider.dart';

void main() {
  group('AppTheme generation', () {
    for (final season in AppSeason.values) {
      if (season == AppSeason.auto) continue;
      
      test('lightTheme($season) produces valid ThemeData', () {
        final theme = AppTheme.lightTheme(season);
        expect(theme, isNotNull);
        expect(theme.colorScheme.brightness, Brightness.light);
        expect(theme.colorScheme.primary, isNotNull);
        expect(theme.colorScheme.surface, isNotNull);
        expect(theme.colorScheme.onPrimary, isNotNull);
        expect(theme.colorScheme.onSurface, isNotNull);
        
        // Check surface is NOT black
        expect(theme.colorScheme.surface, isNot(equals(Colors.black)));
        expect(theme.colorScheme.surface, isNot(equals(const Color(0xFF000000))));
        
        // Check scaffoldBackgroundColor
        expect(theme.scaffoldBackgroundColor, isNotNull);
        expect(theme.scaffoldBackgroundColor, isNot(equals(Colors.black)));
        
        print('$season light - primary: ${theme.colorScheme.primary}');
        print('$season light - surface: ${theme.colorScheme.surface}');
        print('$season light - scaffoldBg: ${theme.scaffoldBackgroundColor}');
        print('$season light - brightness: ${theme.brightness}');
      });

      test('darkTheme($season) produces valid ThemeData', () {
        final theme = AppTheme.darkTheme(season);
        expect(theme, isNotNull);
        expect(theme.colorScheme.brightness, Brightness.dark);
        expect(theme.colorScheme.primary, isNotNull);
        expect(theme.colorScheme.surface, isNotNull);
        
        print('$season dark - primary: ${theme.colorScheme.primary}');
        print('$season dark - surface: ${theme.colorScheme.surface}');
        print('$season dark - scaffoldBg: ${theme.scaffoldBackgroundColor}');
      });
    }
  });

  group('ThemeProvider', () {
    test('effectiveSeason resolves auto to a real season', () {
      final provider = ThemeProvider();
      expect(provider.season, AppSeason.auto);
      final effective = provider.effectiveSeason;
      expect(effective, isNot(equals(AppSeason.auto)));
      print('Current effective season: $effective');
    });

    test('lightTheme getter returns valid ThemeData', () {
      final provider = ThemeProvider();
      final theme = provider.lightTheme;
      expect(theme, isNotNull);
      expect(theme.colorScheme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, isNot(equals(Colors.black)));
      print('Provider light scaffoldBg: ${theme.scaffoldBackgroundColor}');
    });

    test('darkTheme getter returns valid ThemeData', () {
      final provider = ThemeProvider();
      final theme = provider.darkTheme;
      expect(theme, isNotNull);
      expect(theme.colorScheme.brightness, Brightness.dark);
      print('Provider dark scaffoldBg: ${theme.scaffoldBackgroundColor}');
    });
  });
}
