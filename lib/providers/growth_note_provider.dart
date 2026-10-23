import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/local_completion_store.dart';
import '../services/local_reflection_store.dart';
import '../utils/growth_note.dart';

/// 成長ノートの中身。端末内のデータだけを使う（通信しない）。
class GrowthNoteData {
  final GrowthSummary summary;
  final List<GrowthMonth> months;

  const GrowthNoteData({required this.summary, required this.months});
}

/// 子どもごとの成長ノート。お話を読み終えたあと／ふりかえりを書いたあとは invalidate して更新する。
final growthNoteProvider = FutureProvider.autoDispose
    .family<GrowthNoteData, String>((ref, childId) async {
  final completions = await LocalCompletionStore.load(childId);
  final reflections = await LocalReflectionStore.load(childId);
  final storyIds = {
    for (final p in completions)
      if (p.storyId != null) p.storyId!,
  };
  return GrowthNoteData(
    summary: summarizeGrowth(
      storiesRead: storyIds.length,
      reflections: reflections,
    ),
    months: groupReflectionsByMonth(reflections),
  );
});
