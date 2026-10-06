import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/animal_avatar.dart';
import '../../providers/local_avatar_provider.dart';
import '../../widgets/avatar_display_widget.dart';

/// アバター選択画面。最初の4種は無料、残りはコインで購入する。
class AvatarSelectionScreen extends ConsumerWidget {
  const AvatarSelectionScreen({super.key});

  Future<void> _onTap(BuildContext context, WidgetRef ref, AnimalAvatar a) async {
    final st = ref.read(localAvatarProvider);
    final notifier = ref.read(localAvatarProvider.notifier);
    if (st.isOwned(a)) {
      await notifier.select(a);
      return;
    }
    final price = a.priceCoins ?? 0;
    final enough = st.coins >= price;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${a.name}を手に入れる？'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimalAvatarImage(avatar: a, size: 96),
            const SizedBox(height: 12),
            Text('$priceコインを使うよ（いま ${st.coins}コイン）'),
            if (!enough)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'あと${price - st.coins}コイン たりないよ！\nお話をよむとコインがもらえるよ。',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('やめる')),
          ElevatedButton(
            onPressed: enough ? () => Navigator.pop(ctx, true) : null,
            child: const Text('買う'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await notifier.purchase(a);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(localAvatarProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('アバターをえらぶ'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('🪙 ${st.coins}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemCount: kAnimalAvatars.length,
        itemBuilder: (context, i) {
          final a = kAnimalAvatars[i];
          final owned = st.isOwned(a);
          final selected = st.selectedId == a.id;
          return GestureDetector(
            onTap: () => _onTap(context, ref, a),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? Colors.blue : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: AnimalAvatarImage(
                        avatar: a,
                        size: 64,
                        opacity: owned ? 1 : 0.4,
                      ),
                    ),
                    if (!owned) const Icon(Icons.lock, color: Colors.white, size: 22),
                  ],
                ),
                const SizedBox(height: 4),
                Text(a.name, style: const TextStyle(fontSize: 11), maxLines: 1),
                if (!owned)
                  Text('🪙 ${a.priceCoins}',
                      style: const TextStyle(fontSize: 11, color: Colors.orange)),
              ],
            ),
          );
        },
      ),
    );
  }
}
