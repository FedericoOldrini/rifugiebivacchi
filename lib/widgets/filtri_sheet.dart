import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';
import '../providers/filtro_provider.dart';
import '../providers/preferiti_provider.dart';
import '../services/rifugi_service.dart';

/// Bottom sheet per i filtri avanzati e l'ordinamento.
class FiltriSheet extends StatefulWidget {
  const FiltriSheet({super.key});

  @override
  State<FiltriSheet> createState() => _FiltriSheetState();
}

class _FiltriSheetState extends State<FiltriSheet> {
  List<String> _availableRegions = [];
  List<String> _availableTypes = [];
  double _dbAltMin = 0;
  double _dbAltMax = 5000;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadFilterData();
  }

  Future<void> _loadFilterData() async {
    final regions = await RifugiService.getRegions();
    final types = await RifugiService.getTypes();
    final altRange = await RifugiService.getAltitudeRange();
    if (mounted) {
      setState(() {
        _availableRegions = regions;
        _availableTypes = types;
        _dbAltMin = altRange.min;
        _dbAltMax = altRange.max;
        _dataLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Consumer<FiltroProvider>(
          builder: (context, filtro, _) {
            final hasFavorites = Provider.of<PreferitiProvider>(
              context,
            ).preferiti.isNotEmpty;
            return Column(
              children: [
                // ── Handle + Header ──
                _buildHeader(context, l10n, filtro, colorScheme),
                const Divider(height: 1),
                // ── Body scrollabile ──
                Expanded(
                  child: _dataLoaded
                      ? ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          children: [
                            // ── Preferiti ──
                            if (hasFavorites) ...[
                              _buildFavoritesSection(
                                context,
                                l10n,
                                filtro,
                                colorScheme,
                              ),
                              const SizedBox(height: 24),
                            ],
                            _buildSortSection(
                              context,
                              l10n,
                              filtro,
                              colorScheme,
                            ),
                            const SizedBox(height: 24),
                            _buildTypeSection(
                              context,
                              l10n,
                              filtro,
                              colorScheme,
                            ),
                            const SizedBox(height: 24),
                            _buildRegionSection(
                              context,
                              l10n,
                              filtro,
                              colorScheme,
                            ),
                            const SizedBox(height: 24),
                            _buildAltitudeSection(
                              context,
                              l10n,
                              filtro,
                              colorScheme,
                            ),
                            const SizedBox(height: 24),
                            _buildServicesSection(
                              context,
                              l10n,
                              filtro,
                              colorScheme,
                            ),
                            const SizedBox(height: 24),
                            _buildAccessibilitySection(
                              context,
                              l10n,
                              filtro,
                              colorScheme,
                            ),
                            const SizedBox(height: 24),
                            _buildBedsSection(
                              context,
                              l10n,
                              filtro,
                              colorScheme,
                            ),
                            const SizedBox(height: 32),
                          ],
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ─── Header con handle, titolo e pulsante reset ─────────────

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    FiltroProvider filtro,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.tune, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.filtersTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (filtro.hasActiveFilters)
                TextButton.icon(
                  onPressed: () => filtro.resetFilters(),
                  icon: const Icon(Icons.restart_alt, size: 18),
                  label: Text(l10n.resetFilters),
                ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Sezione header helper ──────────────────────────────────

  Widget _sectionHeader(String title, IconData icon, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // ─── Preferiti ───────────────────────────────────────────

  Widget _buildFavoritesSection(
    BuildContext context,
    AppLocalizations l10n,
    FiltroProvider filtro,
    ColorScheme colorScheme,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(
        filtro.soloPreferiti ? Icons.star : Icons.star_border,
        color: filtro.soloPreferiti ? Colors.amber[700] : colorScheme.primary,
      ),
      title: Text(
        l10n.onlyFavorites,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      value: filtro.soloPreferiti,
      onChanged: (_) => filtro.togglePreferiti(),
    );
  }

  // ─── Ordinamento ────────────────────────────────────────────

  Widget _buildSortSection(
    BuildContext context,
    AppLocalizations l10n,
    FiltroProvider filtro,
    ColorScheme colorScheme,
  ) {
    final sortOptions = [
      (SortOrder.distance, l10n.sortByDistance, Icons.near_me),
      (SortOrder.altitude, l10n.sortByAltitude, Icons.terrain),
      (SortOrder.nameAZ, l10n.sortByName, Icons.sort_by_alpha),
      (SortOrder.beds, l10n.sortByBeds, Icons.bed),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(l10n.sortOrderTitle, Icons.swap_vert, colorScheme),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sortOptions.map((opt) {
            final isSelected = filtro.sortOrder == opt.$1;
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(opt.$3, size: 16),
                  const SizedBox(width: 6),
                  Text(opt.$2),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => filtro.setSortOrder(opt.$1),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Tipo struttura ─────────────────────────────────────────

  Widget _buildTypeSection(
    BuildContext context,
    AppLocalizations l10n,
    FiltroProvider filtro,
    ColorScheme colorScheme,
  ) {
    final typeLabels = <String, String>{
      for (final t in _availableTypes) t: _localizedType(t, l10n),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(l10n.filterTypeTitle, Icons.cabin, colorScheme),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTypes.map((type) {
            final isSelected = filtro.selectedTypes.contains(type);
            return FilterChip(
              label: Text(typeLabels[type] ?? type),
              selected: isSelected,
              onSelected: (_) => filtro.toggleType(type),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _localizedType(String type, AppLocalizations l10n) {
    switch (type.toLowerCase()) {
      case 'rifugio':
        return l10n.typeRifugio;
      case 'bivacco':
        return l10n.typeBivacco;
      case 'malga':
        return l10n.typeMalga;
      default:
        return type;
    }
  }

  // ─── Regione ────────────────────────────────────────────────

  Widget _buildRegionSection(
    BuildContext context,
    AppLocalizations l10n,
    FiltroProvider filtro,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _sectionHeader(
                l10n.filterRegionTitle,
                Icons.map_outlined,
                colorScheme,
              ),
            ),
            if (filtro.selectedRegions.isNotEmpty)
              TextButton(
                onPressed: () => filtro.setSelectedRegions({}),
                child: Text(
                  l10n.clearAll,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableRegions.map((region) {
            final isSelected = filtro.selectedRegions.contains(region);
            return FilterChip(
              label: Text(region),
              selected: isSelected,
              onSelected: (_) => filtro.toggleRegion(region),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Altitudine ─────────────────────────────────────────────

  Widget _buildAltitudeSection(
    BuildContext context,
    AppLocalizations l10n,
    FiltroProvider filtro,
    ColorScheme colorScheme,
  ) {
    final currentMin = filtro.altMin ?? _dbAltMin;
    final currentMax = filtro.altMax ?? _dbAltMax;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(l10n.filterAltitudeTitle, Icons.height, colorScheme),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${currentMin.round()} m',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${currentMax.round()} m',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(currentMin, currentMax),
          min: _dbAltMin,
          max: _dbAltMax,
          divisions: ((_dbAltMax - _dbAltMin) / 50).round().clamp(1, 200),
          labels: RangeLabels(
            '${currentMin.round()} m',
            '${currentMax.round()} m',
          ),
          onChanged: (values) {
            final newMin = values.start == _dbAltMin ? null : values.start;
            final newMax = values.end == _dbAltMax ? null : values.end;
            filtro.setAltitudeRange(min: newMin, max: newMax);
          },
        ),
      ],
    );
  }

  // ─── Servizi ────────────────────────────────────────────────

  Widget _buildServicesSection(
    BuildContext context,
    AppLocalizations l10n,
    FiltroProvider filtro,
    ColorScheme colorScheme,
  ) {
    final services = [
      (l10n.filterWifi, Icons.wifi, filtro.filterWifi, filtro.setFilterWifi),
      (
        l10n.filterRistorante,
        Icons.restaurant,
        filtro.filterRistorante,
        filtro.setFilterRistorante,
      ),
      (
        l10n.filterDocce,
        Icons.shower,
        filtro.filterDocce,
        filtro.setFilterDocce,
      ),
      (
        l10n.filterAcquaCalda,
        Icons.hot_tub,
        filtro.filterAcquaCalda,
        filtro.setFilterAcquaCalda,
      ),
      (
        l10n.filterPos,
        Icons.credit_card,
        filtro.filterPos,
        filtro.setFilterPos,
      ),
      (
        l10n.filterDefibrillatore,
        Icons.medical_services,
        filtro.filterDefibrillatore,
        filtro.setFilterDefibrillatore,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          l10n.filterServicesTitle,
          Icons.miscellaneous_services,
          colorScheme,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: services.map((s) {
            return FilterChip(
              avatar: Icon(s.$2, size: 18),
              label: Text(s.$1),
              selected: s.$3,
              onSelected: (v) => s.$4(v),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Accessibilita ──────────────────────────────────────────

  Widget _buildAccessibilitySection(
    BuildContext context,
    AppLocalizations l10n,
    FiltroProvider filtro,
    ColorScheme colorScheme,
  ) {
    final accessibility = [
      (
        l10n.filterDisabili,
        Icons.accessible,
        filtro.filterDisabili,
        filtro.setFilterDisabili,
      ),
      (
        l10n.filterFamiglie,
        Icons.family_restroom,
        filtro.filterFamiglie,
        filtro.setFilterFamiglie,
      ),
      (
        l10n.filterAuto,
        Icons.directions_car,
        filtro.filterAuto,
        filtro.setFilterAuto,
      ),
      (l10n.filterMtb, Icons.pedal_bike, filtro.filterMtb, filtro.setFilterMtb),
      (
        l10n.filterAnimali,
        Icons.pets,
        filtro.filterAnimali,
        filtro.setFilterAnimali,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          l10n.filterAccessibilityTitle,
          Icons.accessibility_new,
          colorScheme,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: accessibility.map((a) {
            return FilterChip(
              avatar: Icon(a.$2, size: 18),
              label: Text(a.$1),
              selected: a.$3,
              onSelected: (v) => a.$4(v),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Posti letto ────────────────────────────────────────────

  Widget _buildBedsSection(
    BuildContext context,
    AppLocalizations l10n,
    FiltroProvider filtro,
    ColorScheme colorScheme,
  ) {
    final currentMin = (filtro.minPostiLetto ?? 0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(l10n.filterBedsTitle, Icons.bed, colorScheme),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: currentMin,
                min: 0,
                max: 200,
                divisions: 40,
                label: currentMin == 0
                    ? l10n.filterBedsAny
                    : '${currentMin.round()}+',
                onChanged: (v) {
                  filtro.setMinPostiLetto(v == 0 ? null : v.round());
                },
              ),
            ),
            SizedBox(
              width: 56,
              child: Text(
                currentMin == 0 ? l10n.filterBedsAny : '${currentMin.round()}+',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
