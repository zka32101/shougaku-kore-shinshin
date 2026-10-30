import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart'
    show onboardingProvider, weeklyChallengeProvider;

/// ホーム画面に出す定着率施策（初回7日間のごほうび・今週のお話チャレンジ）。
/// 出すものがなければ何も表示しない。
class RetentionSection extends ConsumerWidget {
  const RetentionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final weekly = ref.watch(weeklyChallengeProvider);
    final claimable = onboarding.claimable;

    return Column(
      children: [
        if (claimable.isNotEmpty) ...[
          Card(
            key: const Key('onboarding_rewards_card'),
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🎁 はじめての7日間ごほうび（${onboarding.claimedDays.length}/7）',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  for (final r in claimable)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('${r.day}日目: ${r.title}'),
                      // アイテム付きの説明文は、このアプリでは付与しないので出さない
                      subtitle: r.itemId == null ? Text(r.description) : null,
                      trailing: FilledButton(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final got = await ref
                              .read(onboardingProvider.notifier)
                              .claim(r.day);
                          if (got != null) {
                            messenger.showSnackBar(SnackBar(
                                content: Text('🪙 ${got.coins} コインをもらったよ！')));
                          }
                        },
                        child: Text('🪙 ${r.coins}'),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Card(
          key: const Key('weekly_story_challenge_card'),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weekly.isComplete
                      ? '🎉 今週のチャレンジ達成！'
                      : '🎯 今週のチャレンジ：あと${weekly.remaining}つ お話をよもう',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: weekly.progress),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
