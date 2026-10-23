import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/premium_provider.dart';
import '../screens/upgrade_screen.dart';

/// ホームに出す「いまのプラン」カード。
/// 無料期間中は のこり日数、期間が終わったら「プレミアムにする」、購読中は「プレミアム」を出す。
/// タップでプレミアム購読画面（[UpgradeScreen]）を開く。
class PlanCard extends ConsumerWidget {
  const PlanCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premium = ref.watch(premiumProvider);

    final String title;
    final String sub;
    final String action;
    final Color color;
    if (premium.isPremium) {
      title = '🌟 プレミアム';
      sub = 'すべての がくしゅうが つかえるよ';
      action = 'プランを見る';
      color = const Color(0xFF43A047);
    } else if (premium.isTrialActive) {
      title = '⏳ 無料期間 あと${premium.trialDaysLeft}日';
      sub = '全部の がくしゅうが ためせるよ';
      action = '試す';
      color = const Color(0xFF1E88E5);
    } else {
      title = '🔒 無料期間が おわりました';
      sub = 'つづけるには プレミアムに しよう';
      action = 'プレミアムにする';
      color = const Color(0xFFE64A19);
    }

    return Semantics(
      container: true,
      label: '$title。$sub。$action',
      child: Card(
        margin: const EdgeInsets.only(top: 12),
        color: color.withValues(alpha: 0.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withValues(alpha: 0.5), width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const UpgradeScreen()),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: color)),
                      const SizedBox(height: 4),
                      Text(sub, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: color),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => const UpgradeScreen()),
                  ),
                  child: Text(action),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
