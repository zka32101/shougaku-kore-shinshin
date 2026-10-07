import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shougaku_kore_doutoku/widgets/module_tab_strip.dart';
import 'package:shougaku_kore_doutoku/widgets/shell_route_observer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/app_providers.dart';
import 'screens/home_screen.dart';
import 'screens/badge_screen.dart';
import 'screens/parent_dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/art/color_diagnosis_screen.dart';
import 'screens/art/art_month_screen.dart';
import 'screens/art/canvas_screen.dart';
import 'screens/music/music_diagnosis_screen.dart';
import 'screens/music/composition_screen.dart';
import 'screens/home_ec/home_diagnosis_screen.dart';
import 'screens/home_ec/home_month_screen.dart';
import 'screens/home_ec/home_ec_hub_screen.dart';
import 'screens/home_ec/home_ec_topic_screen.dart';
import 'screens/music/music_hub_screen.dart';
import 'screens/music/free_piano_screen.dart';
import 'screens/music/theme_compose_screen.dart';
import 'screens/memory_screen.dart';
import 'theme/app_theme.dart';

/// 小学コレ！芸術モジュール（小学コレ！心身に統合）
///
/// 独立アプリだった頃の MaterialApp を入れ子の Navigator に置き換えたもの。
/// SharedPreferences はここで初期化して providers 側に渡す
/// （入れ子の ProviderScope + override は Riverpod の依存宣言が必要になるため使わない）。
class GeijutsuModule extends StatefulWidget {
  /// アプリ全体の下部ナビを全画面ページで隠すための見張り役（任意）
  final ShellRouteObserver? observer;

  const GeijutsuModule({super.key, this.observer});

  @override
  State<GeijutsuModule> createState() => _GeijutsuModuleState();
}

class _GeijutsuModuleState extends State<GeijutsuModule> {
  final _navKey = GlobalKey<NavigatorState>();
  late final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    Route<void> page(WidgetBuilder builder) =>
        MaterialPageRoute<void>(builder: builder, settings: settings);

    switch (settings.name) {
      case '/':
      case '/home':
        return page((_) => const RootShell());
      case '/memories':
        final tab = settings.arguments is int ? settings.arguments as int : 0;
        return page((_) => MemoryScreen(initialTab: tab));
      case '/badges':
        return page((_) => const BadgeScreen());
      case '/parent':
        return page((_) => const ParentDashboardScreen());
      case '/settings':
        return page((_) => const SettingsScreen());
      case '/art/diagnosis':
        return page((_) => const ColorDiagnosisScreen());
      case '/music/diagnosis':
        return page((_) => const MusicDiagnosisScreen());
      case '/music/hub':
        return page((_) => const MusicHubScreen());
      case '/music/free-piano':
        return page((_) => const FreePianoScreen());
      case '/music/theme-compose':
        return page((_) => const ThemeComposeScreen());
      case '/home-ec/diagnosis':
        return page((_) => const HomeDiagnosisScreen());
      case '/home-ec/hub':
        return page((_) => const HomeEcHubScreen());
      case '/art/month':
        final month = settings.arguments as int;
        return page((_) => ArtMonthScreen(month: month));
      case '/art/canvas':
        final args = settings.arguments as Map<String, dynamic>;
        return page((_) => CanvasScreen(args: args));
      case '/music/compose':
        final stage = settings.arguments as int;
        return page((_) => CompositionScreen(stage: stage));
      case '/home-ec/month':
        final month = settings.arguments as int;
        return page((_) => HomeMonthScreen(month: month));
      case '/home-ec/topic':
        final topicId = settings.arguments as String;
        return page((_) => HomeEcTopicScreen(topicId: topicId));
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: _prefs,
      builder: (context, snapshot) {
        final prefs = snapshot.data;
        if (prefs == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        geijutsuPrefs = prefs;
        return Theme(
          data: buildAppTheme(),
          // 芸術モジュール内で戻れるうちは内側を pop、トップなら心身側へ戻る
          child: NavigatorPopHandler(
            onPopWithResult: (_) {}, // 戻る処理は MainShell が担当（二重 pop 防止）
            child: Navigator(
              key: _navKey,
              initialRoute: '/', // '/home' だと '/' と二重に積まれるため '/' を直接ホームにする
              observers: [if (widget.observer != null) widget.observer!],
              onGenerateRoute: _onGenerateRoute,
            ),
          ),
        );
      },
    );
  }
}

class RootShell extends ConsumerStatefulWidget {
  const RootShell({super.key});

  @override
  ConsumerState<RootShell> createState() => _RootShellState();
}

class _RootShellState extends ConsumerState<RootShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    // アプリ全体の下部ナビと二重にならないよう、内側の切り替えは画面上部に置く
    return Scaffold(
      body: Column(
        children: [
          ModuleTabStrip(
            color: const Color(0xFFD81B60),
            index: _tab,
            onTap: (i) => setState(() => _tab = i),
            tabs: const [
              ModuleTab(Icons.palette, 'げいじゅつ'),
              ModuleTab(Icons.star, 'バッジ'),
              ModuleTab(Icons.family_restroom, '保護者'),
              ModuleTab(Icons.settings, '設定'),
            ],
          ),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: IndexedStack(
                index: _tab,
                children: const [
                  HomeScreen(),
                  BadgeScreen(),
                  ParentDashboardScreen(),
                  SettingsScreen(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
