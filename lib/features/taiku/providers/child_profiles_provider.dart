import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../literacy_core/literacy_core.dart';
import 'dart:convert';
import '../data/child_profile.dart';

/// 子どもプロフィール管理プロバイダー
final childProfilesProvider =
    StateNotifierProvider<ChildProfilesNotifier, ChildProfilesState>((ref) {
  return ChildProfilesNotifier();
});

class ChildProfilesNotifier extends StateNotifier<ChildProfilesState> {
  static const _kProfilesKey = 'taiku_child_profiles';
  static const _kCurrentKey = 'taiku_current_profile_id';

  ChildProfilesNotifier()
      : super(const ChildProfilesState(profiles: [], currentProfileId: '')) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = prefs.getString(_kProfilesKey);
    final currentId = prefs.getString(_kCurrentKey);

    if (profilesJson == null) {
      // 初回 → デフォルトプロフィール作成
      final defaultProfile = ChildProfile(
        id: _generateId(),
        name: '子ども1',
        gradeLevel: GradeLevel.low,
        color: '#2196F3',
        emoji: '👦',
        createdAt: DateTime.now(),
      );
      state = ChildProfilesState(
        profiles: [defaultProfile],
        currentProfileId: defaultProfile.id,
      );
      await _save();
    } else {
      final profiles = (jsonDecode(profilesJson) as List)
          .cast<Map<String, dynamic>>()
          .map((p) => ChildProfile.fromJson(p))
          .toList();

      final validCurrentId = currentId != null &&
              profiles.any((p) => p.id == currentId)
          ? currentId
          : profiles.first.id;

      state = ChildProfilesState(
        profiles: profiles,
        currentProfileId: validCurrentId,
      );
    }
  }

  Future<void> addProfile(String name, GradeLevel gradeLevel) async {
    final colors = ['#2196F3', '#FF5722', '#4CAF50', '#FF9800'];
    final emojis = ['👦', '👧', '🧒', '👨'];
    final idx = state.profiles.length % colors.length;

    final newProfile = ChildProfile(
      id: _generateId(),
      name: name,
      gradeLevel: gradeLevel,
      color: colors[idx],
      emoji: emojis[idx],
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      profiles: [...state.profiles, newProfile],
      currentProfileId: newProfile.id,
    );
    await _save();
  }

  Future<void> switchProfile(String profileId) async {
    if (!state.profiles.any((p) => p.id == profileId)) return;
    state = state.copyWith(currentProfileId: profileId);
    await _save();
  }

  Future<void> deleteProfile(String profileId) async {
    if (state.profiles.length == 1) return; // 最後の1つは削除不可
    if (state.currentProfileId == profileId && state.profiles.length > 1) {
      // 削除対象が現在のプロフィールの場合、別のプロフィールに切り替え
      final nextProfile = state.profiles.firstWhere((p) => p.id != profileId);
      state = state.copyWith(
        profiles: state.profiles.where((p) => p.id != profileId).toList(),
        currentProfileId: nextProfile.id,
      );
    } else {
      state = state.copyWith(
        profiles: state.profiles.where((p) => p.id != profileId).toList(),
      );
    }
    await _save();
  }

  Future<void> updateProfile(ChildProfile profile) async {
    final updated = state.profiles
        .map((p) => p.id == profile.id ? profile : p)
        .toList();
    state = state.copyWith(profiles: updated);
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = jsonEncode(
      state.profiles.map((p) => p.toJson()).toList(),
    );
    await prefs.setString(_kProfilesKey, profilesJson);
    await prefs.setString(_kCurrentKey, state.currentProfileId);
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

/// 現在のプロフィール（便利プロバイダー）
final currentChildProfileProvider = Provider<ChildProfile?>((ref) {
  final state = ref.watch(childProfilesProvider);
  return state.currentProfile;
});
