import 'package:purchases_flutter/purchases_flutter.dart';

/// 小学コレ！心身用 RevenueCat サービス（月額¥300 / 年額¥2,400 固定）。
///
/// API キーは `--dart-define=REVENUE_CAT_GOOGLE_KEY=goog_...` で渡す。
/// 未設定なら初期化をスキップし、購入・復元は何もしない（null を返す）。
class ShinshinPurchaseService {
  ShinshinPurchaseService._();
  static final ShinshinPurchaseService instance = ShinshinPurchaseService._();

  static const String _googleKey =
      String.fromEnvironment('REVENUE_CAT_GOOGLE_KEY');
  static const String premiumEntitlementId = '小学コレ_pro';

  bool _configured = false;
  bool get isConfigured => _configured;

  Future<void> initialize() async {
    if (_configured || _googleKey.isEmpty) return;
    await Purchases.configure(PurchasesConfiguration(_googleKey));
    _configured = true;
  }

  /// プレミアム有効なら期限日（無期限なら遠い未来）、無効なら null。
  Future<DateTime?> premiumExpiry() async {
    if (!_configured) return null;
    return _expiryOf(await Purchases.getCustomerInfo());
  }

  Future<DateTime?> purchase({required bool monthly}) async {
    if (!_configured) return null;
    final offerings = await Purchases.getOfferings();
    final current = offerings.current;
    final package = monthly ? current?.monthly : current?.annual;
    if (package == null) return null;
    final result = await Purchases.purchase(PurchaseParams.package(package));
    return _expiryOf(result.customerInfo);
  }

  Future<DateTime?> restore() async {
    if (!_configured) return null;
    return _expiryOf(await Purchases.restorePurchases());
  }

  DateTime? _expiryOf(CustomerInfo info) {
    final entitlement = info.entitlements.active[premiumEntitlementId];
    if (entitlement == null) return null;
    final expiration = entitlement.expirationDate;
    return (expiration != null ? DateTime.tryParse(expiration) : null) ??
        DateTime(2100);
  }
}
