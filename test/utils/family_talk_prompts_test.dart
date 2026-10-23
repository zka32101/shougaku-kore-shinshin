import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/services/local_reflection_store.dart';
import 'package:shougaku_kore_doutoku/utils/family_talk_prompts.dart';

void main() {
  test('どのテーマにも3つずつ問いがあり、全般の問いもある', () {
    for (final t in [
      'kindness',
      'honesty',
      'responsibility',
      'courage',
      'respect',
      'cooperation',
    ]) {
      expect(kFamilyPromptsByTheme[t], hasLength(3), reason: t);
    }
    expect(kFamilyGeneralPrompts, isNotEmpty);
  });

  test('読んだお話が多いテーマの問いから出る', () {
    final p = buildFamilyPrompts(
      themeCounts: {'honesty': 1, 'courage': 4, 'kindness': 2},
      reflections: const [],
      year: 2026,
      month: 10,
    );
    expect(p.map((e) => e.theme), ['courage', 'kindness', 'honesty']);
    expect(p, hasLength(3));
  });

  test('お話を読んでいない月は全般の問いで3つ埋める', () {
    final p = buildFamilyPrompts(
      themeCounts: const {},
      reflections: const [],
      year: 2026,
      month: 10,
    );
    expect(p, hasLength(3));
    expect(p.every((e) => e.theme == null), isTrue);
    expect(p.map((e) => e.question).toSet(), hasLength(3));
  });

  test('同じ入力なら同じ結果。月が変わると同じテーマでも別の問いになる', () {
    List<String> q(int month) => buildFamilyPrompts(
          themeCounts: {'honesty': 1},
          reflections: const [],
          year: 2026,
          month: month,
        ).map((e) => e.question).toList();
    expect(q(10), q(10));
    expect(q(10).first, isNot(q(11).first));
  });

  test('お子さんが選んだ相手の気持ちから、理由をたずねる問いを先頭に出す', () {
    final p = buildFamilyPrompts(
      themeCounts: {'kindness': 1},
      reflections: [
        ReflectionEntry(
          storyId: 's1',
          storyTitle: 'ともだちのかさ',
          theme: 'kindness',
          choiceId: 'c1',
          feeling: 'sad',
          note: null,
          at: DateTime(2026, 10, 2),
        ),
      ],
      year: 2026,
      month: 10,
    );
    expect(p.first.question, contains('ともだちのかさ'));
    expect(p.first.question, contains('かなしい'));
    expect(p, hasLength(3));
  });

  test('問いは limit を超えない', () {
    final p = buildFamilyPrompts(
      themeCounts: {
        'kindness': 1,
        'honesty': 1,
        'courage': 1,
        'respect': 1,
      },
      reflections: const [],
      year: 2026,
      month: 10,
      limit: 2,
    );
    expect(p, hasLength(2));
  });
}
