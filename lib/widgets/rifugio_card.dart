import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/rifugio.dart';
import '../providers/rifugi_provider.dart';
import '../providers/passaporto_provider.dart';
import '../providers/preferiti_provider.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';
import 'rifugio_image.dart';

class RifugioCard extends StatelessWidget {
  final Rifugio rifugio;
  final VoidCallback onTap;

  const RifugioCard({super.key, required this.rifugio, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RifugiProvider>(context);
    final passaportoProvider = Provider.of<PassaportoProvider>(context);
    final preferitiProvider = Provider.of<PreferitiProvider>(context);
    final distance = provider.getDistanceFromUser(rifugio);

    // Verifica se questo rifugio è stato visitato e conta le visite
    final visitCount = passaportoProvider.getVisitCount(rifugio.id);
    final isVisited = visitCount > 0;
    final isPreferito = preferitiProvider.isPreferito(rifugio.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isPreferito
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      elevation: isPreferito ? 2 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: isPreferito
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.5),
                    width: 1.5,
                  ),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (rifugio.immagine != null &&
                    rifugio.immagine!.isNotEmpty) ...[
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: RifugioImage(
                          imageUrl: rifugio.immagine!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getIconForType(rifugio.tipo),
                                color: Theme.of(context).colorScheme.primary,
                                size: 32,
                              ),
                            );
                          },
                        ),
                      ),
                      // Badge "Visitato" se è stato fatto check-in
                      if (isVisited)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.shadow
                                      .withAlpha((0.2 * 255).toInt()),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                if (visitCount > 1) ...[
                                  const SizedBox(width: 2),
                                  Text(
                                    '$visitCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Stellina preferito
                          if (isPreferito)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.star,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                            ),
                          if (rifugio.immagine == null)
                            Icon(
                              _getIconForType(rifugio.tipo),
                              color: Theme.of(context).colorScheme.primary,
                              size: 28,
                            ),
                          if (rifugio.immagine == null)
                            const SizedBox(width: 12),
                          // Badge "Visitato" per rifugi senza immagine
                          if (isVisited && rifugio.immagine == null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  if (visitCount > 1) ...[
                                    const SizedBox(width: 2),
                                    Text(
                                      '$visitCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          if (isVisited && rifugio.immagine == null)
                            const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rifugio.nome,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      _getLabelForType(rifugio.tipo, context),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    if (rifugio.altitudine != null) ...[
                                      Text(
                                        ' • ',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      Icon(
                                        Icons.terrain,
                                        size: 12,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${rifugio.altitudine!.toInt()} m',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          if (distance != null)
                            _InfoChip(
                              icon: Icons.location_on,
                              label: distance < 1
                                  ? '${(distance * 1000).toInt()} m'
                                  : '${distance.toStringAsFixed(1)} km',
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          if (rifugio.postiLetto != null &&
                              rifugio.postiLetto! > 0)
                            _InfoChip(
                              icon: Icons.bed,
                              label: '${rifugio.postiLetto}',
                            ),
                          if (rifugio.ristorante == true)
                            _InfoChip(
                              icon: Icons.restaurant,
                              label: AppLocalizations.of(context)!.restaurant,
                            ),
                          if (rifugio.wifi == true)
                            _InfoChip(
                              icon: Icons.wifi,
                              label: AppLocalizations.of(context)!.wifi,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'bivacco':
        return Icons.cabin;
      case 'malga':
        return Icons.cottage;
      case 'rifugio':
      default:
        return Icons.home;
    }
  }

  String _getLabelForType(String tipo, BuildContext context) {
    switch (tipo.toLowerCase()) {
      case 'bivacco':
        return AppLocalizations.of(context)!.bivacco;
      case 'malga':
        return AppLocalizations.of(context)!.malga;
      case 'rifugio':
      default:
        return AppLocalizations.of(context)!.rifugio;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
