import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/widgets/new_badge_dialog.dart';

void main() {
  testWidgets('おめでとう・バッジ名・了解で閉じる', (tester) async {
    var closed = false;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: TextButton(
            onPressed: () => showDialog(
              context: ctx,
              builder: (_) => NewBadgeDialog(
                  badgeNames: const ['10本クリア'], onClose: () => closed = true),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('おめでとう！'), findsOneWidget);
    expect(find.text('10本クリア'), findsOneWidget);
    await tester.tap(find.text('了解'));
    await tester.pumpAndSettle();
    expect(closed, isTrue);
    expect(find.text('おめでとう！'), findsNothing);
  });
}
