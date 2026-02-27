import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/rifugio.dart';
import '../services/rifugi_service.dart';
import 'filtro_provider.dart';

class RifugiProvider extends ChangeNotifier {
  List<Rifugio> _rifugi = [];
  List<Rifugio> _filteredRifugi = [];
  String _searchQuery = '';
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _errorMessage;
  Position? _userPosition;
  DateTime? _lastSyncTime;

  /// Se [testMode] è `true`, salta l'inizializzazione (Firebase, SQLite, Geo).
  /// Usato per screenshot automatici e test.
  RifugiProvider({bool testMode = false}) {
    if (!testMode) {
      _initializeApp();
    } else {
      _isLoading = false;
    }
  }

  /// Inietta una lista di rifugi dall'esterno (per test/screenshot).
  /// Non usare in produzione.
  void setRifugiForTest(List<Rifugio> rifugi) {
    _rifugi = rifugi;
    _filteredRifugi = List.from(rifugi);
    _isLoading = false;
    notifyListeners();
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
      _errorMessage = 'init_error:$e';
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
      // Sincronizzazione fallita, l'app continua offline
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
        ) /
        1000; // Converti in km
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

  /// Lista completa (non filtrata) – utile per la mappa
  List<Rifugio> get allRifugi => _rifugi;
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
      _errorMessage = 'load_error:$e';
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
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Applica tutti i filtri e l'ordinamento sulla lista completa.
  /// Chiamato da lista_rifugi_screen ogni volta che cambia FiltroProvider,
  /// PreferitiProvider o la query di ricerca.
  void applyFilters(FiltroProvider filtro, {Set<String>? preferitiIds}) {
    List<Rifugio> result = List.from(_rifugi);

    // ── Ricerca testuale ──
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((r) {
        final nome = r.nome.toLowerCase();
        final descrizione = r.descrizione?.toLowerCase() ?? '';
        final operatore = r.operatore?.toLowerCase() ?? '';
        return nome.contains(q) ||
            descrizione.contains(q) ||
            operatore.contains(q);
      }).toList();
    }

    // ── Preferiti ──
    if (filtro.soloPreferiti && preferitiIds != null) {
      result = result.where((r) => preferitiIds.contains(r.id)).toList();
    }

    // ── Tipo ──
    if (filtro.selectedTypes.isNotEmpty) {
      result = result
          .where((r) => filtro.selectedTypes.contains(r.tipo))
          .toList();
    }

    // ── Regione ──
    if (filtro.selectedRegions.isNotEmpty) {
      result = result
          .where(
            (r) =>
                r.region != null && filtro.selectedRegions.contains(r.region),
          )
          .toList();
    }

    // ── Altitudine ──
    if (filtro.altMin != null) {
      result = result
          .where((r) => r.altitudine != null && r.altitudine! >= filtro.altMin!)
          .toList();
    }
    if (filtro.altMax != null) {
      result = result
          .where((r) => r.altitudine != null && r.altitudine! <= filtro.altMax!)
          .toList();
    }

    // ── Servizi ──
    if (filtro.filterWifi) {
      result = result.where((r) => r.wifi == true).toList();
    }
    if (filtro.filterRistorante) {
      result = result.where((r) => r.ristorante == true).toList();
    }
    if (filtro.filterDocce) {
      result = result.where((r) => r.showers == true).toList();
    }
    if (filtro.filterAcquaCalda) {
      result = result.where((r) => r.hotWater == true).toList();
    }
    if (filtro.filterPos) {
      result = result.where((r) => r.pagamentoPos == true).toList();
    }
    if (filtro.filterDefibrillatore) {
      result = result.where((r) => r.defibrillatore == true).toList();
    }

    // ── Accessibilità ──
    if (filtro.filterDisabili) {
      result = result.where((r) => r.disabledAccess == true).toList();
    }
    if (filtro.filterFamiglie) {
      result = result.where((r) => r.familiesChildrenAccess == true).toList();
    }
    if (filtro.filterAuto) {
      result = result.where((r) => r.carAccess == true).toList();
    }
    if (filtro.filterMtb) {
      result = result.where((r) => r.mountainBikeAccess == true).toList();
    }
    if (filtro.filterAnimali) {
      result = result.where((r) => r.petAccess == true).toList();
    }

    // ── Posti letto minimo ──
    if (filtro.minPostiLetto != null) {
      result = result
          .where(
            (r) =>
                r.postiLetto != null && r.postiLetto! >= filtro.minPostiLetto!,
          )
          .toList();
    }

    // ── Ordinamento ──
    switch (filtro.sortOrder) {
      case SortOrder.distance:
        if (_userPosition != null) {
          result.sort((a, b) {
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
        break;
      case SortOrder.altitude:
        result.sort((a, b) {
          final altA = a.altitudine ?? 0;
          final altB = b.altitudine ?? 0;
          return altB.compareTo(altA); // decrescente
        });
        break;
      case SortOrder.nameAZ:
        result.sort(
          (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
        );
        break;
      case SortOrder.beds:
        result.sort((a, b) {
          final bedsA = a.postiLetto ?? 0;
          final bedsB = b.postiLetto ?? 0;
          return bedsB.compareTo(bedsA); // decrescente
        });
        break;
    }

    // Guard: evita notifyListeners se la lista filtrata non è cambiata.
    // Previene loop infiniti nel Consumer3 → addPostFrameCallback → applyFilters.
    final oldIds = _filteredRifugi.map((r) => r.id).toList();
    final newIds = result.map((r) => r.id).toList();
    if (listEquals(oldIds, newIds)) return;

    _filteredRifugi = result;
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
