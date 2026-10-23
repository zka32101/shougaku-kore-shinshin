import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/story.dart';
import '../screens/library/library_screen.dart' show libraryCompletedIdsProvider;
import '../utils/today_pick.dart';
import 'child_provider.dart';
import 'story_provider.dart';

/// 選んでいる子どものための「きょうのおすすめ」。子どもが未選択・読み込み中は null。
final todayPickProvider = Provider.autoDispose<TodayPick?>((ref) {
  final child = ref.watch(selectedChildProvider).valueOrNull;
  if (child == null) return null;
  final stories = ref.watch(allLocalStoriesProvider).valueOrNull ?? const <Story>[];
  final done = ref.watch(libraryCompletedIdsProvider);
  return pickTodayStory(
    stories: stories,
    completedIds: done,
    grade: child.grade,
    date: DateTime.now(),
  );
});
