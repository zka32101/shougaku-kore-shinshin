import 'package:flutter/material.dart';
import '../reward_assets.dart';

/// 連続学習バッジの見出し横に出す節目クラウン（7/14/30日）。到達済みは通常、未到達は薄く表示。
class StreakCrownRow extends StatelessWidget {
  final int longestStreak;
  const StreakCrownRow({super.key, required this.longestStreak});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final d in const [7, 14, 30])
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Opacity(
              opacity: longestStreak >= d ? 1.0 : 0.25,
              child: Image.asset(
                streakCrownAsset(d)!,
                key: Key('badge_crown_$d'),
                height: 24,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
      ],
    );
  }
}
