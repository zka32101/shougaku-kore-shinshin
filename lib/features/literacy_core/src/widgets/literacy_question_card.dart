import 'package:flutter/material.dart';
import '../enums/grade_level.dart';
import '../enums/literacy_ui_level.dart';
import '../models/literacy_question.dart';
import '../theme/literacy_colors.dart';
import '../theme/literacy_typography.dart';

/// フレームワーク §4: 学年別問題カードウィジェット
class LiteracyQuestionCard extends StatelessWidget {
  final LiteracyQuestion question;
  final int? selectedIndex;
  final bool isAnswered;
  final ValueChanged<int> onChoiceSelected;
  final Widget? visualSupport; // イラスト・図（低学年向け）

  const LiteracyQuestionCard({
    super.key,
    required this.question,
    required this.selectedIndex,
    required this.isAnswered,
    required this.onChoiceSelected,
    this.visualSupport,
  });

  @override
  Widget build(BuildContext context) {
    final level = LiteracyUILevelExt.from(question.gradeLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _QuestionText(question: question, level: level),
        if (visualSupport != null && question.hasVisualSupport) ...[
          const SizedBox(height: 16),
          visualSupport!,
        ],
        const SizedBox(height: 20),
        _ChoiceGrid(
          question: question,
          level: level,
          selectedIndex: selectedIndex,
          isAnswered: isAnswered,
          onChoiceSelected: onChoiceSelected,
        ),
      ],
    );
  }
}

class _QuestionText extends StatelessWidget {
  final LiteracyQuestion question;
  final LiteracyUILevel level;

  const _QuestionText({required this.question, required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(level == LiteracyUILevel.simple ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(level.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: level == LiteracyUILevel.simple ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        question.questionText,
        style: TextStyle(
          fontSize: LiteracyTypography.questionTextSize(question.gradeLevel),
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
        textAlign: level == LiteracyUILevel.simple ? TextAlign.center : TextAlign.left,
      ),
    );
  }
}

class _ChoiceGrid extends StatelessWidget {
  final LiteracyQuestion question;
  final LiteracyUILevel level;
  final int? selectedIndex;
  final bool isAnswered;
  final ValueChanged<int> onChoiceSelected;

  const _ChoiceGrid({
    required this.question,
    required this.level,
    required this.selectedIndex,
    required this.isAnswered,
    required this.onChoiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    // 低学年: 2x2グリッド  中・高学年: 縦リスト
    if (level == LiteracyUILevel.simple) {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: List.generate(
          question.choices.length,
          (i) => _ChoiceButton(
            text: question.choices[i],
            index: i,
            level: level,
            grade: question.gradeLevel,
            correctIndex: question.correctIndex,
            selectedIndex: selectedIndex,
            isAnswered: isAnswered,
            onTap: () => onChoiceSelected(i),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(
        question.choices.length,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _ChoiceButton(
            text: question.choices[i],
            index: i,
            level: level,
            grade: question.gradeLevel,
            correctIndex: question.correctIndex,
            selectedIndex: selectedIndex,
            isAnswered: isAnswered,
            onTap: () => onChoiceSelected(i),
          ),
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String text;
  final int index;
  final LiteracyUILevel level;
  final GradeLevel grade;
  final int correctIndex;
  final int? selectedIndex;
  final bool isAnswered;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.text,
    required this.index,
    required this.level,
    required this.grade,
    required this.correctIndex,
    required this.selectedIndex,
    required this.isAnswered,
    required this.onTap,
  });

  Color _bgColor() {
    if (!isAnswered) {
      return selectedIndex == index ? const Color(0xFFE3F2FD) : Colors.white;
    }
    if (index == correctIndex) return LiteracyColors.correct.withOpacity(0.15);
    if (selectedIndex == index) return LiteracyColors.incorrect.withOpacity(0.15);
    return Colors.white;
  }

  Color _borderColor() {
    if (!isAnswered) {
      return selectedIndex == index ? const Color(0xFF2196F3) : Colors.grey.shade300;
    }
    if (index == correctIndex) return LiteracyColors.correct;
    if (selectedIndex == index) return LiteracyColors.incorrect;
    return Colors.grey.shade200;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAnswered ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: level == LiteracyUILevel.simple ? 16 : 14,
          vertical: level == LiteracyUILevel.simple ? 14 : 12,
        ),
        decoration: BoxDecoration(
          color: _bgColor(),
          borderRadius: BorderRadius.circular(level.cardBorderRadius),
          border: Border.all(color: _borderColor(), width: 2),
        ),
        child: Row(
          children: [
            if (level != LiteracyUILevel.simple) ...[
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _borderColor(), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    ['ア', 'イ', 'ウ', 'エ', 'オ', 'カ'][index],
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _borderColor()),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: LiteracyTypography.choiceTextSize(grade),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: level == LiteracyUILevel.simple ? TextAlign.center : TextAlign.left,
              ),
            ),
            if (isAnswered && index == correctIndex)
              const Icon(Icons.check_circle, color: LiteracyColors.correct, size: 20),
            if (isAnswered && selectedIndex == index && index != correctIndex)
              const Icon(Icons.cancel, color: LiteracyColors.incorrect, size: 20),
          ],
        ),
      ),
    );
  }
}
