import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'child_profiles_provider.dart';

const _kKey = 'taiku_mistake_notes';

class MistakeNoteNotifier
    extends StateNotifier<Map<String, Set<String>>> {
  MistakeNoteNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null) return;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    state = decoded.map(
      (k, v) => MapEntry(k, Set<String>.from(v as List)),
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = state.map((k, v) => MapEntry(k, v.toList()));
    await prefs.setString(_kKey, jsonEncode(json));
  }

  void addWrongAnswer(String profileId, String questionId) {
    final updated = Map<String, Set<String>>.from(state);
    final set = Set<String>.from(updated[profileId] ?? {});
    set.add(questionId);
    updated[profileId] = set;
    state = updated;
    _save();
  }

  void markLearned(String profileId, String questionId) {
    final updated = Map<String, Set<String>>.from(state);
    final set = Set<String>.from(updated[profileId] ?? {});
    set.remove(questionId);
    updated[profileId] = set;
    state = updated;
    _save();
  }

  void clearAll(String profileId) {
    final updated = Map<String, Set<String>>.from(state);
    updated[profileId] = {};
    state = updated;
    _save();
  }

  Set<String> getIds(String profileId) {
    return state[profileId] ?? {};
  }
}

final mistakeNoteProvider =
    StateNotifierProvider<MistakeNoteNotifier, Map<String, Set<String>>>(
  (ref) => MistakeNoteNotifier(),
);

final mistakeCountProvider = Provider.family<int, String>((ref, profileId) {
  return ref.watch(mistakeNoteProvider)[profileId]?.length ?? 0;
});

final currentMistakeCountProvider = Provider<int>((ref) {
  final profile = ref.watch(currentChildProfileProvider);
  if (profile == null) return 0;
  return ref.watch(mistakeCountProvider(profile.id));
});
