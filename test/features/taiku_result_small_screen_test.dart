import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shougaku_kore_doutoku/features/taiku/data/activity_catalog.dart';
import 'package:shougaku_kore_doutoku/features/taiku/providers/taiku_providers.dart';
import 'package:shougaku_kore_doutoku/features/taiku/screens/activity_screen.dart';
import 'package:shougaku_kore_doutoku/features/taiku/screens/result_screen.dart';

/// 「かんたん」な実体験があるステージ（ActivityScreen の初期表示で活動が出る）
final int _stage = allActivities
    .firstWhere((a) => a.difficulty == ActivityDifficulty.easy)
    .relatedStage;

const _sizes = <String, Size>{
  '360x640': Size(360, 640),
  '393x851': Size(393, 851),
};

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(ProviderScope(
    overrides: [currentStageProvider.overrideWith((ref) => _stage)],
    child: MaterialApp(
      home: const ResultScreen(),
      routes: {'/home': (_) => const Scaffold(body: Text('HOME'))},
    ),
  ));
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  for (final e in _sizes.entries) {
    group('ResultScreen ${e.key}', () {
      testWidgets('shows primary buttons without overflow (scrollable)',
          (tester) async {
        await _pump(tester, e.value);
        expect(tester.takeException(), isNull);
        expect(find.byType(SingleChildScrollView), findsWidgets);
        final practice = find.textContaining('じっさいにやって');
        expect(practice, findsOneWidget);
        await tester.scrollUntilVisible(practice, 100,
            scrollable: find.byType(Scrollable).first);
        final home = find.textContaining('ホーム');
        await tester.scrollUntilVisible(home, 100,
            scrollable: find.byType(Scrollable).first);
        expect(home, findsOneWidget);
        // 画面内に収まって押せる
        final r = tester.getRect(home);
        expect(r.bottom, lessThanOrEqualTo(e.value.height));
        expect(tester.takeException(), isNull);
      });

      testWidgets('photo chooser is reachable from the practice flow',
          (tester) async {
        await _pump(tester, e.value);
        final practice = find.textContaining('じっさいにやって');
        await tester.scrollUntilVisible(practice, 100,
            scrollable: find.byType(Scrollable).first);
        await tester.tap(practice);
        await tester.pumpAndSettle();
        // 活動カードを開いて「完了」を押す
        final act = find.byType(ActivityScreen);
        final list = find.descendant(of: act, matching: find.byType(Scrollable));
        await tester.tap(find
            .descendant(of: act, matching: find.byType(InkWell))
            .first);
        await tester.pumpAndSettle();
        final done = find.descendant(
            of: act, matching: find.byIcon(Icons.emoji_events));
        await tester.scrollUntilVisible(done.first, 100,
            scrollable: list.first);
        await tester.tap(done.first);
        await tester.pumpAndSettle();
        expect(find.text('カメラでとる'), findsOneWidget);
        expect(find.text('アルバムからえらぶ'), findsOneWidget);
      });
    });
  }
}
