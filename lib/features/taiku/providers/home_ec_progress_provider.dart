import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'child_profiles_provider.dart';

/// 家庭科アクティビティの完了状態を管理する。
/// キーは既存のローカル保存形式に合わせて "$topicId-$activityId"（例: "HomeEcTopic.tidying-sort"）。
final homeEcProgressProvider =
    StateNotifierProvider<HomeEcProgressNotifier, AsyncValue<Map<String, bool>>>((ref) {
  return HomeEcProgressNotifier(ref);
});

class HomeEcProgressNotifier extends StateNotifier<AsyncValue<Map<String, bool>>> {
  HomeEcProgressNotifier(this.ref) : super(const AsyncValue.loading()) {
    _init();
  }

  final Ref ref;
  static const _localKeyPrefix = 'HomeEcTopic.';

  String get _userId => ref.read(currentChildProfileProvider)?.id ?? 'anonymous';

  DocumentReference<Map<String, dynamic>> get _doc => FirebaseFirestore.instance
      .collection('users')
      .doc(_userId)
      .collection('progress')
      .doc('home_ec');

  Future<void> _init() async {
    try {
      final cached = await _getCache();
      state = AsyncValue.data(cached);
      await fetch();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> fetch() async {
    try {
      final snapshot = await _doc.get();
      final remote = snapshot.data()?['activities'] as Map<String, dynamic>? ?? {};
      final merged = <String, bool>{
        ...state.valueOrNull ?? {},
        for (final entry in remote.entries) entry.key: entry.value as bool,
      };
      state = AsyncValue.data(merged);
      await _saveCache(merged);
    } catch (_) {
      // オフライン時はローカルキャッシュのみで継続
    }
  }

  bool isCompleted(String topicId, String activityId) =>
      state.valueOrNull?['$topicId-$activityId'] ?? false;

  Future<void> toggle(String topicId, String activityId) async {
    final key = '$topicId-$activityId';
    final current = state.valueOrNull ?? {};
    final newValue = !(current[key] ?? false);
    final updated = {...current, key: newValue};
    state = AsyncValue.data(updated);
    await _saveCache(updated);

    try {
      await _doc.set({
        'activities': {key: newValue},
      }, SetOptions(merge: true));
    } catch (_) {
      // オフライン保存は成功済み。次回fetch時に再同期を試みる
    }
  }

  Future<void> _saveCache(Map<String, bool> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final entry in data.entries) {
        await prefs.setBool(entry.key, entry.value);
      }
    } catch (_) {}
  }

  Future<Map<String, bool>> _getCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_localKeyPrefix));
      return {
        for (final k in keys) k: prefs.getBool(k) ?? false,
      };
    } catch (_) {
      return {};
    }
  }
}
