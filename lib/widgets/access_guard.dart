import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/premium_provider.dart';
import '../screens/upgrade_screen.dart';

/// 学習画面を、無料期間(14日)または購読中の場合のみ表示する。
/// 無料期間が終わり購読もしていない場合は購読案内画面を出す。
/// （ホームの PremiumGate と同じ [premiumProvider] を参照する）
class AccessGuard extends ConsumerWidget {
  final Widget child;

  const AccessGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premium = ref.watch(premiumProvider);
    return premium.hasAccess ? child : const UpgradeScreen();
  }
}
