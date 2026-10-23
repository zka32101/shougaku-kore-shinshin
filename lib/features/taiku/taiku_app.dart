import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shougaku_kore_doutoku/widgets/shell_route_observer.dart';
import '../literacy_core/literacy_core.dart';
import 'screens/album_screen.dart';
import 'screens/badge_screen.dart';
import 'screens/home_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/parent_dashboard_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/result_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/sport_encyclopedia_screen.dart';
import 'providers/taiku_providers.dart' show activeTabProvider;

/// 体験・体育コレ！のテーマカラー
class TaikuColors {
  static const primary = Color(0xFFE64A19); // ディープオレンジ（スポーツ）
  static const sports = Color(0xFFFF6D00); // オレンジ
  static const disaster = Color(0xFF1565C0); // ブルー（防災）
  static const nutrition = Color(0xFF2E7D32); // グリーン（栄養）
  static const career = Color(0xFF6A1B9A); // パープル（キャリア）
  static const health = Color(0xFF00838F); // ティール（けんこう管理）
  static const safety = Color(0xFFB71C1C); // ダークレッド（安全・防犯）
  static const environment = Color(0xFF1B5E20); // ダークグリーン（環境）
  static const money = Color(0xFFF57F17); // アンバー（お金）
  static const values = Color(0xFF4A148C); // ディープパープル（道徳）
  static const art = Color(0xFFE91E63); // ピンク（図工）
  static const music = Color(0xFF7B1FA2); // パープル（音楽）
  static const homeEc = Color(0xFF5D4037); // ブラウン（家庭科）
  static const ict = Color(0xFF0277BD); // ブルー（ICT）
  static const experience = Color(0xFF795548); // ブラウン（体験活動）

  static Color forTheme(String theme) {
    switch (theme) {
      case 'sports':
        return sports;
      case 'disaster':
        return disaster;
      case 'nutrition':
        return nutrition;
      case 'career':
        return career;
      case 'health':
        return health;
      case 'safety':
        return safety;
      case 'environment':
        return environment;
      case 'money':
        return money;
      case 'values':
        return values;
      case 'art':
        return art;
      case 'music':
        return music;
      case 'home_ec':
        return homeEc;
      case 'experience':
        return experience;
      case 'ict':
        return ict;
      default:
        return primary;
    }
  }
}

/// 体験・体育コレ！モジュール（小学コレ！心身に統合）
///
/// 独立アプリだった頃の MaterialApp を、入れ子の Navigator に置き換えたもの。
/// 体育側の画面は pushNamed('/quiz') などの名前付きルートをそのまま使える。
class TaikuModule extends ConsumerStatefulWidget {
  /// アプリ全体の下部ナビを全画面ページで隠すための見張り役（任意）
  final ShellRouteObserver? observer;

  /// 最初に開く画面。全体のホームから「バッジ」「アルバム」「保護者」を直接開くときに使う
  final String initialRoute;

  /// 全体のホームから push で開いたとき true。トップで戻ると呼び出し元へ戻る
  final bool standalone;

  const TaikuModule({
    super.key,
    this.observer,
    this.initialRoute = '/',
    this.standalone = false,
  });

  @override
  ConsumerState<TaikuModule> createState() => _TaikuModuleState();
}

class _TaikuModuleState extends ConsumerState<TaikuModule> {
  final _navKey = GlobalKey<NavigatorState>();

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final builders = <String, WidgetBuilder>{
      '/': (_) => const SplashScreen(),
      '/onboarding': (_) => const OnboardingScreen(),
      '/home': (_) => const RootShell(),
      '/quiz': (_) => const QuizScreen(),
      '/result': (_) => const ResultScreen(),
      '/settings': (_) => const SettingsScreen(),
      '/parent': (_) => const ParentDashboardScreen(),
      '/sports': (_) => const SportEncyclopediaScreen(),
      '/badges': (_) => const BadgeScreen(),
      '/album': (_) => const AlbumScreen(),
    };
    final builder = builders[settings.name];
    if (builder == null) return null;
    return MaterialPageRoute<void>(builder: builder, settings: settings);
  }

  @override
  Widget build(BuildContext context) {
    final grade = ref.watch(gradeLevelProvider);
    return Theme(
      data: LiteracyTheme.buildFor(grade, subjectColor: TaikuColors.primary),
      // 体育モジュール内で戻れるうちは内側を pop、トップなら道徳側へ戻る
      child: NavigatorPopHandler(
        // 通常は戻る処理を MainShell が担当（二重 pop 防止）。単独で開いたときだけ呼び出し元へ戻る
        onPopWithResult: (_) {
          if (widget.standalone) Navigator.of(context).maybePop();
        },
        child: Navigator(
          key: _navKey,
          initialRoute: widget.initialRoute,
          observers: [if (widget.observer != null) widget.observer!],
          onGenerateRoute: _onGenerateRoute,
        ),
      ),
    );
  }
}

class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

/// 体育の入口。アプリ全体の下部ナビと重なる専用メニューは持たず、
/// 「たいいく（ホーム）」と「まなぶ」だけを切り替える。
/// バッジ・アルバム・保護者・設定は、アプリ全体のホームから開く。
class _RootShellState extends ConsumerState<RootShell> {
  int _tab = 0;

  static const _screens = [
    HomeScreen(),
    LearnScreen(),
  ];

  void _setTab(int i) {
    setState(() => _tab = i);
    ref.read(activeTabProvider.notifier).state = i;
  }

  @override
  Widget build(BuildContext context) {
    // activeTabProvider からの外部タブ切り替え（ホーム画面の「まなぶ」ボタンなど）
    ref.listen(activeTabProvider, (_, next) {
      if (next != _tab && next < _screens.length) setState(() => _tab = next);
    });

    // まなぶ画面でシステムの戻るを押したら、アプリを抜けずに体育ホームへ戻す
    return PopScope(
      canPop: _tab == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _tab != 0) _setTab(0);
      },
      child: Scaffold(
        body: Column(
          children: [
            if (_tab != 0)
              Material(
                color: Colors.white,
                elevation: 2,
                child: SafeArea(
                  bottom: false,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _setTab(0),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('たいいくへ もどる'),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: _tab != 0,
                child: IndexedStack(index: _tab, children: _screens),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
