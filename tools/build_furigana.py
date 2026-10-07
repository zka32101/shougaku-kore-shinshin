"""アプリ内の日本語文から「ふりがな辞書」と「学年別漢字」データを生成する(開発時のみ実行)。

使い方:  pip install fugashi unidic-lite  してから  python tools/build_furigana.py
出力:    assets/furigana/words.json  /  lib/data/kanji_grades.dart
漢字の学年は tools/kyoiku_kanji.json(学年別漢字配当表 1026字)から。
"""
import json, re, pathlib
from fugashi import Tagger

root = pathlib.Path(__file__).resolve().parent.parent
grades = {int(k): v for k, v in json.load(open(root / 'tools/kyoiku_kanji.json', encoding='utf8')).items()}
g_of = {}
for g, chars in grades.items():
    for c in chars:
        g_of.setdefault(c, g)

KANJI = re.compile('[一-鿿々]')
STR = re.compile(r"""'((?:[^'\\n]|\.)*)'|"((?:[^"\\n]|\.)*)\"""")

texts = []
for p in list((root / 'lib').rglob('*.dart')) + list((root / 'assets').rglob('*.json')):
    if p.name in ('kanji_grades.dart', 'words.json'):
        continue
    s = p.read_text(encoding='utf8', errors='ignore')
    if p.suffix == '.json':
        for m in re.finditer(r'"((?:[^"\\n]|\.)*)"', s):
            texts.append(m.group(1))
    else:
        for m in STR.finditer(s):
            texts.append(m.group(1) or m.group(2) or '')
texts = [t for t in texts if KANJI.search(t)]

def kata2hira(s):
    return ''.join(chr(ord(c) - 0x60) if 'ァ' <= c <= 'ヶ' else c for c in s)

tagger = Tagger()
from collections import Counter, defaultdict
reads = defaultdict(Counter)
for t in texts:
    t = t.replace('\n', '\n').replace('$', ' ')
    for w in tagger(t):
        surf = w.surface
        if not KANJI.search(surf) or not re.fullmatch(r'[぀-ヿ一-鿿々]+', surf):
            continue
        kana = getattr(w.feature, 'kana', None) or getattr(w.feature, 'pron', None)
        if not kana or kana == '*':
            continue
        r = kata2hira(kana)
        # 固有名詞(人名など)は誤読が多いので学年判定どおり付けるが、辞書には登録する
        if max((g_of.get(c, 7) for c in surf if KANJI.match(c)), default=0) <= 1:
            continue  # 1年生配当の漢字だけ -> 誰にも付けない
        reads[surf][r] += 1

# 同じ表記で読みが割れる語は、最頻の読みが75%以上のときだけ採用(誤った読みを出さない)
words = {}
for surf, c in reads.items():
    top, n = c.most_common(1)[0]
    if n / sum(c.values()) >= 0.75:
        words[surf] = top

(root / 'assets/furigana/words.json').write_text(
    json.dumps(dict(sorted(words.items())), ensure_ascii=False, separators=(',', ':')), encoding='utf8')

dart = ["// 自動生成: tools/build_furigana.py(元データ: tools/kyoiku_kanji.json)", "// 学年別漢字配当表(小学校1026字)。",
        "const Map<int, String> kKanjiByGrade = {"]
for g in range(1, 7):
    dart.append(f"  {g}: '{grades[g]}',")
dart.append("};")
(root / 'lib/data/kanji_grades.dart').write_text('\n'.join(dart) + '\n', encoding='utf8')
print(len(texts), 'strings;', len(words), 'words')
