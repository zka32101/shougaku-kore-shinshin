import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';

class MusicHubScreen extends ConsumerStatefulWidget {
  const MusicHubScreen({super.key});

  @override
  ConsumerState<MusicHubScreen> createState() => _MusicHubScreenState();
}

class _MusicHubScreenState extends ConsumerState<MusicHubScreen> {
  bool _whyExpanded = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final musicStage = settings['currentMusicStage'] as int? ?? 1;
    final musicProfile = ref.watch(musicProfileProvider);
    final compositions = ref.watch(compositionProvider);
    final badges = ref.watch(badgeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎵 音楽コレ！'),
        backgroundColor: kMusicColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // なぜ音楽を学ぶの？
          GestureDetector(
            onTap: () => setState(() => _whyExpanded = !_whyExpanded),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kMusicColor, kMusicColor.withValues(alpha: 0.7)],
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
                          'なぜ音楽を学ぶの？',
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
                      icon: '🧠',
                      text: '音楽を学ぶと脳の左右がバランスよく発達します。メロディは右脳、リズムは左脳を使うため、考える力が伸びます。',
                    ),
                    _WhyItem(
                      icon: '❤️',
                      text: '音楽は感情を表現する言葉。うれしい・悲しい・ワクワクを音で表すことで、自分の気持ちを理解する力が育ちます。',
                    ),
                    _WhyItem(
                      icon: '🤝',
                      text: 'みんなで合わせる合唱や合奏は「聴く力」と「協力する心」を育てます。社会で生きる大切なチカラです。',
                    ),
                    _WhyItem(
                      icon: '🌍',
                      text: '音楽は国境を越えます。世界中の音楽を知ることで、異なる文化や人々への理解と尊重が深まります。',
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
              color: kMusicColorLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(label: '楽曲数', value: '${compositions.items.length}', emoji: '🎶'),
                _StatItem(label: 'Stage', value: '$musicStage/8', emoji: '🏆'),
                _StatItem(label: 'バッジ', value: '${badges.forSubject('music').length}', emoji: '⭐'),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            'メニュー',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),

          // フリーピアノ
          _MenuCard(
            emoji: '🎹',
            title: 'フリーピアノで遊ぼう！',
            subtitle: '好きな音を自由に鳴らしてみよう',
            description: '音楽の基本は「聴く」こと。まず自分の耳で音を確かめよう！',
            color: const Color(0xFF2196F3),
            onTap: () => Navigator.pushNamed(context, '/music/free-piano'),
          ),

          const SizedBox(height: 12),

          // テーマ作曲チャレンジ
          _MenuCard(
            emoji: '🎼',
            title: 'テーマ作曲チャレンジ',
            subtitle: 'テーマを選んで曲を書いてみよう',
            description: '「春」「夏」「悲しみ」…気持ちをメロディにしてみよう！',
            color: const Color(0xFFE91E63),
            onTap: () => Navigator.pushNamed(context, '/music/theme-compose'),
          ),

          const SizedBox(height: 12),

          // 8段階作曲チャレンジ
          _MenuCard(
            emoji: '🎸',
            title: '8段階作曲チャレンジ',
            subtitle: '5音 → フルオーケストラへ',
            description: musicProfile.isCompleted
                ? 'Stage $musicStage から続ける！'
                : '先に音感診断をしよう',
            color: kMusicColor,
            badge: 'Stage $musicStage',
            onTap: () {
              if (!musicProfile.isCompleted) {
                Navigator.pushNamed(context, '/music/diagnosis');
              } else {
                Navigator.pushNamed(context, '/music/compose', arguments: musicStage);
              }
            },
          ),

          const SizedBox(height: 12),

          // 音感診断
          _MenuCard(
            emoji: '🎧',
            title: '音感タイプ診断',
            subtitle: '自分の音楽タイプを調べよう',
            description: musicProfile.isCompleted
                ? '診断済み: ${musicProfile.musicType}'
                : 'まだ診断していないよ',
            color: const Color(0xFF795548),
            badge: musicProfile.isCompleted ? '診断済み ✓' : null,
            onTap: () => Navigator.pushNamed(context, '/music/diagnosis'),
          ),

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
          Text(icon, style: const TextStyle(fontSize: 18)),
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
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kMusicColor)),
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
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
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
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(badge!, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 12, height: 1.4)),
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
