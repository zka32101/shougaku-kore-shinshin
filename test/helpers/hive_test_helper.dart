import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shougaku_kore_doutoku/services/hive_service.dart';

/// HiveService を一時ディレクトリで初期化する。
///
/// HiveService は状態を static に持つので、[setUpAll] で一度呼べば、
/// 同じファイル内のテスト（testWidgets を含む）から使える。
/// testWidgets の中（FakeAsync）で呼ぶとファイル I/O が進まないため、
/// 必ず setUp/setUpAll から呼ぶこと。
Future<Directory> initHiveForTest() async {
  final dir = await Directory.systemTemp.createTemp('hive_test_');
  HiveService.resetForTesting();
  await HiveService().initialize(path: dir.path);
  return dir;
}

Future<void> disposeHiveForTest(Directory dir) async {
  await Hive.close();
  if (dir.existsSync()) {
    try {
      dir.deleteSync(recursive: true);
    } catch (_) {}
  }
}
