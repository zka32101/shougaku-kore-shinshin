import '../services/local_reflection_store.dart';

/// 「もういちど考えてみよう」で出す1件。
class RevisitPick {
  final ReflectionEntry entry;

  /// 考えてから何日たったか
  final int daysAgo;

  const RevisitPick(this.entry, this.daysAgo);
}

/// 考えてから [minDays] 日以上たったお話の中から、その日に出す1件を選ぶ。
///
/// 同じ日なら同じ結果になる。[reflections] は同じお話について複数あっても構わない
/// （お話ごとに新しい記録だけを見る）。該当がなければ null。
RevisitPick? pickRevisit({
  required List<ReflectionEntry> reflections,
  required DateTime now,
  int minDays = 7,
}) {
  final latest = <String, ReflectionEntry>{};
  for (final r in reflections) {
    final cur = latest[r.storyId];
    if (cur == null || r.at.isAfter(cur.at)) latest[r.storyId] = r;
  }
  final today = DateTime(now.year, now.month, now.day);
  final candidates = <RevisitPick>[];
  for (final r in latest.values) {
    if (r.storyTitle.isEmpty) continue;
    final days = today.difference(DateTime(r.at.year, r.at.month, r.at.day)).inDays;
    if (days >= minDays) candidates.add(RevisitPick(r, days));
  }
  if (candidates.isEmpty) return null;
  candidates.sort((a, b) => a.entry.storyId.compareTo(b.entry.storyId));
  final dayIndex = today.difference(DateTime(2020)).inDays;
  return candidates[dayIndex % candidates.length];
}
