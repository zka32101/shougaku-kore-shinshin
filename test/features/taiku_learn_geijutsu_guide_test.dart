import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shougaku_kore_doutoku/features/taiku/screens/learn_screen.dart';

void main() {
  testWidgets('体育のまなぶ画面から図工・音楽・家庭科の導線が外れ、げいじゅつへの案内が出る',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: LearnScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('taiku_geijutsu_guide')), findsOneWidget);
    expect(find.text('ずこう・おんがく・かていかは「げいじゅつ」で あそべるよ'),
        findsOneWidget);
    // 旧セクション・旧ステージ(S28〜S33)は表示されない
    for (final label in ['図工・美術', '音楽', '家庭科']) {
      expect(find.text(label), findsNothing, reason: label);
    }
    for (final s in ['S28', 'S29', 'S30', 'S31', 'S32', 'S33']) {
      expect(find.text(s), findsNothing, reason: s);
    }
    // ICT(S34/35)は残っている
    expect(find.text('ICT・プログラミング'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
