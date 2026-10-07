import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart' show BaseCharacter;

import '../../data/shinshin_characters.dart';
import '../../data/shinshin_unlocks.dart';
import '../../providers/character_provider.dart';
import '../../providers/local_avatar_provider.dart';

/// コインが足りない時のやさしい案内文（足りていれば null）。
String? coinShortageMessage(int coins, int cost) {
  if (coins >= cost) return null;
  return 'あと${cost - coins}コイン たりないよ！\nストーリーを よむと コインが もらえるよ。';
}

/// 心身キャラ図鑑（16体・レベルアップ対応）。
class CharacterCollectionScreen extends ConsumerWidget {
  const CharacterCollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(shinshinCharacterProvider);
    final coins = ref.watch(localAvatarProvider.select((s) => s.coins));
    final cleared = storiesClearedFromCoins(
      ref.watch(localAvatarProvider.select((s) => s.totalEarned)),
    );
    final unlocked = unlockedCount(cleared, st.levelOf);
    return Scaffold(
      appBar: AppBar(title: const Text('キャラずかん')),
      backgroundColor: const Color(0xFFF7F9FC),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber),
                const SizedBox(width: 6),
                Text(
                  '$coins コイン',
                  key: const Key('coinBalance'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  'みつけた $unlocked / ${kShinshinCharacters.length}たい',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.8,
              ),
              itemCount: kShinshinCharacters.length,
              itemBuilder: (context, i) {
                final c = kShinshinCharacters[i];
                final isUnlocked = isCharacterUnlocked(
                  c.id,
                  storiesCleared: cleared,
                  level: st.levelOf(c.id),
                );
                return _CharacterTile(
                  character: c,
                  level: st.levelOf(c.id),
                  locked: !isUnlocked,
                  lockHint: unlockHint(c.id, cleared),
                  onTap: !isUnlocked
                      ? () => ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(
                                'まだ ひみつ！\n${unlockHint(c.id, cleared)}',
                              ),
                            ),
                          )
                      : () => showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (_) =>
                              _CharacterDetailSheet(characterId: c.id),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _levelLabel(int lv) => lv >= kShinshinMaxLevel ? 'MAX ✨' : 'Lv.$lv';

class _CharacterTile extends StatelessWidget {
  final BaseCharacter character;
  final int level;
  final VoidCallback onTap;
  final bool locked;
  final String lockHint;
  const _CharacterTile({
    required this.character,
    required this.level,
    required this.onTap,
    this.locked = false,
    this.lockHint = '',
  });

  @override
  Widget build(BuildContext context) {
    final isMax = level >= kShinshinMaxLevel;
    return GestureDetector(
      key: Key('tile_${character.id}'),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isMax ? Border.all(color: Colors.amber, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: locked
                    ? ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF9AA5B1),
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          character.imageAssetForLevel(1)!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      )
                    : Image.asset(
                        character.imageAssetForLevel(level)!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
              ),
            ),
            if (locked)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Column(
                  children: [
                    const Text(
                      '???',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black45,
                      ),
                    ),
                    Text(
                      lockHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        character.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _levelLabel(level),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isMax
                            ? Colors.amber.shade800
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CharacterDetailSheet extends ConsumerWidget {
  final String characterId;
  const _CharacterDetailSheet({required this.characterId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = kShinshinCharacters.firstWhere((e) => e.id == characterId);
    final st = ref.watch(shinshinCharacterProvider);
    final lv = st.levelOf(c.id);
    final cost = st.nextCost(c.id);
    final coins = ref.watch(localAvatarProvider.select((s) => s.coins));
    final primary = Theme.of(context).colorScheme.primary;
    final mq = MediaQuery.of(context);
    // 低い画面でもボタンまで届くよう、画像は画面高さの約28%に抑えスクロール可能にする
    final imgSize = (mq.size.height * 0.28).clamp(120.0, 220.0);
    final shortage = cost == null ? null : coinShortageMessage(coins, cost);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 32 + mq.padding.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              c.imageAssetForLevel(lv)!,
              key: const Key('detailImage'),
              width: imgSize,
              height: imgSize,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              c.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              '担当：${c.subject}',
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < kShinshinMaxLevel; i++)
                  Container(
                    width: 16,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i < lv ? Colors.amber : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  _levelLabel(lv),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: lv >= kShinshinMaxLevel
                        ? Colors.amber.shade800
                        : primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(c.backstory, style: const TextStyle(height: 1.7)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
              const SizedBox(width: 6),
              Text('もっているコイン：$coins'),
            ],
          ),
          const SizedBox(height: 16),
          if (cost == null)
            Center(
              key: const Key('maxLabel'),
              child: Text(
                '✨ MAXレベル！',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
            )
          else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                key: const Key('levelUpButton'),
                onPressed: shortage != null
                    ? null
                    : () => _confirmAndLevelUp(context, ref, c, lv),
                icon: const Icon(Icons.upgrade, size: 18),
                label: Text('Lv.${lv + 1} にそだてる（$costコイン）'),
              ),
            ),
            if (shortage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  shortage,
                  key: const Key('shortageText'),
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

Future<void> _confirmAndLevelUp(
  BuildContext context,
  WidgetRef ref,
  BaseCharacter c,
  int lv,
) async {
  final next = lv + 1;
  final cost = shinshinLevelUpCost(next)!;
  final messenger = ScaffoldMessenger.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('${c.name}を Lv.$next にする？'),
      content: Text('$costコインを つかうよ'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('やめる'),
        ),
        ElevatedButton(
          key: const Key('confirmLevelUp'),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('そだてる'),
        ),
      ],
    ),
  );
  if (ok != true) return;
  final err = await ref.read(shinshinCharacterProvider.notifier).levelUp(c.id);
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        err ??
            (next >= kShinshinMaxLevel
                ? '✨ ${c.name}が MAX レベルになったよ！'
                : '${c.name}が Lv.$next になったよ！'),
      ),
    ),
  );
}
