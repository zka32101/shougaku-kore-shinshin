import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/features/literacy_core/literacy_core.dart';
import 'package:shougaku_kore_doutoku/features/taiku/data/taiku_questions.dart';

void main() {
  final originals = <TaikuQuestion>[
    for (var s = 1; s <= 35; s++) ...getQuestionsForStage(s),
  ];

  test('there are many questions to check', () {
    expect(originals.length, greaterThan(400));
  });

  test('shuffling keeps the correct option identity (text) for every question',
      () {
    for (final q in originals) {
      for (final seed in [1, 2, 3]) {
        final sh = q.withShuffledChoices(Random(seed));
        final correctText = q.choices[q.correctIndex];
        expect(sh.choices[sh.correctIndex], correctText, reason: q.id);
        expect(sh.checkCorrect(sh.choices.indexOf(correctText)), isTrue);
        expect([...sh.choices]..sort(), [...q.choices]..sort(),
            reason: '${q.id} keeps the same options');
      }
    }
  });

  test('correct answer position is roughly uniform (no index > 40%)', () {
    for (final seed in [11, 222, 3333]) {
      final counts = <int, int>{};
      var total = 0;
      for (final q in originals) {
        final sh = shuffledForDisplay(q, seed: seed);
        counts[sh.correctIndex] = (counts[sh.correctIndex] ?? 0) + 1;
        total++;
      }
      for (final e in counts.entries) {
        expect(e.value / total, lessThan(0.40),
            reason: 'seed $seed: index ${e.key} has ${e.value}/$total');
      }
    }
  });

  test('display order is stable for the same seed and question', () {
    final q = originals.first;
    final a = shuffledForDisplay(q, seed: 5);
    final b = shuffledForDisplay(q, seed: 5);
    expect(a.choices, b.choices);
    expect(a.correctIndex, b.correctIndex);
  });

  test('questions that refer to other options keep their order', () {
    const q = TaikuQuestion(
      id: 'x',
      stage: LiteracyStage.stage1,
      gradeLevel: GradeLevel.low,
      contentType: ContentLiteracyType.fundamental,
      difficultyRank: 1,
      questionText: 'q',
      choices: ['A', 'B', 'どちらも', 'D'],
      correctIndex: 2,
      feedbackCorrect: 'ok',
      feedbackIncorrect: 'ng',
      theme: 'sports',
    );
    expect(q.withShuffledChoices(Random(1)).choices, q.choices);
  });
}
