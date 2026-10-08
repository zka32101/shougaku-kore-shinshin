import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/local_avatar_provider.dart';
import 'decor_items.dart';

/// 持っているきせかえと、いま「つけている」きせかえ（種類ごとに1つ）。
class DecorState {
  const DecorState({this.owned = const {}, this.background, this.frame, this.effect});

  final Set<String> owned;
  final String? background;
  final String? frame;
  final String? effect;

  String? of(DecorKind kind) {
    switch (kind) {
      case DecorKind.background:
        return background;
      case DecorKind.frame:
        return frame;
      case DecorKind.effect:
        return effect;
    }
  }

  DecorState withOwned(Set<String> o) => DecorState(owned: o, background: background, frame: frame, effect: effect);

  DecorState withSlot(DecorKind kind, String? id) {
    switch (kind) {
      case DecorKind.background:
        return DecorState(owned: owned, background: id, frame: frame, effect: effect);
      case DecorKind.frame:
        return DecorState(owned: owned, background: background, frame: id, effect: effect);
      case DecorKind.effect:
        return DecorState(owned: owned, background: background, frame: frame, effect: id);
    }
  }
}

/// きせかえの所持・装着。コインは既存の [localAvatarProvider]（local_avatar_coins）の
/// spendCoins を使い、所持IDだけ `decor_owned` に別保存する（アバター所持は int ID のため分けた）。
class DecorNotifier extends StateNotifier<DecorState> {
  DecorNotifier(this._ref) : super(const DecorState()) {
    loaded = _load();
  }

  final Ref _ref;
  late final Future<void> loaded;

  static const kOwned = 'decor_owned';
  static const _keyOf = {
    DecorKind.background: 'decor_background',
    DecorKind.frame: 'decor_frame',
    DecorKind.effect: 'decor_effect',
  };

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      state = DecorState(
        owned: (p.getStringList(kOwned) ?? const <String>[]).toSet(),
        background: p.getString(_keyOf[DecorKind.background]!),
        frame: p.getString(_keyOf[DecorKind.frame]!),
        effect: p.getString(_keyOf[DecorKind.effect]!),
      );
    } catch (_) {}
  }

  /// コインで買う。持っている・コイン不足・知らないIDなら false。
  Future<bool> purchase(DecorItem item) async {
    if (state.owned.contains(item.id) || decorItemById(item.id) == null) return false;
    final ok = await _ref.read(localAvatarProvider.notifier).spendCoins(item.coinCost);
    if (!ok) return false;
    state = state.withOwned({...state.owned, item.id});
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(kOwned, state.owned.toList());
    } catch (_) {}
    return true;
  }

  /// 買ったきせかえをつける。持っていないものはつけられない。
  Future<bool> equip(DecorItem item) async {
    if (!state.owned.contains(item.id)) return false;
    state = state.withSlot(item.kind, item.id);
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_keyOf[item.kind]!, item.id);
    } catch (_) {}
    return true;
  }

  /// はずす。
  Future<void> unequip(DecorKind kind) async {
    state = state.withSlot(kind, null);
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove(_keyOf[kind]!);
    } catch (_) {}
  }
}

final decorProvider = StateNotifierProvider<DecorNotifier, DecorState>((ref) => DecorNotifier(ref));

/// 持っているものだけに絞った「いまのきせかえ」。持っていない・種類が違う・知らないIDは無視する。
final activeDecorProvider = Provider<DecorState>((ref) {
  final s = ref.watch(decorProvider);
  String? valid(DecorKind k) {
    final item = decorItemById(s.of(k));
    return (item != null && item.kind == k && s.owned.contains(item.id)) ? item.id : null;
  }

  return DecorState(
    owned: s.owned,
    background: valid(DecorKind.background),
    frame: valid(DecorKind.frame),
    effect: valid(DecorKind.effect),
  );
});
