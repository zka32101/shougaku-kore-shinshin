import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../models/badge.dart';
import '../theme/app_theme.dart';
import 'package:shougaku_kore_doutoku/widgets/badge_emblem.dart';

class BadgeScreen extends ConsumerWidget {
  const BadgeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeCollection = ref.watch(badgeProvider);
    final earned = badgeCollection.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('バッジコレクション'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _BadgeSummaryCard(total: earned.length),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _BadgeSection(
                  subject: 'art',
                  title: '🎨 図工バッジ',
                  color: kArtColor,
                  earned: earned,
                ),
                const SizedBox(height: 16),
                _BadgeSection(
                  subject: 'music',
                  title: '🎵 音楽バッジ',
                  color: kMusicColor,
                  earned: earned,
                ),
                const SizedBox(height: 16),
                _BadgeSection(
                  subject: 'home_ec',
                  title: '🏠 家庭科バッジ',
                  color: kHomeEcColor,
                  earned: earned,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeSummaryCard extends StatelessWidget {
  final int total;
  const _BadgeSummaryCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFE91E8C)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$total 個獲得！',
                style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white,
                ),
              ),
              Text(
                '全${BadgeCollection.allDefinitions.length}個中',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgeSection extends StatelessWidget {
  final String subject;
  final String title;
  final Color color;
  final List<AppBadge> earned;

  const _BadgeSection({
    required this.subject,
    required this.title,
    required this.color,
    required this.earned,
  });

  @override
  Widget build(BuildContext context) {
    final defs = BadgeCollection.allDefinitions
        .where((d) => d['subject'] == subject)
        .toList();
    final earnedIds = earned.map((b) => b.id).toSet();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: defs.length,
            itemBuilder: (context, i) {
              final def = defs[i];
              final isEarned = earnedIds.contains(def['id']);
              return _BadgeTile(
                badgeId: def['id']!,
                emoji: def['emoji']!,
                name: def['name']!,
                isEarned: isEarned,
                color: color,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final String badgeId;
  final String emoji;
  final String name;
  final bool isEarned;
  final Color color;

  const _BadgeTile({
    required this.badgeId, required this.emoji, required this.name,
    required this.isEarned, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isEarned ? color.withValues(alpha: 0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: isEarned
            ? Border.all(color: color.withValues(alpha: 0.3), width: 1.5)
            : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isEarned)
            BadgeEmblem(badgeId: badgeId, fallbackEmoji: emoji, size: 36)
          else
            const Text('🔒', style: TextStyle(fontSize: 30)),
          const SizedBox(height: 6),
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: isEarned ? color : Colors.grey,
              fontWeight: isEarned ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
