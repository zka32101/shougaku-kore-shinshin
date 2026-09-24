import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'subscription_service.dart';
import 'logger_service.dart';

class PaymentService {
  static const String monthlyProductId =
      'jp.petitworks.shougaku_kore_doutoku.monthly';
  static const String yearlyProductId =
      'jp.petitworks.shougaku_kore_doutoku.yearly';

  late final InAppPurchase _iap;
  late final SubscriptionService _subscriptionService;

  bool _isAvailable = false;

  PaymentService() {
    _iap = InAppPurchase.instance;
    _subscriptionService = SubscriptionService();

    _initializeInAppPurchase();
  }

  void _initializeInAppPurchase() {
    if (Platform.isAndroid) {
      InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
    }
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
            receipt: purchaseDetails.serverVerificationData.localVerificationData,
          );
        } else if (Platform.isAndroid) {
          verified = await _subscriptionService.verifyGooglePlayReceipt(
            userId: userId,
            packageName: purchaseDetails.packageName,
            productId: purchaseDetails.productID,
            purchaseToken: purchaseDetails.verificationData.serverVerificationData,
          );
        }

        if (verified) {
          // Update subscription in Firestore
          await _subscriptionService.activateSubscription(
            userId: userId,
            planType: planType,
            transactionId: purchaseDetails.purchaseID,
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
      if (purchaseDetails.pendingCompleteMark) {
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
      if (purchaseDetails.pendingCompleteMark) {
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
  Future<List<PurchaseDetails>> getPendingPurchases() async {
    try {
      final purchases = await _iap.queryPastPurchases();
      LoggerService.info('Found ${purchases.length} past purchases');
      return purchases;
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
