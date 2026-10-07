import '../constants/app_constants.dart';
import 'shinshin_characters.dart';

/// キャラの解放条件。ストーリーをクリアした回数(=もらったコイン合計 ÷ 1回分)で決める。
/// 0 は最初から見られる(各系統1〜2体)。
const Map<String, int> kShinshinUnlockStories = {
  'shinshin_01': 0, // ハシルくん(からだ)
  'shinshin_02': 0, // トブちゃん(からだ)
  'shinshin_09': 0, // ココロン(こころ)
  'shinshin_08': 0, // イロハ(げいじゅつ)
  'shinshin_14': 0, // リョウリちゃん(せいかつ)
  'shinshin_03': 3,
  'shinshin_10': 3,
  'shinshin_04': 6,
  'shinshin_11': 6,
  'shinshin_05': 10,
  'shinshin_12': 10,
  'shinshin_06': 15,
  'shinshin_15': 15,
  'shinshin_07': 20,
  'shinshin_16': 20,
  'shinshin_13': 30,
};

/// いままでにクリアしたストーリー数(もらったコインから換算)。
int storiesClearedFromCoins(int totalEarnedCoins) =>
    totalEarnedCoins ~/ AppConstants.coinsPerStory;

/// このキャラを解放するのに必要なクリア数(未定義は 0 = 最初から)。
int unlockStoriesFor(String id) => kShinshinUnlockStories[id] ?? 0;

/// 解放済みか。レベルアップ済み(=すでに育てている)キャラは必ず解放済みにする。
bool isCharacterUnlocked(String id,
        {required int storiesCleared, int level = 1}) =>
    level > 1 || storiesCleared >= unlockStoriesFor(id);

/// 未解放キャラに出す条件の文。
String unlockHint(String id, int storiesCleared) {
  final need = unlockStoriesFor(id);
  final left = (need - storiesCleared).clamp(0, need);
  return 'ストーリーを $need かい クリア\n(あと $left かい)';
}

/// 解放済みの数。
int unlockedCount(int storiesCleared, int Function(String id) levelOf) =>
    kShinshinCharacters
        .where((c) => isCharacterUnlocked(c.id,
            storiesCleared: storiesCleared, level: levelOf(c.id)))
        .length;
