import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/rifugio.dart';
import '../../providers/auth_provider.dart';
import '../../providers/passaporto_provider.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';

/// Sezione check-in: stato visite, pulsante check-in, info raggio.
class CheckinSection extends StatelessWidget {
  final Rifugio rifugio;
  final bool hasVisited;
  final bool isCheckingIn;
  final VoidCallback onCheckIn;
  final String Function(DateTime date) formatDate;

  const CheckinSection({
    super.key,
    required this.rifugio,
    required this.hasVisited,
    required this.isCheckingIn,
    required this.onCheckIn,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer2<AuthProvider, PassaportoProvider>(
      builder: (context, authProvider, passaportoProvider, child) {
        final isAuthenticated = authProvider.isAuthenticated;

        if (isAuthenticated) {
          final visitCount = passaportoProvider.getVisitCount(rifugio.id);
          final hasCheckedInToday = passaportoProvider.hasCheckedInToday(
            rifugio.id,
          );
          final firstVisit = passaportoProvider.getFirstVisit(rifugio.id);
          final lastVisit = passaportoProvider.getLastVisit(rifugio.id);

          return Column(
            children: [
              if (hasVisited)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              visitCount == 1
                                  ? l10n.visitedOnce
                                  : l10n.visitedMultiple(visitCount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (firstVisit != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          l10n.firstVisit(formatDate(firstVisit)),
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (visitCount > 1 && lastVisit != null)
                          Text(
                            l10n.lastVisit(formatDate(lastVisit)),
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              if (!hasCheckedInToday)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isCheckingIn ? null : onCheckIn,
                    icon: isCheckingIn
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : const Icon(Icons.location_on),
                    label: Text(
                      isCheckingIn
                          ? l10n.checkInProgress
                          : hasVisited
                          ? l10n.checkInAgain
                          : l10n.checkIn,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                  ),
                )
              else ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: colorScheme.tertiary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.checkInAlreadyToday,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                l10n.checkInRadius,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
