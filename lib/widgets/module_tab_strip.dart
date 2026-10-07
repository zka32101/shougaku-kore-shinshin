import 'package:flutter/material.dart';

/// 画面上部に置く、横並びの切り替えタブ。
///
/// 体育・芸術モジュールの内側の切り替え（まなぶ／バッジ／…）を、アプリ全体の
/// 下部ナビと重ならないよう、画面の上側に出すために使う。
class ModuleTabStrip extends StatelessWidget {
  final List<ModuleTab> tabs;
  final int index;
  final ValueChanged<int> onTap;
  final Color color;

  const ModuleTabStrip({
    super.key,
    required this.tabs,
    required this.index,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            itemCount: tabs.length,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (context, i) {
              final t = tabs[i];
              final selected = i == index;
              return Semantics(
                button: true,
                selected: selected,
                label: t.label,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => onTap(i),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 40, minWidth: 64),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: selected ? color : color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Badge(
                          label: Text('${t.badge}'),
                          isLabelVisible: t.badge > 0,
                          child: Icon(t.icon,
                              size: 20, color: selected ? Colors.white : color),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          t.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: selected ? Colors.white : color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ModuleTab {
  final IconData icon;
  final String label;
  final int badge;
  const ModuleTab(this.icon, this.label, {this.badge = 0});
}
