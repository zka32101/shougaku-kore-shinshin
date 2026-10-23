import '../services/local_reflection_store.dart';

/// 成長ノートの1か月ぶん。新しい記録が先。
class GrowthMonth {
  final int year;
  final int month;
  final List<ReflectionEntry> entries;

  const GrowthMonth(this.year, this.month, this.entries);
}

/// ふりかえりの記録を、月ごとにまとめる（新しい月が先、月の中も新しい順）。
List<GrowthMonth> groupReflectionsByMonth(List<ReflectionEntry> entries) {
  final sorted = [...entries]..sort((a, b) => b.at.compareTo(a.at));
  final result = <GrowthMonth>[];
  for (final e in sorted) {
    if (result.isNotEmpty &&
        result.last.year == e.at.year &&
        result.last.month == e.at.month) {
      result.last.entries.add(e);
    } else {
      result.add(GrowthMonth(e.at.year, e.at.month, [e]));
    }
  }
  return result;
}

/// 成長ノートの上に出す、まとめの数字。
class GrowthSummary {
  /// 読み終えたお話の数
  final int storiesRead;

  /// ふりかえり（気持ち・ひとこと）を書いた数
  final int reflections;

  /// ひとことを書いた数
  final int notes;

  const GrowthSummary({
    required this.storiesRead,
    required this.reflections,
    required this.notes,
  });
}

GrowthSummary summarizeGrowth({
  required int storiesRead,
  required List<ReflectionEntry> reflections,
}) =>
    GrowthSummary(
      storiesRead: storiesRead,
      reflections: reflections.length,
      notes: reflections.where((e) => (e.note ?? '').trim().isNotEmpty).length,
    );
