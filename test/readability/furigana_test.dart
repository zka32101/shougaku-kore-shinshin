import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/providers/furigana_provider.dart';
import 'package:shougaku_kore_doutoku/utils/furigana.dart';
import 'package:shougaku_kore_doutoku/widgets/furigana_text.dart';

void main() {
  final engine = FuriganaEngine({
    '協力': 'きょうりょく',
    '友達': 'ともだち',
    '借り': 'かり',
    '手伝っ': 'てつだっ',
    '学校': 'がっこう',
    '先生': 'せんせい',
  });

  test('漢字の学年判定', () {
    expect(KanjiGrade.of('学'), 1);
    expect(KanjiGrade.of('協'), 4);
    expect(KanjiGrade.of('誠'), 6);
    expect(KanjiGrade.of('鬱'), 7); // 配当表にない字は中学以上扱い
    expect(KanjiGrade.maxOf('友達'), 4);
    expect(KanjiGrade.maxOf('ひらがな'), 0);
  });

  test('学年より上の漢字を含む語にだけ読みを付ける', () {
    // 3年生: 協(4年)を含む協力には付く。学校・先生には付かない。
    final p3 = engine.convert('学校で協力する', 3);
    expect(p3, [
      const FuriganaPiece('学校で'),
      const FuriganaPiece('協力', 'きょうりょく'),
      const FuriganaPiece('する'),
    ]);
    // 4年生: 協力も習済み。
    expect(engine.convert('学校で協力する', 4), [const FuriganaPiece('学校で協力する')]);
    // 1年生: 学校(学1・校1)は付かないが 先生(先1・生1)も付かない。友達(友2・達4)は付く。
    expect(engine.convert('先生と友達', 1).last, const FuriganaPiece('友達', 'ともだち'));
    expect(engine.convert('先生と友達', 1).first, const FuriganaPiece('先生と'));
  });

  test('送りがなは読みから除いて漢字部分にだけ付ける', () {
    expect(FuriganaEngine.splitRuby('借り', 'かり'),
        [const FuriganaPiece('借', 'か'), const FuriganaPiece('り')]);
    expect(FuriganaEngine.splitRuby('手伝っ', 'てつだっ'),
        [const FuriganaPiece('手伝', 'てつだ'), const FuriganaPiece('っ')]);
    // 位置が合わなければ語全体に付ける
    expect(FuriganaEngine.splitRuby('借り', 'ちがう'),
        [const FuriganaPiece('借り', 'ちがう')]);
  });

  test('語彙集の分割は長い語を優先', () {
    final segs = splitByGlossary('責任感と責任', ['責任', '責任感']);
    expect(segs.map((e) => e.term).toList(), ['責任感', null, '責任']);
  });

  testWidgets('FuriganaText は「漢字（よみ）」形式で表示する', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        furiganaEngineProvider.overrideWith((ref) async => engine),
      ],
      child: const MaterialApp(
        home: Scaffold(body: FuriganaText('友達と協力', gradeOverride: 3)),
      ),
    ));
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('友達（ともだち）', findRichText: true), findsOneWidget);
    expect(find.textContaining('協力（きょうりょく）', findRichText: true), findsOneWidget);
  });

  test('活用形(悲しく)にも、語幹から読みが付く', () {
    final e = FuriganaEngine({'悲しい': 'かなしい', '借りる': 'かりる'});
    expect(e.convert('悲しくなった', 2).map((p) => p.toString()).join(),
        '悲(かな)しくなった');
    expect(e.convert('本を借りた', 2).map((p) => p.toString()).join(),
        '本を借(か)りた');
  });
}
