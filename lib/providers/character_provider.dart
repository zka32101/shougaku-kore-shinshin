import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/shinshin_characters.dart';
import 'local_avatar_provider.dart';

/// 心身キャラのレベル状態（characterId -> level 1..5）。
///
/// 全16体は最初から所有（Lv1）。コインは端末内ウォレット
/// （[localAvatarProvider] / local_avatar_coins）を唯一の出どころとして使う。
class ShinshinCharacterState {
  final Map<String, int> levels;
  const ShinshinCharacterState([this.levels = const {}]);

  int levelOf(String id) => (levels[id] ?? 1).clamp(1, kShinshinMaxLevel);
  bool isMax(String id) => levelOf(id) >= kShinshinMaxLevel;

  /// 次レベルのコスト（MAXなら null）
  int? nextCost(String id) =>
      isMax(id) ? null : shinshinLevelUpCost(levelOf(id) + 1);
}

class ShinshinCharacterNotifier extends StateNotifier<ShinshinCharacterState> {
  ShinshinCharacterNotifier(this._ref) : super(const ShinshinCharacterState()) {
    loaded = _load();
  }

  static const storageKey = 'shinshin_char_states';
  final Ref _ref;
  late final Future<void> loaded;

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(storageKey);
      if (raw == null) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      state = ShinshinCharacterState({
        for (final e in map.entries)
          if (e.value is int) e.key: e.value as int,
      });
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(storageKey, jsonEncode(state.levels));
    } catch (_) {}
  }

  /// レベルアップ。エラー文言 or 成功時 null。
  Future<String?> levelUp(String id) async {
    await loaded;
    if (!kShinshinCharacters.any((c) => c.id == id)) return 'キャラが見つかりません';
    if (state.isMax(id)) return 'すでにMAXレベルです';
    final cost = state.nextCost(id)!;
    final ok = await _ref.read(localAvatarProvider.notifier).spendCoins(cost);
    if (!ok) return 'コインが足りません（必要: $costコイン）';
    state = ShinshinCharacterState({
      ...state.levels,
      id: state.levelOf(id) + 1,
    });
    await _save();
    return null;
  }
}

final shinshinCharacterProvider =
    StateNotifierProvider<ShinshinCharacterNotifier, ShinshinCharacterState>(
  (ref) => ShinshinCharacterNotifier(ref),
);
