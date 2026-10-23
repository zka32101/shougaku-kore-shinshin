import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shougaku_kore_doutoku/models/progress.dart';
import 'package:shougaku_kore_doutoku/services/local_completion_store.dart';
import 'package:shougaku_kore_doutoku/services/local_reflection_store.dart';
import 'package:shougaku_kore_doutoku/utils/local_data_summary.dart';

Progress _p(String id, DateTime at) => Progress(
      id: id,
      childId: 'c',
      storyId: id,
      action: 'story_completed',
      virtue: 'kindness',
      completionCount: 1,
      recordedAt: at,
    );

ReflectionEntry _r(String id, DateTime at) => ReflectionEntry(
      storyId: id,
      storyTitle: 'お話$id',
      theme: 'kindness',
      choiceId: 'c',
      feeling: 'happy',
      note: 'ひみつのひとこと',
      at: at,
    );

void main() {
  test('件数と、いちばん古い／新しい日付をまとめる', () {
    final s = summarizeLocalData(
      completions: [_p('a', DateTime(2026, 9, 3)), _p('b', DateTime(2026, 10, 1))],
      reflections: [_r('a', DateTime(2026, 8, 20)), _r('b', DateTime(2026, 10, 5))],
    );
    expect(s.storyCount, 2);
    expect(s.reflectionCount, 2);
    expect(s.firstAt, DateTime(2026, 8, 20));
    expect(s.lastAt, DateTime(2026, 10, 5));
    expect(s.isEmpty, isFalse);
  });

  test('記録が無ければ空で、日付は null', () {
    final s = summarizeLocalData(completions: const [], reflections: const []);
    expect(s.isEmpty, isTrue);
    expect(s.firstAt, isNull);
    expect(s.lastAt, isNull);
  });

  test('clear で、その子の記録だけが消える', () async {
    SharedPreferences.setMockInitialValues({});
    await LocalCompletionStore.record(
        childId: 'c1', storyId: 's1', theme: 'kindness');
    await LocalCompletionStore.record(
        childId: 'c2', storyId: 's1', theme: 'kindness');
    await LocalReflectionStore.record(childId: 'c1', entry: _r('s1', DateTime(2026)));
    await LocalReflectionStore.record(childId: 'c2', entry: _r('s1', DateTime(2026)));

    await LocalCompletionStore.clear('c1');
    await LocalReflectionStore.clear('c1');

    expect(await LocalCompletionStore.load('c1'), isEmpty);
    expect(await LocalReflectionStore.load('c1'), isEmpty);
    expect(await LocalCompletionStore.load('c2'), hasLength(1));
    expect(await LocalReflectionStore.load('c2'), hasLength(1));
  });
}
