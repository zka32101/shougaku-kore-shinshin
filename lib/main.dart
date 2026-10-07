import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cross_promo_kit/cross_promo_kit.dart' show CrossPromoService;
import 'firebase_options.dart';
import 'screens/home/main_shell.dart';
import 'screens/subscription/trial_status_screen.dart';
import 'screens/subscription/subscription_screen.dart';
import 'screens/settings/avatar_selection_screen.dart';
import 'screens/ranking/ranking_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/child_registration_screen.dart';
import 'screens/badge/badge_showcase_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'services/hive_service.dart';
import 'services/logger_service.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/premium_provider.dart';
import 'services/shinshin_purchase_service.dart';
import 'widgets/startup_splash.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初期化（Firebase・ローカル保存・課金）の間は組織ロゴ入りの起動画面を出す。
  // 初期化が終わったら、下の本番の runApp で置き換わる。
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartupSplash(),
    ),
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException(
          'Firebase initialization timeout after 10 seconds. '
          'Check your internet connection and Firebase configuration.',
        );
      },
    );

    LoggerService.info('Firebase initialized successfully');
  } catch (e, stackTrace) {
    LoggerService.error(
      'Firebase initialization error',
      error: e,
      stackTrace: stackTrace,
    );

    // Show error screen to user instead of crashing
    runApp(
      MaterialApp(
        title: '小学コレ！心身',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4CAF50),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: _ErrorScreen(error: e, stackTrace: stackTrace),
      ),
    );
    return;
  }

  // クロスプロモーション（他アプリ紹介）。失敗しても起動は止めない
  try {
    await CrossPromoService.init();
  } catch (_) {}

  // ローカル保存（設定・進捗）。失敗してもアプリは起動を続ける
  try {
    await HiveService().initialize();
  } catch (_) {}

  // 課金（RevenueCat）。キー未設定・失敗でも起動を続ける
  try {
    await ShinshinPurchaseService.instance.initialize();
  } catch (_) {}

  runApp(
    const ProviderScope(
      child: ShougakuKoreDoutokuApp(),
    ),
  );
}

/// Error screen shown when Firebase initialization fails
class _ErrorScreen extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;

  const _ErrorScreen({
    required this.error,
    required this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Initialization Error'),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                'Failed to Initialize App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Error: ${error.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please check:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                '• Internet connection is active\n'
                '• Firebase credentials are correctly configured\n'
                '• Firebase project is properly set up\n'
                '• Try restarting the app',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Restart app
                  main();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Main app widget with theme support
class ShougakuKoreDoutokuApp extends ConsumerWidget {
  const ShougakuKoreDoutokuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme mode and brightness
    ref.watch(initializeThemeProvider);
    ref.watch(premiumBootstrapProvider);
    final brightness = ref.watch(brightnessProvider);

    return MaterialApp(
      title: '小学コレ！心身',
      navigatorKey: navigatorKey,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: _themeModeToBrightness(brightness),
      // ステータスバーの時計・電池は、明るい画面では濃い色、暗い画面では白にする
      // (AppBar を持つ画面は AppBar 側の指定が優先される)
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const MainShell(),
        '/child-registration': (context) => const ChildRegistrationScreen(),
        '/trial_status': (context) => const TrialStatusScreen(),
        '/subscription': (context) => const SubscriptionScreen(),
        '/avatar_selection': (context) => const AvatarSelectionScreen(),
        '/ranking': (context) => const RankingScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/badge_showcase': (context) => const BadgeShowcaseScreen(),
      },
    );
  }

  /// Convert brightness to ThemeMode
  static ThemeMode _themeModeToBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
  }
}
