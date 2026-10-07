import 'package:flutter/material.dart';
import 'package:shougaku_kore_doutoku/widgets/furigana_text.dart';
import '../enums/grade_level.dart';
import '../models/literacy_question.dart';
import '../theme/literacy_colors.dart';
import '../theme/literacy_typography.dart';

/// フレームワーク §6.2: 学年別フィードバックウィジェット
///
/// 低学年: 「ピンポン！」「もう一回！」+ 大アニメーション
/// 中学年: 理由付き説明「〇〇だから」
/// 高学年: 詳細解説 + 別解 + 同パターン問題リンク
class LiteracyFeedbackWidget extends StatelessWidget {
  final LiteracyFeedbackContent feedback;
  final VoidCallback onNext;
  final VoidCallback? onShowRelated;

  const LiteracyFeedbackWidget({
    super.key,
    required this.feedback,
    required this.onNext,
    this.onShowRelated,
  });

  @override
  Widget build(BuildContext context) {
    switch (feedback.grade) {
      case GradeLevel.low:
        return _LowGradeFeedback(feedback: feedback, onNext: onNext);
      case GradeLevel.mid:
        return _MidGradeFeedback(feedback: feedback, onNext: onNext);
      case GradeLevel.high:
        return _HighGradeFeedback(
          feedback: feedback,
          onNext: onNext,
          onShowRelated: onShowRelated,
        );
    }
  }
}

/// 低学年: シンプル・視覚的・大フォント
class _LowGradeFeedback extends StatelessWidget {
  final LiteracyFeedbackContent feedback;
  final VoidCallback onNext;

  const _LowGradeFeedback({required this.feedback, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final color = feedback.isCorrect ? LiteracyColors.correct : LiteracyColors.incorrect;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            feedback.isCorrect ? '🎉' : '😊',
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 12),
          FuriganaText(
            feedback.mainText,
            style: TextStyle(
              fontSize: LiteracyTypography.feedbackTextSize(GradeLevel.low),
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                feedback.isCorrect ? 'つぎへ！' : 'もう一回！',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 中学年: 理由付き + シンプルな説明
class _MidGradeFeedback extends StatelessWidget {
  final LiteracyFeedbackContent feedback;
  final VoidCallback onNext;

  const _MidGradeFeedback({required this.feedback, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final color = feedback.isCorrect ? LiteracyColors.correct : LiteracyColors.incorrect;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 8)],
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                feedback.isCorrect ? Icons.check_circle : Icons.cancel,
                color: color,
                size: 28,
              ),
              const SizedBox(width: 8),
              FuriganaText(
                feedback.mainText,
                style: TextStyle(
                  fontSize: LiteracyTypography.feedbackTextSize(GradeLevel.mid),
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          if (feedback.explanation != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: FuriganaText(
                feedback.explanation!, glossary: true,
                style: const TextStyle(fontSize: 14, color: Color(0xFF555555)),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(backgroundColor: color),
                child: const Text('次へ'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 高学年: 詳細解説 + 別解 + 同パターン問題リンク
class _HighGradeFeedback extends StatelessWidget {
  final LiteracyFeedbackContent feedback;
  final VoidCallback onNext;
  final VoidCallback? onShowRelated;

  const _HighGradeFeedback({
    required this.feedback,
    required this.onNext,
    this.onShowRelated,
  });

  @override
  Widget build(BuildContext context) {
    final color = feedback.isCorrect ? LiteracyColors.correct : LiteracyColors.incorrect;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            feedback.isCorrect ? '✓ 正解' : '✗ 不正解',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          FuriganaText(
            feedback.mainText,
            style: const TextStyle(fontSize: 14, color: Color(0xFF2C3E50)),
          ),
          if (feedback.explanation != null) ...[
            const SizedBox(height: 8),
            const Text(
              '解説',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            FuriganaText(
              feedback.explanation!, glossary: true,
              style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.5),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (feedback.relatedQuestionId != null && onShowRelated != null)
                TextButton.icon(
                  onPressed: onShowRelated,
                  icon: const Icon(Icons.link, size: 14),
                  label: const Text('同パターン', style: TextStyle(fontSize: 12)),
                ),
              const Spacer(),
              OutlinedButton(
                onPressed: onNext,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('次へ', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
