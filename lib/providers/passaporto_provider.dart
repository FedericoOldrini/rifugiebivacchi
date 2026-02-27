import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/rifugio.dart';
import '../models/rifugio_checkin.dart';
import '../services/passaporto_service.dart';

class PassaportoProvider with ChangeNotifier {
  PassaportoService? _passaportoService;

  List<RifugioCheckIn> _checkIns = [];
  bool _isLoading = false;
  String? _error;

  /// Se [testMode] è `true`, non crea il service Firebase.
  final bool _testMode;

  PassaportoProvider({bool testMode = false}) : _testMode = testMode {
    if (!testMode) {
      _passaportoService = PassaportoService();
    }
  }

  /// Inietta check-in fake dall'esterno (per test/screenshot).
  /// Non usare in produzione.
  void setCheckInsForTest(List<RifugioCheckIn> checkIns) {
    _checkIns = checkIns;
    notifyListeners();
  }

  List<RifugioCheckIn> get checkIns => _checkIns;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get visitCount => _checkIns.length;

  // Raggruppa i check-in per rifugio
  Map<String, List<RifugioCheckIn>> get checkInsByRifugio {
    final Map<String, List<RifugioCheckIn>> grouped = {};
    for (var checkIn in _checkIns) {
      grouped.putIfAbsent(checkIn.rifugioId, () => []).add(checkIn);
    }
    // Ordina ogni lista per data (più recenti prima)
    grouped.forEach((key, list) {
      list.sort((a, b) => b.dataVisita.compareTo(a.dataVisita));
    });
    return grouped;
  }

  // Ottieni il numero di visite per un rifugio
  int getVisitCount(String rifugioId) {
    return _checkIns.where((c) => c.rifugioId == rifugioId).length;
  }

  // Ottieni la prima visita a un rifugio
  DateTime? getFirstVisit(String rifugioId) {
    final visits = _checkIns.where((c) => c.rifugioId == rifugioId).toList();
    if (visits.isEmpty) return null;
    visits.sort((a, b) => a.dataVisita.compareTo(b.dataVisita));
    return visits.first.dataVisita;
  }

  // Ottieni l'ultima visita a un rifugio
  DateTime? getLastVisit(String rifugioId) {
    final visits = _checkIns.where((c) => c.rifugioId == rifugioId).toList();
    if (visits.isEmpty) return null;
    visits.sort((a, b) => b.dataVisita.compareTo(a.dataVisita));
    return visits.first.dataVisita;
  }

  // Verifica se c'è già un check-in oggi per questo rifugio
  bool hasCheckedInToday(String rifugioId) {
    final today = DateTime.now();
    return _checkIns.any((checkIn) {
      if (checkIn.rifugioId != rifugioId) return false;
      final checkInDate = checkIn.dataVisita;
      return checkInDate.year == today.year &&
          checkInDate.month == today.month &&
          checkInDate.day == today.day;
    });
  }

  // Carica i check-in dell'utente
  void loadCheckIns(String userId) {
    if (_testMode) return;
    _passaportoService!.getCheckIns(userId).listen((checkIns) {
      _checkIns = checkIns;
      notifyListeners();
    });
  }

  // Verifica se l'utente è vicino al rifugio (entro 100 metri)
  Future<bool> isNearRifugio(Rifugio rifugio) async {
    try {
      // Verifica i permessi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      // Ottieni la posizione corrente
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Calcola la distanza
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        rifugio.latitudine,
        rifugio.longitudine,
      );

      // Ritorna true se entro 100 metri
      return distanceInMeters <= 100;
    } catch (e) {
      return false;
    }
  }

  // Esegui check-in a un rifugio
  Future<bool> checkInRifugio(String userId, Rifugio rifugio) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Verifica se c'è già un check-in oggi per questo rifugio
      if (hasCheckedInToday(rifugio.id)) {
        _error = 'already_checked_in_today';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Verifica se l'utente è vicino al rifugio
      final isNear = await isNearRifugio(rifugio);
      if (!isNear) {
        _error = 'not_near_rifugio';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Crea il check-in
      final checkIn = RifugioCheckIn(
        rifugioId: rifugio.id,
        rifugioNome: rifugio.nome,
        rifugioLat: rifugio.latitudine,
        rifugioLng: rifugio.longitudine,
        altitudine: rifugio.altitudine,
        dataVisita: DateTime.now(),
      );

      // Salva su Firestore
      await _passaportoService!.saveCheckIn(userId, checkIn);

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verifica se un rifugio è già stato visitato
  Future<bool> hasVisited(String userId, String rifugioId) async {
    if (_testMode) return _checkIns.any((c) => c.rifugioId == rifugioId);
    return await _passaportoService!.hasVisited(userId, rifugioId);
  }

  // Elimina un check-in
  Future<void> deleteCheckIn(String userId, String rifugioId) async {
    if (_testMode) return;
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _passaportoService!.deleteCheckIn(userId, rifugioId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Resetta lo stato
  void reset() {
    _checkIns = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
