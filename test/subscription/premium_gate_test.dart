import 'package:shougaku_kore_doutoku/providers/premium_provider.dart';
import 'package:shougaku_kore_doutoku/screens/upgrade_screen.dart';
import 'package:shougaku_kore_doutoku/widgets/premium_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _trialKey = 'trial_start_ms';

Future<ProviderContainer> _load({int? daysSinceFirstLaunch}) async {
  SharedPreferences.setMockInitialValues({
    if (daysSinceFirstLaunch != null)
      _trialKey: DateTime.now()
          .subtract(Duration(days: daysSinceFirstLaunch, hours: 1))
          .millisecondsSinceEpoch,
  });
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await container.read(premiumProvider.notifier).load();
  return container;
}

void main() {
  group('trial period', () {
    test('first launch starts a 14-day trial', () async {
      final c = await _load();
      final s = c.read(premiumProvider);
      expect(s.trialDaysLeft, 14);
      expect(s.isTrialActive, isTrue);
      expect(s.hasAccess, isTrue);
    });

    test('day 5 has 9 days left', () async {
      final s = (await _load(daysSinceFirstLaunch: 5)).read(premiumProvider);
      expect(s.trialDaysLeft, 9);
      expect(s.hasAccess, isTrue);
    });

    test('day 13 is the last day with access', () async {
      final s = (await _load(daysSinceFirstLaunch: 13)).read(premiumProvider);
      expect(s.trialDaysLeft, 1);
      expect(s.hasAccess, isTrue);
    });

    test('day 14 ends the trial', () async {
      final s = (await _load(daysSinceFirstLaunch: 14)).read(premiumProvider);
      expect(s.trialDaysLeft, 0);
      expect(s.isTrialActive, isFalse);
      expect(s.hasAccess, isFalse);
    });

    test('trial start is persisted, not reset on next launch', () async {
      final c = await _load();
      final first = (await SharedPreferences.getInstance()).getInt(_trialKey);
      await c.read(premiumProvider.notifier).load();
      final second = (await SharedPreferences.getInstance()).getInt(_trialKey);
      expect(first, isNotNull);
      expect(second, first);
    });
  });

  group('PremiumGate', () {
    Widget app(ProviderContainer c) => UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(
            home: PremiumGate(child: Text('STORY CONTENT')),
          ),
        );

    testWidgets('shows content during the trial', (tester) async {
      final c = await _load(daysSinceFirstLaunch: 3);
      await tester.pumpWidget(app(c));
      expect(find.text('STORY CONTENT'), findsOneWidget);
      expect(find.byType(UpgradeScreen), findsNothing);
    });

    testWidgets('shows paywall after the trial when not subscribed',
        (tester) async {
      final c = await _load(daysSinceFirstLaunch: 15);
      await tester.pumpWidget(app(c));
      expect(find.text('STORY CONTENT'), findsNothing);
      expect(find.byType(UpgradeScreen), findsOneWidget);
      expect(find.text('無料期間は終了しました'), findsOneWidget);
      expect(find.text('¥2,400 / 年'), findsOneWidget);
      expect(find.text('¥300 / 月'), findsOneWidget);
    });
  });
}
