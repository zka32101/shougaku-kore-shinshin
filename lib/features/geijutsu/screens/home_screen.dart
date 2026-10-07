import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import 'package:shougaku_kore_doutoku/widgets/ukalab_emoji.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final activeProfile = ref.watch(profileProvider).active;
    final artMonth = settings['currentArtMonth'] as int? ?? 1;
    final musicStage = settings['currentMusicStage'] as int? ?? 1;
    final homeMonth = settings['currentHomeMonth'] as int? ?? 1;
    final artworks = ref.watch(artworkProvider);
    final compositions = ref.watch(compositionProvider);
    final challenges = ref.watch(homeChallengeProvider);
    final badges = ref.watch(badgeProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF6B35), Color(0xFFE91E8C), Color(0xFF9B59B6)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            if (activeProfile != null) ...[
                              UkalabEmoji(activeProfile.avatarEmoji, size: 28),
                              const SizedBox(width: 8),
                            ],
                            const Text(
                              '小学コレ！芸術',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activeProfile != null
                              ? '${activeProfile.name} ・ バッジ ${badges.items.length}個'
                              : 'バッジ: ${badges.items.length}個獲得',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SubjectCard(
                  emoji: '🎨',
                  title: '図工',
                  subtitle: '色彩表現チャレンジ',
                  description: '12色テーマで\n感情を絵に表現しよう',
                  color: kArtColor,
                  bgColor: kArtColorLight,
                  progress: artworks.completedMonths / 12,
                  progressLabel: '${artworks.completedMonths}/12 ヶ月完了',
                  currentLabel: '現在: $artMonth月「${kMonthColors[artMonth - 1]['name']}」',
                  onTap: () {
                    final colorProfile = ref.read(colorProfileProvider);
                    if (!colorProfile.isCompleted) {
                      Navigator.pushNamed(context, '/art/diagnosis');
                    } else {
                      Navigator.pushNamed(context, '/art/month', arguments: artMonth);
                    }
                  },
                ),
                const SizedBox(height: 12),
                _SubjectCard(
                  emoji: '🎵',
                  title: '音楽',
                  subtitle: '8段階作曲チャレンジ',
                  description: '5音メロディから\nフルオーケストラへ！',
                  color: kMusicColor,
                  bgColor: kMusicColorLight,
                  progress: compositions.maxStageCompleted / 8,
                  progressLabel: 'ステージ ${compositions.maxStageCompleted}/8 完了',
                  currentLabel: '現在: Stage $musicStage',
                  onTap: () => Navigator.pushNamed(context, '/music/hub'),
                ),
                const SizedBox(height: 12),
                _SubjectCard(
                  emoji: '🍳',
                  title: '家庭科',
                  subtitle: '色彩料理×ファッション',
                  description: '毎月のカラーで\n料理と服を作ろう',
                  color: kHomeEcColor,
                  bgColor: kHomeEcColorLight,
                  progress: challenges.completedMonths / 12,
                  progressLabel: '${challenges.completedMonths}/12 ヶ月完了',
                  currentLabel: '現在: $homeMonth月「${kMonthColors[homeMonth - 1]['name']}」',
                  onTap: () => Navigator.pushNamed(context, '/home-ec/hub'),
                ),
                const SizedBox(height: 24),
                _QuickStatsRow(
                  artworks: artworks.items.length,
                  compositions: compositions.items.length,
                  challenges: challenges.items.length,
                  badges: badges.items.length,
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final Color bgColor;
  final double progress;
  final String progressLabel;
  final String currentLabel;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.bgColor,
    required this.progress,
    required this.progressLabel,
    required this.currentLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  UkalabEmoji(emoji, size: 48),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  subtitle,
                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(fontSize: 13, color: color.withValues(alpha: 0.8), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: color),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(progressLabel,
                          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
                      Text(currentLabel,
                          style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
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

class _QuickStatsRow extends StatelessWidget {
  final int artworks;
  final int compositions;
  final int challenges;
  final int badges;

  const _QuickStatsRow({
    required this.artworks,
    required this.compositions,
    required this.challenges,
    required this.badges,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(emoji: '🖼️', label: '作品', count: artworks),
        const SizedBox(width: 8),
        _StatChip(emoji: '🎶', label: '楽曲', count: compositions),
        const SizedBox(width: 8),
        _StatChip(emoji: '📸', label: '記録', count: challenges),
        const SizedBox(width: 8),
        _StatChip(emoji: '⭐', label: 'バッジ', count: badges),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String emoji;
  final String label;
  final int count;

  const _StatChip({required this.emoji, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            UkalabEmoji(emoji, size: 24),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
