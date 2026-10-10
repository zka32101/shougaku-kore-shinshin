import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/features/literacy_core/literacy_core.dart';
import 'package:shougaku_kore_doutoku/features/taiku/data/question_images.dart';
import 'package:shougaku_kore_doutoku/features/taiku/data/taiku_questions.dart';
import 'package:shougaku_kore_doutoku/features/taiku/screens/mistake_note_screen.dart';

Future<void> _pump(WidgetTester t, TaikuQuestion q) async {
  t.view.physicalSize = const Size(320, 700);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: MistakeCardForTest(question: q, grade: GradeLevel.low),
      ),
    ),
  ));
  await t.pump();
}

void main() {
  test('image ids match question ids', () {
    final ids = allStageQuestions.map((q) => q.id).toSet();
    for (final k in kQuestionImages.keys) {
      expect(ids.contains(k), isTrue, reason: k);
    }
  });

  testWidgets('shows image for mapped id, no overflow at 320px', (t) async {
    final q = allStageQuestions.firstWhere((q) => kQuestionImages.containsKey(q.id));
    await _pump(t, q);
    expect(find.byType(QuestionImage), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('hides image for unmapped id', (t) async {
    final q = allStageQuestions.firstWhere((q) => !kQuestionImages.containsKey(q.id));
    await _pump(t, q);
    expect(find.byType(QuestionImage), findsNothing);
  });
}
