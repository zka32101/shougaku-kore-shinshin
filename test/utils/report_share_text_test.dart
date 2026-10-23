import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/utils/family_talk_prompts.dart';
import 'package:shougaku_kore_doutoku/utils/report_share_text.dart';

String _label(String t) => {'kindness': '思いやり', 'honesty': '正直'}[t] ?? t;

void main() {
  test('年月・お話の数・よく読んだテーマ・問いだけを入れる', () {
    final text = buildReportShareText(
      year: 2026,
      month: 10,
      storyCount: 5,
      themeCounts: {'honesty': 2, 'kindness': 3},
      prompts: const [FamilyPrompt('今日いちばん楽しかったことは何？')],
      themeLabel: _label,
    );
    expect(text, contains('2026年10月'));
    expect(text, contains('読んだお話：5話'));
    expect(text, contains('よく読んだテーマ：思いやり、正直'));
    expect(text, contains('1. 今日いちばん楽しかったことは何？'));
  });

  test('お話がなければテーマは書かない。問いが無ければ問いの欄も出さない', () {
    final text = buildReportShareText(
      year: 2026,
      month: 1,
      storyCount: 0,
      themeCounts: const {},
      prompts: const [],
      themeLabel: _label,
    );
    expect(text, '【小学コレ！ 2026年1月のようす】\n読んだお話：0話');
  });

  test('テーマは多い順に最大3つまで', () {
    final text = buildReportShareText(
      year: 2026,
      month: 3,
      storyCount: 10,
      themeCounts: {'a': 1, 'b': 4, 'c': 3, 'd': 2},
      prompts: const [],
      themeLabel: (t) => t,
    );
    expect(text, contains('よく読んだテーマ：b、c、d'));
    expect(text, isNot(contains('、a')));
  });
}
