import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import 'package:shougaku_kore_doutoku/widgets/ukalab_emoji.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artworks = ref.watch(artworkProvider);
    final compositions = ref.watch(compositionProvider);
    final challenges = ref.watch(homeChallengeProvider);
    final badges = ref.watch(badgeProvider);
    final colorProfile = ref.watch(colorProfileProvider);
    final musicProfile = ref.watch(musicProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('親ダッシュボード'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _OverviewCard(
            artCount: artworks.items.length,
            musicCount: compositions.items.length,
            homeCount: challenges.items.length,
            badgeCount: badges.items.length,
          ),
          const SizedBox(height: 16),
          if (colorProfile.isCompleted) ...[
            _ProfileCard(
              title: '🎨 色彩タイプ',
              typeName: colorProfile.expressionStyle,
              primaryColor: colorProfile.primaryColor,
              metrics: {
                '暖色親和度': colorProfile.warmAffinity,
                '冷色親和度': colorProfile.coolAffinity,
                'ニュートラル': colorProfile.neutralAffinity,
              },
              color: kArtColor,
            ),
            const SizedBox(height: 12),
          ],
          if (musicProfile.isCompleted) ...[
            _ProfileCard(
              title: '🎵 音感タイプ',
              typeName: musicProfile.musicType,
              primaryColor: musicProfile.musicType,
              metrics: {
                'メロディ感応度': musicProfile.melodyAffinity,
                'リズム感応度': musicProfile.rhythmAffinity,
                '身体記憶力': musicProfile.bodyMemory,
                '情動反応度': musicProfile.emotionResponse,
              },
              color: kMusicColor,
            ),
            const SizedBox(height: 12),
          ],
          _ProgressSection(
            artMonths: artworks.completedMonths,
            musicStages: compositions.maxStageCompleted,
            homeMonths: challenges.completedMonths,
          ),
          const SizedBox(height: 16),
          _ParentTipsCard(),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final int artCount, musicCount, homeCount, badgeCount;

  const _OverviewCard({
    required this.artCount, required this.musicCount,
    required this.homeCount, required this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFF9B59B6)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'お子さんの学習まとめ',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _CountBadge(emoji: '🖼️', count: artCount, label: '作品'),
              const SizedBox(width: 12),
              _CountBadge(emoji: '🎶', count: musicCount, label: '楽曲'),
              const SizedBox(width: 12),
              _CountBadge(emoji: '📸', count: homeCount, label: '記録'),
              const SizedBox(width: 12),
              _CountBadge(emoji: '⭐', count: badgeCount, label: 'バッジ'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final String emoji;
  final int count;
  final String label;

  const _CountBadge({required this.emoji, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            UkalabEmoji(emoji, size: 20),
            Text(
              count.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String title;
  final String typeName;
  final String primaryColor;
  final Map<String, double> metrics;
  final Color color;

  const _ProfileCard({
    required this.title, required this.typeName, required this.primaryColor,
    required this.metrics, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(typeName, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          ...metrics.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(e.key, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: e.value / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${e.value.toInt()}%',
                  style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final int artMonths, musicStages, homeMonths;

  const _ProgressSection({
    required this.artMonths, required this.musicStages, required this.homeMonths,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('進捗', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _ProgressRow('🎨 図工', artMonths, 12, kArtColor),
          const SizedBox(height: 8),
          _ProgressRow('🎵 音楽', musicStages, 8, kMusicColor),
          const SizedBox(height: 8),
          _ProgressRow('🍳 家庭科', homeMonths, 12, kHomeEcColor),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final int current;
  final int total;
  final Color color;

  const _ProgressRow(this.label, this.current, this.total, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 13))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: current / total,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$current/$total', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ParentTipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 保護者の方へ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryColor),
          ),
          const SizedBox(height: 10),
          const Text(
            '• 「上手い/下手」ではなく「個性」を認めて褒めましょう',
            style: TextStyle(fontSize: 13, height: 1.6),
          ),
          const Text(
            '• 「色が素敵だね」「リズムがいいね」と声かけしましょう',
            style: TextStyle(fontSize: 13, height: 1.6),
          ),
          const Text(
            '• 月末の「親子セッション」で一緒に振り返りましょう',
            style: TextStyle(fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }
}
