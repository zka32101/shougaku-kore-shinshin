import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 学習画面は最初からすべて見られる（ロックしない）ため、常に child を表示する。
class AccessGuard extends ConsumerWidget {
  final Widget child;

  const AccessGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return child;
  }
}
