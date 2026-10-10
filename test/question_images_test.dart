import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/features/taiku/data/question_images.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all kQuestionImages assets exist', () async {
    for (final p in kQuestionImages.values) {
      final d = await rootBundle.load(p);
      expect(d.lengthInBytes, greaterThan(0), reason: p);
    }
  });

  testWidgets('unknown id renders nothing', (t) async {
    await t.pumpWidget(const MaterialApp(home: QuestionImage('nope')));
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('no overflow at 320px', (t) async {
    t.view.physicalSize = const Size(320, 600);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(children: [QuestionImage(kQuestionImages.keys.first)]),
        ),
      ),
    );
    await t.pump();
    expect(tester(t), isNull);
  });
}

Object? tester(WidgetTester t) => t.takeException();
