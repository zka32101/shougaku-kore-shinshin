import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/local_completion_store.dart';
import '../services/local_reflection_store.dart';
import '../utils/local_data_summary.dart';
import 'growth_note_provider.dart';
import 'today_pick_provider.dart';

/// 端末の中に残っているどうとくの記録の件数と期間（本文は読まない集計だけ）。
final localDataSummaryProvider = FutureProvider.autoDispose
    .family<LocalDataSummary, String>((ref, childId) async {
  return summarizeLocalData(
    completions: await LocalCompletionStore.load(childId),
    reflections: await LocalReflectionStore.load(childId),
  );
});

/// 端末の中のどうとくの記録（読んだお話・考えてみよう）を消して、画面の表示も更新する。
Future<void> deleteLocalDoutokuData(WidgetRef ref, String childId) async {
  await LocalCompletionStore.clear(childId);
  await LocalReflectionStore.clear(childId);
  ref.invalidate(localDataSummaryProvider(childId));
  ref.invalidate(localCompletedStoryIdsProvider(childId));
  ref.invalidate(growthNoteProvider(childId));
  ref.invalidate(revisitPickProvider(childId));
}
