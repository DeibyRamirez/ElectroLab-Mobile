import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

class BillingManager {
  final InAppPurchase _iap = InAppPurchase.instance;
  late final StreamSubscription<List<PurchaseDetails>> _subscription;

  final void Function(String productId) onPurchaseSuccess;

  BillingManager({required this.onPurchaseSuccess});

  Future<void> start() async {
    final available = await _iap.isAvailable();
    if (!available) {
      throw Exception("In-App Purchases no disponibles");
    }

    _subscription = _iap.purchaseStream.listen(_listenToPurchases);
  }

  void dispose() {
    _subscription.cancel();
  }

  Future<void> buy(String productId) async {
    final response = await _iap.queryProductDetails({productId});

    if (response.productDetails.isEmpty) {
      throw Exception("Producto no encontrado en Play Console: $productId");
    }

    final product = response.productDetails.first;

    final param = PurchaseParam(productDetails: product);

    if (productId.startsWith("creditos_")) {
      await _iap.buyConsumable(
        purchaseParam: param,
        autoConsume: true,
      );
    } else {
      await _iap.buyNonConsumable(
        purchaseParam: param,
      );
    }
  }

  void _listenToPurchases(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        _completePurchase(purchase);
      }
    }
  }

  Future<void> _completePurchase(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }

    onPurchaseSuccess(purchase.productID);
  }
}
