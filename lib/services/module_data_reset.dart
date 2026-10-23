import 'package:shared_preferences/shared_preferences.dart';

/// 体育・芸術モジュールの学習データ（バッジ・進捗・記録など）だけを消す。
///
/// 端末の設定を丸ごと消す `SharedPreferences.clear()` とは違い、アプリ全体のプロフィール・
/// 学年・通知設定・どうとくの記録などには触れない。プロフィール（なまえ等）も残す。
class ModuleDataReset {
  ModuleDataReset._();

  /// 体育：消さないキー（プロフィール・初回案内の済み表示）
  static const _taikuKeep = <String>{
    'taiku_child_profiles',
    'taiku_current_profile_id',
    'taiku_onboarded',
  };

  /// 体育：`taiku_` で始まらないが、体育が使うキー
  static const _taikuOtherKeys = <String>{
    'composition_cache',
    'pending_photo_memory',
  };

  /// 体育：前置きで始まるキー（家庭科の進捗、クイズの進捗とバッジの判定用データ）
  static const _taikuOtherPrefixes = <String>[
    'HomeEcTopic.',
    'literacy_progress_taiku_',
  ];

  /// 芸術：プロフィールごとの記録（キーそのもの、または `<プロフィールID>_` が前に付く）
  static const _geijutsuNames = <String>{
    'colorProfile',
    'musicProfile',
    'artworks',
    'compositions',
    'homeChallenges',
    'badges',
    'currentArtMonth',
    'currentMusicStage',
    'currentHomeMonth',
  };

  static bool isTaikuDataKey(String key) {
    if (_taikuKeep.contains(key)) return false;
    return key.startsWith('taiku_') ||
        _taikuOtherKeys.contains(key) ||
        _taikuOtherPrefixes.any(key.startsWith);
  }

  static bool isGeijutsuDataKey(String key) {
    // 体育のキー（taiku_badges など）は芸術のものではない
    if (key.startsWith('taiku_')) return false;
    if (_geijutsuNames.contains(key)) return true;
    for (final name in _geijutsuNames) {
      if (key.endsWith('_$name')) return true;
    }
    // 家庭科の進捗: <プロフィールID>_topic_<トピックID>_<活動ID>
    return key.contains('_topic_');
  }

  /// 体育のデータを消し、消したキーの数を返す。
  static Future<int> resetTaiku(SharedPreferences prefs) =>
      _remove(prefs, isTaikuDataKey);

  /// 芸術のデータを消し、消したキーの数を返す。
  static Future<int> resetGeijutsu(SharedPreferences prefs) =>
      _remove(prefs, isGeijutsuDataKey);

  static Future<int> _remove(
    SharedPreferences prefs,
    bool Function(String) test,
  ) async {
    var n = 0;
    for (final key in prefs.getKeys().where(test).toList()) {
      if (await prefs.remove(key)) n++;
    }
    return n;
  }
}
