import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/premium_provider.dart';
import '../screens/upgrade_screen.dart';

/// 無料期間が終わって購読していないときに、学習タブの代わりに出す画面。
/// 無料期間中・購読中は [child] をそのまま出す。
class PremiumGate extends ConsumerWidget {
  final Widget child;
  const PremiumGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAccess = ref.watch(premiumProvider.select((s) => s.hasAccess));
    if (hasAccess) return child;
    return const PremiumLockView();
  }
}

class PremiumLockView extends StatelessWidget {
  const PremiumLockView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔒', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                const Text('無料期間が おわりました',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('つづけて まなぶには、プレミアムに しよう。\n（月額¥300 / 年額¥2,400）',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => const UpgradeScreen()),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('プレミアムにする', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
