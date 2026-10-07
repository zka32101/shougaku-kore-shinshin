import '../data/kanji_grades.dart';

/// 漢字1字が小学何年生で習うか(配当表にない字は 7 = 中学以上扱い)。
class KanjiGrade {
  KanjiGrade._();

  static Map<String, int>? _map;

  static Map<String, int> get _table {
    final m = _map;
    if (m != null) return m;
    final built = <String, int>{};
    kKanjiByGrade.forEach((g, chars) {
      for (final r in chars.runes) {
        built.putIfAbsent(String.fromCharCode(r), () => g);
      }
    });
    return _map = built;
  }

  static bool isKanji(String ch) {
    if (ch.isEmpty) return false;
    final c = ch.runes.first;
    return (c >= 0x4E00 && c <= 0x9FFF) || c == 0x3005;
  }

  static int of(String ch) => _table[ch] ?? 7;

  /// 語の中で最も難しい漢字の学年。漢字を含まなければ 0。
  static int maxOf(String word) {
    var max = 0;
    for (final r in word.runes) {
      final ch = String.fromCharCode(r);
      if (isKanji(ch)) {
        final g = of(ch);
        if (g > max) max = g;
      }
    }
    return max;
  }
}

/// 表示用の断片。[reading] があるとき text の後ろに「（よみ）」を付ける。
class FuriganaPiece {
  final String text;
  final String? reading;
  const FuriganaPiece(this.text, [this.reading]);

  @override
  bool operator ==(Object other) =>
      other is FuriganaPiece && other.text == text && other.reading == reading;

  @override
  int get hashCode => Object.hash(text, reading);

  @override
  String toString() => reading == null ? text : '$text($reading)';
}

/// 語→読みの辞書を使って、学年に合わせて「漢字（かんじ）」形式の断片に変換する。
class FuriganaEngine {
  final Map<String, String> words;
  late final int _maxLen;

  FuriganaEngine(this.words) {
    var m = 1;
    for (final k in words.keys) {
      if (k.length > m) m = k.length;
    }
    _maxLen = m;
  }

  /// [userGrade] (1〜6)より上の学年で習う漢字を含む語にだけ読みを付ける。
  List<FuriganaPiece> convert(String text, int userGrade) {
    final out = <FuriganaPiece>[];
    final buf = StringBuffer();
    void flush() {
      if (buf.isNotEmpty) {
        out.add(FuriganaPiece(buf.toString()));
        buf.clear();
      }
    }

    var i = 0;
    while (i < text.length) {
      final ch = text[i];
      if (!KanjiGrade.isKanji(ch)) {
        buf.write(ch);
        i++;
        continue;
      }
      String? hit;
      final maxEnd = (i + _maxLen) < text.length ? i + _maxLen : text.length;
      for (var end = maxEnd; end > i; end--) {
        final cand = text.substring(i, end);
        if (words.containsKey(cand)) {
          hit = cand;
          break;
        }
      }
      if (hit == null) {
        buf.write(ch);
        i++;
        continue;
      }
      if (KanjiGrade.maxOf(hit) > userGrade) {
        flush();
        out.addAll(splitRuby(hit, words[hit]!));
      } else {
        buf.write(hit);
      }
      i += hit.length;
    }
    flush();
    return out;
  }

  /// 「借り」+「かり」 → [借(か), り] のように、漢字部分にだけ読みを割り当てる。
  /// 割り当てできない語は、語全体に読みを付ける。
  static List<FuriganaPiece> splitRuby(String word, String reading) {
    // 漢字の連続 / それ以外 に分割
    final tokens = <(bool, String)>[];
    final b = StringBuffer();
    bool? cur;
    for (final r in word.runes) {
      final ch = String.fromCharCode(r);
      final k = KanjiGrade.isKanji(ch);
      if (cur != null && k != cur) {
        tokens.add((cur, b.toString()));
        b.clear();
      }
      cur = k;
      b.write(ch);
    }
    if (cur != null) tokens.add((cur, b.toString()));

    final pieces = <FuriganaPiece>[];
    var p = 0;
    for (var t = 0; t < tokens.length; t++) {
      final (isKanji, s) = tokens[t];
      if (!isKanji) {
        final h = _toHira(s);
        if (reading.startsWith(h, p)) {
          pieces.add(FuriganaPiece(s));
          p += h.length;
          continue;
        }
        return [FuriganaPiece(word, reading)];
      }
      int end;
      if (t + 1 < tokens.length) {
        final next = _toHira(tokens[t + 1].$2);
        final idx = reading.indexOf(next, p + 1);
        if (idx < 0) return [FuriganaPiece(word, reading)];
        end = idx;
      } else {
        end = reading.length;
      }
      if (end <= p) return [FuriganaPiece(word, reading)];
      pieces.add(FuriganaPiece(s, reading.substring(p, end)));
      p = end;
    }
    if (p != reading.length) return [FuriganaPiece(word, reading)];
    return pieces;
  }

  static String _toHira(String s) => String.fromCharCodes(s.runes.map(
      (c) => (c >= 0x30A1 && c <= 0x30F6) ? c - 0x60 : c));
}
