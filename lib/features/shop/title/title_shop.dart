import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/local_avatar_provider.dart';
import 'title_items.dart';
import 'title_provider.dart';

/// きせかえショップ内の「しょうごう」区分。コインで買う称号と、達成で解放される称号。
class TitleShop extends ConsumerWidget {
  const TitleShop({super.key});

  Future<void> _buy(BuildContext context, WidgetRef ref, TitleItem item) async {
    final coins = ref.read(localAvatarProvider).coins;
    final enough = coins >= item.coinCost;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('「${item.name}」を買う？（🪙${item.coinCost}）'),
        content: Text(enough
            ? '「${item.name}」に ${item.coinCost}コインを使うよ（いま $coinsコイン）'
            : 'あと${item.coinCost - coins}コイン たりないよ！\nお話をよむとコインがもらえるよ。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('やめる')),
          ElevatedButton(onPressed: enough ? () => Navigator.pop(ctx, true) : null, child: const Text('買う')),
        ],
      ),
    );
    if (ok == true) {
      final bought = await ref.read(titleProvider.notifier).purchase(item);
      if (bought && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('「${item.name}」を買ったよ！タップしてつけてね')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(titleProvider);
    final stats = ref.watch(titleStatsProvider);
    final notifier = ref.read(titleProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('しょうごう', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const Text('つけた称号は、ホームの名前の下に出るよ。もう一度タップすると外れるよ。',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final t in kTitleItems)
              _tile(
                t,
                available: isTitleAvailable(t, owned: s.owned, stats: stats),
                equipped: s.equipped == t.id,
                onTap: () {
                  final avail = isTitleAvailable(t, owned: s.owned, stats: stats);
                  if (avail) {
                    s.equipped == t.id ? notifier.unequip() : notifier.equip(t);
                  } else if (t.isCoin) {
                    _buy(context, ref, t);
                  }
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _tile(TitleItem t, {required bool available, required bool equipped, required VoidCallback onTap}) {
    final String sub;
    if (available) {
      sub = equipped ? '✓ つけてる' : 'もっている';
    } else if (t.isCoin) {
      sub = '🪙 ${t.coinCost}';
    } else {
      sub = '🔒 ${t.condition}';
    }
    return InkWell(
      key: ValueKey('title_shop_${t.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: equipped ? const Color(0xFF40D1B6) : Colors.grey.shade300, width: equipped ? 3 : 1),
        ),
        child: Column(
          children: [
            Opacity(opacity: available ? 1 : 0.45, child: _Mini(name: t.name)),
            const SizedBox(height: 4),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: available ? Colors.green : (t.isCoin ? Colors.orange : Colors.grey.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset('assets/title_plate/plate_shinshin.webp',
                fit: BoxFit.fill, errorBuilder: (c, e, s) => const SizedBox.shrink()),
          ),
          SizedBox(
            width: 90,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3E2A12))),
            ),
          ),
        ],
      ),
    );
  }
}
