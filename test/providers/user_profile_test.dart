import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shougaku_kore_doutoku/features/taiku/providers/child_profiles_provider.dart';
import 'package:shougaku_kore_doutoku/providers/furigana_provider.dart';
import 'package:shougaku_kore_doutoku/providers/user_profile_provider.dart';
import 'package:shougaku_kore_doutoku/widgets/profile_name_card.dart';

/// テスト用: container から WidgetRef を取り出して saveUserProfile を呼ぶ。
Future<void> _save(WidgetTester tester, ProviderContainer c,
    {required String name, int? grade, String? emoji}) async {
  late WidgetRef r;
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: Consumer(builder: (_, ref, _) {
      r = ref;
      return const SizedBox();
    }),
  ));
  await saveUserProfile(r, name: name, grade: grade, emoji: emoji);
}

Future<ProviderContainer> _boot([Map<String, Object>? init]) async {
  SharedPreferences.setMockInitialValues(init ?? {});
  final c = ProviderContainer();
  c.read(childProfilesProvider);
  c.read(profileGradeProvider);
  c.read(profileCardDismissedProvider);
  await Future<void>.delayed(const Duration(milliseconds: 50));
  return c;
}

void main() {
  group('validateProfileName', () {
    test('空・空白のみは不可', () {
      expect(validateProfileName(''), isNotNull);
      expect(validateProfileName('   '), isNotNull);
    });
    test('11文字以上は不可、10文字は可', () {
      expect(validateProfileName('あ' * 10), isNull);
      expect(validateProfileName('あ' * 11), isNotNull);
    });
    test('前後の空白は除く', () {
      expect(normalizeProfileName('  たろう '), 'たろう');
      expect(validateProfileName(' ${'あ' * 10} '), isNull);
    });
  });

  group('プロフィール保存', () {
    testWidgets('名前を入れるとID不変で名前・学年が変わり、ふりがな学年に反映', (tester) async {
      await tester.runAsync(() async {
        final c = await _boot();
        addTearDown(c.dispose);
        final idBefore = c.read(currentChildProfileProvider)!.id;
        expect(c.read(displayNameProvider), isNull);
        expect(c.read(showNameCardProvider), isTrue);
        expect(c.read(readingGradeProvider), 2);

        await _save(tester, c, name: ' たろう ', grade: 5, emoji: '🐱');

        final p = c.read(currentChildProfileProvider)!;
        expect(p.id, idBefore);
        expect(p.name, 'たろう');
        expect(p.emoji, '🐱');
        expect(c.read(displayNameProvider), 'たろう');
        expect(c.read(showNameCardProvider), isFalse);
        expect(c.read(readingGradeProvider), 5);
      });
    });

    testWidgets('学年を選ばない保存は既存の学年を変えない', (tester) async {
      await tester.runAsync(() async {
        final c = await _boot();
        addTearDown(c.dispose);
        final before = c.read(currentChildProfileProvider)!.gradeLevel;
        await _save(tester, c, name: 'はな');
        expect(c.read(currentChildProfileProvider)!.gradeLevel, before);
        expect(c.read(profileGradeProvider), isNull);
      });
    });

    testWidgets('既存プロフィールのIDは変わらない', (tester) async {
      await tester.runAsync(() async {
        final c = await _boot({
          'taiku_child_profiles':
              '[{"id":"12345","name":"子ども1","gradeLevel":1,"color":"#2196F3","emoji":"👦","createdAt":1000}]',
          'taiku_current_profile_id': '12345',
        });
        addTearDown(c.dispose);
        await _save(tester, c, name: 'みお', grade: 4);
        expect(c.read(currentChildProfileProvider)!.id, '12345');
        expect(c.read(childProfilesProvider).profiles.length, 1);
      });
    });
  });

  group('ホームのカード', () {
    testWidgets('360x600でも溢れず、あとでで消える', (tester) async {
      tester.view.physicalSize = const Size(360, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.runAsync(() async {
        final c = await _boot();
        addTearDown(c.dispose);
        await tester.pumpWidget(UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(
            home: Scaffold(body: ProfileNameCard()),
          ),
        ));
        await tester.pump();
        expect(find.byKey(const Key('profile_name_card')), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('あとで'));
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
        expect(find.byKey(const Key('profile_name_card')), findsNothing);
      });
    });
  });
}
