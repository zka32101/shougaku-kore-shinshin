import 'package:shared_core/shared_core.dart';

/// 心身(小学コレ！心身)の利用時間制限(スクリーンタイム管理)Notifier。
///
/// shared_core の [BaseScreenTimeNotifier] を継承し、ストレージキーのみ
/// アプリ固有にする。`main.dart` の ProviderScope で注入する。
class ScreenTimeNotifier extends BaseScreenTimeNotifier {
  @override
  String get storageKey => 'shinshin_screen_time';
}
