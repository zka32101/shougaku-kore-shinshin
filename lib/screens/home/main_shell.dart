import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/taiku/providers/album_provider.dart';
import '../../features/taiku/screens/activity_screen.dart' show recoverLostPhotoMemory;
import '../characters/character_collection_screen.dart';
import '../library/library_screen.dart';
import '../../features/taiku/taiku_app.dart' show TaikuModule;
import '../../features/geijutsu/geijutsu_app.dart' show GeijutsuModule;
import '../../widgets/badge_celebration_host.dart';
import '../../widgets/shell_route_observer.dart';
import 'home_screen.dart';
import 'shell_navigation.dart';

/// アプリ全体の土台。いつも下に表示されるナビゲーションバーで、
/// ホーム／どうとく／たいいく／げいじゅつ／キャラ をワンタップで切り替えられる。
///
/// 各タブの画面は最初に開いたときに作る（起動を重くしない）。
/// 切り替えても各タブの状態は保たれる（IndexedStack）。
class MainShell extends StatefulWidget {
  /// テストで重い画面を差し替えるための引数（省略時は本物の画面）。
  final Map<HomeSection, WidgetBuilder>? tabBuilders;

  const MainShell({super.key, this.tabBuilders});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  HomeSection _current = HomeSection.home;
  final Set<HomeSection> _visited = {HomeSection.home};
  // 体育・芸術の内側で全画面ページ（クイズ・結果・描画・撮影など）が開いている間は下部ナビを隠す
  final _taikuObs = ShellRouteObserver();
  final _geijutsuObs = ShellRouteObserver();
  // タブを切り替えるたびにバッジ獲得を再判定する
  final _badgeRecheck = ValueNotifier<int>(0);

  ShellRouteObserver? _obsFor(HomeSection s) => switch (s) {
        HomeSection.taiku => _taikuObs,
        HomeSection.geijutsu => _geijutsuObs,
        _ => null,
      };

  void _onShellRequest() {
    final s = shellSectionRequest.value;
    if (s == null) return;
    shellSectionRequest.value = null;
    if (mounted) _select(s);
  }

  @override
  void initState() {
    super.initState();
    shellSectionRequest.addListener(_onShellRequest);
    // 撮影中に端末がアプリを終了していたら、撮った写真をアルバムへ保存し直す
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final container = ProviderScope.containerOf(context);
      final saved =
          await recoverLostPhotoMemory(container.read(albumProvider.notifier));
      if (saved && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('アルバムに保存したよ！📷')),
        );
      }
    });
  }

  @override
  void dispose() {
    shellSectionRequest.removeListener(_onShellRequest);
    _taikuObs.dispose();
    _geijutsuObs.dispose();
    _badgeRecheck.dispose();
    super.dispose();
  }

  // ホームで「戻る」を押したとき、2秒以内にもう一度押すと終了する（うっかり終了を防ぐ）
  DateTime? _lastHomeBack;

  void _backAtHome() {
    final now = DateTime.now();
    final last = _lastHomeBack;
    if (last != null && now.difference(last) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
      return;
    }
    _lastHomeBack = now;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('もう一度おすと、アプリをとじるよ'),
        duration: Duration(seconds: 2),
      ));
  }

  void _select(HomeSection s) {
    setState(() {
      _current = s;
      _visited.add(s);
    });
    _badgeRecheck.value++;
  }

  Widget _build(HomeSection s) {
    final custom = widget.tabBuilders?[s];
    if (custom != null) return Builder(builder: custom);
    switch (s) {
      case HomeSection.home:
        return HomeScreen(onSelectSection: _select);
      case HomeSection.doutoku:
        return const LibraryScreen();
      case HomeSection.taiku:
        return TaikuModule(observer: _taikuObs);
      case HomeSection.geijutsu:
        return GeijutsuModule(observer: _geijutsuObs);
      case HomeSection.characters:
        return const CharacterCollectionScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final obs = _obsFor(_current);
    final shell = _buildShell(obs);
    // テスト用に画面を差し替えた場合(tabBuilders)は演出ホストを付けない
    if (widget.tabBuilders != null) return shell;
    return BadgeCelebrationHost(recheck: _badgeRecheck, child: shell);
  }

  Widget _buildShell(ShellRouteObserver? obs) {
    return ListenableBuilder(
      listenable: obs?.fullScreen ?? _never,
      builder: (context, _) {
        final hideBar = obs?.fullScreen.value ?? false;
        return PopScope(
          // ホーム以外で「戻る」を押したら、まず内側の画面を戻し、無ければホームへ戻す。
          // ホームでは「もう一度おすと終了」を出す
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (_current == HomeSection.home) {
              _backAtHome();
              return;
            }
            if (hideBar && await obs!.popInner()) return;
            _select(HomeSection.home);
          },
          child: Scaffold(
            body: IndexedStack(
              index: _current.index,
              children: [
                for (final s in HomeSection.values)
                  _visited.contains(s) ? _build(s) : const SizedBox.shrink(),
              ],
            ),
            bottomNavigationBar: hideBar ? null : _bar(),
          ),
        );
      },
    );
  }

  static final _never = ValueNotifier<bool>(false);

  Widget _bar() {
    return NavigationBar(
      selectedIndex: _current.index,
      onDestinationSelected: (i) => _select(HomeSection.values[i]),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 68,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'ホーム',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: 'どうとく',
        ),
        NavigationDestination(
          icon: Icon(Icons.directions_run_outlined),
          selectedIcon: Icon(Icons.directions_run),
          label: 'たいいく',
        ),
        NavigationDestination(
          icon: Icon(Icons.palette_outlined),
          selectedIcon: Icon(Icons.palette),
          label: 'げいじゅつ',
        ),
        NavigationDestination(
          icon: Icon(Icons.pets_outlined),
          selectedIcon: Icon(Icons.pets),
          label: 'キャラ',
        ),
      ],
    );
  }
}
