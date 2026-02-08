import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/in_app_purchase_service.dart';

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Grazie per il tuo supporto! ❤️'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      },
      onPurchaseError: (String error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Errore: $error'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
    );

    setState(() {
      _isLoading = false;
      if (!_purchaseService.isAvailable) {
        _errorMessage = 'Gli acquisti in-app non sono disponibili';
      } else if (_purchaseService.queryProductError != null) {
        _errorMessage = _purchaseService.queryProductError;
      }
    });
  }

  Future<void> _buyProduct(ProductDetails product) async {
    final success = await _purchaseService.buyProduct(product);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossibile avviare l\'acquisto'),
          backgroundColor: Colors.red,
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

  String _getTitleForProductId(String productId) {
    switch (productId) {
      case InAppPurchaseService.donationSmallId:
        return 'Offrimi un caffè';
      case InAppPurchaseService.donationMediumId:
        return 'Offrimi un pranzo';
      case InAppPurchaseService.donationLargeId:
        return 'Donazione generosa';
      default:
        return 'Donazione';
    }
  }

  Color _getColorForProductId(String productId) {
    switch (productId) {
      case InAppPurchaseService.donationSmallId:
        return Colors.brown;
      case InAppPurchaseService.donationMediumId:
        return Colors.orange;
      case InAppPurchaseService.donationLargeId:
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donazioni'),
      ),
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
                          const Text(
                            'Supporta lo Sviluppo',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Se ti piace questa app e vuoi supportare lo sviluppo, '
                            'considera di fare una donazione!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
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
                    Card(
                      color: Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Perché donare
                  const Text(
                    'Perché donare?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FeatureItem(
                    icon: Icons.update,
                    title: 'Aggiornamenti regolari',
                    description: 'Nuove funzionalità e miglioramenti continui',
                  ),
                  _FeatureItem(
                    icon: Icons.add_location,
                    title: 'Più rifugi',
                    description: 'Espansione del database con nuovi rifugi',
                  ),
                  _FeatureItem(
                    icon: Icons.bug_report,
                    title: 'Supporto e bug fix',
                    description: 'Risoluzione rapida di problemi e bug',
                  ),
                  _FeatureItem(
                    icon: Icons.insights,
                    title: 'Nuove funzionalità',
                    description: 'Sviluppo di features richieste dalla community',
                  ),
                  const SizedBox(height: 32),

                  // Opzioni di donazione
                  const Text(
                    'Opzioni di donazione',
                    style: TextStyle(
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
                          title: _getTitleForProductId(product.id),
                          subtitle: product.price,
                          color: _getColorForProductId(product.id),
                          isPending: _purchaseService.purchasePending,
                          onTap: () => _buyProduct(product),
                        ),
                      );
                    }).toList()
                  else
                    // Fallback se i prodotti non sono disponibili
                    ...[
                      _DonationCard(
                        icon: Icons.coffee,
                        title: 'Offrimi un caffè',
                        subtitle: 'Non disponibile',
                        color: Colors.brown,
                        isPending: false,
                        onTap: () {},
                      ),
                      const SizedBox(height: 8),
                      _DonationCard(
                        icon: Icons.lunch_dining,
                        title: 'Offrimi un pranzo',
                        subtitle: 'Non disponibile',
                        color: Colors.orange,
                        isPending: false,
                        onTap: () {},
                      ),
                      const SizedBox(height: 8),
                      _DonationCard(
                        icon: Icons.card_giftcard,
                        title: 'Donazione generosa',
                        subtitle: 'Non disponibile',
                        color: Colors.purple,
                        isPending: false,
                        onTap: () {},
                      ),
                    ],
                  
                  const SizedBox(height: 32),

                  // Info
                  Card(
                    color: Colors.grey[100],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Le donazioni sono pagamenti una tantum e non comportano abbonamenti.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Grazie per il tuo supporto! 🏔️',
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
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
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
                    color: Colors.grey[700],
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
                  child: Icon(
                    icon,
                    color: color,
                    size: 32,
                  ),
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
                          color: Colors.grey[600],
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
