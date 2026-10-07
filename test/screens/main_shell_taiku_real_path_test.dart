import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shougaku_kore_doutoku/screens/home/home_screen.dart';
import 'package:shougaku_kore_doutoku/screens/home/main_shell.dart';

/// 実際の体育モジュール（スプラッシュ → ホーム → おすすめカード → クイズ）で
/// 下部ナビが隠れること、戻るで復帰することを確認する。
void main() {
  testWidgets('shell bar hides on the quiz page reached via the stage card',
      (tester) async {
    tester.view.physicalSize = const Size(393, 851);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'taiku_onboarded': true});

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: MainShell(tabBuilders: {
          for (final s in HomeSection.values)
            if (s != HomeSection.taiku) s: (_) => const SizedBox(),
        }),
      ),
    ));
    await tester.tap(find.text('たいいく'));
    await tester.pump();
    // スプラッシュ(1.8秒)のあとホームへ
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(NavigationBar), findsOneWidget,
        reason: 'visible on the module home');

    final card = find.textContaining('Stage ');
    expect(card, findsWidgets);
    await tester.tap(card.first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(NavigationBar), findsNothing,
        reason: 'hidden on the quiz page');

    // システムの戻る：クイズ → 体育ホーム（ナビが戻る）
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    // クイズ中の戻るは確認ダイアログ → 「やめる」
    expect(find.text('クイズをやめる？'), findsOneWidget);
    await tester.tap(find.text('やめる'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(NavigationBar), findsOneWidget);
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.selectedIndex, HomeSection.taiku.index,
        reason: 'back from quiz stays in the module home');

    // もう一度戻る → アプリのホームタブ
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        0);
  });
}
