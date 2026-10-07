import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/models/child_profile.dart';
import 'package:shougaku_kore_doutoku/models/story.dart';
import 'package:shougaku_kore_doutoku/providers/child_provider.dart';
import 'package:shougaku_kore_doutoku/providers/progress_provider.dart';
import 'package:shougaku_kore_doutoku/providers/story_provider.dart'; // allLocalStoriesProvider
import 'package:shougaku_kore_doutoku/screens/library/library_screen.dart';

// ─── Fixtures ────────────────────────────────────────────────────────────────

final _testChild = ChildProfile(
  id: 'child-1',
  parentId: 'parent-1',
  name: 'はなこ',
  grade: 4,
  avatarEmoji: '🌸',
  createdAt: DateTime(2024, 1, 1),
);

Story _makeStory({
  String id = 'story-1',
  String title = 'テストストーリー',
  String theme = 'kindness',
  bool isPremium = false,
  int gradeLevel = 3,
}) {
  return Story.fromJson({
    'id': id,
    'title': title,
    'description': '説明',
    'theme': theme,
    'gradeLevel': gradeLevel,
    'difficulty': 1,
    'isPremium': isPremium,
    'content': null,
    'durationSeconds': 300,
    'createdAt': '2024-01-01T00:00:00.000Z',
    'updatedAt': '2024-01-01T00:00:00.000Z',
  });
}

// ─── Helper ──────────────────────────────────────────────────────────────────

Widget _wrap({
  ChildProfile? child,
  List<Story>? allStories,
  List<Story>? completedStories,
}) {
  return ProviderScope(
    overrides: [
      selectedChildProvider.overrideWith(
        (ref) => Future.value(child),
      ),
      allLocalStoriesProvider.overrideWith(
        (ref) => Future.value(allStories ?? []),
      ),
      completedStoriesProvider.overrideWith(
        (ref, _) => Future.value(completedStories ?? []),
      ),
    ],
    child: const MaterialApp(
      home: LibraryScreen(),
    ),
  );
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('LibraryScreen', () {
    testWidgets('shows AppBar with title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.text('どうとく ストーリー'), findsOneWidget);
    });

    testWidgets('shows two tabs: ぜんぶ / クリアしたお話', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.text('ぜんぶ'), findsWidgets);
      expect(find.text('クリアしたお話'), findsOneWidget);
    });

    group('All tab', () {
      testWidgets('shows empty view when no stories', (tester) async {
        await tester.pumpWidget(_wrap(allStories: []));
        await tester.pumpAndSettle();
        expect(find.text('この条件のお話はまだないよ'), findsOneWidget);
      });

      testWidgets('shows every story with its grade band tag', (tester) async {
        final stories = [
          _makeStory(title: '友情の話', gradeLevel: 1),
          _makeStory(id: 'story-2', title: '勇気の話', gradeLevel: 6),
        ];
        await tester.pumpWidget(_wrap(allStories: stories));
        await tester.pumpAndSettle();
        expect(find.text('友情の話'), findsOneWidget);
        expect(find.text('勇気の話'), findsOneWidget);
        expect(find.text('低学年'), findsWidgets);
        expect(find.text('高学年'), findsWidgets);
      });

      testWidgets('premium story shows no Premium tag (no locks)', (tester) async {
        final story = _makeStory(isPremium: true);
        await tester.pumpWidget(_wrap(allStories: [story]));
        await tester.pumpAndSettle();
        expect(find.text('Premium'), findsNothing);
      });

      testWidgets('has grade and theme filter chips', (tester) async {
        await tester.pumpWidget(_wrap());
        await tester.pumpAndSettle();
        expect(find.text('低学年(1-2年)'), findsOneWidget);
        expect(find.text('中学年(3-4年)'), findsOneWidget);
        expect(find.text('高学年(5-6年)'), findsOneWidget);
        expect(find.text('思いやり'), findsOneWidget);
        expect(find.text('勇気'), findsOneWidget);
      });

      testWidgets('grade chip filters the list', (tester) async {
        final stories = [
          _makeStory(title: 'ひくい', gradeLevel: 1),
          _makeStory(id: 'story-2', title: 'たかい', gradeLevel: 6),
        ];
        await tester.pumpWidget(_wrap(allStories: stories));
        await tester.pumpAndSettle();
        await tester.tap(find.text('高学年(5-6年)'));
        await tester.pumpAndSettle();
        expect(find.text('たかい'), findsOneWidget);
        expect(find.text('ひくい'), findsNothing);
      });

      testWidgets('theme chip filters the list', (tester) async {
        final stories = [
          _makeStory(title: '思いやりのお話', theme: 'kindness'),
          _makeStory(id: 'story-2', title: '勇気のお話', theme: 'courage'),
        ];
        await tester.pumpWidget(_wrap(allStories: stories));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilterChip, '勇気'));
        await tester.pumpAndSettle();
        expect(find.text('勇気のお話'), findsOneWidget);
        expect(find.text('思いやりのお話'), findsNothing);
      });
    });

    group('Completed tab', () {
      testWidgets('shows no-child message when child is null', (tester) async {
        await tester.pumpWidget(_wrap(child: null));
        await tester.pumpAndSettle();
        await tester.tap(find.text('クリアしたお話'));
        await tester.pumpAndSettle();
        expect(find.text('お子さんを選択してください'), findsOneWidget);
      });

      testWidgets('shows empty state when no completed stories', (tester) async {
        await tester.pumpWidget(
          _wrap(child: _testChild, completedStories: []),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('クリアしたお話'));
        await tester.pumpAndSettle();
        expect(find.textContaining('まだ完了したストーリーはありません'), findsOneWidget);
      });

      testWidgets('shows completed stories list', (tester) async {
        final completed = [
          _makeStory(id: 'story-done', title: '完了済みストーリー'),
        ];
        await tester.pumpWidget(
          _wrap(child: _testChild, completedStories: completed),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('クリアしたお話'));
        await tester.pumpAndSettle();
        expect(find.text('完了済みストーリー'), findsOneWidget);
      });
    });
  });
}
