import 'package:flutter/material.dart';

/// 問題ID -> 解説用イラスト(assets/explain/q/)。無い問題は何も表示しない。
const Map<String, String> kQuestionImages = {
  'tai_13_2': 'assets/explain/q/tai_13_2.webp',
  'tai_13_4': 'assets/explain/q/tai_13_4.webp',
  'tai_13_6': 'assets/explain/q/tai_13_6.webp',
  'tai_13_10': 'assets/explain/q/tai_13_10.webp',
  'tai_13_12': 'assets/explain/q/tai_13_12.webp',
  'tai_14_3': 'assets/explain/q/tai_14_3.webp',
  'tai_14_6': 'assets/explain/q/tai_14_6.webp',
  'tai_14_8': 'assets/explain/q/tai_14_8.webp',
  'tai_15_2': 'assets/explain/q/tai_15_2.webp',
  'tai_15_8': 'assets/explain/q/tai_15_8.webp',
  'tai_15_9': 'assets/explain/q/tai_15_9.webp',
  'tai_15_12': 'assets/explain/q/tai_15_12.webp',
  'tai_16_4': 'assets/explain/q/tai_16_4.webp',
  'tai_16_7': 'assets/explain/q/tai_16_7.webp',
  'tai_17_5': 'assets/explain/q/tai_17_5.webp',
  'tai_17_10': 'assets/explain/q/tai_17_10.webp',
  'tai_18_2': 'assets/explain/q/tai_18_2.webp',
  'tai_18_7': 'assets/explain/q/tai_18_7.webp',
  'tai_18_10': 'assets/explain/q/tai_18_10.webp',
  'tai_18_11': 'assets/explain/q/tai_18_11.webp',
  'tai_18_12': 'assets/explain/q/tai_18_12.webp',
  'tai_28_1': 'assets/explain/q/tai_28_1.webp',
  'tai_28_6': 'assets/explain/q/tai_28_6.webp',
  'tai_32_7': 'assets/explain/q/tai_32_7.webp',
  'tai_32_14': 'assets/explain/q/tai_32_14.webp',
  'tai_33_2': 'assets/explain/q/tai_33_2.webp',
  'tai_33_4': 'assets/explain/q/tai_33_4.webp',
};

/// 問題IDに対応するイラストを表示する。未登録/読込失敗時は空。
class QuestionImage extends StatelessWidget {
  final String id;
  final double maxHeight;
  const QuestionImage(this.id, {super.key, this.maxHeight = 180});

  @override
  Widget build(BuildContext context) {
    final path = kQuestionImages[id];
    if (path == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              path,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
