import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';


//Comprar in-app
class InAppPurchaseService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // IDs cadastrados no Play Console
  final Set<String> subscriptionIds = {'premium_acess', 'premium_acess_month'};
  final Set<String> oneTimeIds = {'vitalicio'};

  Future<void> initialize() async {
    _subscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => print('Erro nas compras: $error'),
    );

    await loadProducts();
  }

  Future<List<ProductDetails>> loadProducts() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) return [];

    final List<ProductDetails> allProducts = [];

    if (subscriptionIds.isNotEmpty) {
      final subsResponse = await _inAppPurchase.queryProductDetails(subscriptionIds);
      allProducts.addAll(subsResponse.productDetails);
    }

    if (oneTimeIds.isNotEmpty) {
      final oneTimeResponse = await _inAppPurchase.queryProductDetails(oneTimeIds);
      allProducts.addAll(oneTimeResponse.productDetails);
    }

    return allProducts;
  }

  Future<void> buyProduct(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);

    if (subscriptionIds.contains(product.id)) {
      // Assinatura
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } else if (oneTimeIds.contains(product.id)) {
      // Compra única (vitalício)
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      // Consumível (caso você use no futuro)
      await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
    }
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        _verifyPurchase(purchase);
      }
    }
  }

  Future<void> _verifyPurchase(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchase);
    }
  }

  Future<bool> hasActivePurchase() async {
    final List<PurchaseDetails> purchases = await _getPastPurchases();

    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        final isActive = purchase is GooglePlayPurchaseDetails
            ? _isAndroidPurchaseActive(purchase)
            : _isIosPurchaseActive(purchase);

        if (isActive) return true;
      }
    }

    return false;
  }

  Future<List<PurchaseDetails>> getActivePurchases() async {
    final List<PurchaseDetails> activePurchases = [];
    final purchases = await _getPastPurchases();

    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        final isActive = purchase is GooglePlayPurchaseDetails
            ? _isAndroidPurchaseActive(purchase)
            : _isIosPurchaseActive(purchase);

        if (isActive) {
          activePurchases.add(purchase);
        }
      }
    }

    return activePurchases;
  }

  bool _isAndroidPurchaseActive(GooglePlayPurchaseDetails purchase) {
    if (purchase.pendingCompletePurchase) {
      _inAppPurchase.completePurchase(purchase);
    }

    return purchase.billingClientPurchase.isAcknowledged;
  }

  bool _isIosPurchaseActive(PurchaseDetails purchase) {
    return purchase.status == PurchaseStatus.purchased;
  }

  Future<List<PurchaseDetails>> _getPastPurchases() async {
  final List<PurchaseDetails> pastPurchases = [];
  final Completer<List<PurchaseDetails>> completer = Completer();

  final tempSubscription = _inAppPurchase.purchaseStream.listen(
    (purchases) {
      pastPurchases.addAll(
        purchases.where((p) => p.status == PurchaseStatus.purchased),
      );
      completer.complete(pastPurchases);
    },
    onError: (error) {
      print("Erro ao restaurar compras: $error");
      completer.complete(pastPurchases); // retorna lista vazia em caso de erro
    },
  );

  await _inAppPurchase.restorePurchases();

  return completer.future.timeout(
    const Duration(seconds: 5),
    onTimeout: () => pastPurchases,
  ).whenComplete(() => tempSubscription.cancel());
}

  void dispose() {
    _subscription?.cancel();
  }
}
