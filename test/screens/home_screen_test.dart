import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/providers/auth_provider.dart';
import 'package:shougaku_kore_doutoku/screens/home/home_screen.dart';
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

    testWidgets('shows a menu card for every section', (tester) async {
      _setTallViewport(tester);
      await _pumpHome(tester);

      for (final title in const [
        'どうとく ストーリー',
        'ランキング',
        'ダッシュボード',
        'キャラずかん',
        'バッジ',
        'ほごしゃ レポート',
        'せってい',
        'たいいく・けんこう',
        'げいじゅつ',
        'できたことチェック',
        'きょうのきろく',
      ]) {
        expect(find.text(title), findsOneWidget, reason: 'card "$title"');
      }
    });

    testWidgets('体育・健康 and 芸術 cards describe their contents',
        (tester) async {
      _setTallViewport(tester);
      await _pumpHome(tester);

      expect(find.text('スポーツ・防災・栄養'), findsOneWidget);
      expect(find.text('図工・音楽・家庭科'), findsOneWidget);
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
