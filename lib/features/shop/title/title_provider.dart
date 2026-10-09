import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/shinshin_unlocks.dart';
import '../../../providers/character_provider.dart';
import '../../../providers/local_avatar_provider.dart';
import 'title_items.dart';

class TitleState {
  const TitleState({this.owned = const {}, this.equipped});
  final Set<String> owned;
  final String? equipped;
}

/// 称号の購入済み・装着。コインは localAvatarProvider.spendCoins を再利用する。
class TitleNotifier extends StateNotifier<TitleState> {
  TitleNotifier(this._ref) : super(const TitleState()) {
    loaded = _load();
  }

  final Ref _ref;
  late final Future<void> loaded;

  static const kOwned = 'title_owned';
  static const kEquipped = 'title_equipped';

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      state = TitleState(
        owned: (p.getStringList(kOwned) ?? const <String>[]).toSet(),
        equipped: p.getString(kEquipped),
      );
    } catch (_) {}
  }

  Future<bool> purchase(TitleItem item) async {
    if (!item.isCoin || state.owned.contains(item.id)) return false;
    final ok = await _ref.read(localAvatarProvider.notifier).spendCoins(item.coinCost);
    if (!ok) return false;
    state = TitleState(owned: {...state.owned, item.id}, equipped: state.equipped);
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(kOwned, state.owned.toList());
    } catch (_) {}
    return true;
  }

  /// つける。使えない称号はつけられない。
  Future<bool> equip(TitleItem item) async {
    final stats = _ref.read(titleStatsProvider);
    if (!isTitleAvailable(item, owned: state.owned, stats: stats)) return false;
    state = TitleState(owned: state.owned, equipped: item.id);
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(kEquipped, item.id);
    } catch (_) {}
    return true;
  }

  Future<void> unequip() async {
    state = TitleState(owned: state.owned);
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove(kEquipped);
    } catch (_) {}
  }
}

final titleProvider = StateNotifierProvider<TitleNotifier, TitleState>((ref) => TitleNotifier(ref));

/// 既存の進捗値から作る判定用の値。
final titleStatsProvider = Provider<TitleStats>((ref) {
  final avatar = ref.watch(localAvatarProvider);
  final chars = ref.watch(shinshinCharacterProvider);
  var maxLv = 1;
  for (final v in chars.levels.values) {
    if (v > maxLv) maxLv = v;
  }
  return TitleStats(
    storiesCleared: storiesClearedFromCoins(avatar.totalEarned),
    maxCharacterLevel: maxLv,
  );
});

/// ホームに出す称号名（なければ null）。
final equippedTitleNameProvider = Provider<String?>((ref) {
  final s = ref.watch(titleProvider);
  return equippedTitleName(s.equipped, owned: s.owned, stats: ref.watch(titleStatsProvider));
});
