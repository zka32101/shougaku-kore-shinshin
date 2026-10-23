import 'package:flutter/widgets.dart';
import 'package:shared_core/shared_core.dart' show requireParentalGate;

/// 大人であることを計算で確認する。通ったときだけ true（確認後も画面が残っているとき）。
///
/// 子どもが誤って、データの削除や公開範囲の変更などをしないためのもの。
/// [purpose] には、何の操作かを短く書く（例：「データを消す操作です。」）。
Future<bool> confirmAdult(BuildContext context, {required String purpose}) async {
  final ok = await requireParentalGate(
    context,
    description: '$purpose\n下の計算の答えを入力してください。',
  );
  return ok && context.mounted;
}
