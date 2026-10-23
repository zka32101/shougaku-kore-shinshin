import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/models/story.dart';
import 'package:shougaku_kore_doutoku/utils/today_pick.dart';

Story _s(String id, int grade) => Story(
      id: id,
      title: id,
      theme: 'kindness',
      gradeLevel: grade,
      isPremium: false,
      durationSeconds: 60,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  final stories = [
    _s('a', 1),
    _s('b', 2),
    _s('c', 3),
    _s('d', 3),
    _s('e', 4),
    _s('f', 6),
  ];
  final day = DateTime(2026, 10, 23);

  test('子どもの学年帯のお話から選ぶ', () {
    final p = pickTodayStory(
        stories: stories, completedIds: const {}, grade: 3, date: day)!;
    expect(['c', 'd', 'e'], contains(p.story.id));
    expect(p.isReview, isFalse);
  });

  test('クリア済みは選ばない', () {
    for (var d = 0; d < 10; d++) {
      final p = pickTodayStory(
          stories: stories,
          completedIds: const {'c', 'd'},
          grade: 3,
          date: day.add(Duration(days: d)))!;
      expect(p.story.id, 'e');
    }
  });

  test('その学年帯をすべてクリアしていたら、復習として同じ学年帯から選ぶ', () {
    final p = pickTodayStory(
        stories: stories,
        completedIds: const {'c', 'd', 'e'},
        grade: 4,
        date: day)!;
    expect(p.isReview, isTrue);
    expect(['c', 'd', 'e'], contains(p.story.id));
  });

  test('同じ日なら同じお話。日が変わると順番に進む', () {
    String id(DateTime d) => pickTodayStory(
            stories: stories, completedIds: const {}, grade: 3, date: d)!
        .story
        .id;
    expect(id(day), id(DateTime(2026, 10, 23, 23, 59)));
    expect(id(day), isNot(id(day.add(const Duration(days: 1)))));
    // 3本を3日で一巡
    expect({for (var i = 0; i < 3; i++) id(day.add(Duration(days: i)))},
        {'c', 'd', 'e'});
  });

  test('読み込み順が違っても結果は同じ', () {
    final a = pickTodayStory(
        stories: stories, completedIds: const {}, grade: 3, date: day)!;
    final b = pickTodayStory(
        stories: stories.reversed.toList(),
        completedIds: const {},
        grade: 3,
        date: day)!;
    expect(a.story.id, b.story.id);
  });

  test('その学年帯のお話が無ければ全体から選ぶ。お話が無ければ null', () {
    final only = [_s('x', 6)];
    expect(
        pickTodayStory(
                stories: only, completedIds: const {}, grade: 1, date: day)!
            .story
            .id,
        'x');
    expect(
        pickTodayStory(
            stories: const [], completedIds: const {}, grade: 1, date: day),
        isNull);
  });
}
