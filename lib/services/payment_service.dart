import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'subscription_service.dart';
import 'logger_service.dart';

class PaymentService {
  static const String monthlyProductId =
      'jp.petitworks.shougaku_kore_doutoku.monthly';
  static const String yearlyProductId =
      'jp.petitworks.shougaku_kore_doutoku.yearly';

  /// android/app/build.gradle.kts の applicationId と一致させる
  static const String _androidPackageName = 'com.yourwish.shougakukore.shinshin';

  late final InAppPurchase _iap;
  late final SubscriptionService _subscriptionService;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  bool _isAvailable = false;

  /// 直近で purchaseStream から受け取った購入一覧のキャッシュ
  /// (in_app_purchase 3.x には queryPastPurchases が無いため、
  ///  restorePurchases() 実行後にこのキャッシュを参照する)
  final List<PurchaseDetails> _purchaseCache = [];

  PaymentService() {
    _iap = InAppPurchase.instance;
    _subscriptionService = SubscriptionService();

    // pending purchases (Android) は in_app_purchase_android の現行バージョンでは
    // デフォルトで有効なため明示的な初期化は不要
    _purchaseSubscription = _iap.purchaseStream.listen((purchases) {
      _purchaseCache
        ..removeWhere((p) => purchases.any((np) => np.purchaseID == p.purchaseID))
        ..addAll(purchases);
    });
  }

  void dispose() {
    _purchaseSubscription?.cancel();
  }

  /// Check if in-app purchase is available
  Future<bool> isAvailable() async {
    try {
      _isAvailable = await _iap.isAvailable();
      LoggerService.info('IAP available: $_isAvailable');
      return _isAvailable;
    } catch (e) {
      LoggerService.error(
        'Failed to check IAP availability',
        error: e,
      );
      return false;
    }
  }

  /// Get product details
  Future<ProductDetailsResponse> getProductDetails(
      List<String> productIds) async {
    try {
      final response = await _iap.queryProductDetails(productIds.toSet());
      LoggerService.info('Product details fetched: ${response.productDetails.length}');
      return response;
    } catch (e) {
      LoggerService.error(
        'Failed to get product details',
        error: e,
      );
      rethrow;
    }
  }

  /// Purchase monthly subscription
  Future<bool> purchaseMonthly(String userId) async {
    return _purchaseProduct(userId, monthlyProductId, 'monthly');
  }

  /// Purchase yearly subscription
  Future<bool> purchaseYearly(String userId) async {
    return _purchaseProduct(userId, yearlyProductId, 'yearly');
  }

  /// Internal method to handle purchase
  Future<bool> _purchaseProduct(
    String userId,
    String productId,
    String planType,
  ) async {
    try {
      if (!_isAvailable) {
        final available = await isAvailable();
        if (!available) {
          throw Exception('In-App Purchase not available');
        }
      }

      final response = await getProductDetails([productId]);

      if (response.productDetails.isEmpty) {
        throw Exception('Product not found: $productId');
      }

      final product = response.productDetails.first;

      final purchaseParam = PurchaseParam(productDetails: product);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);

      LoggerService.info('Purchase initiated for product: $productId');
      return true;
    } catch (e) {
      LoggerService.error(
        'Failed to purchase product: $productId',
        error: e,
      );
      rethrow;
    }
  }

  /// Listen to purchase updates
  Stream<List<PurchaseDetails>> getPurchaseUpdates() {
    return _iap.purchaseStream;
  }

  /// Handle purchase results
  Future<void> handlePurchaseUpdate(
    PurchaseDetails purchaseDetails,
    String userId,
  ) async {
    try {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Determine plan type from product ID
        final planType = purchaseDetails.productID == monthlyProductId
            ? 'monthly'
            : 'yearly';

        // Verify receipt
        bool verified = false;
        if (Platform.isIOS) {
          verified = await _subscriptionService.verifyAppleReceipt(
            userId: userId,
            receipt: purchaseDetails.verificationData.localVerificationData,
          );
        } else if (Platform.isAndroid) {
          verified = await _subscriptionService.verifyGooglePlayReceipt(
            userId: userId,
            packageName: _androidPackageName,
            productId: purchaseDetails.productID,
            purchaseToken: purchaseDetails.verificationData.serverVerificationData,
          );
        }

        if (verified) {
          // Update subscription in Firestore
          await _subscriptionService.activateSubscription(
            userId: userId,
            planType: planType,
            transactionId: purchaseDetails.purchaseID ?? purchaseDetails.productID,
          );

          LoggerService.info('Purchase completed and verified for user: $userId');
        }
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        LoggerService.error(
        'Purchase error for product: ${purchaseDetails.productID}',
        error: purchaseDetails.error.toString(),
      );
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        LoggerService.info('Purchase cancelled for product: ${purchaseDetails.productID}');
      }

      // Mark purchase as processed
      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
      }
    } catch (e) {
      LoggerService.error(
        'Failed to handle purchase update',
        error: e,
      );
    }
  }

  /// Complete a purchase
  Future<void> completePurchase(PurchaseDetails purchaseDetails) async {
    try {
      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
        LoggerService.info(
            'Purchase completed: ${purchaseDetails.purchaseID}');
      }
    } catch (e) {
      LoggerService.error(
        'Failed to complete purchase',
        error: e,
      );
      rethrow;
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
      LoggerService.info('Purchases restored');
    } catch (e) {
      LoggerService.error(
        'Failed to restore purchases',
        error: e,
      );
      rethrow;
    }
  }

  /// Get pending purchases
  /// in_app_purchase 3.x には queryPastPurchases が無いため、
  /// restorePurchases() を実行して purchaseStream 経由でキャッシュに反映されるのを待つ
  Future<List<PurchaseDetails>> getPendingPurchases() async {
    try {
      await _iap.restorePurchases();
      // purchaseStream 経由の反映を少し待つ
      await Future.delayed(const Duration(seconds: 2));
      LoggerService.info('Found ${_purchaseCache.length} past purchases');
      return List.unmodifiable(_purchaseCache);
    } catch (e) {
      LoggerService.error(
        'Failed to get pending purchases',
        error: e,
      );
      return [];
    }
  }

  /// Check if a product is purchased
  Future<bool> isProductPurchased(String productId) async {
    try {
      final purchases = await getPendingPurchases();
      return purchases.any((purchase) =>
          purchase.productID == productId &&
          (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored));
    } catch (e) {
      LoggerService.error(
        'Failed to check if product is purchased',
        error: e,
      );
      return false;
    }
  }
}
