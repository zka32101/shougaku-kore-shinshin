import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/features/taiku/screens/stage_learn_screen.dart';

Widget _wrap(int n) => ProviderScope(
  child: MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: StageIntroCard(stageNum: n, color: Colors.green, isLow: true),
      ),
    ),
  ),
);

void main() {
  testWidgets('stage 1 shows explain image', (t) async {
    t.view.physicalSize = const Size(360, 640);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(_wrap(1));
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(AspectRatio), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('stage 13 shows explain image', (t) async {
    t.view.physicalSize = const Size(360, 640);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(_wrap(13));
    expect(find.byType(Image), findsOneWidget);
  });
  testWidgets('stage 36 shows no image', (t) async {
    await t.pumpWidget(_wrap(36));
    expect(find.byType(Image), findsNothing);
  });
}
