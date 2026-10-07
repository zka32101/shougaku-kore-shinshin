import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/color_profile.dart';
import '../models/music_profile.dart';
import '../models/artwork.dart';
import '../models/composition.dart';
import '../models/home_challenge.dart';
import '../models/badge.dart';
import '../../taiku/providers/child_profiles_provider.dart';

/// GeijutsuModule が表示前に初期化する（独立アプリ時代は ProviderScope の
/// override で注入していたが、統合アプリでは入れ子スコープを使わない）。
SharedPreferences? geijutsuPrefs;

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  final prefs = geijutsuPrefs;
  if (prefs == null) {
    throw StateError('GeijutsuModule で SharedPreferences が未初期化です');
  }
  return prefs;
});

// ---- プロフィール管理 ----
class ProfileNotifier extends StateNotifier<ProfileState> {
  final SharedPreferences _prefs;
  static const _profilesKey = 'profiles';
  static const _activeIdKey = 'activeProfileId';
  ProfileNotifier(this._prefs) : super(ProfileState.empty()) { _load(); }

  /// 芸術側のプロフィールは「データ保存キー(ID)」としてだけ内部で使う。
  /// 画面には出さず、名前・アバターはアプリ全体の現在プロフィールを表示する。
  /// - 既存プロフィールがあれば、最後に使っていたもの(activeProfileId)を、
  ///   無効なら先頭を使う。既存データ(`<id>_...`)はそのまま引き継がれる。
  /// - 1つも無ければ内部用の既定プロフィールを自動作成する。
  void _load() {
    final s = _prefs.getString(_profilesKey);
    var profiles = <UserProfile>[];
    if (s != null) {
      try {
        profiles = ProfileState.profilesFromJson(s);
      } catch (_) {}
    }
    if (profiles.isEmpty) {
      profiles = [
        UserProfile(
          id: const Uuid().v4(),
          name: 'ユーザー',
          avatarEmoji: '🧒',
          createdAt: DateTime.now(),
          grade: 0,
        ),
      ];
      _prefs.setString(
          _profilesKey, jsonEncode(profiles.map((e) => e.toJson()).toList()));
    }
    var activeId = _prefs.getString(_activeIdKey) ?? '';
    if (!profiles.any((p) => p.id == activeId)) {
      activeId = profiles.first.id;
      _prefs.setString(_activeIdKey, activeId);
    }
    state = ProfileState(profiles: profiles, activeId: activeId);
  }
  Future<void> addProfile(UserProfile p) async {
    final updated = [...state.profiles, p];
    await _prefs.setString(_profilesKey, jsonEncode(updated.map((e) => e.toJson()).toList()));
    final newId = state.activeId.isEmpty ? p.id : state.activeId;
    await _prefs.setString(_activeIdKey, newId);
    state = ProfileState(profiles: updated, activeId: newId);
  }
  Future<void> setActive(String id) async {
    await _prefs.setString(_activeIdKey, id);
    state = state.copyWith(activeId: id);
  }
  Future<void> updateProfile(UserProfile p) async {
    final updated = state.profiles.map((e) => e.id == p.id ? p : e).toList();
    await _prefs.setString(_profilesKey, jsonEncode(updated.map((e) => e.toJson()).toList()));
    state = state.copyWith(profiles: updated);
  }
  Future<void> deleteProfile(String id) async {
    final updated = state.profiles.where((p) => p.id != id).toList();
    await _prefs.setString(_profilesKey, jsonEncode(updated.map((e) => e.toJson()).toList()));
    final newActive = state.activeId == id
        ? (updated.isNotEmpty ? updated.first.id : '') : state.activeId;
    await _prefs.setString(_activeIdKey, newActive);
    state = ProfileState(profiles: updated, activeId: newActive);
  }
}
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref.watch(sharedPrefsProvider));
});

/// 芸術画面で表示する名前とアバター(絵文字)。アプリ全体の現在プロフィールから取る。
class GeijutsuDisplay {
  final String name;
  final String avatarEmoji;
  const GeijutsuDisplay(this.name, this.avatarEmoji);
}

final geijutsuDisplayProvider = Provider<GeijutsuDisplay>((ref) {
  final child = ref.watch(currentChildProfileProvider);
  final name = child?.name.trim() ?? '';
  final emoji = child?.emoji ?? '';
  return GeijutsuDisplay(
    name.isEmpty ? 'ユーザー' : name,
    emoji.isEmpty ? '🧒' : emoji,
  );
});

// ---- 設定 ----
class SettingsNotifier extends StateNotifier<Map<String, dynamic>> {
  final SharedPreferences _prefs;
  final String _pid;
  SettingsNotifier(this._prefs, this._pid) : super({}) { _load(); }
  String _k(String key) => _pid.isEmpty ? key : '${_pid}_$key';
  void _load() {
    state = {
      'onboardingDone': _prefs.getBool('onboardingDone') ?? false,
      'currentArtMonth': _prefs.getInt(_k('currentArtMonth')) ?? 1,
      'currentMusicStage': _prefs.getInt(_k('currentMusicStage')) ?? 1,
      'currentHomeMonth': _prefs.getInt(_k('currentHomeMonth')) ?? 1,
    };
  }
  Future<void> setOnboardingDone(bool v) async {
    await _prefs.setBool('onboardingDone', v);
    state = {...state, 'onboardingDone': v};
  }
  Future<void> setCurrentArtMonth(int m) async {
    await _prefs.setInt(_k('currentArtMonth'), m);
    state = {...state, 'currentArtMonth': m};
  }
  Future<void> setCurrentMusicStage(int s) async {
    await _prefs.setInt(_k('currentMusicStage'), s);
    state = {...state, 'currentMusicStage': s};
  }
  Future<void> setCurrentHomeMonth(int m) async {
    await _prefs.setInt(_k('currentHomeMonth'), m);
    state = {...state, 'currentHomeMonth': m};
  }
}
final settingsProvider = StateNotifierProvider<SettingsNotifier, Map<String, dynamic>>((ref) {
  final pid = ref.watch(profileProvider).activeId;
  return SettingsNotifier(ref.watch(sharedPrefsProvider), pid);
});

// ---- 色彩プロファイル（図工） ----
class ColorProfileNotifier extends StateNotifier<ColorProfile> {
  final SharedPreferences _prefs;
  final String _key;
  ColorProfileNotifier(this._prefs, String pid)
      : _key = pid.isEmpty ? 'colorProfile' : '${pid}_colorProfile',
        super(ColorProfile.empty()) {
    final s = _prefs.getString(_key);
    if (s != null) state = ColorProfile.fromJsonString(s);
  }
  Future<void> save(ColorProfile p) async {
    await _prefs.setString(_key, p.toJsonString());
    state = p;
  }
}
final colorProfileProvider = StateNotifierProvider<ColorProfileNotifier, ColorProfile>((ref) {
  final pid = ref.watch(profileProvider).activeId;
  return ColorProfileNotifier(ref.watch(sharedPrefsProvider), pid);
});

// ---- 音感プロファイル（音楽） ----
class MusicProfileNotifier extends StateNotifier<MusicProfile> {
  final SharedPreferences _prefs;
  final String _key;
  MusicProfileNotifier(this._prefs, String pid)
      : _key = pid.isEmpty ? 'musicProfile' : '${pid}_musicProfile',
        super(MusicProfile.empty()) {
    final s = _prefs.getString(_key);
    if (s != null) state = MusicProfile.fromJsonString(s);
  }
  Future<void> save(MusicProfile p) async {
    await _prefs.setString(_key, p.toJsonString());
    state = p;
  }
}
final musicProfileProvider = StateNotifierProvider<MusicProfileNotifier, MusicProfile>((ref) {
  final pid = ref.watch(profileProvider).activeId;
  return MusicProfileNotifier(ref.watch(sharedPrefsProvider), pid);
});

// ---- アートワーク（図工） ----
class ArtworkNotifier extends StateNotifier<ArtworkCollection> {
  final SharedPreferences _prefs;
  final String _key;
  ArtworkNotifier(this._prefs, String pid)
      : _key = pid.isEmpty ? 'artworks' : '${pid}_artworks',
        super(ArtworkCollection([])) {
    final s = _prefs.getString(_key);
    if (s != null) state = ArtworkCollection.fromJsonString(s);
  }
  Future<void> add(Artwork a) async {
    final updated = ArtworkCollection([...state.items, a]);
    await _prefs.setString(_key, updated.toJsonString());
    state = updated;
  }
}
final artworkProvider = StateNotifierProvider<ArtworkNotifier, ArtworkCollection>((ref) {
  final pid = ref.watch(profileProvider).activeId;
  return ArtworkNotifier(ref.watch(sharedPrefsProvider), pid);
});

// ---- 作曲（音楽） ----
class CompositionNotifier extends StateNotifier<CompositionCollection> {
  final SharedPreferences _prefs;
  final String _key;
  CompositionNotifier(this._prefs, String pid)
      : _key = pid.isEmpty ? 'compositions' : '${pid}_compositions',
        super(CompositionCollection([])) {
    final s = _prefs.getString(_key);
    if (s != null) state = CompositionCollection.fromJsonString(s);
  }
  Future<void> add(Composition c) async {
    final updated = CompositionCollection([...state.items, c]);
    await _prefs.setString(_key, updated.toJsonString());
    state = updated;
  }
}
final compositionProvider = StateNotifierProvider<CompositionNotifier, CompositionCollection>((ref) {
  final pid = ref.watch(profileProvider).activeId;
  return CompositionNotifier(ref.watch(sharedPrefsProvider), pid);
});

// ---- 家庭科チャレンジ ----
class HomeChallengeNotifier extends StateNotifier<HomeChallengeCollection> {
  final SharedPreferences _prefs;
  final String _key;
  HomeChallengeNotifier(this._prefs, String pid)
      : _key = pid.isEmpty ? 'homeChallenges' : '${pid}_homeChallenges',
        super(HomeChallengeCollection([])) {
    final s = _prefs.getString(_key);
    if (s != null) state = HomeChallengeCollection.fromJsonString(s);
  }
  Future<void> add(HomeChallenge h) async {
    final updated = HomeChallengeCollection([...state.items, h]);
    await _prefs.setString(_key, updated.toJsonString());
    state = updated;
  }
}
final homeChallengeProvider = StateNotifierProvider<HomeChallengeNotifier, HomeChallengeCollection>((ref) {
  final pid = ref.watch(profileProvider).activeId;
  return HomeChallengeNotifier(ref.watch(sharedPrefsProvider), pid);
});

// ---- バッジ ----
class BadgeNotifier extends StateNotifier<BadgeCollection> {
  final SharedPreferences _prefs;
  final String _key;
  BadgeNotifier(this._prefs, String pid)
      : _key = pid.isEmpty ? 'badges' : '${pid}_badges',
        super(BadgeCollection([])) {
    final s = _prefs.getString(_key);
    if (s != null) state = BadgeCollection.fromJsonString(s);
  }
  Future<void> award(String id, String name, String subject, String emoji, String desc) async {
    if (state.has(id)) return;
    final badge = AppBadge(
      id: id, name: name, description: desc,
      subject: subject, iconEmoji: emoji,
      rarity: 'normal',
      earnedAt: DateTime.now(),
    );
    final updated = BadgeCollection([...state.items, badge]);
    await _prefs.setString(_key, updated.toJsonString());
    state = updated;
  }
}
final badgeProvider = StateNotifierProvider<BadgeNotifier, BadgeCollection>((ref) {
  final pid = ref.watch(profileProvider).activeId;
  return BadgeNotifier(ref.watch(sharedPrefsProvider), pid);
});
