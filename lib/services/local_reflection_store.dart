import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// ストーリーを読んだあとの「考えてみよう」の記録。
///
/// 相手の気持ち（感情）と、ひとこと。端末の中にだけ保存し、サーバーには送らない。
class ReflectionEntry {
  final String storyId;
  final String storyTitle;
  final String theme;
  final String choiceId;

  /// 「相手はどんな気持ちだったかな？」の答え（[kReflectionFeelings] のキー）。未選択なら null
  final String? feeling;

  /// 「ほかの選択ならどうなる？」などのひとこと。空なら null
  final String? note;
  final DateTime at;

  const ReflectionEntry({
    required this.storyId,
    required this.storyTitle,
    required this.theme,
    required this.choiceId,
    required this.feeling,
    required this.note,
    required this.at,
  });

  Map<String, dynamic> toJson() => {
        'storyId': storyId,
        'storyTitle': storyTitle,
        'theme': theme,
        'choiceId': choiceId,
        'feeling': feeling,
        'note': note,
        'at': at.toIso8601String(),
      };

  static ReflectionEntry? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final storyId = raw['storyId'];
    final at = DateTime.tryParse('${raw['at']}');
    if (storyId is! String || at == null) return null;
    return ReflectionEntry(
      storyId: storyId,
      storyTitle: raw['storyTitle'] as String? ?? '',
      theme: raw['theme'] as String? ?? '',
      choiceId: raw['choiceId'] as String? ?? '',
      feeling: raw['feeling'] as String?,
      note: raw['note'] as String?,
      at: at,
    );
  }
}

/// 「相手の気持ち」の選択肢：キー → (絵文字, ことば)
const kReflectionFeelings = <String, (String, String)>{
  'happy': ('😊', 'うれしい'),
  'sad': ('😢', 'かなしい'),
  'angry': ('😠', 'おこった'),
  'worried': ('😟', 'しんぱい'),
  'relieved': ('😌', 'ほっとした'),
  'shy': ('😳', 'はずかしい'),
};

class LocalReflectionStore {
  LocalReflectionStore._();

  static const maxEntries = 200;
  static const maxNoteLength = 80;

  static String _key(String childId) => 'local_reflections_$childId';

  /// 1件追加する。同じお話の記録は新しいもので置き換える。感情もひとことも無ければ何もしない。
  static Future<void> record({
    required String childId,
    required ReflectionEntry entry,
  }) async {
    final note = entry.note?.trim();
    if (entry.feeling == null && (note == null || note.isEmpty)) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _decode(prefs.getString(_key(childId)))
        ..removeWhere((e) => e.storyId == entry.storyId);
      list.add(ReflectionEntry(
        storyId: entry.storyId,
        storyTitle: entry.storyTitle,
        theme: entry.theme,
        choiceId: entry.choiceId,
        feeling: entry.feeling,
        note: (note == null || note.isEmpty)
            ? null
            : (note.length > maxNoteLength
                ? note.substring(0, maxNoteLength)
                : note),
        at: entry.at,
      ));
      final trimmed = list.length > maxEntries
          ? list.sublist(list.length - maxEntries)
          : list;
      await prefs.setString(
          _key(childId), jsonEncode([for (final e in trimmed) e.toJson()]));
    } catch (_) {
      // 保存に失敗しても学習は続けられる
    }
  }

  /// 新しい順
  static Future<List<ReflectionEntry>> load(String childId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return _decode(prefs.getString(_key(childId)))
        ..sort((a, b) => b.at.compareTo(a.at));
    } catch (_) {
      return [];
    }
  }

  /// この子どもの「考えてみよう」の記録をすべて消す。
  static Future<void> clear(String childId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(childId));
  }

  static List<ReflectionEntry> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final d = jsonDecode(raw);
      if (d is! List) return [];
      return [
        for (final e in d)
          if (ReflectionEntry.fromJson(e) != null) ReflectionEntry.fromJson(e)!,
      ];
    } catch (_) {
      return [];
    }
  }
}
