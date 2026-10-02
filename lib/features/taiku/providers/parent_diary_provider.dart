import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/parent_diary.dart';

final parentDiaryProvider =
    StateNotifierProvider<ParentDiaryNotifier, List<DiaryMessage>>((ref) {
  return ParentDiaryNotifier();
});

final unreadDiaryCountProvider =
    Provider.family<int, String>((ref, profileId) {
  final messages = ref.watch(parentDiaryProvider);
  return messages.where((m) => m.toProfileId == profileId && !m.read).length;
});

class ParentDiaryNotifier extends StateNotifier<List<DiaryMessage>> {
  static const _kKey = 'taiku_parent_diary';

  ParentDiaryNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_kKey);
    if (json != null) {
      final list = (jsonDecode(json) as List)
          .cast<Map<String, dynamic>>()
          .map(DiaryMessage.fromJson)
          .toList();
      state = list;
    }
  }

  Future<void> sendMessage({
    required String fromName,
    required String toProfileId,
    required String message,
    required String emoji,
  }) async {
    final msg = DiaryMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fromName: fromName,
      toProfileId: toProfileId,
      message: message,
      emoji: emoji,
      createdAt: DateTime.now(),
      read: false,
    );
    state = [msg, ...state.take(49)];
    await _save();
  }

  Future<void> markRead(String profileId) async {
    state = state
        .map((m) => m.toProfileId == profileId ? m.copyWith(read: true) : m)
        .toList();
    await _save();
  }

  List<DiaryMessage> forProfile(String profileId) =>
      state.where((m) => m.toProfileId == profileId).toList();

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kKey, jsonEncode(state.map((m) => m.toJson()).toList()));
  }
}
