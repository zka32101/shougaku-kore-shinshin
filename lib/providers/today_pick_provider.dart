import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/story.dart';
import '../services/local_completion_store.dart';
import '../utils/today_pick.dart';
import 'child_provider.dart';
import 'story_provider.dart';

/// 端末内に記録した、クリア済みのお話ID。
///
/// ホームに出す「きょうのおすすめ」用に、サーバーへ問い合わせない軽い読み込みにしてある
/// （ホームを開くたびに通信が走らない／オフラインでも動く）。
/// お話をクリアしたあとは、この値を invalidate して更新する。
final localCompletedStoryIdsProvider = FutureProvider.autoDispose
    .family<Set<String>, String>((ref, childId) async {
  final list = await LocalCompletionStore.load(childId);
  return {
    for (final p in list)
      if (p.storyId != null) p.storyId!,
  };
});

/// 選んでいる子どものための「きょうのおすすめ」。子どもが未選択・読み込み中は null。
final todayPickProvider = Provider.autoDispose<TodayPick?>((ref) {
  final child = ref.watch(selectedChildProvider).valueOrNull;
  if (child == null) return null;
  final stories =
      ref.watch(allLocalStoriesProvider).valueOrNull ?? const <Story>[];
  final done =
      ref.watch(localCompletedStoryIdsProvider(child.id)).valueOrNull ??
          const <String>{};
  return pickTodayStory(
    stories: stories,
    completedIds: done,
    grade: child.grade,
    date: DateTime.now(),
  );
});
