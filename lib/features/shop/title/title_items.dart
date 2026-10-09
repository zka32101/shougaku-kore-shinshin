/// 称号の入手方法。
enum TitleAcquire { coin, achievement }

/// 称号の判定に使う、既存の進捗値（新しい計測はしない）。
class TitleStats {
  const TitleStats({this.storiesCleared = 0, this.maxCharacterLevel = 1});

  /// クリアしたストーリー数（もらったコイン合計から換算）。
  final int storiesCleared;

  /// 育てているキャラの最高レベル(1〜5)。
  final int maxCharacterLevel;
}

class TitleItem {
  const TitleItem({
    required this.id,
    required this.name,
    required this.acquire,
    this.coinCost = 0,
    this.condition = '',
    this.test,
  });

  final String id;
  final String name;
  final TitleAcquire acquire;
  final int coinCost;

  /// 達成称号の条件文（未解放のとき表示）。
  final String condition;
  final bool Function(TitleStats s)? test;

  bool get isCoin => acquire == TitleAcquire.coin;
}

/// 称号8個。コインで買う5個 + 達成で自動解放の3個。
final List<TitleItem> kTitleItems = [
  const TitleItem(id: 'title_genki', name: 'げんきいっぱい', acquire: TitleAcquire.coin, coinCost: 100),
  const TitleItem(id: 'title_kokoro', name: 'こころやさしい', acquire: TitleAcquire.coin, coinCost: 150),
  const TitleItem(id: 'title_karada', name: 'からだづくりめいじん', acquire: TitleAcquire.coin, coinCost: 250),
  const TitleItem(id: 'title_bousai', name: 'ぼうさいはかせ', acquire: TitleAcquire.coin, coinCost: 350),
  const TitleItem(id: 'title_champion', name: 'しんしんチャンピオン', acquire: TitleAcquire.coin, coinCost: 500),
  TitleItem(
    id: 'title_first',
    name: 'はじめのいっぽ',
    acquire: TitleAcquire.achievement,
    condition: 'ストーリーを 1かい クリア',
    test: (s) => s.storiesCleared >= 1,
  ),
  TitleItem(
    id: 'title_story',
    name: 'おはなしはかせ',
    acquire: TitleAcquire.achievement,
    condition: 'ストーリーを 10かい クリア',
    test: (s) => s.storiesCleared >= 10,
  ),
  TitleItem(
    id: 'title_sodate',
    name: 'そだてのめいじん',
    acquire: TitleAcquire.achievement,
    condition: 'キャラを レベル3まで そだてる',
    test: (s) => s.maxCharacterLevel >= 3,
  ),
];

TitleItem? titleItemById(String? id) {
  if (id == null) return null;
  for (final t in kTitleItems) {
    if (t.id == id) return t;
  }
  return null;
}

/// 達成称号が解放済みか（コイン称号は false: 購入で判定する）。
bool isAchievementUnlocked(TitleItem t, TitleStats s) => t.test?.call(s) ?? false;

/// 使える称号か（買った or 達成済み）。
bool isTitleAvailable(TitleItem t, {required Set<String> owned, required TitleStats stats}) =>
    t.isCoin ? owned.contains(t.id) : isAchievementUnlocked(t, stats);

/// ホームに出す称号名。未選択・未所持・知らないIDは null。
String? equippedTitleName(String? equippedId, {required Set<String> owned, required TitleStats stats}) {
  final t = titleItemById(equippedId);
  if (t == null || !isTitleAvailable(t, owned: owned, stats: stats)) return null;
  return t.name;
}
