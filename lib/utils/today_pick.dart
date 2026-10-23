import '../models/story.dart';
import 'grade_band.dart';

/// 「きょうのおすすめ」のお話と、復習かどうか。
class TodayPick {
  final Story story;

  /// その学年帯のお話をすべてクリア済みで、もう一度おすすめするとき true
  final bool isReview;

  const TodayPick(this.story, {required this.isReview});
}

/// きょうのおすすめのお話を1つ選ぶ。
///
/// - 子どもの学年帯のお話を優先し、無ければ全部から選ぶ
/// - まだクリアしていないお話を優先し、全部クリア済みなら復習として選ぶ
/// - 同じ日なら同じお話（日付から決まる）。日が変わると順番に進む
/// - 候補をID順にそろえてから選ぶので、読み込み順に左右されない
TodayPick? pickTodayStory({
  required List<Story> stories,
  required Set<String> completedIds,
  required int grade,
  required DateTime date,
}) {
  final list = pickTodayCandidates(
    stories: stories,
    completedIds: completedIds,
    grade: grade,
    date: date,
    count: 1,
  );
  return list.isEmpty ? null : list.first;
}

/// 親子で選べるように、きょうの候補を最大 [count] 件つくる。
///
/// 先頭は [pickTodayStory] と同じお話。以降は同じ候補の中で順番に続く（重複しない）。
List<TodayPick> pickTodayCandidates({
  required List<Story> stories,
  required Set<String> completedIds,
  required int grade,
  required DateTime date,
  int count = 3,
}) {
  if (stories.isEmpty) return const [];

  final band = gradeBandOf(grade);
  var pool = [
    for (final s in stories)
      if (gradeBandOf(s.gradeLevel) == band) s,
  ];
  if (pool.isEmpty) pool = [...stories];

  final fresh = [
    for (final s in pool)
      if (!completedIds.contains(s.id)) s,
  ];
  final isReview = fresh.isEmpty;
  final candidates = isReview ? pool : fresh;
  candidates.sort((a, b) => a.id.compareTo(b.id));

  final day = DateTime.utc(date.year, date.month, date.day)
      .difference(DateTime.utc(2020, 1, 1))
      .inDays;
  final n = count < candidates.length ? count : candidates.length;
  return [
    for (var i = 0; i < n; i++)
      TodayPick(candidates[(day + i) % candidates.length], isReview: isReview),
  ];
}
