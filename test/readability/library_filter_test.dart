import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/models/story.dart';
import 'package:shougaku_kore_doutoku/screens/library/library_screen.dart';
import 'package:shougaku_kore_doutoku/utils/grade_band.dart';

Story _s(String id, String theme, int grade) => Story(
      id: id,
      title: id,
      theme: theme,
      gradeLevel: grade,
      isPremium: false,
      durationSeconds: 60,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  test('学年帯の判定', () {
    expect(gradeBandOf(1), GradeBand.low);
    expect(gradeBandOf(2), GradeBand.low);
    expect(gradeBandOf(3), GradeBand.mid);
    expect(gradeBandOf(4), GradeBand.mid);
    expect(gradeBandOf(5), GradeBand.high);
    expect(gradeBandLabel(6), '高学年');
  });

  test('ストーリーの絞り込みと学年順', () {
    final all = [
      _s('a', 'kindness', 5),
      _s('b', 'honesty', 1),
      _s('c', 'kindness', 3),
    ];
    expect(filterStories(all).map((e) => e.id), ['b', 'c', 'a']);
    expect(filterStories(all, theme: 'kindness').map((e) => e.id), ['c', 'a']);
    expect(filterStories(all, band: GradeBand.low).map((e) => e.id), ['b']);
    expect(
        filterStories(all, theme: 'kindness', band: GradeBand.high)
            .map((e) => e.id),
        ['a']);
  });
}
