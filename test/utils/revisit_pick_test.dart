import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/services/local_reflection_store.dart';
import 'package:shougaku_kore_doutoku/utils/revisit_pick.dart';

ReflectionEntry _e(String id, DateTime at, {String title = 'お話'}) =>
    ReflectionEntry(
      storyId: id,
      storyTitle: title,
      theme: 'kindness',
      choiceId: 'c',
      feeling: 'happy',
      note: null,
      at: at,
    );

void main() {
  final now = DateTime(2026, 10, 23, 9);

  test('7日たっていなければ出さない', () {
    expect(pickRevisit(reflections: [_e('a', DateTime(2026, 10, 17))], now: now),
        isNull);
    expect(pickRevisit(reflections: const [], now: now), isNull);
  });

  test('7日以上たったお話を出し、日数を返す', () {
    final p =
        pickRevisit(reflections: [_e('a', DateTime(2026, 10, 16, 23))], now: now);
    expect(p!.entry.storyId, 'a');
    expect(p.daysAgo, 7);
  });

  test('同じお話は新しい記録で判断する', () {
    final p = pickRevisit(reflections: [
      _e('a', DateTime(2026, 9, 1)),
      _e('a', DateTime(2026, 10, 22)),
    ], now: now);
    expect(p, isNull);
  });

  test('同じ日は同じ結果、日が変わると巡回する', () {
    final list = [
      _e('a', DateTime(2026, 9, 1)),
      _e('b', DateTime(2026, 9, 2)),
    ];
    final d1 = pickRevisit(reflections: list, now: now)!.entry.storyId;
    expect(pickRevisit(reflections: list, now: now)!.entry.storyId, d1);
    final d2 = pickRevisit(
            reflections: list, now: now.add(const Duration(days: 1)))!
        .entry
        .storyId;
    expect(d2, isNot(d1));
  });
}
