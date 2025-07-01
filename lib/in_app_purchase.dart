import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart'; // Para Android/ Para iOS

class InAppPurchaseService {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // Produtos/assinaturas cadastrados no Play Console/App Store
  final Set<String> _kProductIds = {
    'mensal',
    'anual',
    'plano_vitalicio'
  };

  Future<void> initialize() async {
    // Configura listener para atualizações de compra
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

  // Separe os IDs de acordo com o tipo de produto
  final Set<String> subscriptionIds = {'mensal', 'anual'};
  final Set<String> oneTimeIds = {'plano_vitalicio'};

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
    final purchaseParam = PurchaseParam(
      productDetails: product,
      applicationUserName: null, // Opcional: ID do usuário
    );

    await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        _verifyPurchase(purchase); // Valida no seu backend
      }
    }
  }

  Future<void> _verifyPurchase(PurchaseDetails purchase) async {
    // Implemente validação com seu backend aqui
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
        
        if (isActive) {
          return true;
        }
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
    
    return purchase.billingClientPurchase.isAcknowledged && 
           !purchase.billingClientPurchase.isAutoRenewing;
  }

  bool _isIosPurchaseActive(PurchaseDetails purchase) {
    return purchase.status == PurchaseStatus.purchased;
  }

  Future<List<PurchaseDetails>> _getPastPurchases() async {
    await _inAppPurchase.restorePurchases();
    
    final List<PurchaseDetails> pastPurchases = [];
    final completer = Completer<List<PurchaseDetails>>();
    
    final sub = _inAppPurchase.purchaseStream.listen((purchases) {
      pastPurchases.addAll(
        purchases.where((p) => p.status == PurchaseStatus.purchased)
      );
      completer.complete(pastPurchases);
    });

    await completer.future.timeout(
      Duration(seconds: 5), 
      onTimeout: () => pastPurchases
    );
    
    await sub.cancel();
    return pastPurchases;
  }

  void dispose() {
    _subscription?.cancel();
  }
}