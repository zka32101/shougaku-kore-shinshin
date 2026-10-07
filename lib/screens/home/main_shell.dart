import 'package:flutter/material.dart';
import '../characters/character_collection_screen.dart';
import '../library/library_screen.dart';
import '../../features/taiku/taiku_app.dart' show TaikuModule;
import '../../features/geijutsu/geijutsu_app.dart' show GeijutsuModule;
import 'home_screen.dart';

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

  void _select(HomeSection s) {
    setState(() {
      _current = s;
      _visited.add(s);
    });
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
        return const TaikuModule();
      case HomeSection.geijutsu:
        return const GeijutsuModule();
      case HomeSection.characters:
        return const CharacterCollectionScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // ホーム以外で「戻る」を押したら、アプリを閉じずにホームへ戻す
      canPop: _current == HomeSection.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(HomeSection.home);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _current.index,
          children: [
            for (final s in HomeSection.values)
              _visited.contains(s) ? _build(s) : const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
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
        ),
      ),
    );
  }
}
