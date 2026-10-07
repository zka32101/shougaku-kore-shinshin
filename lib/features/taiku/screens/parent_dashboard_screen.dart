import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../literacy_core/literacy_core.dart';
import '../taiku_app.dart';
import '../providers/taiku_providers.dart';
import '../providers/child_profiles_provider.dart';
import '../providers/sibling_quest_provider.dart';
import '../providers/parent_diary_provider.dart';
import '../data/sibling_quest.dart';
import '../data/child_profile.dart';
import '../data/parent_diary.dart';
import 'package:shougaku_kore_doutoku/widgets/ukalab_emoji.dart';

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grade = ref.watch(gradeLevelProvider);
    final parentTheme = ref.watch(parentThemeProvider);
    final progressAsync = ref.watch(taikuProgressProvider);
    final acquired = ref.watch(acquiredBadgesProvider);
    final streak = ref.watch(streakProvider);
    final profilesState = ref.watch(childProfilesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 80,
            pinned: true,
            backgroundColor: Colors.indigo.shade700,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 16, bottom: 14, right: 16),
              title: const Text(
                '👨‍👩‍👧 親メニュー',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 月間テーマ設定（設計書v2.0 修正1）
                  _MonthlyThemeCard(parentTheme: parentTheme),
                  const SizedBox(height: 20),

                  // 子どもの進捗サマリー
                  progressAsync.when(
                    data: (p) => _ProgressSummaryCard(
                      progress: p,
                      acquired: acquired,
                      grade: grade,
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),

                  // ストリーク表示（学習継続性）
                  _StreakCard(streak: streak),
                  const SizedBox(height: 20),

                  // ③ 成長ハイライト
                  progressAsync.when(
                    data: (p) => _GrowthHighlightCard(
                      streak: streak,
                      acquired: acquired,
                      completedStages: p.stages.values
                          .where((s) => s.isCompleted)
                          .length,
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),

                  // ⑤ 兄弟協力クエスト
                  _SiblingQuestCard(profilesState: profilesState),
                  const SizedBox(height: 20),

                  // ① 親子交換日記
                  _ParentDiaryCard(profilesState: profilesState),
                  const SizedBox(height: 20),

                  // 推奨理由の説明（設計書v2.0）
                  _RecommendationExplanation(),
                  const SizedBox(height: 20),

                  // 実体験ガイド
                  _ActivityGuideCard(),
                  const SizedBox(height: 20),

                  // 6年ロードマップ（設計書v2.0 段階バッジ）
                  _SixYearRoadmap(acquired: acquired),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 月間テーマカード ───

class _MonthlyThemeCard extends ConsumerWidget {
  final String? parentTheme;
  const _MonthlyThemeCard({required this.parentTheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text(
                '今月のテーマ設定',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (parentTheme != null)
                GestureDetector(
                  onTap: () =>
                      ref.read(parentThemeProvider.notifier).clearTheme(),
                  child: const Icon(Icons.close,
                      size: 18, color: Colors.grey),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'テーマを選ぶと、お子さんへの推奨が最適化されます',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          if (parentTheme != null) ...[
            // 選択済み
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: TaikuColors.forTheme(parentTheme!).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: TaikuColors.forTheme(parentTheme!), width: 2),
              ),
              child: Row(
                children: [
                  Text(_themeEmoji(parentTheme!),
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '選択中: ${_themeLabel(parentTheme!)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: TaikuColors.forTheme(parentTheme!),
                        ),
                      ),
                      Text(
                        _themeDesc(parentTheme!),
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 24),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => _showThemeSelector(context, ref),
              child: const Text('テーマを変更する'),
            ),
          ] else ...[
            // 未選択
            const Text(
              '今月注力したいテーマを選びましょう：',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            ...['sports', 'disaster', 'nutrition', 'career']
                .map((theme) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ThemeButton(
                        theme: theme,
                        onTap: () async {
                          await ref
                              .read(parentThemeProvider.notifier)
                              .setTheme(theme);
                        },
                      ),
                    )),
          ],
        ],
      ),
    );
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('テーマを選ぶ',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...['sports', 'disaster', 'nutrition', 'career']
                .map((theme) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ThemeButton(
                        theme: theme,
                        onTap: () async {
                          await ref
                              .read(parentThemeProvider.notifier)
                              .setTheme(theme);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _themeEmoji(String t) {
    switch (t) {
      case 'sports': return '⚽';
      case 'disaster': return '🛡️';
      case 'nutrition': return '🥗';
      case 'career': return '⭐';
      default: return '🏃';
    }
  }

  String _themeLabel(String t) {
    switch (t) {
      case 'sports': return 'スポーツ';
      case 'disaster': return '防災';
      case 'nutrition': return '栄養・健康';
      case 'career': return 'キャリア探索';
      default: return t;
    }
  }

  String _themeDesc(String t) {
    switch (t) {
      case 'sports': return 'ルール・チームワーク・運動';
      case 'disaster': return '地震・火事・水難対応';
      case 'nutrition': return '食事・栄養バランス・健康';
      case 'career': return 'スポーツの職業・科学的思考';
      default: return '';
    }
  }
}

class _ThemeButton extends StatelessWidget {
  final String theme;
  final VoidCallback onTap;

  const _ThemeButton({required this.theme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = TaikuColors.forTheme(theme);
    final emoji = _emoji(theme);
    final label = _label(theme);
    final desc = _desc(theme);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            UkalabEmoji(emoji, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: color)),
                  Text(desc,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }

  String _emoji(String t) {
    switch (t) {
      case 'sports': return '⚽';
      case 'disaster': return '🛡️';
      case 'nutrition': return '🥗';
      case 'career': return '⭐';
      default: return '🏃';
    }
  }

  String _label(String t) {
    switch (t) {
      case 'sports': return 'スポーツ';
      case 'disaster': return '防災';
      case 'nutrition': return '栄養・健康';
      case 'career': return 'キャリア探索';
      default: return t;
    }
  }

  String _desc(String t) {
    switch (t) {
      case 'sports': return 'ルール・チームワーク・運動の基本';
      case 'disaster': return '地震・火事・水難から身を守る';
      case 'nutrition': return '食事・栄養バランス・健康習慣';
      case 'career': return 'スポーツ関連の職業・未来を考える';
      default: return '';
    }
  }
}

// ─── 進捗サマリーカード ───

class _ProgressSummaryCard extends StatelessWidget {
  final LiteracyProgress progress;
  final List<String> acquired;
  final GradeLevel grade;

  const _ProgressSummaryCard({
    required this.progress,
    required this.acquired,
    required this.grade,
  });

  @override
  Widget build(BuildContext context) {
    final completedStages = progress.stages.values
        .where((s) => s.isCompleted)
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📊', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text('学習の進捗',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatTile(
                label: 'クリア済みステージ',
                value: '$completedStages / 11',
                color: TaikuColors.primary,
              ),
              _StatTile(
                label: '獲得バッジ',
                value: '${acquired.length} 個',
                color: TaikuColors.career,
              ),
              _StatTile(
                label: '総学習問題',
                value: '${progress.stages.values.fold(0, (s, p) => s + p.totalAttempts)} 問',
                color: TaikuColors.nutrition,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('テーマ別進捗',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _ThemeProgressBar(
              theme: 'sports', progress: progress, color: TaikuColors.sports),
          const SizedBox(height: 4),
          _ThemeProgressBar(
              theme: 'disaster',
              progress: progress,
              color: TaikuColors.disaster),
          const SizedBox(height: 4),
          _ThemeProgressBar(
              theme: 'nutrition',
              progress: progress,
              color: TaikuColors.nutrition),
          const SizedBox(height: 4),
          _ThemeProgressBar(
              theme: 'career',
              progress: progress,
              color: TaikuColors.career),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            textAlign: TextAlign.center),
      ],
    );
  }
}

class _ThemeProgressBar extends StatelessWidget {
  final String theme;
  final LiteracyProgress progress;
  final Color color;

  const _ThemeProgressBar({
    required this.theme,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final stagesInTheme = _stagesForTheme(theme);
    final completed =
        stagesInTheme.where((s) => progress.stages[s]?.isCompleted ?? false).length;
    final ratio = stagesInTheme.isEmpty ? 0.0 : completed / stagesInTheme.length;

    final label = _themeLabel(theme);
    final emoji = _themeEmoji(theme);

    return Row(
      children: [
        UkalabEmoji(emoji, size: 14),
        const SizedBox(width: 6),
        SizedBox(
          width: 60,
          child: Text(label,
              style: const TextStyle(fontSize: 11)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$completed/${stagesInTheme.length}',
          style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  List<int> _stagesForTheme(String theme) {
    const map = <String, List<int>>{
      'sports': [1, 2, 4],
      'disaster': [5, 6],
      'nutrition': [3, 7, 8],
      'career': [9, 10, 11],
    };
    return map[theme] ?? [];
  }

  String _themeLabel(String t) {
    switch (t) {
      case 'sports': return 'スポーツ';
      case 'disaster': return '防災';
      case 'nutrition': return '栄養';
      case 'career': return 'キャリア';
      default: return t;
    }
  }

  String _themeEmoji(String t) {
    switch (t) {
      case 'sports': return '⚽';
      case 'disaster': return '🛡️';
      case 'nutrition': return '🥗';
      case 'career': return '⭐';
      default: return '🏃';
    }
  }
}

// ─── ストリークカード ───

class _StreakCard extends StatelessWidget {
  final StreakState streak;

  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    final hasActive = streak.currentStreak > 0;
    final streakColor = hasActive
        ? (streak.currentStreak >= 7 ? Colors.red : Colors.amber)
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: streakColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: streakColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(hasActive ? '🔥' : '❄️',
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text('学習継続（ストリーク）',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StreakStat(
                label: '現在のストリーク',
                value: '${streak.currentStreak}',
                unit: '日',
                color: streakColor,
              ),
              _StreakStat(
                label: '最長ストリーク',
                value: '${streak.longestStreak}',
                unit: '日',
                color: Colors.blue,
              ),
              _StreakStat(
                label: '総学習日数',
                value: '${streak.totalStudyDays}',
                unit: '日',
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (hasActive)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: streakColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text('💪', style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${streak.currentStreak}日間の継続中！このペースを保ちましょう',
                      style: TextStyle(
                          fontSize: 12, color: streakColor.shade700),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text('📚', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '今日も一緒に学習を始めましょう！',
                      style: TextStyle(
                          fontSize: 12, color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StreakStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StreakStat({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color),
              ),
              TextSpan(
                text: unit,
                style: TextStyle(fontSize: 12, color: color),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            textAlign: TextAlign.center),
      ],
    );
  }
}

// ─── 推奨理由の説明 ───

class _RecommendationExplanation extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentTheme = ref.watch(parentThemeProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('💡', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text('推奨の仕組み（親向け）',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '「今日のおすすめ」は以下の重み付けで自動計算されます：',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 10),
          _WeightBar(
              label: '親テーマ適合度', weight: 50, color: Colors.green),
          const SizedBox(height: 6),
          _WeightBar(
              label: 'AI学習適応度', weight: 35, color: Colors.blue),
          const SizedBox(height: 6),
          _WeightBar(
              label: 'その他', weight: 15, color: Colors.orange),
          if (parentTheme == null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Text('⚠️', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '月間テーマを設定すると、推奨の精度が大幅に上がります！',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeightBar extends StatelessWidget {
  final String label;
  final int weight;
  final Color color;

  const _WeightBar(
      {required this.label, required this.weight, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: weight / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$weight%',
            style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ─── 実体験ガイドカード ───

class _ActivityGuideCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TaikuColors.nutrition.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: TaikuColors.nutrition.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🌟', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text('実体験アイデア（親子チャレンジ）',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ..._activities.map((a) => _ActivityItem(
                emoji: a.$1,
                title: a.$2,
                description: a.$3,
              )),
        ],
      ),
    );
  }

  static const _activities = [
    ('⚽', '公園でシュート練習', '親子で的を作り、距離を変えながら挑戦！'),
    ('🛡️', '防災グッズ確認会', '月1回、家族で防災袋の中身をチェックしよう'),
    ('🥗', '三色弁当チャレンジ', '赤・黄・緑の食材を使ったお弁当を一緒に作ろう！'),
    ('⭐', '職業インタビュー', '身近な大人に「お仕事について」聞いてみよう！'),
  ];
}

class _ActivityItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;

  const _ActivityItem({
    required this.emoji,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UkalabEmoji(emoji, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold)),
                Text(description,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 6年ロードマップ（設計書v2.0 段階バッジ）───

class _SixYearRoadmap extends StatelessWidget {
  final List<String> acquired;

  const _SixYearRoadmap({required this.acquired});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade800, Colors.purple.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🗺️', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text(
                '6年間の学習ロードマップ',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _RoadmapStep(
            emoji: '🏅',
            title: '小1-2: 基礎スポーツマスター',
            desc: 'ルール理解・基本フォーム・防災基礎',
            isCompleted: acquired.contains('grade_low'),
          ),
          _RoadmapArrow(),
          _RoadmapStep(
            emoji: '🏆',
            title: '小3-5: 応用思考力者',
            desc: '栄養・チームワーク・水の安全・複合判断',
            isCompleted: acquired.contains('grade_mid'),
          ),
          _RoadmapArrow(),
          _RoadmapStep(
            emoji: '👑',
            title: '小6: ホリスティック学習者',
            desc: 'スポーツ科学・キャリア探索・健康総合',
            isCompleted: acquired.contains('grade_high'),
          ),
        ],
      ),
    );
  }
}

class _RoadmapStep extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;
  final bool isCompleted;

  const _RoadmapStep({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.white.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: isCompleted
            ? Border.all(color: Colors.amber, width: 2)
            : null,
      ),
      child: Row(
        children: [
          UkalabEmoji(emoji, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                Text(desc,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 11)),
              ],
            ),
          ),
          if (isCompleted)
            const Icon(Icons.check_circle, color: Colors.amber, size: 24),
        ],
      ),
    );
  }
}

class _RoadmapArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: Icon(Icons.keyboard_arrow_down,
            color: Colors.white54, size: 24),
      ),
    );
  }
}

// ─── ③ 成長ハイライトカード ───

class _GrowthHighlightCard extends StatelessWidget {
  final StreakState streak;
  final List<String> acquired;
  final int completedStages;

  const _GrowthHighlightCard({
    required this.streak,
    required this.acquired,
    required this.completedStages,
  });

  @override
  Widget build(BuildContext context) {
    final message = _buildMessage();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📈', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text(
                '今月の成長ハイライト',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _shareHighlight(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.ios_share,
                          color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text('シェア',
                          style:
                              TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _HighlightStat('🔥', '${streak.currentStreak}日', '連続学習'),
              _HighlightStat('🏅', '${acquired.length}個', 'バッジ獲得'),
              _HighlightStat('📚', '${streak.totalStudyDays}日', '累計学習日'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _buildMessage() {
    if (completedStages >= 8) return '素晴らしい！ほぼ全ステージ制覇！学習の達人です 🏆';
    if (completedStages >= 4) return 'よく頑張っています！引き続き一緒に応援しましょう 💪';
    if (streak.currentStreak >= 7) return '7日連続達成！毎日続けることが一番大切！';
    if (streak.totalStudyDays >= 3) return '一歩一歩着実に前進中！続けることが力になります ⭐';
    return '今日も一緒に学習を始めましょう！ 📚';
  }

  void _shareHighlight(BuildContext context) {
    final text =
        '【体育・体験コレ！】${streak.currentStreak}日連続学習中！'
        'バッジ${acquired.length}個獲得！ステージ$completedStages/11クリア！ #たいくコレ';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 クリップボードにコピーしました！SNSに貼り付けてシェアしよう'),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.teal,
      ),
    );
  }
}

class _HighlightStat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _HighlightStat(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UkalabEmoji(emoji, size: 26),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        Text(
          label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
        ),
      ],
    );
  }
}

// ─── ⑤ 兄弟協力クエストカード ───

class _SiblingQuestCard extends ConsumerWidget {
  final ChildProfilesState profilesState;

  const _SiblingQuestCard({required this.profilesState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quests = ref.watch(siblingQuestProvider);
    final profiles = profilesState.profiles;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('👨‍👧‍👦', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              const Text(
                'きょうだい協力クエスト',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (profiles.length >= 2)
                TextButton(
                  onPressed: () =>
                      ref.read(siblingQuestProvider.notifier).generateNewQuests(),
                  child: const Text('更新',
                      style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'みんなで一緒に達成しよう！',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          if (profiles.length < 2) ...[
            _NoSiblingMessage(),
          ] else if (quests.isEmpty) ...[
            Center(
              child: ElevatedButton.icon(
                onPressed: () =>
                    ref.read(siblingQuestProvider.notifier).generateNewQuests(),
                icon: const Icon(Icons.add),
                label: const Text('クエストを始める'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ] else ...[
            ...quests.map((q) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _QuestTile(
                quest: q,
                profiles: profiles,
                onReset: () =>
                    ref.read(siblingQuestProvider.notifier).resetQuest(q.id),
              ),
            )),
          ],
        ],
      ),
    );
  }
}

class _NoSiblingMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Text('💡', style: TextStyle(fontSize: 18)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'プロフィールを2人以上追加すると、きょうだいクエストが始まります！',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestTile extends StatelessWidget {
  final SiblingQuest quest;
  final List<ChildProfile> profiles;
  final VoidCallback onReset;

  const _QuestTile({
    required this.quest,
    required this.profiles,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final color = quest.completed ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UkalabEmoji(quest.emoji, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  quest.title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color.shade700),
                ),
              ),
              if (quest.completed) ...[
                const Icon(Icons.check_circle,
                    color: Colors.green, size: 20),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onReset,
                  child: Text(
                    'リセット',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            quest.description,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: quest.totalProgress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          ...quest.progress.entries.map((e) {
            final profile = profiles.where((p) => p.id == e.key).firstOrNull;
            if (profile == null) return const SizedBox.shrink();
            final done = e.value >= quest.targetCount;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  UkalabEmoji(profile.emoji, size: 14),
                  const SizedBox(width: 6),
                  Text(profile.name,
                      style: const TextStyle(fontSize: 12)),
                  const Spacer(),
                  Text(
                    '${e.value} / ${quest.targetCount}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: done ? Colors.green : color,
                    ),
                  ),
                  if (done) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check,
                        color: Colors.green, size: 14),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── ① 親子交換日記カード ───

class _ParentDiaryCard extends ConsumerStatefulWidget {
  final ChildProfilesState profilesState;

  const _ParentDiaryCard({required this.profilesState});

  @override
  ConsumerState<_ParentDiaryCard> createState() => _ParentDiaryCardState();
}

class _ParentDiaryCardState extends ConsumerState<_ParentDiaryCard> {
  String? _selectedProfileId;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profiles = widget.profilesState.profiles;
    final messages = ref.watch(parentDiaryProvider);
    final targetId = _selectedProfileId ?? profiles.firstOrNull?.id;
    final recentMessages =
        messages.where((m) => m.toProfileId == targetId).take(3).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCC02), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('💌', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                '親子交換日記',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'お子さんへ応援メッセージを送ろう！',
            style: TextStyle(fontSize: 12, color: Color(0xFF795548)),
          ),
          const SizedBox(height: 16),

          // プロフィール選択
          if (profiles.length > 1) ...[
            const Text('送り先：',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: profiles.map((p) {
                  final selected = (targetId == p.id);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedProfileId = p.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFFFCC02)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFFFFB300)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          '${p.emoji} ${p.name}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // テンプレート選択
          const Text('テンプレート：',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: kDiaryTemplates.map((t) => GestureDetector(
              onTap: () => _controller.text = t['message']!,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Text(
                  '${t['emoji']} ${t['message']!.substring(0, (t['message']!.length).clamp(0, 12))}…',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),

          // カスタムメッセージ入力
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'オリジナルメッセージを入力...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.amber.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: targetId == null ? null : () => _send(targetId),
              icon: const Icon(Icons.send, size: 16),
              label: const Text('送る！'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB300),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          // 最近のメッセージ
          if (recentMessages.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('最近のメッセージ：',
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...recentMessages.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UkalabEmoji(m.emoji, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(m.message,
                          style: const TextStyle(fontSize: 12)),
                    ),
                    if (!m.read)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('未読',
                            style: TextStyle(
                                color: Colors.white, fontSize: 9)),
                      ),
                  ],
                ),
              ),
            )),
          ],
        ],
      ),
    );
  }

  Future<void> _send(String toProfileId) async {
    final msg = _controller.text.trim();
    if (msg.isEmpty) return;

    // テンプレートのemojiを探す
    String emoji = '⭐';
    for (final t in kDiaryTemplates) {
      if (t['message'] == msg) {
        emoji = t['emoji']!;
        break;
      }
    }

    await ref.read(parentDiaryProvider.notifier).sendMessage(
      fromName: 'おとうさん・おかあさん',
      toProfileId: toProfileId,
      message: msg,
      emoji: emoji,
    );

    _controller.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('💌 メッセージを送りました！'),
          backgroundColor: Colors.amber,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
