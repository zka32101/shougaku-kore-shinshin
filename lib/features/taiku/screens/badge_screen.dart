import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../taiku_app.dart';
import '../providers/mistake_note_provider.dart';
import '../providers/taiku_providers.dart';
import 'package:shougaku_kore_doutoku/widgets/badge_emblem.dart';
import '../../../widgets/streak_crown_row.dart';
import '../../../widgets/streak_calendar.dart';
import 'activity_screen.dart';
import 'characters_screen.dart';
import 'mistake_note_screen.dart';

class BadgeScreen extends ConsumerWidget {
  const BadgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acquired = ref.watch(acquiredBadgesProvider);
    final mistakeCount = ref.watch(currentMistakeCountProvider);

    final stageBadges =
        allBadges.where((b) => b.category == 'stage').toList();
    final gradeBadges =
        allBadges.where((b) => b.category == 'grade').toList();
    final streakBadges =
        allBadges.where((b) => b.category == 'streak').toList();
    final activityBadges =
        allBadges.where((b) => b.category == 'activity').toList();
    final specialBadges =
        allBadges.where((b) => b.category == 'special').toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: TaikuColors.primary,
        title: const Text(
          '🏅 バッジコレクション',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MistakeNoteCard(mistakeCount: mistakeCount),
          const SizedBox(height: 12),
          const _CharactersEntryCard(),
          const SizedBox(height: 12),
          const _ExperienceEntryCard(),
          const SizedBox(height: 16),
          _buildBadgeSection(
            context,
            title: '⭐ 段階バッジ',
            subtitle: '学習の節目に獲得！',
            badges: gradeBadges,
            acquired: acquired,
            color: TaikuColors.career,
          ),
          const SizedBox(height: 20),
          _buildBadgeSection(
            context,
            title: '🏆 ステージクリアバッジ',
            subtitle: '各ステージをクリアして獲得！',
            badges: stageBadges,
            acquired: acquired,
            color: TaikuColors.primary,
          ),
          const SizedBox(height: 20),
          _buildBadgeSection(
            context,
            title: '🔥 連続学習バッジ',
            subtitle: '毎日続けて獲得！',
            headerTrailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreakCrownRow(
                    longestStreak: ref.watch(streakProvider).longestStreak),
                IconButton(
                  key: const Key('badge_streak_calendar_button'),
                  tooltip: 'れんぞくカレンダー',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.calendar_month, color: Colors.orange),
                  onPressed: () => showStreakCalendar(
                      context, ref.read(streakProvider).studyDaySet),
                ),
              ],
            ),
            badges: streakBadges,
            acquired: acquired,
            color: Colors.orange,
          ),
          const SizedBox(height: 20),
          _buildBadgeSection(
            context,
            title: '🎯 実体験バッジ',
            subtitle: '実際にやってみて獲得！',
            badges: activityBadges,
            acquired: acquired,
            color: TaikuColors.nutrition,
          ),
          const SizedBox(height: 20),
          _buildBadgeSection(
            context,
            title: '🎊 特別バッジ',
            subtitle: '特別な達成で獲得！',
            badges: specialBadges,
            acquired: acquired,
            color: TaikuColors.sports,
          ),
          const SizedBox(height: 20),
          _AcquisitionSummary(
            total: allBadges.length,
            acquired: acquired.length,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<TaikuBadge> badges,
    required List<String> acquired,
    required Color color,
    Widget? headerTrailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            if (headerTrailing != null) ...[
              const SizedBox(width: 8),
              headerTrailing,
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: badges.map((badge) {
            final isAcquired = acquired.contains(badge.id);
            return _BadgeCard(
              badge: badge,
              isAcquired: isAcquired,
              color: color,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final TaikuBadge badge;
  final bool isAcquired;
  final Color color;

  const _BadgeCard({
    required this.badge,
    required this.isAcquired,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAcquired
          ? () => _showBadgeDetail(context)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isAcquired
              ? color.withValues(alpha: 0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAcquired ? color : Colors.grey.shade200,
            width: isAcquired ? 2 : 1,
          ),
          boxShadow: isAcquired
              ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 8)]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ColorFiltered(
              colorFilter: isAcquired
                  ? const ColorFilter.mode(
                      Colors.transparent, BlendMode.saturation)
                  : const ColorFilter.matrix([
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0, 0, 0, 0.4, 0,
                    ]),
              child: BadgeEmblem(
                badgeId: badge.id,
                fallbackEmoji: badge.emoji,
                size: isAcquired ? 38 : 34,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              badge.title,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isAcquired ? color : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!isAcquired) ...[
              const SizedBox(height: 2),
              const Text(
                '🔒',
                style: TextStyle(fontSize: 10),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${badge.emoji} ${badge.title}'),
        content: Text(badge.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}

class _MistakeNoteCard extends StatelessWidget {
  final int mistakeCount;
  const _MistakeNoteCard({required this.mistakeCount});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => const MistakeNoteScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: mistakeCount > 0
              ? Colors.red.shade50
              : Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: mistakeCount > 0
                ? Colors.red.shade200
                : Colors.green.shade200,
          ),
        ),
        child: Row(
          children: [
            Text(
              mistakeCount > 0 ? '📝' : '🎉',
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'まちがいノート',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    mistakeCount > 0
                        ? '$mistakeCount 問のまちがいが記録されています'
                        : '間違いはありません！',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (mistakeCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$mistakeCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _CharactersEntryCard extends StatelessWidget {
  const _CharactersEntryCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CharactersScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: TaikuColors.sports.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TaikuColors.sports.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Text('🏃', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'キャラクターずかん',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    '体育・体験の仲間たち16人を見てみよう',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _ExperienceEntryCard extends StatelessWidget {
  const _ExperienceEntryCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ActivityScreen(stage: 100)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: TaikuColors.experience.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TaikuColors.experience.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Text('🏕️', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '体験活動チャレンジ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    'キャンプ・料理・農業・工作にチャレンジしよう',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _AcquisitionSummary extends StatelessWidget {
  final int total;
  final int acquired;

  const _AcquisitionSummary({
    required this.total,
    required this.acquired,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? acquired / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [TaikuColors.primary, Color(0xFFBF360C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🏅', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$acquired / $total 個獲得！',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor:
                        const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(percentage * 100).round()}% 達成',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
