import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/widgets/streak_crown_row.dart';

void main() {
  testWidgets('StreakCrownRow no overflow at 320px with long title', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Row(children: [
          Flexible(child: Text('🔥 連続学習バッジ', style: TextStyle(fontSize: 16))),
          SizedBox(width: 8),
          StreakCrownRow(longestStreak: 14),
        ]),
      ),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('badge_crown_7')), findsOneWidget);
    expect(find.byKey(const Key('badge_crown_30')), findsOneWidget);
  });
}
