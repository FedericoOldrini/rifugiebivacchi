import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseService {
  static final InAppPurchaseService _instance =
      InAppPurchaseService._internal();
  factory InAppPurchaseService() => _instance;
  InAppPurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // IDs dei prodotti (devono corrispondere a quelli configurati su App Store Connect e Google Play Console)
  static const String donationSmallId = 'rifugi_donation_coffee';
  static const String donationMediumId = 'rifugi_donation_lunch';
  static const String donationLargeId = 'rifugi_donation_generous';

  static const List<String> _productIds = [
    donationSmallId,
    donationMediumId,
    donationLargeId,
  ];

  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  String? _queryProductError;

  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;
  bool get purchasePending => _purchasePending;
  String? get queryProductError => _queryProductError;

  /// Inizializza il servizio di acquisto in-app
  Future<void> initialize({
    required Function(PurchaseDetails) onPurchaseCompleted,
    required Function(String) onPurchaseError,
  }) async {
    // Verifica se gli acquisti in-app sono disponibili
    _isAvailable = await _inAppPurchase.isAvailable();

    if (!_isAvailable) {
      debugPrint('In-app purchases not available');
      return;
    }

    // Ascolta gli aggiornamenti degli acquisti
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;

    _subscription = purchaseUpdated.listen(
      (List<PurchaseDetails> purchaseDetailsList) {
        _listenToPurchaseUpdated(
          purchaseDetailsList,
          onPurchaseCompleted,
          onPurchaseError,
        );
      },
      onDone: () {
        _subscription.cancel();
      },
      onError: (Object error) {
        debugPrint('Purchase stream error: $error');
        onPurchaseError(error.toString());
      },
    );

    // Carica i prodotti disponibili
    await loadProducts();
  }

  /// Carica i prodotti disponibili
  Future<void> loadProducts() async {
    if (!_isAvailable) {
      _queryProductError = 'iap_not_available';
      return;
    }

    try {
      final ProductDetailsResponse productDetailResponse = await _inAppPurchase
          .queryProductDetails(_productIds.toSet());

      if (productDetailResponse.error != null) {
        final errorMsg = productDetailResponse.error!.message;
        // Gestisci errori comuni di configurazione
        if (errorMsg.contains('Failed to get response from platform')) {
          _queryProductError = 'iap_products_not_configured';
        } else {
          _queryProductError = 'iap_product_load_error:$errorMsg';
        }
        debugPrint('Error loading products: $errorMsg');
        return;
      }

      if (productDetailResponse.productDetails.isEmpty) {
        _queryProductError = 'iap_no_products_found';
        debugPrint('No products found. Expected IDs: $_productIds');
        return;
      }

      _products = productDetailResponse.productDetails;
      _queryProductError = null;

      debugPrint('Products loaded: ${_products.length}');
      for (var product in _products) {
        debugPrint(
          'Product: ${product.id} - ${product.title} - ${product.price}',
        );
      }
    } catch (e) {
      _queryProductError = 'iap_connection_error:${e.toString()}';
      debugPrint('Exception loading products: $e');
    }
  }

  /// Effettua un acquisto
  Future<bool> buyProduct(ProductDetails productDetails) async {
    if (!_isAvailable) {
      return false;
    }

    _purchasePending = true;

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );

    try {
      final bool success = await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );

      return success;
    } catch (e) {
      debugPrint('Error buying product: $e');
      _purchasePending = false;
      return false;
    }
  }

  /// Gestisce gli aggiornamenti degli acquisti
  void _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
    Function(PurchaseDetails) onPurchaseCompleted,
    Function(String) onPurchaseError,
  ) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      debugPrint('Purchase status: ${purchaseDetails.status}');

      if (purchaseDetails.status == PurchaseStatus.pending) {
        _purchasePending = true;
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _purchasePending = false;
          onPurchaseError(purchaseDetails.error?.message ?? 'Unknown error');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          _purchasePending = false;
          onPurchaseCompleted(purchaseDetails);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  /// Ripristina gli acquisti (per iOS)
  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      return;
    }

    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
    }
  }

  /// Pulisce le risorse
  void dispose() {
    _subscription.cancel();
  }
}
