import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/rifugio.dart';
import '../services/rifugi_service.dart';

class RifugiProvider extends ChangeNotifier {
  List<Rifugio> _rifugi = [];
  List<Rifugio> _filteredRifugi = [];
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _errorMessage;
  Position? _userPosition;
  DateTime? _lastSyncTime;

  RifugiProvider() {
    _initializeApp();
  }

  /// Inizializza l'app: DB locale + sincronizzazione
  Future<void> _initializeApp() async {
    try {
      // Prima inizializza il DB locale
      await RifugiService.initializeWithLocalData();
      
      // Poi carica i rifugi (offline-first)
      await _loadRifugi();
      
      // Inizializza la posizione
      _initializeLocation();
      
      // Sincronizza in background con Firestore
      _syncInBackground();
    } catch (e) {
      _errorMessage = 'Errore nell\'inizializzazione: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sincronizza con Firestore in background
  Future<void> _syncInBackground() async {
    try {
      _isSyncing = true;
      notifyListeners();
      
      await RifugiService.syncFromFirestore();
      
      // Ricarica i dati dopo la sync
      await _loadRifugi();
      
      _lastSyncTime = DateTime.now();
      _isSyncing = false;
      notifyListeners();
    } catch (e) {
      _isSyncing = false;
      print('⚠️  Sincronizzazione fallita (app continua offline): $e');
      notifyListeners();
    }
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
          ),
        );
        _userPosition = position;
        _sortByDistance();
        notifyListeners();
      }
    } catch (e) {
      // Permessi negati o errore, continua senza posizione
    }
  }

  void updateUserPosition(Position position) {
    _userPosition = position;
    _sortByDistance();
    notifyListeners();
  }

  double? getDistanceFromUser(Rifugio rifugio) {
    if (_userPosition == null) return null;
    
    return Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      rifugio.latitudine,
      rifugio.longitudine,
    ) / 1000; // Converti in km
  }

  void _sortByDistance() {
    if (_userPosition == null) return;
    
    _filteredRifugi.sort((a, b) {
      final distA = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        a.latitudine,
        a.longitudine,
      );
      final distB = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        b.latitudine,
        b.longitudine,
      );
      return distA.compareTo(distB);
    });
  }

  List<Rifugio> get rifugi => _filteredRifugi;
  String get searchQuery => _searchQuery;
  Position? get userPosition => _userPosition;
  bool get hasLocation => _userPosition != null;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get errorMessage => _errorMessage;

  /// Carica i rifugi dal database locale
  Future<void> _loadRifugi() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _rifugi = await RifugiService.loadRifugiLocal();
      _filteredRifugi = List.from(_rifugi);
      _sortByDistance();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Errore nel caricamento dei rifugi: $e';
      notifyListeners();
    }
  }

  /// Forza una sincronizzazione manuale
  Future<void> forceSyncFromFirestore() async {
    await _syncInBackground();
  }

  /// Ottiene lo stato della sincronizzazione
  Future<Map<String, dynamic>> getSyncStatus() async {
    return await RifugiService.getSyncStatus();
  }

  void search(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredRifugi = List.from(_rifugi);
    } else {
      _filteredRifugi = _rifugi.where((rifugio) {
        final nome = rifugio.nome.toLowerCase();
        final descrizione = rifugio.descrizione?.toLowerCase() ?? '';
        final operatore = rifugio.operatore?.toLowerCase() ?? '';
        final queryLower = query.toLowerCase();
        
        return nome.contains(queryLower) ||
            descrizione.contains(queryLower) ||
            operatore.contains(queryLower);
      }).toList();
    }
    _sortByDistance();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredRifugi = List.from(_rifugi);
    _sortByDistance();
    notifyListeners();
  }

  Rifugio? getRifugioById(String id) {
    try {
      return _rifugi.firstWhere((rifugio) => rifugio.id == id);
    } catch (e) {
      return null;
    }
  }
}
