import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/achievement_checklist.dart';
import '../models/daily_effort_record.dart';
import 'child_provider.dart';

/// 子どもごとの「今日できたこと」記録を端末内(SharedPreferences)に保存する
/// ノティファイアー。新しい記録が先頭に来るように並べる。
class DailyEffortRecordNotifier extends StateNotifier<List<DailyEffortRecord>> {
  DailyEffortRecordNotifier(this._childId) : super([]) {
    _load();
  }

  final String _childId;
  String get _storageKey => 'daily_effort_records_${_childId}';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return;
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      state = decoded
          .map((e) => DailyEffortRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // 壊れたデータは無視して空の状態を維持
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString =
        jsonEncode(state.map((r) => r.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  Future<void> addRecord({
    required ChecklistCategory category,
    required String text,
  }) async {
    final record = DailyEffortRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      childId: _childId,
      category: category,
      text: text,
      recordedAt: DateTime.now(),
    );
    state = [record, ...state];
    await _save();
  }

  Future<void> deleteRecord(String id) async {
    state = state.where((r) => r.id != id).toList();
    await _save();
  }
}

/// 現在選択中の子どもの日々の記録一覧
final dailyEffortRecordProvider = StateNotifierProvider.autoDispose<
    DailyEffortRecordNotifier, List<DailyEffortRecord>>((ref) {
  final childId = ref.watch(currentChildIdProvider) ?? 'default';
  return DailyEffortRecordNotifier(childId);
});
