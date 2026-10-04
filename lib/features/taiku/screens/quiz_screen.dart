import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../literacy_core/literacy_core.dart';
import '../data/taiku_questions.dart';
import '../taiku_app.dart';
import '../providers/child_profiles_provider.dart';
import '../providers/mistake_note_provider.dart';
import '../providers/taiku_providers.dart';

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key});

  /// クイズ途中で抜けるときの確認（誤タップで進み具合が消えないように）。
  Future<void> _confirmExit(BuildContext context) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('クイズをやめる？'),
        content: const Text('やめると、ここまでの答えはなくなります。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('つづける'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('やめる'),
          ),
        ],
      ),
    );
    if (leave == true && context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grade = ref.watch(gradeLevelProvider);
    final stage = ref.watch(currentStageProvider);
    final quiz = ref.watch(quizNotifierProvider);
    final theme = stageThemes[stage] ?? 'sports';
    final color = TaikuColors.forTheme(theme);

    if (quiz.isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/result');
      });
      return const SizedBox.shrink();
    }

    final question = quiz.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    final total = quiz.questions.length;
    final current = quiz.currentIndex + 1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit(context);
      },
      child: Scaffold(
        backgroundColor: LiteracyColors.backgroundFor(grade),
        appBar: AppBar(
          backgroundColor: color,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => _confirmExit(context),
          ),
          title: Row(
            children: [
              Text(
                stageEmoji[stage] ?? '🏃',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stageTitle[stage] ?? 'ステージ$stage',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(6),
            child: LinearProgressIndicator(
              value: current / total,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 6,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(grade == GradeLevel.low ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$current / $total もん',
                  style: TextStyle(
                    fontSize: grade == GradeLevel.low ? 16 : 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        LiteracyQuestionCard(
                          question: question,
                          selectedIndex: quiz.selectedChoice,
                          isAnswered: quiz.isAnswered,
                          onChoiceSelected: (i) {
                            ref
                                .read(quizNotifierProvider.notifier)
                                .selectChoice(i);
                          },
                        ),
                        if (quiz.isAnswered) ...[
                          const SizedBox(height: 16),
                          LiteracyFeedbackWidget(
                            feedback: question.feedbackFor(
                              quiz.selectedChoice == question.correctIndex,
                            ),
                            onNext: () {
                              final isCorrect =
                                  quiz.selectedChoice == question.correctIndex;
                              if (!isCorrect) {
                                final profileId = ref
                                    .read(currentChildProfileProvider)
                                    ?.id;
                                if (profileId != null) {
                                  ref
                                      .read(mistakeNoteProvider.notifier)
                                      .addWrongAnswer(profileId, question.id);
                                }
                              }
                              ref
                                  .read(quizNotifierProvider.notifier)
                                  .nextQuestion();
                              ref
                                  .read(taikuProgressProvider.notifier)
                                  .recordAnswer(
                                    stageNumber: stage,
                                    isCorrect: isCorrect,
                                    grade: grade,
                                  );
                            },
                          ),
                        ],
                      ],
                    ),
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
