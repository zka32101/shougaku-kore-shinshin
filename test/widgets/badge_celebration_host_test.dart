import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shougaku_kore_doutoku/models/badge.dart';
import 'package:shougaku_kore_doutoku/providers/badge_provider.dart';
import 'package:shougaku_kore_doutoku/providers/child_provider.dart';
import 'package:shougaku_kore_doutoku/widgets/badge_celebration_host.dart';
import 'package:shougaku_kore_doutoku/widgets/new_badge_dialog.dart';

final _ids = StateProvider<List<String>>((ref) => []);

Widget _app() => ProviderScope(
      overrides: [
        effectiveChildIdProvider.overrideWithValue('c1'),
        earnedBadgesProvider.overrideWith((ref, id) async => [
              for (final b in ref.watch(_ids))
                EarnedBadge(badgeId: b, earnedAt: DateTime(2026)),
            ]),
      ],
      child: MaterialApp(
        home: BadgeCelebrationHost(
          child: Consumer(builder: (c, ref, _) {
            ref.watch(_ids);
            return const Scaffold(body: Text('home'));
          }),
        ),
      ),
    );

ProviderContainer _c(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.text('home')));

Future<void> _settle(WidgetTester t) async {
  await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
  await t.pump();
  await t.pump(const Duration(milliseconds: 400));
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('初回起動後に新規バッジを獲得したら1回だけ出る・再表示しない・永続化される',
      (t) async {
    await t.pumpWidget(_app());
    await _settle(t);
    expect(find.byType(NewBadgeDialog), findsNothing);

    _c(t).read(_ids.notifier).state = ['first_story'];
    await _settle(t);
    expect(find.byType(NewBadgeDialog), findsOneWidget);

    await t.tap(find.text('了解'));
    await t.pumpAndSettle();
    expect(find.byType(NewBadgeDialog), findsNothing);

    // 同じ集合で再判定しても出ない
    _c(t).invalidate(earnedBadgesProvider('c1'));
    await _settle(t);
    expect(find.byType(NewBadgeDialog), findsNothing);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('notified_badges_c1'), contains('first_story'));
  });

  testWidgets('最初の判定がすでに獲得済みでも(取得が遅れた場合)通知される・複数は1つにまとまる',
      (t) async {
    await t.pumpWidget(_app());
    _c(t).read(_ids.notifier).state = ['first_story', 'courage_1'];
    await _settle(t);
    expect(find.byType(NewBadgeDialog), findsOneWidget);
    final d = t.widget<NewBadgeDialog>(find.byType(NewBadgeDialog));
    expect(d.badgeNames.length, 2);
  });

  testWidgets('通知済みIDが保存済みなら再起動後も出ない', (t) async {
    SharedPreferences.setMockInitialValues({
      'notified_badges_c1': ['first_story']
    });
    await t.pumpWidget(_app());
    _c(t).read(_ids.notifier).state = ['first_story'];
    await _settle(t);
    expect(find.byType(NewBadgeDialog), findsNothing);
  });

  testWidgets('360dp幅でオーバーフローしない', (t) async {
    t.view.physicalSize = const Size(360, 640);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(_app());
    _c(t).read(_ids.notifier).state = ['first_story', 'courage_1'];
    await _settle(t);
    expect(find.byType(NewBadgeDialog), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
