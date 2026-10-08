import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/story_provider.dart';
import '../providers/child_provider.dart';
import '../widgets/branded_splash.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  // バックエンドが応答しない時にスプラッシュで待ち続けないための上限
  static const _backendTimeout = Duration(seconds: 3);

  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // スプラッシュを最低 1.5 秒は表示してから起動フロー開始
    Future.delayed(const Duration(milliseconds: 1500), _runStartupFlow);
  }

  /// 起動フロー: 匿名認証 → JWT交換 → 子どもチェック → 適切な画面へ遷移
  Future<void> _runStartupFlow() async {
    if (!mounted || _navigated) return;

    // Firebase 認証状態を確認（まだ読み込み中なら再試行）
    final authState = ref.read(userAuthStateProvider);
    if (authState is AsyncLoading) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _runStartupFlow();
    }

    // ログイン画面は無し: 未認証なら匿名サインインし、失敗してもゲストで続行する
    var user = authState.asData?.value;
    user ??= await ref.read(firebaseServiceProvider).signInAnonymously();

    final api = ref.read(apiServiceProvider);
    if (user != null) {
      // Firebase ID トークンをバックエンド JWT に交換（失敗してもゲストで続行）
      try {
        final idToken = await user.getIdToken();
        if (idToken != null) {
          final result = await api
              .loginWithFirebase(idToken)
              .timeout(_backendTimeout);
          final jwt = result['accessToken'] as String?;
          if (jwt != null) api.setAuthToken(jwt);
        }
      } catch (_) {}
    }

    // 子どもプロフィールの存在を確認してルーティング
    try {
      final children = await api.fetchChildrenProfiles().timeout(_backendTimeout);
      if (!mounted) return;
      _navigated = true;
      if (children.isNotEmpty) {
        // 最初の子どもを選択状態にしてホームへ
        ref.read(currentChildIdProvider.notifier).state = children.first.id;
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // 子どもがいない → 子ども登録画面へ
        Navigator.of(context).pushReplacementNamed('/child-registration');
      }
    } catch (_) {
      // API エラー (ネットワーク不調など) → ゲストモードでホームへ
      _navigated = true;
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 起動画面（StartupSplash）と同じ見た目。アニメを再生し直さない。
    return const BrandedSplash(
      title: '小学コレ！心身',
      subtitle: 'かっこいい大人になるために',
      gradient: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
      animate: false,
    );
  }
}
