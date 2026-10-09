import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../literacy_core/literacy_core.dart';
import '../taiku_app.dart';
import '../providers/taiku_providers.dart';
import 'general_overview_screen.dart';
import 'stage_learn_screen.dart';
import 'package:shougaku_kore_doutoku/widgets/ukalab_emoji.dart';

// ─── まなぶ画面 ───

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  static const _themeGroups = [
    _ThemeGroup('sports', '⚽', 'スポーツ', [1, 2, 4]),
    _ThemeGroup('disaster', '🛡️', '防災・安全', [5, 6]),
    _ThemeGroup('nutrition', '🥗', '栄養・健康', [3, 7, 8]),
    _ThemeGroup('career', '⭐', 'キャリア・未来', [9, 10, 11, 12]),
    _ThemeGroup('health', '🏥', 'けんこう管理', [13, 14, 15]),
    _ThemeGroup('safety', '🚨', '安全・防犯', [16, 17, 18]),
    _ThemeGroup('environment', '🌱', '環境・SDGs', [19, 22, 23]),
    _ThemeGroup('money', '💰', 'お金のきほん', [20, 24, 25]),
    _ThemeGroup('values', '🤝', '道徳・人権', [21, 26, 27]),
    _ThemeGroup('ict', '💻', 'ICT・プログラミング', [34, 35]),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grade = ref.watch(gradeLevelProvider);
    final progressAsync = ref.watch(taikuProgressProvider);
    final isLow = grade == GradeLevel.low;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 90,
            pinned: true,
            backgroundColor: const Color(0xFF0277BD),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0277BD), Color(0xFF01579B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
              title: Text(
                isLow ? '📚 まなぶ' : '📚 まなぶ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: progressAsync.when(
                data: (progress) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OverviewEntryCard(grade: grade),
                    const SizedBox(height: 14),
                    _GradeInfoBanner(grade: grade),
                    const SizedBox(height: 20),
                    for (final group in _themeGroups) ...[
                      if (group.theme == 'ict') ...[
                        const GeijutsuGuideNote(),
                        const SizedBox(height: 24),
                      ],
                      _ThemeSection(
                        group: group,
                        grade: grade,
                        progress: progress,
                      ),
                      const SizedBox(height: 24),
                    ],
                    const SizedBox(height: 60),
                  ],
                ),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 図工・音楽・家庭科は「げいじゅつ」で遊べることを知らせる1行の案内。
class GeijutsuGuideNote extends StatelessWidget {
  const GeijutsuGuideNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('taiku_geijutsu_guide'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF48FB1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.palette_outlined, color: Color(0xFFD81B60), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'ずこう・おんがく・かていかは「げいじゅつ」で あそべるよ',
              style: TextStyle(fontSize: 12, color: Color(0xFFAD1457)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeGroup {
  final String theme;
  final String emoji;
  final String label;
  final List<int> stages;
  const _ThemeGroup(this.theme, this.emoji, this.label, this.stages);
}

class _GradeInfoBanner extends StatelessWidget {
  final GradeLevel grade;
  const _GradeInfoBanner({required this.grade});

  @override
  Widget build(BuildContext context) {
    final isLow = grade == GradeLevel.low;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF90CAF9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.school_outlined, color: Color(0xFF1565C0), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isLow
                  ? 'ステージを えらんで、まなびの ポイントを よもう！'
                  : 'ステージをタップして、学習ポイントと解説を確認しよう！',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1565C0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeSection extends StatelessWidget {
  final _ThemeGroup group;
  final GradeLevel grade;
  final LiteracyProgress progress;

  const _ThemeSection({
    required this.group,
    required this.grade,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final color = TaikuColors.forTheme(group.theme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // テーマヘッダー
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              UkalabEmoji(group.emoji, size: 15),
              const SizedBox(width: 6),
              Text(
                group.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // ステージグリッド
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.65,
          ),
          itemCount: group.stages.length,
          itemBuilder: (context, i) {
            final stageNum = group.stages[i];
            final info = _stageInfo(stageNum);
            final stageData = progress.stages[stageNum];
            final isCompleted = stageData?.isCompleted ?? false;
            final accuracy = stageData?.accuracy;

            return _StageCard(
              stageNum: stageNum,
              emoji: info.$1,
              title: info.$2,
              theme: group.theme,
              color: color,
              grade: grade,
              isCompleted: isCompleted,
              accuracy: accuracy,
            );
          },
        ),
      ],
    );
  }

  (String, String) _stageInfo(int stage) {
    const m = {
      1: ('⚽', 'スポーツのルール'),
      2: ('🤸', 'からだを動かそう'),
      3: ('🥗', 'スポーツと栄養'),
      4: ('👥', 'チームスポーツ'),
      5: ('🛡️', '防災の基本'),
      6: ('🌊', '水の安全・救助'),
      7: ('🍎', '栄養と健康'),
      8: ('💪', '食事とトレーニング'),
      9: ('🔭', 'キャリア探索'),
      10: ('🔬', 'スポーツ科学'),
      11: ('🌟', '健康とキャリア総合'),
      12: ('🌍', 'グローバルスポーツ・未来'),
    };
    return m[stage] ?? ('📖', 'ステージ$stage');
  }
}

class _StageCard extends StatelessWidget {
  final int stageNum;
  final String emoji;
  final String title;
  final String theme;
  final Color color;
  final GradeLevel grade;
  final bool isCompleted;
  final double? accuracy;

  const _StageCard({
    required this.stageNum,
    required this.emoji,
    required this.title,
    required this.theme,
    required this.color,
    required this.grade,
    required this.isCompleted,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    final isLow = grade == GradeLevel.low;

    void navigateTo() {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => StageLearnScreen(
          stageNum: stageNum,
          emoji: emoji,
          title: title,
          theme: theme,
          color: color,
        ),
      ));
    }

    return InkWell(
      onTap: navigateTo,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCompleted ? color : Colors.grey.shade200,
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UkalabEmoji(emoji, size: 20),
                const Spacer(),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      accuracy != null
                          ? '${(accuracy! * 100).round()}%'
                          : '✓',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Icon(Icons.book_outlined, size: 14, color: color),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isLow ? 11 : 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                Text(
                  isLow ? 'まなぶ →' : '学ぶ →',
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  'S$stageNum',
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 全般説明画面へのエントリカード ───

class _OverviewEntryCard extends StatelessWidget {
  final GradeLevel grade;
  const _OverviewEntryCard({required this.grade});

  @override
  Widget build(BuildContext context) {
    final isLow = grade == GradeLevel.low;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const GeneralOverviewScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0277BD), Color(0xFF1B5E20)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade900.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('📖', style: TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLow ? 'まなびの ぜんたいマップ' : 'まなびの全体マップ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isLow
                        ? '4テーマ・12ステージ・180もんを いっかいで みよう'
                        : '4テーマ・12ステージ・全180問の内容を一望する',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _MiniThemeChip('⚽', 'スポーツ', const Color(0xFFFF6D00)),
                      const SizedBox(width: 4),
                      _MiniThemeChip('🛡️', '防災', const Color(0xFF1565C0)),
                      const SizedBox(width: 4),
                      _MiniThemeChip('🥗', '栄養', const Color(0xFF2E7D32)),
                      const SizedBox(width: 4),
                      _MiniThemeChip('⭐', 'キャリア', const Color(0xFF6A1B9A)),
                      const SizedBox(width: 4),
                      _MiniThemeChip('🏥', 'けんこう', const Color(0xFF00838F)),
                      _MiniThemeChip('🚨', '安全', const Color(0xFFB71C1C)),
                      _MiniThemeChip('🌱', '環境', const Color(0xFF1B5E20)),
                      _MiniThemeChip('💰', 'お金', const Color(0xFFF57F17)),
                      _MiniThemeChip('🤝', '道徳', const Color(0xFF4A148C)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

class _MiniThemeChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  const _MiniThemeChip(this.emoji, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UkalabEmoji(emoji, size: 10),
          const SizedBox(width: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
