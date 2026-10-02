import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../literacy_core/literacy_core.dart';
import '../data/taiku_questions.dart';
import '../taiku_app.dart';
import '../providers/child_profiles_provider.dart';
import '../providers/mistake_note_provider.dart';
import '../providers/taiku_providers.dart';
export '../providers/taiku_providers.dart' show reviewQuestionsOverrideProvider;

class MistakeNoteScreen extends ConsumerWidget {
  const MistakeNoteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grade = ref.watch(gradeLevelProvider);
    final profile = ref.watch(currentChildProfileProvider);
    final noteState = ref.watch(mistakeNoteProvider);
    final ids = profile != null ? (noteState[profile.id] ?? {}) : <String>{};

    final wrongQuestions = allStageQuestions
        .where((q) => ids.contains(q.id))
        .toList();

    final isLow = grade == GradeLevel.low;

    return Scaffold(
      backgroundColor: LiteracyColors.backgroundFor(grade),
      appBar: AppBar(
        backgroundColor: Colors.redAccent.shade700,
        title: Text(
          isLow ? 'まちがいノート' : 'まちがいノート',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (wrongQuestions.isNotEmpty && profile != null)
            TextButton(
              onPressed: () => _showClearDialog(context, ref, profile.id, isLow),
              child: const Text('リセット',
                  style: TextStyle(color: Colors.white70)),
            ),
        ],
      ),
      body: wrongQuestions.isEmpty
          ? _EmptyState(isLow: isLow)
          : Column(
              children: [
                _Header(
                  count: wrongQuestions.length,
                  isLow: isLow,
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: wrongQuestions.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final q = wrongQuestions[i];
                      return _MistakeCard(
                        question: q,
                        grade: grade,
                        onLearned: profile != null
                            ? () {
                                ref
                                    .read(mistakeNoteProvider.notifier)
                                    .markLearned(profile.id, q.id);
                              }
                            : null,
                      );
                    },
                  ),
                ),
                if (wrongQuestions.isNotEmpty)
                  _RetakeButton(
                    wrongQuestions: wrongQuestions,
                    grade: grade,
                  ),
              ],
            ),
    );
  }

  void _showClearDialog(
      BuildContext context, WidgetRef ref, String profileId, bool isLow) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isLow ? 'ぜんぶ けす？' : 'まちがいノートをリセット'),
        content: Text(isLow
            ? 'ぜんぶの まちがいを けしますか？'
            : 'すべての間違いを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(mistakeNoteProvider.notifier)
                  .clearAll(profileId);
              Navigator.pop(context);
            },
            child: Text(isLow ? 'けす' : '削除',
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int count;
  final bool isLow;
  const _Header({required this.count, required this.isLow});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: Colors.red.shade50,
      child: Row(
        children: [
          const Text('📝', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Text(
            isLow
                ? 'まちがえた もんだい：$count こ'
                : '間違えた問題：$count 問',
            style: TextStyle(
              fontSize: isLow ? 16 : 15,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MistakeCard extends StatelessWidget {
  final TaikuQuestion question;
  final GradeLevel grade;
  final VoidCallback? onLearned;

  const _MistakeCard({
    required this.question,
    required this.grade,
    this.onLearned,
  });

  @override
  Widget build(BuildContext context) {
    final isLow = grade == GradeLevel.low;
    final themeColor = TaikuColors.forTheme(question.theme);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.06),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    stageTitle[_stageNumber(question.stage)] ?? '',
                    style: TextStyle(
                        fontSize: 11,
                        color: themeColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                const Text('❌', style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              question.questionText,
              style: TextStyle(
                fontSize: isLow ? 15 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Text('✅ ',
                      style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(
                      question.choices[question.correctIndex],
                      style: TextStyle(
                        fontSize: isLow ? 14 : 13,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (onLearned case final fn?) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: fn,
                  icon: const Icon(Icons.check_circle_outline,
                      size: 16, color: Colors.green),
                  label: Text(
                    isLow ? 'おぼえた！' : '覚えた！',
                    style: const TextStyle(
                        color: Colors.green, fontSize: 13),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _stageNumber(LiteracyStage stage) {
    return int.tryParse(stage.name.replaceAll('stage', '')) ?? 1;
  }
}

class _RetakeButton extends ConsumerWidget {
  final List<TaikuQuestion> wrongQuestions;
  final GradeLevel grade;

  const _RetakeButton({
    required this.wrongQuestions,
    required this.grade,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () => _startRetake(context, ref),
          icon: const Icon(Icons.replay),
          label: Text(
            grade == GradeLevel.low
                ? 'もういちど ちょうせん！'
                : '間違えた問題を復習する',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ),
    );
  }

  void _startRetake(BuildContext context, WidgetRef ref) {
    ref.read(reviewQuestionsOverrideProvider.notifier).state = wrongQuestions;
    Navigator.of(context).pushNamed('/quiz');
  }
}

class _EmptyState extends StatelessWidget {
  final bool isLow;
  const _EmptyState({required this.isLow});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎉', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            isLow ? 'まちがいは ないよ！' : '間違いノートは空です',
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isLow
                ? 'ぜんもん せいかい！すごい！'
                : 'すべての問題を正解しています！',
            style:
                TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
