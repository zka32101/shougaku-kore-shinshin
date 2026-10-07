import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import 'package:shougaku_kore_doutoku/widgets/ukalab_emoji.dart';

class HomeEcHubScreen extends ConsumerStatefulWidget {
  const HomeEcHubScreen({super.key});

  @override
  ConsumerState<HomeEcHubScreen> createState() => _HomeEcHubScreenState();
}

class _HomeEcHubScreenState extends ConsumerState<HomeEcHubScreen> {
  bool _whyExpanded = false;

  static const _topics = [
    {
      'id': 'tidying',
      'emoji': '🗂️',
      'name': '整理整頓',
      'subtitle': '片づけ上手になろう！',
      'color': Color(0xFF2196F3),
    },
    {
      'id': 'cleaning',
      'emoji': '🧹',
      'name': '清掃',
      'subtitle': 'きれいな空間をつくろう',
      'color': Color(0xFF4CAF50),
    },
    {
      'id': 'shopping',
      'emoji': '🛒',
      'name': '買い物とお金',
      'subtitle': 'かしこいお買い物名人へ',
      'color': Color(0xFFFF9800),
    },
    {
      'id': 'chores',
      'emoji': '🍳',
      'name': '家庭の仕事',
      'subtitle': '家族の一員として働こう',
      'color': Color(0xFFE91E63),
    },
    {
      'id': 'eco',
      'emoji': '🌱',
      'name': '環境の配慮',
      'subtitle': '地球にやさしい生活を',
      'color': Color(0xFF009688),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final homeMonth = settings['currentHomeMonth'] as int? ?? 1;
    final challenges = ref.watch(homeChallengeProvider);
    final badges = ref.watch(badgeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏠 家庭科コレ！'),
        backgroundColor: kHomeEcColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text('これまでの家庭科の記録を ふりかえる'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/memories', arguments: 2),
            ),
          ),
          const SizedBox(height: 12),
          // なぜ家庭科を学ぶの？
          GestureDetector(
            onTap: () => setState(() => _whyExpanded = !_whyExpanded),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kHomeEcColor, kHomeEcColor.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🎓', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'なぜ家庭科を学ぶの？',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        _whyExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  if (_whyExpanded) ...[
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white30),
                    const SizedBox(height: 8),
                    _WhyItem(
                      icon: '🏡',
                      text: '家庭科は「生きる力」を学ぶ教科です。料理・掃除・整理整頓は、自立した生活に欠かせないスキルです。',
                    ),
                    _WhyItem(
                      icon: '💰',
                      text: 'お金の使い方や買い物の仕方を学ぶことで、大人になっても困らない判断力が育ちます。',
                    ),
                    _WhyItem(
                      icon: '🤝',
                      text: '家族と協力して家の仕事をすることで、感謝の気持ちと責任感が生まれます。',
                    ),
                    _WhyItem(
                      icon: '🌍',
                      text: '食事・衣服・住まいの知識は、環境や社会とつながっています。賢い消費者として地球を守れます。',
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 進捗サマリ
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kHomeEcColorLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: '色彩Month',
                  value: '$homeMonth/12',
                  emoji: '🎨',
                ),
                _StatItem(
                  label: '記録',
                  value: '${challenges.items.length}',
                  emoji: '📸',
                ),
                _StatItem(
                  label: 'バッジ',
                  value: '${badges.forSubject('home_ec').length}',
                  emoji: '⭐',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            '色彩チャレンジ',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),

          // 色彩料理×ファッション（既存）
          _MenuCard(
            emoji: '🍳',
            title: '色彩料理×ファッション',
            subtitle: '12ヶ月・12色のカラーチャレンジ',
            description: '$homeMonth月「${kMonthColors[homeMonth - 1]['name']}」に挑戦中！',
            color: kHomeEcColor,
            badge: '$homeMonth月',
            onTap: () => Navigator.pushNamed(context, '/home-ec/month', arguments: homeMonth),
          ),

          const SizedBox(height: 20),
          const Text(
            '生活スキルチャレンジ',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),

          // 5つのトピック
          ..._topics.map((topic) {
            final topicBadges = badges.items
                .where((b) => b.id.startsWith('home_${topic['id']}'))
                .length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MenuCard(
                emoji: topic['emoji'] as String,
                title: topic['name'] as String,
                subtitle: topic['subtitle'] as String,
                description: topicBadges > 0
                    ? '✓ チャレンジ済み ($topicBadgesバッジ獲得)'
                    : 'タップしてチャレンジしよう！',
                color: topic['color'] as Color,
                badge: topicBadges > 0 ? '完了 ✓' : null,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/home-ec/topic',
                  arguments: topic['id'],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _WhyItem extends StatelessWidget {
  final String icon;
  final String text;
  const _WhyItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UkalabEmoji(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  const _StatItem({required this.label, required this.value, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UkalabEmoji(emoji, size: 24),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: kHomeEcColor)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _MenuCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: UkalabEmoji(emoji, size: 28)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold, color: color)),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(badge!,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: color,
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(description,
                      style: const TextStyle(fontSize: 12, height: 1.4)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}
