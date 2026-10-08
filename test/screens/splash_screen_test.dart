import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/models/child_profile.dart';
import 'package:shougaku_kore_doutoku/providers/auth_provider.dart';
import 'package:shougaku_kore_doutoku/providers/story_provider.dart' show apiServiceProvider;
import 'package:shougaku_kore_doutoku/screens/splash_screen.dart';
import 'package:shougaku_kore_doutoku/services/api_service.dart';
import 'package:shougaku_kore_doutoku/services/firebase_service.dart';
import '../helpers/firebase_test_helper.dart';

// ─── Fakes ───────────────────────────────────────────────────────────────────

/// 匿名サインインが失敗する（オフライン等）FirebaseService。
class _OfflineFirebaseService extends FirebaseService {
  @override
  Future<fb.User?> signInAnonymously() async => null;
}

/// バックエンドの応答を差し替える ApiService（実ネットワークは使わない）。
class _FakeApiService extends ApiService {
  _FakeApiService({this.children, this.unreachable = false});

  final List<ChildProfile>? children;
  final bool unreachable;

  @override
  Future<List<ChildProfile>> fetchChildrenProfiles() async {
    if (unreachable) throw Exception('backend unreachable');
    return children ?? const [];
  }
}

ChildProfile _child() => ChildProfile(
      id: 'c1',
      parentId: 'p1',
      name: 'たろう',
      grade: 3,
      avatarEmoji: '🌟',
      createdAt: DateTime(2024),
    );

// ─── Helper ──────────────────────────────────────────────────────────────────

Widget _wrap({required ApiService api}) => ProviderScope(
      overrides: [
        // 未サインイン状態。匿名サインインも失敗する（ゲスト続行の確認用）
        userAuthStateProvider.overrideWith((_) => Stream.value(null)),
        firebaseServiceProvider.overrideWithValue(_OfflineFirebaseService()),
        apiServiceProvider.overrideWithValue(api),
      ],
      child: MaterialApp(
        home: const SplashScreen(),
        routes: {
          '/home': (_) => const Scaffold(body: Text('HomePage')),
          '/child-registration': (_) =>
              const Scaffold(body: Text('RegisterPage')),
        },
      ),
    );

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  // Hive は初期化しない: 選択中の子どもIDの永続化(HiveService)は、未初期化なら
  // 例外が握りつぶされる設計。testWidgets の疑似時間内で実ファイルI/Oを行うと
  // 完了せずテストが固まるため。
  setUpAll(setupFirebaseForTest);

  group('SplashScreen', () {
    // ── Static UI (before the 1.5s startup timer fires) ───────────────────

    testWidgets('shows app icon and organization logo', (tester) async {
      await tester.pumpWidget(_wrap(api: _FakeApiService(unreachable: true)));
      await tester.pump();
      expect(find.byKey(const ValueKey('splash_app_icon')), findsOneWidget);
      expect(find.byKey(const ValueKey('splash_company_logo')), findsOneWidget);
      expect(find.text('Your Wish'), findsOneWidget);
      // Drain the 1.5s pending timer (+300ms auth-loading retry) so the test ends cleanly
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();
    });

    testWidgets('shows app title 小学コレ！心身', (tester) async {
      await tester.pumpWidget(_wrap(api: _FakeApiService(unreachable: true)));
      await tester.pump();
      expect(find.text('小学コレ！心身'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();
    });

    testWidgets('shows subtitle かっこいい大人になるために', (tester) async {
      await tester.pumpWidget(_wrap(api: _FakeApiService(unreachable: true)));
      await tester.pump();
      expect(find.text('かっこいい大人になるために'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();
    });

    // ── Navigation (after the 1.5s delay) ─────────────────────────────────
    // ログイン画面は廃止。匿名サインインに失敗してもゲストで続行する。

    testWidgets('continues as guest to /home when backend is unreachable',
        (tester) async {
      await tester.pumpWidget(_wrap(api: _FakeApiService(unreachable: true)));
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();
      expect(find.text('HomePage'), findsOneWidget);
    });

    testWidgets('goes to /home when a child profile exists', (tester) async {
      await tester.pumpWidget(_wrap(api: _FakeApiService(children: [_child()])));
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();
      expect(find.text('HomePage'), findsOneWidget);
    });

    testWidgets('goes to /child-registration when there is no child profile',
        (tester) async {
      await tester.pumpWidget(_wrap(api: _FakeApiService(children: const [])));
      await tester.pump(const Duration(milliseconds: 2000));
      await tester.pumpAndSettle();
      expect(find.text('RegisterPage'), findsOneWidget);
    });
  });
}
