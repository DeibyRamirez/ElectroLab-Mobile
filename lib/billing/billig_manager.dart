import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

class BillingManager {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  final void Function(String productId) onPurchaseSuccess;

  BillingManager({required this.onPurchaseSuccess});

  void start() {
    _subscription = _iap.purchaseStream.listen(_listenToPurchases);
  }

  void dispose() {
    _subscription.cancel();
  }

  Future<void> buy(String productId) async {
    final response = await _iap.queryProductDetails({productId});
    if (response.notFoundIDs.isNotEmpty) return;

    final product = response.productDetails.first;
    final param = PurchaseParam(productDetails: product);

    if (productId.startsWith("coins_")) {
      // CONSUMIBLE
      _iap.buyConsumable(
        purchaseParam: param,
        autoConsume: true,
      );
    } else {
      // NO CONSUMIBLE (ej: remove_ads)
      _iap.buyNonConsumable(
        purchaseParam: param,
      );
    }
  }

  void _listenToPurchases(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        _handlePurchase(purchase);
      }
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }

    onPurchaseSuccess(purchase.productID);
  }
}
