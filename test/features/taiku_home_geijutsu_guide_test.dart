import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shougaku_kore_doutoku/features/literacy_core/literacy_core.dart';
import 'package:shougaku_kore_doutoku/features/taiku/data/taiku_questions.dart';
import 'package:shougaku_kore_doutoku/features/taiku/providers/taiku_providers.dart';
import 'package:shougaku_kore_doutoku/features/taiku/screens/home_screen.dart';

void main() {
  test('図工・音楽・家庭科(S28-33)は学年別ステージ一覧に含まれず、問題データは残っている', () {
    for (final g in GradeLevel.values) {
      final stages = stagesForGrade(g);
      for (final s in [28, 29, 30, 31, 32, 33]) {
        expect(stages.contains(s), isFalse, reason: '$g S$s');
      }
    }
    for (final s in [28, 29, 30, 31, 32, 33]) {
      expect(getQuestionsForStage(s), isNotEmpty, reason: 'S$s data kept');
    }
  });

  for (final grade in GradeLevel.values) {
    testWidgets('体育ホーム($grade)に図工/音楽/家庭科の導線が出ず、げいじゅつ案内が出る',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 8000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(ProviderScope(
        overrides: [gradeLevelProvider.overrideWith((ref) => GradeLevelNotifier()..state = grade)],
        child: const MaterialApp(home: HomeScreen()),
      ));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byKey(const Key('taiku_geijutsu_guide')), findsOneWidget);
      expect(find.text('ずこう・おんがく・かていかは「げいじゅつ」で あそべるよ'),
          findsOneWidget);
      for (final label in ['図工', '音楽', '家庭科', '図工・美術']) {
        expect(find.text(label), findsNothing, reason: label);
      }
      for (final s in ['S28', 'S29', 'S30', 'S31', 'S32', 'S33']) {
        expect(find.text(s), findsNothing, reason: s);
      }
    });
  }
}
