import 'package:flutter/material.dart';
import '../enums/grade_level.dart';
import '../theme/literacy_colors.dart';

/// 学年グループ選択ウィジェット（オンボーディング・設定画面用）
class GradeSelectorWidget extends StatelessWidget {
  final GradeLevel? selected;
  final ValueChanged<GradeLevel> onSelected;

  const GradeSelectorWidget({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: GradeLevel.values.map((grade) {
        final isSelected = selected == grade;
        final color = LiteracyColors.primaryFor(grade);

        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(grade),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color, width: 2),
                boxShadow: isSelected
                    ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                    : [],
              ),
              child: Column(
                children: [
                  Text(
                    _emoji(grade),
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    grade.shortLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : color,
                    ),
                  ),
                  Text(
                    _gradeRange(grade),
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _emoji(GradeLevel grade) {
    switch (grade) {
      case GradeLevel.low: return '🌱';
      case GradeLevel.mid: return '🌿';
      case GradeLevel.high: return '🌳';
    }
  }

  String _gradeRange(GradeLevel grade) {
    switch (grade) {
      case GradeLevel.low: return '小1〜小3';
      case GradeLevel.mid: return '小4〜小5';
      case GradeLevel.high: return '小6';
    }
  }
}
