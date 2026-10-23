import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shougaku_kore_doutoku/services/local_reflection_store.dart';

ReflectionEntry _e(String storyId,
        {String? feeling, String? note, DateTime? at}) =>
    ReflectionEntry(
      storyId: storyId,
      storyTitle: 'タイトル$storyId',
      theme: 'kindness',
      choiceId: 'c1',
      feeling: feeling,
      note: note,
      at: at ?? DateTime(2026, 10, 1),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('感情もひとことも無ければ保存しない', () async {
    await LocalReflectionStore.record(childId: 'c', entry: _e('s1'));
    await LocalReflectionStore.record(
        childId: 'c', entry: _e('s2', note: '   '));
    expect(await LocalReflectionStore.load('c'), isEmpty);
  });

  test('保存して新しい順に読める。同じお話は置き換わる', () async {
    await LocalReflectionStore.record(
        childId: 'c',
        entry: _e('s1', feeling: 'sad', at: DateTime(2026, 10, 1)));
    await LocalReflectionStore.record(
        childId: 'c',
        entry: _e('s2', note: 'あやまる', at: DateTime(2026, 10, 3)));
    await LocalReflectionStore.record(
        childId: 'c',
        entry: _e('s1', feeling: 'happy', at: DateTime(2026, 10, 5)));
    final list = await LocalReflectionStore.load('c');
    expect(list.map((e) => e.storyId), ['s1', 's2']);
    expect(list.first.feeling, 'happy');
    expect(list.last.note, 'あやまる');
  });

  test('ひとことは80文字までに切り、子どもごとに別々に保存する', () async {
    await LocalReflectionStore.record(
        childId: 'a', entry: _e('s1', note: 'あ' * 200));
    expect((await LocalReflectionStore.load('a')).single.note!.length, 80);
    expect(await LocalReflectionStore.load('b'), isEmpty);
  });

  test('壊れたデータでも落ちずに空として扱う', () async {
    SharedPreferences.setMockInitialValues(
        {'local_reflections_c': 'not json'});
    expect(await LocalReflectionStore.load('c'), isEmpty);
  });
}
