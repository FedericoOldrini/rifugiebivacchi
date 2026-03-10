import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rifugi_bivacchi/providers/theme_provider.dart';

void main() {
  testWidgets('MaterialApp with ThemeProvider renders correctly', (
    tester,
  ) async {
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeProvider>.value(
        value: themeProvider,
        child: Consumer<ThemeProvider>(
          builder: (context, tp, _) {
            return MaterialApp(
              theme: tp.lightTheme,
              darkTheme: tp.darkTheme,
              themeMode: tp.themeMode,
              home: Scaffold(body: Center(child: Text('Hello World'))),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that the text is rendered
    expect(find.text('Hello World'), findsOneWidget);

    // Verify Scaffold is there
    expect(find.byType(Scaffold), findsOneWidget);

    // Get the Scaffold and check its background
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    debugPrint('Scaffold background: ${scaffold.backgroundColor}');

    // Get the MaterialApp
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    debugPrint(
      'MaterialApp theme brightness: ${materialApp.theme?.brightness}',
    );
    debugPrint(
      'MaterialApp theme surface: ${materialApp.theme?.colorScheme.surface}',
    );
    debugPrint(
      'MaterialApp theme scaffoldBg: ${materialApp.theme?.scaffoldBackgroundColor}',
    );

    debugPrint('TEST PASSED - Widget tree renders correctly');
  });
}
