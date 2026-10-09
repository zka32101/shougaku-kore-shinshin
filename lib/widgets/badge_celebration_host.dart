import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/badge.dart';
import '../providers/badge_provider.dart';
import '../providers/child_provider.dart';
import '../providers/progress_provider.dart';
import '../utils/badge_celebration.dart';
import 'new_badge_dialog.dart';

/// 新しく獲得したバッジを検知して達成演出ダイアログを1回だけ出す。
/// 通知済みIDは子どもごとに SharedPreferences へ保存する。
/// [recheck] が増えるたびに進捗を再取得して判定し直す。
class BadgeCelebrationHost extends ConsumerStatefulWidget {
  final Widget child;
  final ValueNotifier<int>? recheck;

  const BadgeCelebrationHost({super.key, required this.child, this.recheck});

  @override
  ConsumerState<BadgeCelebrationHost> createState() =>
      _BadgeCelebrationHostState();
}



class _BadgeCelebrationHostState extends ConsumerState<BadgeCelebrationHost> {
  bool _showing = false;

  static String _key(String childId) => 'notified_badges_$childId';

  @override
  void initState() {
    super.initState();
    widget.recheck?.addListener(_onRecheck);
  }

  @override
  void dispose() {
    widget.recheck?.removeListener(_onRecheck);
    super.dispose();
  }

  void _onRecheck() {
    final id = ref.read(effectiveChildIdProvider);
    ref.invalidate(userProgressProvider(id));
  }

  Future<void> _handle(String childId, List<EarnedBadge> earned) async {
    if (_showing) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_key(childId));
      final ids = earned.map((e) => e.badgeId).toList();
      // 初回(null)も「まだ何も通知していない」として扱う。
      // 以前は初回の既存分を黙って登録していたため、通信なしで進捗取得が遅れ、
      // 最初の判定が1話完了後になると獲得バッジが通知されなかった。
      final fresh = detectNewBadgeIds(
          earned: ids, notified: stored?.toSet() ?? <String>{});
      // 通知済みIDを追加登録（再表示・再起動後の再表示を防ぐ）
      await prefs.setStringList(
          _key(childId), {...?stored, ...ids}.toList());
      if (fresh.isEmpty || !mounted) return;
      final names = [
        for (final id in fresh)
          if (findBadge(id) != null) findBadge(id)!.name,
      ];
      if (names.isEmpty) return;
      _showing = true;
      await showDialog<void>(
        context: context,
        builder: (_) => NewBadgeDialog(badgeNames: names),
      );
      _showing = false;
    } catch (_) {
      _showing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final childId = ref.watch(effectiveChildIdProvider);
    ref.listen<AsyncValue<List<EarnedBadge>>>(
      earnedBadgesProvider(childId),
      (_, next) {
        final v = next.valueOrNull;
        if (v != null) _handle(childId, v);
      },
    );
    return widget.child;
  }
}
