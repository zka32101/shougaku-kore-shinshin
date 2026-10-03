import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/shinshin_purchase_service.dart';

/// 初回起動から全機能を無料で使える日数。
const int kTrialDays = 14;
const String _kTrialStartKey = 'trial_start_ms';

final premiumProvider =
    StateNotifierProvider<PremiumNotifier, PremiumStatus>((ref) {
  return PremiumNotifier();
});

/// 起動時に無料期間と購読状態を読み込む（アプリのルートで watch する）。
final premiumBootstrapProvider = FutureProvider<void>((ref) async {
  await ref.read(premiumProvider.notifier).load();
});

class PremiumStatus {
  final bool isPremium;
  final DateTime? expiryDate;
  final int trialDaysLeft;

  const PremiumStatus({
    this.isPremium = false,
    this.expiryDate,
    this.trialDaysLeft = kTrialDays,
  });

  bool get isTrialActive => !isPremium && trialDaysLeft > 0;

  /// 学習コンテンツを使えるか（購読中、または無料期間中）。
  bool get hasAccess => isPremium || isTrialActive;

  PremiumStatus copyWith({
    bool? isPremium,
    DateTime? expiryDate,
    int? trialDaysLeft,
  }) =>
      PremiumStatus(
        isPremium: isPremium ?? this.isPremium,
        expiryDate: expiryDate ?? this.expiryDate,
        trialDaysLeft: trialDaysLeft ?? this.trialDaysLeft,
      );
}

class PremiumNotifier extends StateNotifier<PremiumStatus> {
  PremiumNotifier() : super(const PremiumStatus());

  /// 無料期間（初回起動日）と購読状態を読み込む。起動時に1回呼ぶ。
  Future<void> load() async {
    final daysLeft = await _loadTrialDaysLeft();
    state = state.copyWith(trialDaysLeft: daysLeft);
    _sync(await _guard(() => ShinshinPurchaseService.instance.premiumExpiry()));
  }

  Future<int> _loadTrialDaysLeft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var startMs = prefs.getInt(_kTrialStartKey);
      if (startMs == null) {
        startMs = DateTime.now().millisecondsSinceEpoch;
        await prefs.setInt(_kTrialStartKey, startMs);
      }
      final elapsed = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(startMs))
          .inDays;
      final left = kTrialDays - elapsed;
      return left < 0 ? 0 : left;
    } catch (_) {
      // 読み書きできない環境では無料期間を維持（ユーザーを締め出さない）。
      return kTrialDays;
    }
  }

  Future<bool> restorePurchases() async =>
      _sync(await _guard(() => ShinshinPurchaseService.instance.restore()));

  Future<bool> purchaseMonthly() async => _sync(
      await _guard(() => ShinshinPurchaseService.instance.purchase(monthly: true)));

  Future<bool> purchaseYearly() async => _sync(await _guard(
      () => ShinshinPurchaseService.instance.purchase(monthly: false)));

  Future<DateTime?> _guard(Future<DateTime?> Function() action) async {
    if (!ShinshinPurchaseService.instance.isConfigured && kDebugMode) {
      debugPrint('⚠️ RevenueCat is not configured '
          '(REVENUE_CAT_GOOGLE_KEY missing). Purchases will fail.');
    }
    try {
      return await action();
    } catch (e, st) {
      if (kDebugMode) debugPrint('❌ Purchase error: $e\n$st');
      return null;
    }
  }

  bool _sync(DateTime? expiry) {
    if (expiry == null) return false;
    state = state.copyWith(isPremium: true, expiryDate: expiry);
    return true;
  }
}
