import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/artwork.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../memory_screen.dart';
import 'package:shougaku_kore_doutoku/widgets/furigana_text.dart';

class ArtMonthScreen extends ConsumerWidget {
  final int month;
  const ArtMonthScreen({super.key, required this.month});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorData = kMonthColors[month - 1];
    final color = colorData['color'] as Color;
    final colorName = colorData['name'] as String;
    final keywords = colorData['keywords'] as String;
    final artworks = ref.watch(artworkProvider);
    final monthArtworks = artworks.forMonth(month);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FuriganaText(
                          '$month月: $colorName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FuriganaText(
                          keywords,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
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
                _ColorInfoCard(
                  colorName: colorName,
                  color: color,
                  month: month,
                ),
                const SizedBox(height: 16),
                FuriganaText(
                  '4つのレベルに挑戦しよう',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 12),
                _LevelCard(
                  level: 1,
                  title: '「$colorName」を見つける・感じる',
                  description: '身の回りから「$colorName」を探して撮影！感情を言葉にしよう。',
                  duration: '5日 / 15分×3日',
                  badge: '$colorNameの探検家',
                  color: color,
                  isCompleted: monthArtworks.any((a) => a.level.index == 0),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/art/canvas',
                    arguments: {
                      'month': month,
                      'level': 1,
                      'color': colorName,
                      'colorHex': colorData['hex'],
                    },
                  ),
                ),
                const SizedBox(height: 8),
                _LevelCard(
                  level: 2,
                  title: '「$colorName」で情感を描く',
                  description: '$colorNameだけで感情を描こう。350×350pxの作品を作る。',
                  duration: '5日 / 20分×2日',
                  badge: '$colorNameの表現者',
                  color: color,
                  isCompleted: monthArtworks.any((a) => a.level.index == 1),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/art/canvas',
                    arguments: {
                      'month': month,
                      'level': 2,
                      'color': colorName,
                      'colorHex': colorData['hex'],
                    },
                  ),
                ),
                const SizedBox(height: 8),
                _LevelCard(
                  level: 3,
                  title: '「$colorName × 黒」対比表現',
                  description: '2色の対比で葛藤・決意を表現。400×400pxの作品。',
                  duration: '6日 / 25分×2日',
                  badge: '対比の大師',
                  color: color,
                  isCompleted: monthArtworks.any((a) => a.level.index == 2),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/art/canvas',
                    arguments: {
                      'month': month,
                      'level': 3,
                      'color': colorName,
                      'colorHex': colorData['hex'],
                    },
                  ),
                ),
                const SizedBox(height: 8),
                _LevelCard(
                  level: 4,
                  title: '「$colorName」の世界を完全表現',
                  description: '色相・明度・彩度を全て使いこなして500×500pxの大作を完成！',
                  duration: '8日 / 30分×3日',
                  badge: '$colorNameの哲学者',
                  color: color,
                  isCompleted: monthArtworks.any((a) => a.level.index == 3),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/art/canvas',
                    arguments: {
                      'month': month,
                      'level': 4,
                      'color': colorName,
                      'colorHex': colorData['hex'],
                    },
                  ),
                ),
                const SizedBox(height: 24),
                if (monthArtworks.isNotEmpty) ...[
                  FuriganaText(
                    '今月の作品 (${monthArtworks.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...monthArtworks.map(
                    (a) => _ArtworkTile(
                      artwork: a,
                      color: color,
                      onTap: () => showMemoryDetail(
                        context,
                        artMemories(ArtworkCollection([a])).first,
                        color,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/memories', arguments: 0),
                    icon: const Icon(Icons.history),
                    label: const FuriganaText('ほかの月の作品も ふりかえる'),
                  ),
                ],
                const SizedBox(height: 16),
                if (month < 12)
                  OutlinedButton.icon(
                    onPressed: () {
                      ref
                          .read(settingsProvider.notifier)
                          .setCurrentArtMonth(month + 1);
                      Navigator.pushReplacementNamed(
                        context,
                        '/art/month',
                        arguments: month + 1,
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: FuriganaText(
                      '次の月: Month ${month + 1}「${kMonthColors[month]['name']}」へ',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorInfoCard extends StatelessWidget {
  final String colorName;
  final Color color;
  final int month;

  const _ColorInfoCard({
    required this.colorName,
    required this.color,
    required this.month,
  });

  static const _colorFacts = [
    ['トマト・イチゴ・薔薇', '日本の正月、中国の幸運、インドのヘナ', '情熱・エネルギー・行動・焦り'],
    ['みかん・かぼちゃ・夕焼け', '秋のハロウィン、オランダの王家', '温かみ・友情・親しみやすさ'],
    ['ひまわり・バナナ・卵', '日本の国旗（太陽）・注意色', '楽しさ・明るさ・希望・注意'],
    ['若葉・新芽・キウイ', '春の新緑、環境・エコの色', '成長・新鮮さ・爽やかさ'],
    ['森・草原・ほうれん草', '自然・環境保護、アイルランド', '安心・自然・バランス・癒し'],
    ['海の浅瀬・ターコイズ', '南国の海・宝石のターコイズ', '穏やかさ・リフレッシュ・清潔感'],
    ['空・海・デニム', '世界の国旗に最多、信頼の色', '冷静・深さ・信頼・広がり'],
    ['ラベンダー・ブドウ・紫陽花', '古代ローマの皇帝色、高貴な色', '神秘・創造性・高貴さ'],
    ['桜・桃・カーネーション', '愛と恋愛の色、少女マンガの定番', '優しさ・愛・優雅さ・女性性'],
    ['木・土・チョコレート', '大地・自然の土台、信頼の色', '温もり・安定・自然・信頼'],
    ['曇り空・石・アスファルト', 'モダンデザイン、シンプルの極致', 'バランス・洗練・静寂・中立'],
    ['夜空・墨・炭', '日本の伝統色、強さと決意', '決意・力強さ・プロフェッショナル'],
  ];

  @override
  Widget build(BuildContext context) {
    final facts = _colorFacts[month - 1];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FuriganaText(
            '「$colorName」を知ろう',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          _FactRow('代表物', facts[0], color),
          _FactRow('文化的背景', facts[1], color),
          _FactRow('心理的意味', facts[2], color),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _FactRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: FuriganaText(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final String title;
  final String description;
  final String duration;
  final String badge;
  final Color color;
  final bool isCompleted;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.title,
    required this.description,
    required this.duration,
    required this.badge,
    required this.color,
    required this.isCompleted,
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
          border: isCompleted ? Border.all(color: color, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isCompleted ? color : color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 22)
                    : Text(
                        'Lv$level',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FuriganaText(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FuriganaText(
                    description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      FuriganaText(
                        duration,
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '⭐ $badge',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              isCompleted ? Icons.check_circle : Icons.arrow_forward_ios,
              color: isCompleted ? color : Colors.grey[400],
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtworkTile extends StatelessWidget {
  final dynamic artwork;
  final Color color;
  final VoidCallback? onTap;

  const _ArtworkTile({required this.artwork, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Text(
              artwork.imagePath != null ? '🖼️' : '📷',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FuriganaText(
                    artwork.title.isEmpty
                        ? '作品 Lv${artwork.level.index + 1}'
                        : artwork.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (artwork.description.isNotEmpty)
                    FuriganaText(
                      artwork.description,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Lv${artwork.level.index + 1}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
