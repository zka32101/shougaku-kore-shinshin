import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../models/progress.dart';

/// 端末内に保存するストーリー完了記録。
/// サーバーに繋がらなくてもバッジ判定ができるように、完了のたびに
/// SharedPreferences へ（子どもごとに）残す。
class LocalCompletionStore {
  LocalCompletionStore._();

  static String _key(String childId) => 'local_story_completions_$childId';

  /// ストーリー完了を記録する（同じストーリーは1件だけ保持）。
  static Future<void> record({
    required String childId,
    required String storyId,
    required String theme,
    DateTime? at,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _decode(prefs.getString(_key(childId)));
      if (list.any((e) => e['storyId'] == storyId)) return;
      list.add({
        'storyId': storyId,
        'theme': theme,
        'at': (at ?? DateTime.now()).toIso8601String(),
      });
      await prefs.setString(_key(childId), jsonEncode(list));
    } catch (_) {
      // 保存失敗は無視（バッジ判定が少し遅れるだけ）
    }
  }

  /// 端末内の完了記録を Progress 形式で返す。失敗時は空。
  static Future<List<Progress>> load(String childId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return [
        for (final e in _decode(prefs.getString(_key(childId))))
          Progress(
            id: 'local_${e['storyId']}',
            childId: childId,
            storyId: e['storyId'] as String?,
            action: AppConstants.actionStoryCompleted,
            virtue: e['theme'] as String?,
            completionCount: 1,
            recordedAt:
                DateTime.tryParse('${e['at']}') ?? DateTime.now(),
          ),
      ];
    } catch (_) {
      return [];
    }
  }

  static List<Map<String, dynamic>> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final d = jsonDecode(raw);
      if (d is! List) return [];
      return [
        for (final e in d)
          if (e is Map && e['storyId'] is String)
            Map<String, dynamic>.from(e),
      ];
    } catch (_) {
      return [];
    }
  }
}
