import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/animal_avatar.dart';

/// コインと動物アバター（所有・選択）の状態。端末内（SharedPreferences）に保存する。
class LocalAvatarState {
  final int coins;
  final Set<int> ownedIds;
  final int selectedId;

  const LocalAvatarState({
    this.coins = 0,
    this.ownedIds = const {},
    this.selectedId = 1,
  });

  bool isOwned(AnimalAvatar a) => a.isFree || ownedIds.contains(a.id);

  AnimalAvatar get selected => animalAvatarById(selectedId);

  LocalAvatarState copyWith({int? coins, Set<int>? ownedIds, int? selectedId}) =>
      LocalAvatarState(
        coins: coins ?? this.coins,
        ownedIds: ownedIds ?? this.ownedIds,
        selectedId: selectedId ?? this.selectedId,
      );
}

class LocalAvatarNotifier extends StateNotifier<LocalAvatarState> {
  LocalAvatarNotifier() : super(const LocalAvatarState()) {
    _load();
  }

  static const _kCoins = 'local_avatar_coins';
  static const _kOwned = 'local_avatar_owned';
  static const _kSelected = 'local_avatar_selected';

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      state = LocalAvatarState(
        coins: p.getInt(_kCoins) ?? 0,
        ownedIds: (p.getStringList(_kOwned) ?? const <String>[])
            .map(int.tryParse)
            .whereType<int>()
            .toSet(),
        selectedId: p.getInt(_kSelected) ?? 1,
      );
    } catch (_) {
      // 読み込めなくても初期状態で続行
    }
  }

  Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setInt(_kCoins, state.coins);
      await p.setStringList(_kOwned, state.ownedIds.map((e) => '$e').toList());
      await p.setInt(_kSelected, state.selectedId);
    } catch (_) {}
  }

  /// コインをふやす（ストーリーを読み終えたときなど）
  Future<void> earnCoins(int amount) async {
    if (amount <= 0) return;
    state = state.copyWith(coins: state.coins + amount);
    await _save();
  }

  /// コインをつかう（キャラのレベルアップなど）。足りなければ false
  Future<bool> spendCoins(int amount) async {
    if (amount <= 0 || state.coins < amount) return false;
    state = state.copyWith(coins: state.coins - amount);
    await _save();
    return true;
  }

  /// アバターを選ぶ（持っているものだけ）
  Future<bool> select(AnimalAvatar a) async {
    if (!state.isOwned(a)) return false;
    state = state.copyWith(selectedId: a.id);
    await _save();
    return true;
  }

  /// コインで購入して、そのまま選ぶ。成功したら true
  Future<bool> purchase(AnimalAvatar a) async {
    if (state.isOwned(a)) return false;
    final price = a.priceCoins ?? 0;
    if (state.coins < price) return false;
    state = state.copyWith(
      coins: state.coins - price,
      ownedIds: {...state.ownedIds, a.id},
      selectedId: a.id,
    );
    await _save();
    return true;
  }
}

final localAvatarProvider =
    StateNotifierProvider<LocalAvatarNotifier, LocalAvatarState>(
  (ref) => LocalAvatarNotifier(),
);
