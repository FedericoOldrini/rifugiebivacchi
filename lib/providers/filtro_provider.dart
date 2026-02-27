import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum per l'ordinamento della lista rifugi.
enum SortOrder { distance, altitude, nameAZ, beds }

class FiltroProvider with ChangeNotifier {
  // ── Preferiti ──
  bool _soloPreferiti = false;

  // ── Tipo (rifugio, bivacco, malga) ──
  Set<String> _selectedTypes = {};

  // ── Regione ──
  Set<String> _selectedRegions = {};

  // ── Altitudine ──
  double? _altMin;
  double? _altMax;

  // ── Servizi ──
  bool _filterWifi = false;
  bool _filterRistorante = false;
  bool _filterDocce = false;
  bool _filterAcquaCalda = false;
  bool _filterPos = false;
  bool _filterDefibrillatore = false;

  // ── Accessibilità ──
  bool _filterDisabili = false;
  bool _filterFamiglie = false;
  bool _filterAuto = false;
  bool _filterMtb = false;
  bool _filterAnimali = false;

  // ── Posti letto minimo ──
  int? _minPostiLetto;

  // ── Ordinamento ──
  SortOrder _sortOrder = SortOrder.distance;

  // ─── Getters ─────────────────────────────────────────────

  bool get soloPreferiti => _soloPreferiti;

  Set<String> get selectedTypes => _selectedTypes;
  Set<String> get selectedRegions => _selectedRegions;

  double? get altMin => _altMin;
  double? get altMax => _altMax;

  bool get filterWifi => _filterWifi;
  bool get filterRistorante => _filterRistorante;
  bool get filterDocce => _filterDocce;
  bool get filterAcquaCalda => _filterAcquaCalda;
  bool get filterPos => _filterPos;
  bool get filterDefibrillatore => _filterDefibrillatore;

  bool get filterDisabili => _filterDisabili;
  bool get filterFamiglie => _filterFamiglie;
  bool get filterAuto => _filterAuto;
  bool get filterMtb => _filterMtb;
  bool get filterAnimali => _filterAnimali;

  int? get minPostiLetto => _minPostiLetto;

  SortOrder get sortOrder => _sortOrder;

  /// Restituisce `true` se c'è almeno un filtro attivo (escluso ordinamento).
  bool get hasActiveFilters =>
      _soloPreferiti ||
      _selectedTypes.isNotEmpty ||
      _selectedRegions.isNotEmpty ||
      _altMin != null ||
      _altMax != null ||
      _filterWifi ||
      _filterRistorante ||
      _filterDocce ||
      _filterAcquaCalda ||
      _filterPos ||
      _filterDefibrillatore ||
      _filterDisabili ||
      _filterFamiglie ||
      _filterAuto ||
      _filterMtb ||
      _filterAnimali ||
      _minPostiLetto != null;

  /// Conta il numero di filtri attivi (per il badge).
  int get activeFilterCount {
    int count = 0;
    if (_soloPreferiti) count++;
    if (_selectedTypes.isNotEmpty) count++;
    if (_selectedRegions.isNotEmpty) count++;
    if (_altMin != null || _altMax != null) count++;
    if (_filterWifi) count++;
    if (_filterRistorante) count++;
    if (_filterDocce) count++;
    if (_filterAcquaCalda) count++;
    if (_filterPos) count++;
    if (_filterDefibrillatore) count++;
    if (_filterDisabili) count++;
    if (_filterFamiglie) count++;
    if (_filterAuto) count++;
    if (_filterMtb) count++;
    if (_filterAnimali) count++;
    if (_minPostiLetto != null) count++;
    return count;
  }

  // ─── Setters ─────────────────────────────────────────────

  void togglePreferiti() {
    _soloPreferiti = !_soloPreferiti;
    notifyListeners();
  }

  void setSelectedTypes(Set<String> types) {
    _selectedTypes = types;
    _persist();
    notifyListeners();
  }

  void toggleType(String type) {
    if (_selectedTypes.contains(type)) {
      _selectedTypes.remove(type);
    } else {
      _selectedTypes.add(type);
    }
    _persist();
    notifyListeners();
  }

  void setSelectedRegions(Set<String> regions) {
    _selectedRegions = regions;
    _persist();
    notifyListeners();
  }

  void toggleRegion(String region) {
    if (_selectedRegions.contains(region)) {
      _selectedRegions.remove(region);
    } else {
      _selectedRegions.add(region);
    }
    _persist();
    notifyListeners();
  }

  void setAltitudeRange({double? min, double? max}) {
    _altMin = min;
    _altMax = max;
    _persist();
    notifyListeners();
  }

  void setFilterWifi(bool v) {
    _filterWifi = v;
    _persist();
    notifyListeners();
  }

  void setFilterRistorante(bool v) {
    _filterRistorante = v;
    _persist();
    notifyListeners();
  }

  void setFilterDocce(bool v) {
    _filterDocce = v;
    _persist();
    notifyListeners();
  }

  void setFilterAcquaCalda(bool v) {
    _filterAcquaCalda = v;
    _persist();
    notifyListeners();
  }

  void setFilterPos(bool v) {
    _filterPos = v;
    _persist();
    notifyListeners();
  }

  void setFilterDefibrillatore(bool v) {
    _filterDefibrillatore = v;
    _persist();
    notifyListeners();
  }

  void setFilterDisabili(bool v) {
    _filterDisabili = v;
    _persist();
    notifyListeners();
  }

  void setFilterFamiglie(bool v) {
    _filterFamiglie = v;
    _persist();
    notifyListeners();
  }

  void setFilterAuto(bool v) {
    _filterAuto = v;
    _persist();
    notifyListeners();
  }

  void setFilterMtb(bool v) {
    _filterMtb = v;
    _persist();
    notifyListeners();
  }

  void setFilterAnimali(bool v) {
    _filterAnimali = v;
    _persist();
    notifyListeners();
  }

  void setMinPostiLetto(int? min) {
    _minPostiLetto = min;
    _persist();
    notifyListeners();
  }

  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    _persist();
    notifyListeners();
  }

  // ─── Reset ───────────────────────────────────────────────

  void reset() {
    _soloPreferiti = false;
    _selectedTypes = {};
    _selectedRegions = {};
    _altMin = null;
    _altMax = null;
    _filterWifi = false;
    _filterRistorante = false;
    _filterDocce = false;
    _filterAcquaCalda = false;
    _filterPos = false;
    _filterDefibrillatore = false;
    _filterDisabili = false;
    _filterFamiglie = false;
    _filterAuto = false;
    _filterMtb = false;
    _filterAnimali = false;
    _minPostiLetto = null;
    _sortOrder = SortOrder.distance;
    _persist();
    notifyListeners();
  }

  /// Resetta solo i filtri avanzati, mantenendo l'ordinamento.
  void resetFilters() {
    _soloPreferiti = false;
    _selectedTypes = {};
    _selectedRegions = {};
    _altMin = null;
    _altMax = null;
    _filterWifi = false;
    _filterRistorante = false;
    _filterDocce = false;
    _filterAcquaCalda = false;
    _filterPos = false;
    _filterDefibrillatore = false;
    _filterDisabili = false;
    _filterFamiglie = false;
    _filterAuto = false;
    _filterMtb = false;
    _filterAnimali = false;
    _minPostiLetto = null;
    _persist();
    notifyListeners();
  }

  // ─── Persistenza SharedPreferences ───────────────────────

  static const _kTypes = 'filtro_types';
  static const _kRegions = 'filtro_regions';
  static const _kAltMin = 'filtro_alt_min';
  static const _kAltMax = 'filtro_alt_max';
  static const _kWifi = 'filtro_wifi';
  static const _kRistorante = 'filtro_ristorante';
  static const _kDocce = 'filtro_docce';
  static const _kAcquaCalda = 'filtro_acqua_calda';
  static const _kPos = 'filtro_pos';
  static const _kDefibrillatore = 'filtro_defibrillatore';
  static const _kDisabili = 'filtro_disabili';
  static const _kFamiglie = 'filtro_famiglie';
  static const _kAuto = 'filtro_auto';
  static const _kMtb = 'filtro_mtb';
  static const _kAnimali = 'filtro_animali';
  static const _kMinPosti = 'filtro_min_posti';
  static const _kSortOrder = 'filtro_sort_order';

  /// Carica i filtri persistiti all'avvio.
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final types = prefs.getStringList(_kTypes);
    if (types != null) _selectedTypes = types.toSet();

    final regions = prefs.getStringList(_kRegions);
    if (regions != null) _selectedRegions = regions.toSet();

    _altMin = prefs.getDouble(_kAltMin);
    _altMax = prefs.getDouble(_kAltMax);

    _filterWifi = prefs.getBool(_kWifi) ?? false;
    _filterRistorante = prefs.getBool(_kRistorante) ?? false;
    _filterDocce = prefs.getBool(_kDocce) ?? false;
    _filterAcquaCalda = prefs.getBool(_kAcquaCalda) ?? false;
    _filterPos = prefs.getBool(_kPos) ?? false;
    _filterDefibrillatore = prefs.getBool(_kDefibrillatore) ?? false;

    _filterDisabili = prefs.getBool(_kDisabili) ?? false;
    _filterFamiglie = prefs.getBool(_kFamiglie) ?? false;
    _filterAuto = prefs.getBool(_kAuto) ?? false;
    _filterMtb = prefs.getBool(_kMtb) ?? false;
    _filterAnimali = prefs.getBool(_kAnimali) ?? false;

    final minPosti = prefs.getInt(_kMinPosti);
    _minPostiLetto = minPosti;

    final sortIdx = prefs.getInt(_kSortOrder);
    if (sortIdx != null && sortIdx < SortOrder.values.length) {
      _sortOrder = SortOrder.values[sortIdx];
    }

    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(_kTypes, _selectedTypes.toList());
    await prefs.setStringList(_kRegions, _selectedRegions.toList());

    if (_altMin != null) {
      await prefs.setDouble(_kAltMin, _altMin!);
    } else {
      await prefs.remove(_kAltMin);
    }
    if (_altMax != null) {
      await prefs.setDouble(_kAltMax, _altMax!);
    } else {
      await prefs.remove(_kAltMax);
    }

    await prefs.setBool(_kWifi, _filterWifi);
    await prefs.setBool(_kRistorante, _filterRistorante);
    await prefs.setBool(_kDocce, _filterDocce);
    await prefs.setBool(_kAcquaCalda, _filterAcquaCalda);
    await prefs.setBool(_kPos, _filterPos);
    await prefs.setBool(_kDefibrillatore, _filterDefibrillatore);

    await prefs.setBool(_kDisabili, _filterDisabili);
    await prefs.setBool(_kFamiglie, _filterFamiglie);
    await prefs.setBool(_kAuto, _filterAuto);
    await prefs.setBool(_kMtb, _filterMtb);
    await prefs.setBool(_kAnimali, _filterAnimali);

    if (_minPostiLetto != null) {
      await prefs.setInt(_kMinPosti, _minPostiLetto!);
    } else {
      await prefs.remove(_kMinPosti);
    }

    await prefs.setInt(_kSortOrder, _sortOrder.index);
  }
}
