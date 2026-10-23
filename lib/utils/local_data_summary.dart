import '../models/progress.dart';
import '../services/local_reflection_store.dart';

/// 端末の中に残っているどうとくの記録の「件数と期間」。
///
/// 保護者が確認するためのもの。お子さんが書いたひとこと本文や、選んだ気持ちの中身は含めない。
class LocalDataSummary {
  /// 読んだお話の数
  final int storyCount;

  /// 「考えてみよう」の記録の数（気持ちかひとことのどちらかがあるもの）
  final int reflectionCount;

  /// いちばん古い記録と、いちばん新しい記録の日付。記録が無ければ null
  final DateTime? firstAt;
  final DateTime? lastAt;

  const LocalDataSummary({
    required this.storyCount,
    required this.reflectionCount,
    required this.firstAt,
    required this.lastAt,
  });

  bool get isEmpty => storyCount == 0 && reflectionCount == 0;
}

LocalDataSummary summarizeLocalData({
  required List<Progress> completions,
  required List<ReflectionEntry> reflections,
}) {
  final dates = <DateTime>[
    for (final p in completions) p.recordedAt,
    for (final r in reflections) r.at,
  ]..sort();
  return LocalDataSummary(
    storyCount: completions.length,
    reflectionCount: reflections.length,
    firstAt: dates.isEmpty ? null : dates.first,
    lastAt: dates.isEmpty ? null : dates.last,
  );
}
