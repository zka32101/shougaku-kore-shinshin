import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/app_providers.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
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
import 'screens/profile_select_screen.dart';
import 'theme/app_theme.dart';

/// 小学コレ！芸術モジュール（小学コレ！心身に統合）
///
/// 独立アプリだった頃の MaterialApp を入れ子の Navigator に置き換えたもの。
/// SharedPreferences はここで初期化して providers 側に渡す
/// （入れ子の ProviderScope + override は Riverpod の依存宣言が必要になるため使わない）。
class GeijutsuModule extends StatefulWidget {
  const GeijutsuModule({super.key});

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
        return page((_) => const SplashScreen());
      case '/onboarding':
        return page((_) => const OnboardingScreen());
      case '/home':
        return page((_) => const RootShell());
      case '/profile-select':
        return page((context) {
          final isSwitch = ModalRoute.of(context)?.settings.arguments == true;
          return ProfileSelectScreen(isSwitch: isSwitch);
        });
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
            onPopWithResult: (_) => _navKey.currentState?.maybePop(),
            child: Navigator(
              key: _navKey,
              initialRoute: '/',
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
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [
          HomeScreen(),
          BadgeScreen(),
          ParentDashboardScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'バッジ'),
          BottomNavigationBarItem(icon: Icon(Icons.family_restroom), label: '親'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}
