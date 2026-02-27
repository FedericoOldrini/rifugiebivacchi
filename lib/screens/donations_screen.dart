import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/in_app_purchase_service.dart';
import '../services/analytics_service.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  final InAppPurchaseService _purchaseService = InAppPurchaseService();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logOpenDonations();
    _initializePurchases();
  }

  Future<void> _initializePurchases() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await _purchaseService.initialize(
      onPurchaseCompleted: (PurchaseDetails details) {
        if (mounted) {
          final colorScheme = Theme.of(context).colorScheme;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: colorScheme.onPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(AppLocalizations.of(context)!.donationThanks),
                  ),
                ],
              ),
              backgroundColor: colorScheme.primary,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      onPurchaseError: (String error) {
        if (mounted) {
          final colorScheme = Theme.of(context).colorScheme;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: colorScheme.onError),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.purchaseError(error),
                    ),
                  ),
                ],
              ),
              backgroundColor: colorScheme.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
    );

    setState(() {
      _isLoading = false;
      if (!_purchaseService.isAvailable) {
        _errorMessage = AppLocalizations.of(
          context,
        )!.inAppPurchasesNotAvailable;
      } else if (_purchaseService.queryProductError != null) {
        _errorMessage = _resolveIapError(
          context,
          _purchaseService.queryProductError!,
        );
      }
    });
  }

  String _resolveIapError(BuildContext context, String errorCode) {
    final l10n = AppLocalizations.of(context)!;
    if (errorCode == 'iap_not_available') {
      return l10n.errorIapNotAvailable;
    } else if (errorCode == 'iap_products_not_configured') {
      return l10n.errorIapProductsNotConfigured;
    } else if (errorCode == 'iap_no_products_found') {
      return l10n.errorIapNoProductsFound;
    } else if (errorCode.startsWith('iap_product_load_error:')) {
      final details = errorCode.substring('iap_product_load_error:'.length);
      return l10n.errorIapProductLoadError(details);
    } else if (errorCode.startsWith('iap_connection_error:')) {
      return l10n.errorIapConnectionError;
    }
    return errorCode;
  }

  Future<void> _buyProduct(ProductDetails product) async {
    final success = await _purchaseService.buyProduct(product);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.cannotStartPurchase),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  IconData _getIconForProductId(String productId) {
    switch (productId) {
      case InAppPurchaseService.donationSmallId:
        return Icons.coffee;
      case InAppPurchaseService.donationMediumId:
        return Icons.lunch_dining;
      case InAppPurchaseService.donationLargeId:
        return Icons.card_giftcard;
      default:
        return Icons.favorite;
    }
  }

  String _getTitleForProductId(String productId, BuildContext context) {
    switch (productId) {
      case InAppPurchaseService.donationSmallId:
        return AppLocalizations.of(context)!.buyCoffee;
      case InAppPurchaseService.donationMediumId:
        return AppLocalizations.of(context)!.buyLunch;
      case InAppPurchaseService.donationLargeId:
        return AppLocalizations.of(context)!.generousDonation;
      default:
        return AppLocalizations.of(context)!.donation;
    }
  }

  Color _getColorForProductId(String productId, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (productId) {
      case InAppPurchaseService.donationSmallId:
        return colorScheme.tertiary;
      case InAppPurchaseService.donationMediumId:
        return colorScheme.secondary;
      case InAppPurchaseService.donationLargeId:
        return colorScheme.primary;
      default:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.donations)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.supportDevelopmentTitle,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.supportDevelopmentDescription,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Errore se presente
                  if (_errorMessage != null) ...[
                    Builder(
                      builder: (context) {
                        final colorScheme = Theme.of(context).colorScheme;
                        return Card(
                          color: colorScheme.tertiaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: colorScheme.tertiary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.donationsInApp,
                                        style: TextStyle(
                                          color: colorScheme.tertiary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: colorScheme.onTertiaryContainer,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.donationsNotAvailableNote,
                                  style: TextStyle(
                                    color: colorScheme.tertiary,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Perché donare
                  Text(
                    AppLocalizations.of(context)!.whyDonate,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FeatureItem(
                    icon: Icons.update,
                    title: AppLocalizations.of(context)!.regularUpdates,
                    description: AppLocalizations.of(
                      context,
                    )!.regularUpdatesDesc,
                  ),
                  _FeatureItem(
                    icon: Icons.add_location,
                    title: AppLocalizations.of(context)!.moreRifugi,
                    description: AppLocalizations.of(context)!.moreRifugiDesc,
                  ),
                  _FeatureItem(
                    icon: Icons.bug_report,
                    title: AppLocalizations.of(context)!.supportAndBugfix,
                    description: AppLocalizations.of(
                      context,
                    )!.supportAndBugfixDesc,
                  ),
                  _FeatureItem(
                    icon: Icons.insights,
                    title: AppLocalizations.of(context)!.newFeatures,
                    description: AppLocalizations.of(context)!.newFeaturesDesc,
                  ),
                  const SizedBox(height: 32),

                  // Opzioni di donazione
                  Text(
                    AppLocalizations.of(context)!.donationOptions,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mostra i prodotti disponibili
                  if (_purchaseService.isAvailable && _errorMessage == null)
                    ..._purchaseService.products.map((product) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _DonationCard(
                          icon: _getIconForProductId(product.id),
                          title: _getTitleForProductId(product.id, context),
                          subtitle: product.price,
                          color: _getColorForProductId(product.id, context),
                          isPending: _purchaseService.purchasePending,
                          onTap: () => _buyProduct(product),
                        ),
                      );
                    }).toList()
                  else
                  // Fallback se i prodotti non sono disponibili
                  ...[
                    Builder(
                      builder: (context) {
                        final colorScheme = Theme.of(context).colorScheme;
                        return Column(
                          children: [
                            _DonationCard(
                              icon: Icons.coffee,
                              title: AppLocalizations.of(context)!.buyCoffee,
                              subtitle: AppLocalizations.of(
                                context,
                              )!.notAvailable,
                              color: colorScheme.tertiary,
                              isPending: false,
                              onTap: () {},
                            ),
                            const SizedBox(height: 8),
                            _DonationCard(
                              icon: Icons.lunch_dining,
                              title: AppLocalizations.of(context)!.buyLunch,
                              subtitle: AppLocalizations.of(
                                context,
                              )!.notAvailable,
                              color: colorScheme.secondary,
                              isPending: false,
                              onTap: () {},
                            ),
                            const SizedBox(height: 8),
                            _DonationCard(
                              icon: Icons.card_giftcard,
                              title: AppLocalizations.of(
                                context,
                              )!.generousDonation,
                              subtitle: AppLocalizations.of(
                                context,
                              )!.notAvailable,
                              color: colorScheme.primary,
                              isPending: false,
                              onTap: () {},
                            ),
                          ],
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Info
                  Builder(
                    builder: (context) {
                      final colorScheme = Theme.of(context).colorScheme;
                      return Card(
                        color: colorScheme.surfaceContainerHighest,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context)!.donationsInfo,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.thanksSupport,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isPending;

  const _DonationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: isPending ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: isPending ? 0.5 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPending)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
