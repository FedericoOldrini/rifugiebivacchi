import 'package:flutter/foundation.dart';

class FiltroProvider with ChangeNotifier {
  bool _soloPreferiti = false;

  bool get soloPreferiti => _soloPreferiti;

  void togglePreferiti() {
    _soloPreferiti = !_soloPreferiti;
    notifyListeners();
  }

  void reset() {
    _soloPreferiti = false;
    notifyListeners();
  }
}
