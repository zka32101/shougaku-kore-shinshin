import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/providers/auth_provider.dart';
import 'package:shougaku_kore_doutoku/screens/home/home_screen.dart';
import 'package:shougaku_kore_doutoku/screens/hub/guardian_hub_screen.dart';
import 'package:shougaku_kore_doutoku/screens/hub/records_hub_screen.dart';
import '../helpers/firebase_test_helper.dart';
import '../helpers/hive_test_helper.dart';

// ホーム画面はメニューカードの一覧（道徳・体育・芸術などの入口）。
// 各カードの遷移先は重いので、ここでは「何が並ぶか」を確認する。

Widget _wrap() => ProviderScope(
      overrides: [
        userAuthStateProvider.overrideWith((_) => Stream.value(null)),
      ],
      child: const MaterialApp(home: HomeScreen()),
    );

/// カードは遅延付きのアニメーションで現れる。表示とタイマーの完了まで時間を進める。
Future<void> _pumpHome(WidgetTester tester) async {
  await tester.pumpWidget(_wrap());
  await tester.pump(const Duration(seconds: 3));
}

/// 全カードが画面内に収まるよう、縦長のビューポートにする。
void _setTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  late Directory hiveTestDir;
  setUpAll(() async {
    hiveTestDir = await initHiveForTest();
  });
  tearDownAll(() async {
    await disposeHiveForTest(hiveTestDir);
  });
  setUpAll(setupFirebaseForTest);

  group('HomeScreen', () {
    testWidgets('shows the integrated app name in the AppBar', (tester) async {
      _setTallViewport(tester);
      await _pumpHome(tester);

      expect(find.text('小学コレ！心身'), findsOneWidget);
    });

    testWidgets('ホームはシンプルなメニューだけが並ぶ', (tester) async {
      _setTallViewport(tester);
      await _pumpHome(tester);

      for (final title in const [
        'どうとく ストーリー',
        'たいいく・けんこう',
        'げいじゅつ',
        'キャラずかん',
        'きろく',
        'ほごしゃ',
        'せってい',
      ]) {
        expect(find.text(title), findsOneWidget, reason: 'card "$title"');
      }
      // 「きろく」「ほごしゃ」の中に入れたものは、ホームには並べない
      for (final title in const [
        'ランキング',
        'ダッシュボード',
        'バッジ',
        'できたことチェック',
        'きょうのきろく',
        'ほごしゃ レポート',
        'たいいくのバッジ',
        'たいいくの ほごしゃ',
      ]) {
        expect(find.text(title), findsNothing, reason: 'card "$title"');
      }
    });

    testWidgets('体育・健康 and 芸術 cards describe their contents',
        (tester) async {
      _setTallViewport(tester);
      await _pumpHome(tester);

      expect(find.text('スポーツ・防災・栄養'), findsOneWidget);
      expect(find.text('図工・音楽・家庭科'), findsOneWidget);
    });

    testWidgets('「きろく」にバッジ・ノート・アルバムなどがまとまっている',
        (tester) async {
      _setTallViewport(tester);
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(home: RecordsHubScreen()),
      ));
      await tester.pump(const Duration(seconds: 1));

      for (final title in const [
        'バッジ',
        'せいちょうノート',
        'きょうのきろく',
        'できたことチェック',
        'ランキング',
        'たいいくのバッジ',
        'たいいくのアルバム',
        'げいじゅつのバッジ',
      ]) {
        expect(find.text(title), findsOneWidget, reason: 'card "$title"');
      }
    });

    testWidgets('「ほごしゃ」にレポート・統計・見まもりがまとまっている',
        (tester) async {
      _setTallViewport(tester);
      await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(home: GuardianHubScreen()),
      ));
      await tester.pump(const Duration(seconds: 1));

      for (final title in const [
        'ほごしゃ レポート',
        'ダッシュボード',
        'たいいくの みまもり',
        'げいじゅつの みまもり',
      ]) {
        expect(find.text(title), findsOneWidget, reason: 'card "$title"');
      }
    });

    testWidgets('has no leftover stub cards (piano / drawing / colors)',
        (tester) async {
      _setTallViewport(tester);
      await _pumpHome(tester);

      expect(find.text('ピアノ'), findsNothing);
      expect(find.text('お絵かき'), findsNothing);
      expect(find.text('色選び'), findsNothing);
    });
  });
}
