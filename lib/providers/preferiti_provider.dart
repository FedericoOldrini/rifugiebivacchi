import 'package:flutter/foundation.dart';
import '../services/preferiti_service.dart';

class PreferitiProvider with ChangeNotifier {
  PreferitiService? _preferitiService;

  List<String> _preferiti = [];
  bool _isLoading = false;
  String? _error;

  /// Se [testMode] è `true`, non crea il service Firebase.
  final bool _testMode;

  PreferitiProvider({bool testMode = false}) : _testMode = testMode {
    if (!testMode) {
      _preferitiService = PreferitiService();
    }
  }

  /// Inietta preferiti fake dall'esterno (per test/screenshot).
  /// Non usare in produzione.
  void setPreferitiForTest(List<String> preferiti) {
    _preferiti = preferiti;
    notifyListeners();
  }

  List<String> get preferiti => _preferiti;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Verifica se un rifugio è preferito
  bool isPreferito(String rifugioId) {
    return _preferiti.contains(rifugioId);
  }

  // Carica i preferiti dell'utente
  void loadPreferiti(String userId) {
    if (_testMode) return;
    _preferitiService!.getPreferitiStream(userId).listen((preferiti) {
      _preferiti = preferiti;
      notifyListeners();
    });
  }

  // Aggiungi/rimuovi preferito (toggle)
  Future<bool> togglePreferito(String userId, String rifugioId) async {
    if (_testMode) return true;
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (isPreferito(rifugioId)) {
        await _preferitiService!.removePreferito(userId, rifugioId);
      } else {
        await _preferitiService!.addPreferito(userId, rifugioId);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reset (quando l'utente fa logout)
  void reset() {
    _preferiti = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
