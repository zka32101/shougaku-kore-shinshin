/// 獲得バッジの「新規分」を求める純関数。
///
/// - [notified] が null（初回起動＝まだ一度も記録していない）の場合は
///   既存の獲得済みを一括で通知済みにするため、新規は空を返す。
/// - それ以外は [earned] のうち [notified] に無いIDだけを、重複なし・順序維持で返す。
List<String> detectNewBadgeIds({
  required Iterable<String> earned,
  required Set<String>? notified,
}) {
  if (notified == null) return const [];
  final seen = <String>{};
  return [
    for (final id in earned)
      if (!notified.contains(id) && seen.add(id)) id,
  ];
}
