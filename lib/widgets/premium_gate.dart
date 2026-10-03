import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/premium_provider.dart';
import '../screens/upgrade_screen.dart';

/// 無料期間(14日)が終わり、購読もしていない場合は購読画面を表示する。
class PremiumGate extends ConsumerWidget {
  final Widget child;
  const PremiumGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premium = ref.watch(premiumProvider);
    return premium.hasAccess ? child : const UpgradeScreen();
  }
}
