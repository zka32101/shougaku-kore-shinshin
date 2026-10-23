import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/providers/premium_provider.dart';
import 'package:shougaku_kore_doutoku/widgets/access_guard.dart';

class _FakePremium extends PremiumNotifier {
  _FakePremium(PremiumStatus s) {
    state = s;
  }
}

Widget _wrap(PremiumStatus s) => ProviderScope(
      overrides: [premiumProvider.overrideWith((ref) => _FakePremium(s))],
      child: const MaterialApp(home: AccessGuard(child: Text('CONTENT'))),
    );

void main() {
  testWidgets('無料期間中は中身を出す', (t) async {
    await t.pumpWidget(_wrap(const PremiumStatus(trialDaysLeft: 5)));
    expect(find.text('CONTENT'), findsOneWidget);
  });

  testWidgets('購読中は中身を出す', (t) async {
    await t.pumpWidget(_wrap(const PremiumStatus(isPremium: true, trialDaysLeft: 0)));
    expect(find.text('CONTENT'), findsOneWidget);
  });

  testWidgets('無料期間が終わって未購読なら、中身は出さずロック画面を出す(例外のステージはない)', (t) async {
    await t.pumpWidget(_wrap(const PremiumStatus(trialDaysLeft: 0)));
    expect(find.text('CONTENT'), findsNothing);
    expect(find.text('無料期間は終了しました'), findsOneWidget);
  });
}
