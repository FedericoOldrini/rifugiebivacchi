// Configurazione globale per i test Flutter.
//
// Carica i font dell'app (Material Icons + Roboto) per i golden test,
// in modo che i golden file mostrino icone e testo reali
// invece di box rettangolari vuoti.
import 'dart:async';

import 'package:golden_toolkit/golden_toolkit.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadAppFonts();
  return testMain();
}
