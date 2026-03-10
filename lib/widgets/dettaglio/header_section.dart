import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/rifugio.dart';
import '../../providers/auth_provider.dart';
import '../../providers/preferiti_provider.dart';
import '../../widgets/rifugio_image.dart';
import '../../theme/app_theme.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';

/// SliverAppBar con immagine hero, gradiente e pulsante preferito.
class HeaderSection extends StatelessWidget {
  final Rifugio rifugio;

  const HeaderSection({super.key, required this.rifugio});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final preferitiProvider = Provider.of<PreferitiProvider>(context);
    final isPreferito = preferitiProvider.isPreferito(rifugio.id);
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      foregroundColor: Colors.white, // Over image with scrim — bianco fisso
      actions: [
        // Pulsante preferito
        if (authProvider.user != null)
          IconButton(
            icon: Icon(
              isPreferito ? Icons.star : Icons.star_border,
              color: isPreferito ? AppTheme.favoriteColor : Colors.white,
            ),
            onPressed: () async {
              await preferitiProvider.togglePreferito(
                authProvider.user!.uid,
                rifugio.id,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          isPreferito ? Icons.star_border : Icons.star,
                          color: colorScheme.onInverseSurface,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isPreferito
                                ? AppLocalizations.of(
                                    context,
                                  )!.removedFromFavorites
                                : AppLocalizations.of(
                                    context,
                                  )!.addedToFavorites,
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: isPreferito
                        ? colorScheme.inverseSurface
                        : AppTheme.favoriteColor,
                  ),
                );
              }
            },
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          rifugio.nome,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: rifugio.immagine != null && rifugio.immagine!.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  RifugioImage(
                    imageUrl: rifugio.immagine!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ), // Over gradient — bianco fisso
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          ),
                        ),
                        child: Icon(
                          rifugio.tipo == 'rifugio' ? Icons.home : Icons.cabin,
                          size: 80,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      );
                    },
                  ),
                  // Scrim gradient per leggibilità (Material You)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ],
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Icon(
                  rifugio.tipo == 'rifugio' ? Icons.home : Icons.cabin,
                  size: 80,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
      ),
    );
  }
}
