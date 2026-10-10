import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/widgets/shell_route_observer.dart';

void main() {
  testWidgets('fullScreen is true only while a page above /home is open',
      (tester) async {
    final obs = ShellRouteObserver();
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      home: Navigator(
        key: key,
        observers: [obs],
        initialRoute: '/home',
        onGenerateRoute: (s) => MaterialPageRoute<void>(
          settings: s,
          builder: (_) => Text(s.name ?? 'unnamed'),
        ),
      ),
    ));
    await tester.pump();
    expect(obs.fullScreen.value, isFalse);

    key.currentState!.pushNamed('/quiz');
    await tester.pumpAndSettle();
    expect(obs.fullScreen.value, isTrue);

    key.currentState!.pop();
    await tester.pumpAndSettle();
    expect(obs.fullScreen.value, isFalse);
  });

  for (final base in ['/', '/onboarding']) {
    testWidgets('base page $base keeps the bottom bar visible', (tester) async {
      final obs = ShellRouteObserver();
      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(MaterialApp(
        home: Navigator(
          key: key,
          observers: [obs],
          initialRoute: base,
          onGenerateRoute: (s) => MaterialPageRoute<void>(
            settings: s,
            builder: (_) => Text(s.name ?? 'unnamed'),
          ),
        ),
      ));
      await tester.pump();
      expect(obs.fullScreen.value, isFalse);

      key.currentState!.pushNamed('/quiz');
      await tester.pumpAndSettle();
      expect(obs.fullScreen.value, isTrue);
    });
  }
}
