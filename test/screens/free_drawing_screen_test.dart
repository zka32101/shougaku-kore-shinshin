import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/screens/drawing/free_drawing_screen.dart';

void main() {
  testWidgets('おえかき: 描くと「もどす」「ぜんぶけす」「ほぞん」が使え、もどすで消える', (t) async {
    await t.pumpWidget(const MaterialApp(home: FreeDrawingScreen()));
    final canvas = find.byKey(const Key('drawing_canvas'));

    // 何も描いていないあいだは、ほぞんは押せない
    expect(t.widget<InkWell>(find.ancestor(of: find.text('ほぞん'), matching: find.byType(InkWell))).onTap, isNull);

    await t.drag(canvas, const Offset(80, 40));
    await t.pump();
    expect(t.widget<InkWell>(find.ancestor(of: find.text('ほぞん'), matching: find.byType(InkWell))).onTap, isNotNull);

    await t.tap(find.text('もどす'));
    await t.pump();
    expect(t.widget<InkWell>(find.ancestor(of: find.text('ほぞん'), matching: find.byType(InkWell))).onTap, isNull);
  });

  testWidgets('おえかき: ぜんぶけすは、確認を出してから消す', (t) async {
    await t.pumpWidget(const MaterialApp(home: FreeDrawingScreen()));
    await t.drag(find.byKey(const Key('drawing_canvas')), const Offset(60, 60));
    await t.pump();
    await t.tap(find.text('ぜんぶけす'));
    await t.pumpAndSettle();
    expect(find.text('ぜんぶ けす？'), findsOneWidget);
    await t.tap(find.text('けす'));
    await t.pumpAndSettle();
    expect(t.widget<InkWell>(find.ancestor(of: find.text('ほぞん'), matching: find.byType(InkWell))).onTap, isNull);
  });
}
