import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/providers/premium_provider.dart';
import 'package:shougaku_kore_doutoku/widgets/plan_card.dart';
import 'package:shougaku_kore_doutoku/widgets/premium_lock_view.dart';

class _FakePremium extends PremiumNotifier {
  _FakePremium(PremiumStatus s) {
    state = s;
  }
}

Widget _wrap(PremiumStatus s, Widget child) => ProviderScope(
      overrides: [premiumProvider.overrideWith((ref) => _FakePremium(s))],
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  group('PlanCard', () {
    testWidgets('無料期間中は のこり日数と「試す」を出す', (t) async {
      await t.pumpWidget(_wrap(const PremiumStatus(trialDaysLeft: 9), const PlanCard()));
      expect(find.text('⏳ 無料期間 あと9日'), findsOneWidget);
      expect(find.text('試す'), findsOneWidget);
    });

    testWidgets('期間が終わったら「プレミアムにする」を出す', (t) async {
      await t.pumpWidget(_wrap(const PremiumStatus(trialDaysLeft: 0), const PlanCard()));
      expect(find.text('🔒 無料期間が おわりました'), findsOneWidget);
      expect(find.text('プレミアムにする'), findsOneWidget);
    });

    testWidgets('購読中は「プレミアム」を出す', (t) async {
      await t.pumpWidget(_wrap(const PremiumStatus(isPremium: true), const PlanCard()));
      expect(find.text('🌟 プレミアム'), findsOneWidget);
    });

    testWidgets('タップで課金画面を開く', (t) async {
      await t.pumpWidget(_wrap(const PremiumStatus(trialDaysLeft: 5), const PlanCard()));
      await t.tap(find.text('試す'));
      await t.pumpAndSettle();
      expect(find.text('🌟 プレミアム'), findsWidgets);
      expect(find.textContaining('¥300'), findsWidgets);
    });
  });

  group('PremiumGate', () {
    testWidgets('無料期間中は中身をそのまま出す', (t) async {
      await t.pumpWidget(_wrap(const PremiumStatus(trialDaysLeft: 3),
          const PremiumGate(child: Text('CONTENT'))));
      expect(find.text('CONTENT'), findsOneWidget);
    });

    testWidgets('購読中は中身をそのまま出す', (t) async {
      await t.pumpWidget(_wrap(
          const PremiumStatus(isPremium: true, trialDaysLeft: 0),
          const PremiumGate(child: Text('CONTENT'))));
      expect(find.text('CONTENT'), findsOneWidget);
    });

    testWidgets('期間が終わって未購読ならロック画面を出す', (t) async {
      await t.pumpWidget(_wrap(const PremiumStatus(trialDaysLeft: 0),
          const PremiumGate(child: Text('CONTENT'))));
      expect(find.text('CONTENT'), findsNothing);
      expect(find.text('無料期間が おわりました'), findsOneWidget);
      expect(find.text('プレミアムにする'), findsOneWidget);
    });
  });
}
