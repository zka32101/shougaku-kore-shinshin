import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shougaku_kore_doutoku/constants/app_colors.dart';
import 'package:shougaku_kore_doutoku/providers/auth_provider.dart';
import 'package:shougaku_kore_doutoku/providers/child_provider.dart';
import 'package:shougaku_kore_doutoku/screens/badge/badge_showcase_screen.dart';
import 'package:shougaku_kore_doutoku/screens/home/home_screen.dart';
import 'package:shougaku_kore_doutoku/screens/story/story_learning_screen.dart';
import 'package:shougaku_kore_doutoku/screens/story/story_result_screen.dart';
import '../helpers/firebase_test_helper.dart';
import '../helpers/hive_test_helper.dart';

void main() {
  late Directory hiveTestDir;
  setUpAll(() async {
    hiveTestDir = await initHiveForTest();
  });
  tearDownAll(() async {
    await disposeHiveForTest(hiveTestDir);
  });
  setUpAll(setupFirebaseForTest);

  testWidgets('バッジ図鑑: サーバーの子どもが未選択でも空状態にならない', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: BadgeShowcaseScreen()),
    ));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('子どもを選択してください'), findsNothing);
    expect(find.text('バッジ図鑑へようこそ！'), findsOneWidget);
  });

  test('effectiveChildIdProvider は未選択なら端末内プロフィールを指す', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(effectiveChildIdProvider), kLocalChildId);
  });

  testWidgets('ホーム: 360dp幅でも「どうとく ストーリー」が1行に収まる', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        userAuthStateProvider.overrideWith((_) => Stream.value(null)),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ));
    await tester.pump(const Duration(seconds: 3));
    final f = find.text('どうとく ストーリー');
    expect(f, findsOneWidget);
    final box = tester.renderObject<RenderBox>(f);
    // 1行なら高さは文字サイズ×行高の1行分程度
    final style = tester.widget<Text>(f).style!;
    expect(box.size.height, lessThan(style.fontSize! * 2));
  });

  testWidgets('道徳ストーリーの次へボタン: 有効色で描画しタップで1回だけ呼ばれる', (tester) async {
    var taps = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StoryActionButton(label: 'ふりかえりへ', onPressed: () => taps++),
      ),
    ));
    final container = tester.widget<Container>(find
        .descendant(
            of: find.byType(StoryActionButton), matching: find.byType(Container))
        .first);
    final deco = container.decoration as BoxDecoration;
    expect(deco.color, AppColors.primary);
    expect(find.byType(ElevatedButton), findsNothing);
    await tester.tap(find.text('ふりかえりへ'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('結果画面: 円の中の「100%」が折り返さず円に収まる', (tester) async {
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        home: StoryResultScreen(
            storyTitle: 't', score: 100, pointsEarned: 10, childId: 'c'),
      ),
    ));
    await tester.pumpAndSettle();
    final fit = find
        .ancestor(of: find.text('100%').first, matching: find.byType(FittedBox))
        .first;
    // FittedBox が円(120dp)の内側に収める。文字は1行・折り返し無し
    expect(tester.getSize(fit).width, lessThanOrEqualTo(120));
    final text = tester.widget<Text>(find.text('100%').first);
    expect(text.maxLines, 1);
    expect(text.softWrap, false);
  });
}
