import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/screens/home/home_screen.dart';
import 'package:shougaku_kore_doutoku/screens/home/main_shell.dart';

Widget _app() => MaterialApp(
      home: MainShell(tabBuilders: {
        for (final s in HomeSection.values)
          s: (_) => Center(child: Text('TAB_${s.name}')),
      }),
    );

void main() {
  testWidgets('bottom nav is always visible and switches sections',
      (tester) async {
    await tester.pumpWidget(_app());
    expect(find.byType(NavigationBar), findsOneWidget);
    for (final l in ['ホーム', 'どうとく', 'たいいく', 'げいじゅつ', 'キャラ']) {
      expect(find.text(l), findsOneWidget);
    }
    expect(find.text('TAB_home'), findsOneWidget);

    await tester.tap(find.text('たいいく'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('TAB_taiku'), findsOneWidget);

    await tester.tap(find.text('ホーム'));
    await tester.pumpAndSettle();
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.selectedIndex, 0);
  });

  testWidgets('system back from another section returns to home',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('げいじゅつ'));
    await tester.pumpAndSettle();
    final NavigatorState nav = tester.state(find.byType(Navigator));
    await nav.maybePop();
    await tester.pumpAndSettle();
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.selectedIndex, 0);
  });
}
