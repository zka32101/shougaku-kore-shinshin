import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/local_completion_store.dart';
import '../services/local_reflection_store.dart';
import '../utils/family_talk_prompts.dart';

/// 保護者向け「おうちで話してみよう」：問いと、お子さんのひとこと。
class FamilyTalk {
  final List<FamilyPrompt> prompts;

  /// その月の「考えてみよう」のひとこと（新しい順）
  final List<ReflectionEntry> notes;

  /// その月に読んだお話の数と、テーマごとの数（共有用の文章に使う）
  final int storyCount;
  final Map<String, int> themeCounts;

  const FamilyTalk({
    required this.prompts,
    required this.notes,
    this.storyCount = 0,
    this.themeCounts = const {},
  });
}

/// 選んだ月の完了記録・振り返りから、問いを組み立てる。端末内のデータだけを使う。
final familyTalkProvider = FutureProvider.autoDispose
    .family<FamilyTalk, ({String childId, int year, int month})>(
        (ref, args) async {
  bool inMonth(DateTime d) => d.year == args.year && d.month == args.month;

  final completions = await LocalCompletionStore.load(args.childId);
  final themeCounts = <String, int>{};
  var storyCount = 0;
  for (final p in completions) {
    if (!inMonth(p.recordedAt)) continue;
    storyCount++;
    final v = p.virtue;
    if (v == null) continue;
    themeCounts[v] = (themeCounts[v] ?? 0) + 1;
  }

  final reflections = (await LocalReflectionStore.load(args.childId))
      .where((r) => inMonth(r.at))
      .toList();

  return FamilyTalk(
    storyCount: storyCount,
    themeCounts: themeCounts,
    prompts: buildFamilyPrompts(
      themeCounts: themeCounts,
      reflections: reflections,
      year: args.year,
      month: args.month,
    ),
    notes: [
      for (final r in reflections)
        if ((r.note ?? '').isNotEmpty) r,
    ].take(3).toList(),
  );
});
