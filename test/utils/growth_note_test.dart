import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/services/local_reflection_store.dart';
import 'package:shougaku_kore_doutoku/utils/growth_note.dart';

ReflectionEntry _e(String id, DateTime at, {String? feeling, String? note}) =>
    ReflectionEntry(
      storyId: id,
      storyTitle: 'お話$id',
      theme: 'kindness',
      choiceId: 'c',
      feeling: feeling,
      note: note,
      at: at,
    );

void main() {
  test('月ごとにまとめ、新しい月・新しい記録が先になる', () {
    final months = groupReflectionsByMonth([
      _e('a', DateTime(2026, 9, 3), feeling: 'sad'),
      _e('b', DateTime(2026, 10, 1), feeling: 'happy'),
      _e('c', DateTime(2026, 10, 20), note: 'ひとこと'),
      _e('d', DateTime(2025, 12, 31), feeling: 'shy'),
    ]);
    expect(months.map((m) => '${m.year}-${m.month}'),
        ['2026-10', '2026-9', '2025-12']);
    expect(months.first.entries.map((e) => e.storyId), ['c', 'b']);
  });

  test('記録が無ければ空', () {
    expect(groupReflectionsByMonth(const []), isEmpty);
  });

  test('まとめの数字：読んだお話・考えたこと・ひとことの数', () {
    final s = summarizeGrowth(storiesRead: 5, reflections: [
      _e('a', DateTime(2026, 10, 1), feeling: 'sad'),
      _e('b', DateTime(2026, 10, 2), note: 'あやまる'),
      _e('c', DateTime(2026, 10, 3), feeling: 'happy', note: '  '),
    ]);
    expect(s.storiesRead, 5);
    expect(s.reflections, 3);
    expect(s.notes, 1);
  });

  test('元のリストを書きかえない', () {
    final src = [
      _e('a', DateTime(2026, 9, 3), feeling: 'sad'),
      _e('b', DateTime(2026, 10, 1), feeling: 'happy'),
    ];
    groupReflectionsByMonth(src);
    expect(src.map((e) => e.storyId), ['a', 'b']);
  });
}
