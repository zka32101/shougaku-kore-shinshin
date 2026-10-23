import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/story.dart';
import '../services/local_completion_store.dart';
import '../services/local_reflection_store.dart';
import '../utils/revisit_pick.dart';
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

/// 1週間以上前に「考えてみよう」を書いたお話から、もう一度考える1件。なければ null。
final revisitPickProvider = FutureProvider.autoDispose
    .family<RevisitPick?, String>((ref, childId) async {
  final list = await LocalReflectionStore.load(childId);
  return pickRevisit(reflections: list, now: DateTime.now());
});

/// 親子で選ぶ「きょうの候補」（先頭は [todayPickProvider] と同じお話）。
final todayCandidatesProvider = Provider.autoDispose<List<TodayPick>>((ref) {
  final child = ref.watch(selectedChildProvider).valueOrNull;
  if (child == null) return const [];
  final stories =
      ref.watch(allLocalStoriesProvider).valueOrNull ?? const <Story>[];
  final done =
      ref.watch(localCompletedStoryIdsProvider(child.id)).valueOrNull ??
          const <String>{};
  return pickTodayCandidates(
    stories: stories,
    completedIds: done,
    grade: child.grade,
    date: DateTime.now(),
  );
});
