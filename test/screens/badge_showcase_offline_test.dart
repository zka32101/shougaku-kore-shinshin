import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shougaku_kore_doutoku/models/badge.dart';
import 'package:shougaku_kore_doutoku/models/progress.dart';
import 'package:shougaku_kore_doutoku/models/story.dart';
import 'package:shougaku_kore_doutoku/providers/badge_provider.dart';
import 'package:shougaku_kore_doutoku/providers/child_provider.dart';
import 'package:shougaku_kore_doutoku/providers/progress_provider.dart';
import 'package:shougaku_kore_doutoku/providers/story_provider.dart'
    show apiServiceProvider, hiveServiceProvider;
import 'package:shougaku_kore_doutoku/screens/badge/badge_showcase_screen.dart';
import 'package:shougaku_kore_doutoku/services/api_service.dart';
import 'package:shougaku_kore_doutoku/services/hive_service.dart';
import 'package:shougaku_kore_doutoku/services/local_completion_store.dart';
import 'package:shougaku_kore_doutoku/services/local_story_service.dart';

class _FakeApi extends ApiService {
  bool fail = true;
  List<Progress> progress = [];

  @override
  Future<List<Story>> fetchStories({
    String? theme,
    int? gradeLevel,
    bool? isPremium,
  }) async {
    throw Exception('offline');
  }

  @override
  Future<List<Progress>> fetchProgress(
    String childId, {
    int limit = 100,
  }) async {
    if (fail) throw Exception('offline');
    return progress;
  }
}

class _FakeHive extends HiveService {
  @override
  Future<void> cacheProgressList(List<Progress> items) async {}
  @override
  Future<void> cacheStories(List<Story> items) async {}
  @override
  Future<List<Progress>> getCachedProgress(String childId) async => [];
  @override
  Future<List<Story>> getCachedStories({
    String? theme,
    int? gradeLevel,
    bool? isPremium,
  }) async => [];
}

ProviderContainer _container(_FakeApi api) => ProviderContainer(
  overrides: [
    apiServiceProvider.overrideWithValue(api),
    hiveServiceProvider.overrideWithValue(_FakeHive()),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpScreen(WidgetTester tester, ProviderContainer c) async {
    // 同梱ストーリーのassetは実時間で先に読み込んでおく（fakeAsyncで固まらないように）
    await tester.runAsync(() => LocalStoryService.stories());
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: BadgeShowcaseScreen()),
      ),
    );
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('サーバー例外でも端末内定義のバッジが並び、エラー文は出ない(360dp)', (tester) async {
    final c = _container(_FakeApi());
    addTearDown(c.dispose);
    await pumpScreen(tester, c);

    expect(find.text('データを読み込めませんでした。通信状態を確認して、もう一度ためしてね。'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
    expect(find.text('${kDoutokuBadges.length}'), findsOneWidget);
    expect(find.text('0'), findsWidgets);
  });

  testWidgets('オフラインでストーリー1回完了すると獲得済みが2件になる(360dp)', (tester) async {
    SharedPreferences.setMockInitialValues({
      'local_story_completions_$kLocalChildId':
          '[{"storyId":"s1","theme":"kindness","at":"2026-10-01T00:00:00.000"}]',
    });
    final c = _container(_FakeApi());
    addTearDown(c.dispose);
    await pumpScreen(tester, c);
    expect(tester.takeException(), isNull);
    // first_story と kindness_1
    expect(find.text('2'), findsWidgets);
    expect(find.text('データを読み込めませんでした。通信状態を確認して、もう一度ためしてね。'), findsNothing);
  });

  testWidgets('端末内の進捗でバッジの獲得/未獲得が切り替わる', (tester) async {
    await tester.runAsync(() async {
      final c = _container(_FakeApi());
      addTearDown(c.dispose);

      var earned = await c.read(earnedBadgesProvider(kLocalChildId).future);
      expect(earned, isEmpty);

      await LocalCompletionStore.record(
        childId: kLocalChildId,
        storyId: 's1',
        theme: 'kindness',
      );
      c.invalidate(userProgressProvider(kLocalChildId));
      earned = await c.read(earnedBadgesProvider(kLocalChildId).future);
      final ids = earned.map((e) => e.badgeId).toSet();
      expect(ids, containsAll(['first_story', 'kindness_1']));
      expect(ids.contains('kindness_3'), isFalse);
      expect(ids.contains('honesty_1'), isFalse);
    });
  });

  testWidgets('サーバーが応答したときはサーバーの値を使う', (tester) async {
    await tester.runAsync(() async {
      final api = _FakeApi()
        ..fail = false
        ..progress = [
          for (var i = 0; i < 3; i++)
            Progress(
              id: 'p$i',
              childId: kLocalChildId,
              storyId: 'srv$i',
              action: 'story_completed',
              virtue: 'honesty',
              recordedAt: DateTime.now(),
            ),
        ];
      final c = _container(api);
      addTearDown(c.dispose);
      final ids = (await c.read(
        earnedBadgesProvider(kLocalChildId).future,
      )).map((e) => e.badgeId).toSet();
      expect(ids, containsAll(['honesty_1', 'honesty_3', 'first_story']));
      expect(ids.contains('kindness_1'), isFalse);
    });
  });
}
