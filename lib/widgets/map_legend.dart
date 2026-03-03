import 'package:flutter/material.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';

/// Colori e icone condivisi per i marker della mappa.
/// Usati sia dalla mappa Google Maps che dalla mappa offline.
class MapMarkerStyle {
  // Colori per tipo di struttura
  static const Color rifugioColor = Color(0xFF3B82F6); // Blue-500
  static const Color bivaccoColor = Color(0xFFF59E0B); // Amber-500
  static const Color malgaColor = Color(0xFF22C55E); // Green-500

  // Colori cluster
  static const Color clusterSmall = Color(0xFF6366F1); // Indigo-500
  static const Color clusterMedium = Color(0xFF8B5CF6); // Violet-500
  static const Color clusterLarge = Color(0xFFA855F7); // Purple-500

  static Color colorForTipo(String tipo) {
    switch (tipo) {
      case 'rifugio':
        return rifugioColor;
      case 'bivacco':
        return bivaccoColor;
      default:
        return malgaColor;
    }
  }

  static IconData iconForTipo(String tipo) {
    switch (tipo) {
      case 'bivacco':
        return Icons.cabin;
      case 'malga':
        return Icons.cottage;
      default:
        return Icons.home_rounded;
    }
  }

  static Color clusterColor(int count) {
    if (count < 10) return clusterSmall;
    if (count < 50) return clusterMedium;
    return clusterLarge;
  }
}

/// Legenda compatta e semi-trasparente per le mappe.
class MapLegend extends StatelessWidget {
  const MapLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.65)
            : Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendDot(
            color: MapMarkerStyle.rifugioColor,
            label: l10n.legendRifugi,
          ),
          const SizedBox(width: 12),
          _LegendDot(
            color: MapMarkerStyle.bivaccoColor,
            label: l10n.legendBivacchi,
          ),
          const SizedBox(width: 12),
          _LegendDot(
            color: MapMarkerStyle.malgaColor,
            label: l10n.legendMalghe,
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
