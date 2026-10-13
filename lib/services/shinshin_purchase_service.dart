import 'package:flutter/services.dart' show PlatformException;
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

  /// 直近の購入が失敗した理由（画面に出して原因を切り分けるため）。成功・キャンセル時は null/キャンセル文言。
  String? lastFailure;

  Future<DateTime?> purchase({required bool monthly}) async {
    lastFailure = null;
    if (!_configured) {
      lastFailure = '課金の設定が読み込まれていません（アプリを最新版にしてください）';
      return null;
    }
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      final package = monthly ? current?.monthly : current?.annual;
      if (package == null) {
        lastFailure = 'プランを読み込めませんでした（通信とGoogle Playの状態を確認してください）';
        return null;
      }
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return _expiryOf(result.customerInfo);
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        lastFailure = 'キャンセルしました';
      } else {
        lastFailure = '${code.name}: ${e.message ?? ''}'.trim();
      }
      return null;
    }
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
