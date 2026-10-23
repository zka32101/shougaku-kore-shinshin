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
  if (stories.isEmpty) return null;

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
  return TodayPick(candidates[day % candidates.length], isReview: isReview);
}
