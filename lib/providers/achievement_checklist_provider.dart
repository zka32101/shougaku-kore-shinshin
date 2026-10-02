import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'child_provider.dart';

/// 子どもごとの「できたこと」チェック状態（チェック済みアイテムIDの集合）を
/// 端末内(SharedPreferences)に保存するノティファイアー
class AchievementChecklistNotifier extends StateNotifier<Set<String>> {
  AchievementChecklistNotifier(this._childId) : super({}) {
    _load();
  }

  final String _childId;
  String get _storageKey => 'achievement_checklist_$_childId';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return;
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      state = decoded.map((e) => e as String).toSet();
    } catch (_) {
      // 壊れたデータは無視して空の状態を維持
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state.toList()));
  }

  Future<void> toggle(String itemId) async {
    final updated = {...state};
    if (updated.contains(itemId)) {
      updated.remove(itemId);
    } else {
      updated.add(itemId);
    }
    state = updated;
    await _save();
  }

  bool isChecked(String itemId) => state.contains(itemId);
}

/// 現在選択中の子どものチェックリスト状態
final achievementChecklistProvider = StateNotifierProvider.autoDispose<
    AchievementChecklistNotifier, Set<String>>((ref) {
  final childId = ref.watch(currentChildIdProvider) ?? 'default';
  return AchievementChecklistNotifier(childId);
});
