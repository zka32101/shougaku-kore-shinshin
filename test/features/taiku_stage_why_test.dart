import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/features/taiku/data/stage_why.dart';
import 'package:shougaku_kore_doutoku/features/taiku/data/taiku_questions.dart';

void main() {
  test('全ステージ(1〜35)に「なぜ大切か」の説明がある', () {
    for (var s = 1; s <= 35; s++) {
      final why = kStageWhy[s];
      expect(why, isNotNull, reason: 'stage $s');
      expect(why!.$1.length, greaterThan(20), reason: 'stage $s 低学年');
      expect(why.$2.length, greaterThan(40), reason: 'stage $s 中高学年');
    }
  });

  test('SNSの注意点は低学年・中高学年の両方があり、対象ステージは実在する', () {
    expect(kSnsCautions, isNotEmpty);
    for (final c in kSnsCautions) {
      expect(c.$1.trim(), isNotEmpty);
      expect(c.$2.trim(), isNotEmpty);
    }
    for (final s in kSnsCautionStages) {
      expect(s, inInclusiveRange(1, 35));
    }
  });

  test('クイズの文章に難しい略語(WHO)が残っていない', () {
    for (var s = 1; s <= 35; s++) {
      for (final q in getQuestionsForStage(s)) {
        final all = [
          q.questionText,
          q.feedbackCorrect,
          q.feedbackIncorrect,
          q.hintText ?? '',
          q.explanationDetail ?? '',
          ...q.choices,
        ].join('\n');
        expect(all.contains('WHO'), isFalse, reason: q.id);
      }
    }
  });

  test('「これ犯罪かも？」「相手の心を傷つけるかも？」の項目と対象ステージ', () {
    for (final list in [kCrimeChecks, kHeartChecks, kQuestionAdultChecks]) {
      expect(list.length, greaterThanOrEqualTo(6));
      for (final c in list) {
        expect(c.lowAction.trim(), isNotEmpty);
        expect(c.highAction.trim(), isNotEmpty);
        expect(c.lowWhy.trim(), isNotEmpty);
        expect(c.highWhy.trim(), isNotEmpty);
      }
    }
    for (final s in {...kCrimeCheckStages, ...kHeartCheckStages, ...kQuestionAdultStages}) {
      expect(s, inInclusiveRange(1, 35));
    }
  });
}
