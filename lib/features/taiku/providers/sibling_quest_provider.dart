import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/sibling_quest.dart';
import '../data/child_profile.dart';
import 'child_profiles_provider.dart';

final siblingQuestProvider =
    StateNotifierProvider<SiblingQuestNotifier, List<SiblingQuest>>((ref) {
  final profiles = ref.watch(childProfilesProvider);
  return SiblingQuestNotifier(profiles);
});

class SiblingQuestNotifier extends StateNotifier<List<SiblingQuest>> {
  static const _kKey = 'taiku_sibling_quests';
  final ChildProfilesState _profiles;

  SiblingQuestNotifier(this._profiles) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_kKey);
    if (json == null) {
      if (_profiles.profiles.length >= 2) {
        await _generateInitialQuests();
      }
    } else {
      final list = (jsonDecode(json) as List)
          .cast<Map<String, dynamic>>()
          .map(SiblingQuest.fromJson)
          .toList();
      state = list;
    }
  }

  Future<void> _generateInitialQuests() async {
    final profileIds = _profiles.profiles.map((p) => p.id).toList();
    final now = DateTime.now().millisecondsSinceEpoch;
    final quests = kSiblingQuestTemplates.take(2).toList().asMap().entries.map((e) {
      final t = e.value;
      final progress = {for (final id in profileIds) id: 0};
      return SiblingQuest(
        id: '${now}_${e.key}',
        emoji: t['emoji'] as String,
        title: t['title'] as String,
        description: t['description'] as String,
        themeKey: t['themeKey'] as String,
        targetCount: t['targetCount'] as int,
        progress: progress,
        completed: false,
        createdAt: DateTime.now(),
      );
    }).toList();
    state = quests;
    await _save();
  }

  Future<void> addProgress(String profileId, String themeKey) async {
    state = state.map((q) {
      if (q.themeKey != themeKey || q.completed) return q;
      final newProgress = Map<String, int>.from(q.progress);
      newProgress[profileId] = (newProgress[profileId] ?? 0) + 1;
      final isCompleted =
          newProgress.values.every((v) => v >= q.targetCount);
      return q.copyWith(
        progress: newProgress,
        completed: isCompleted,
        completedAt: isCompleted ? DateTime.now() : null,
      );
    }).toList();
    await _save();
  }

  Future<void> resetQuest(String questId) async {
    state = state.map((q) {
      if (q.id != questId) return q;
      final resetProgress = {for (final k in q.progress.keys) k: 0};
      return q.copyWith(progress: resetProgress, completed: false);
    }).toList();
    await _save();
  }

  Future<void> generateNewQuests() async {
    await _generateInitialQuests();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kKey, jsonEncode(state.map((q) => q.toJson()).toList()));
  }
}
