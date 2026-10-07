import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// コンテンツは最初からすべて見られる（ロックしない）ため、常に child を表示する。
/// 購読状態は [premiumProvider] で引き続き管理するが、画面の表示は止めない。
class PremiumGate extends ConsumerWidget {
  final Widget child;
  const PremiumGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return child;
  }
}
