import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/providers/premium_provider.dart';
import 'package:shougaku_kore_doutoku/screens/upgrade_screen.dart';

/// 購入メソッドの呼び出し回数だけを数える偽物。
class _FakePremium extends PremiumNotifier {
  int yearly = 0;
  int monthly = 0;

  @override
  Future<bool> purchaseYearly() async {
    yearly++;
    return false; // 画面を閉じない
  }

  @override
  Future<bool> purchaseMonthly() async {
    monthly++;
    return false;
  }
}

/// 保護者ゲート(足し算・引き算)の答えを画面から読み取る。
int _answer(WidgetTester tester) {
  final q = tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .firstWhere((d) => RegExp(r'^\d+ [+-] \d+ = \?$').hasMatch(d));
  final m = RegExp(r'(\d+) ([+-]) (\d+)').firstMatch(q)!;
  final a = int.parse(m.group(1)!);
  final b = int.parse(m.group(3)!);
  return m.group(2) == '+' ? a + b : a - b;
}

void main() {
  late _FakePremium fake;

  setUp(() {
    fake = _FakePremium();
  });

  Future<void> pump(WidgetTester tester) async {
    // 料金プランが画面内に入る縦長の画面にする。
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [premiumProvider.overrideWith((ref) => fake)],
      child: const MaterialApp(home: UpgradeScreen()),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('購入ボタンを押すと保護者ゲートが出て、「やめる」では購入されない', (tester) async {
    await pump(tester);

    await tester.tap(find.text('年額プラン'));
    await tester.pumpAndSettle();
    expect(find.text('保護者の方へ確認'), findsOneWidget);
    expect(fake.yearly, 0);

    await tester.tap(find.text('やめる'));
    await tester.pumpAndSettle();
    expect(fake.yearly, 0);

    await tester.tap(find.text('月額プラン'));
    await tester.pumpAndSettle();
    expect(find.text('保護者の方へ確認'), findsOneWidget);
    await tester.tap(find.text('やめる'));
    await tester.pumpAndSettle();
    expect(fake.monthly, 0);
  });

  testWidgets('ゲートに正解すると、年額・月額の購入が実行される', (tester) async {
    await pump(tester);

    await tester.tap(find.text('年額プラン'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '${_answer(tester)}');
    await tester.tap(find.text('つぎへ'));
    await tester.pumpAndSettle();
    expect(fake.yearly, 1);

    await tester.tap(find.text('月額プラン'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '${_answer(tester)}');
    await tester.tap(find.text('つぎへ'));
    await tester.pumpAndSettle();
    expect(fake.monthly, 1);
  });

  testWidgets('間違えると購入されない', (tester) async {
    await pump(tester);

    await tester.tap(find.text('年額プラン'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '${_answer(tester) + 1}');
    await tester.tap(find.text('つぎへ'));
    await tester.pumpAndSettle();
    expect(fake.yearly, 0);
    expect(find.text('答えが違います'), findsOneWidget);
  });
}
