import 'package:flutter/material.dart';

/// 画面いっぱいに広がる Column（Spacer 付き）を、小さい画面でも
/// 下のボタンが切れないようスクロールできるようにする入れ物。
/// 画面が十分大きいときは従来どおり下端にボタンが並ぶ。
class ScrollFill extends StatelessWidget {
  final EdgeInsets padding;
  final Widget child;

  const ScrollFill({
    super.key,
    this.padding = EdgeInsets.zero,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final minH = (c.maxHeight - padding.vertical).clamp(0.0, double.infinity);
        return SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minH),
            child: IntrinsicHeight(child: child),
          ),
        );
      },
    );
  }
}
