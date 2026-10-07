import 'package:flutter/material.dart';

/// モジュール（体育・芸術）の内側 Navigator を見張り、「/home」以外の
/// 全画面ページ（クイズ・結果・描画・撮影など）が開いている間は
/// [fullScreen] を true にする。アプリ全体の下部ナビを隠すために使う。
class ShellRouteObserver extends NavigatorObserver {
  final ValueNotifier<bool> fullScreen = ValueNotifier(false);
  final List<Route<dynamic>> _stack = [];

  bool get _wantFullScreen {
    // 土台の「/home」が一番上のときだけナビを表示する
    final top = _stack.isEmpty ? null : _stack.last;
    return top != null && top.settings.name != '/home';
  }

  void _update() {
    if (fullScreen.value == _wantFullScreen) return;
    // build 中の通知を避ける。実行時点の最新状態で決める（途中の状態で上書きしない）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final next = _wantFullScreen;
      if (fullScreen.value != next) fullScreen.value = next;
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute) _stack.add(route);
    _update();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
    _update();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
    _update();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final i = oldRoute == null ? -1 : _stack.indexOf(oldRoute);
    if (i >= 0) _stack.removeAt(i);
    if (newRoute is PageRoute) {
      _stack.insert(i >= 0 ? i : _stack.length, newRoute);
    }
    _update();
  }

  /// 内側に戻れるページがあれば1つ戻る。戻れたら true。
  Future<bool> popInner() async => await (navigator?.maybePop() ?? false);

  void dispose() => fullScreen.dispose();
}
