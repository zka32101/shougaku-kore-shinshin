import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/activity_memory.dart';

/// ② 体験アルバム：プロバイダー
final albumProvider =
    StateNotifierProvider<AlbumNotifier, List<ActivityMemory>>((ref) {
  return AlbumNotifier();
});

class AlbumNotifier extends StateNotifier<List<ActivityMemory>> {
  static const _kKey = 'taiku_activity_memories';

  AlbumNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_kKey) ?? [];
    state = jsonList
        .map((s) => ActivityMemory.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  Future<void> addMemory(ActivityMemory memory) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = [memory, ...state];
    await prefs.setStringList(
      _kKey,
      updated.map((m) => jsonEncode(m.toJson())).toList(),
    );
    state = updated;
  }

  Future<void> removeMemory(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = state.where((m) => m.id != id).toList();
    await prefs.setStringList(
      _kKey,
      updated.map((m) => jsonEncode(m.toJson())).toList(),
    );
    state = updated;
  }

  /// テーマでフィルター
  List<ActivityMemory> byTheme(String theme) =>
      state.where((m) => m.theme == theme).toList();

  /// 今月の記録
  List<ActivityMemory> get thisMonth {
    final now = DateTime.now();
    return state
        .where((m) => m.completedAt.year == now.year && m.completedAt.month == now.month)
        .toList();
  }

  /// 写真ありのみ
  List<ActivityMemory> get withPhotos =>
      state.where((m) => m.imagePath != null).toList();
}

/// テーマ別フィルタープロバイダー
final albumThemeFilterProvider = StateProvider<String?>((ref) => null);

final filteredAlbumProvider = Provider<List<ActivityMemory>>((ref) {
  final all = ref.watch(albumProvider);
  final filter = ref.watch(albumThemeFilterProvider);
  if (filter == null) return all;
  return all.where((m) => m.theme == filter).toList();
});
