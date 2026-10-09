import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'title_provider.dart';

/// 教科別プレート画像の上に称号名を重ねる小さな表示（幅110程度）。
class TitlePlate extends StatelessWidget {
  const TitlePlate({super.key, required this.name, this.width = 110});

  final String name;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '称号 $name',
      child: ExcludeSemantics(
        child: SizedBox(
          key: const ValueKey('title_plate'),
          width: width,
          height: width / 3,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Image.asset('assets/title_plate/plate_shinshin.webp',
                    fit: BoxFit.fill, errorBuilder: (c, e, s) => const SizedBox.shrink()),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.16),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    name,
                    maxLines: 1,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3E2A12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ホームのヘッダー用。未選択なら何も出さない。
class HomeTitlePlate extends ConsumerWidget {
  const HomeTitlePlate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(equippedTitleNameProvider);
    if (name == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: TitlePlate(name: name),
    );
  }
}
