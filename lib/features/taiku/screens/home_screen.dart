import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../literacy_core/literacy_core.dart';
import '../data/taiku_questions.dart';
import '../taiku_app.dart';
import '../providers/taiku_providers.dart';
import '../providers/weather_provider.dart';
import '../providers/disaster_provider.dart';
import '../providers/child_profiles_provider.dart';
import '../providers/parent_diary_provider.dart';
import 'disaster_drill_screen.dart';
import 'package:shougaku_kore_doutoku/widgets/ukalab_emoji.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grade = ref.watch(gradeLevelProvider);
    final progressAsync = ref.watch(taikuProgressProvider);
    final recommended = ref.watch(recommendedStagesProvider);
    final parentTheme = ref.watch(parentThemeProvider);
    final streak = ref.watch(streakProvider);
    final isDisasterToday = ref.watch(isDisasterDayProvider);
    final weatherAsync = ref.watch(weatherProvider);
    final currentProfile = ref.watch(currentChildProfileProvider);
    final unreadCount = currentProfile != null
        ? ref.watch(unreadDiaryCountProvider(currentProfile.id))
        : 0;
    final isSleepTime = DateTime.now().hour >= 21;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _AppBar(grade: grade, streak: streak),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ⑦ ほしまる睡眠連動（21時以降）
                  if (isSleepTime) ...[
                    _HoshimaruSleepBanner(grade: grade),
                    const SizedBox(height: 12),
                  ],

                  // 📩 親からのメッセージ通知
                  if (unreadCount > 0 && currentProfile != null) ...[
                    _DiaryNotificationBanner(
                      profileName: currentProfile.name,
                      count: unreadCount,
                      profileId: currentProfile.id,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // 🚨 防災の日バナー（9/1・3/11のみ表示）
                  if (isDisasterToday) ...[
                    _DisasterDayBanner(),
                    const SizedBox(height: 12),
                  ],

                  // ③ 天気バナー（きょうの空モード）
                  weatherAsync.whenOrNull(
                    data: (w) => _WeatherBanner(weather: w),
                  ) ?? const SizedBox.shrink(),
                  if (weatherAsync.valueOrNull != null) const SizedBox(height: 12),

                  // ストリークバナー
                  if (streak.currentStreak > 0) ...[
                    _StreakBanner(streak: streak, grade: grade),
                    const SizedBox(height: 16),
                  ],

                  // 今日のおすすめ（v2.0 スマートメニュー）
                  _SmartRecommendCard(
                    recommended: recommended,
                    parentTheme: parentTheme,
                  ),
                  const SizedBox(height: 20),

                  // 週間進捗
                  progressAsync.when(
                    data: (p) => grade != GradeLevel.low
                        ? _WeeklyProgress(progress: p, grade: grade)
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  if (grade != GradeLevel.low) const SizedBox(height: 20),

                  // 📚 まなぶコーナーバナー
                  _LearnCornerBanner(grade: grade),
                  const SizedBox(height: 20),

                  // ⑩ スポーツ図鑑バナー
                  _SportEncyclopediaBanner(grade: grade),
                  const SizedBox(height: 20),

                  // テーマ別ステージグリッド
                  _ThemeStageGrid(grade: grade),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final GradeLevel grade;
  final StreakState streak;
  const _AppBar({required this.grade, required this.streak});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      pinned: true,
      backgroundColor: TaikuColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [TaikuColors.primary, Color(0xFFBF360C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 14, right: 16),
        title: Row(
          children: [
            // 拡大表示(FlexibleSpaceBar が1.5倍)でも横幅を超えないよう、残り幅で省略表示
            const Expanded(
              // 拡大表示(1.5倍)でも省略されないよう、収まらない分は縮小する
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '🏃 体験・体育コレ！',
                  maxLines: 1,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18),
                ),
              ),
            ),
            if (streak.currentStreak > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🔥 ${streak.currentStreak}日',
                  style: const TextStyle(color: Colors.white, fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(grade.shortLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ストリークバナー ───

class _StreakBanner extends StatelessWidget {
  final StreakState streak;
  final GradeLevel grade;

  const _StreakBanner({required this.streak, required this.grade});

  @override
  Widget build(BuildContext context) {
    final isLow = grade == GradeLevel.low;
    final milestones = [3, 7, 14, 30, 60, 100];
    final nextMilestone = milestones.firstWhere(
      (m) => m > streak.currentStreak,
      orElse: () => streak.currentStreak + 10,
    );
    final progress = streak.currentStreak / nextMilestone;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade700, Colors.orange.shade400],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLow
                      ? '${streak.currentStreak}にち れんぞく！'
                      : '${streak.currentStreak}日連続学習中！',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isLow
                      ? 'つぎのバッジまで ${nextMilestone - streak.currentStreak}にち'
                      : '次のバッジまであと ${nextMilestone - streak.currentStreak}日',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85), fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${streak.totalStudyMinutes}分',
                style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                isLow ? 'そうがくしゅう' : '累計学習',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8), fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmartRecommendCard extends ConsumerWidget {
  final List<int> recommended;
  final String? parentTheme;

  const _SmartRecommendCard({
    required this.recommended,
    required this.parentTheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (recommended.isEmpty) return const SizedBox.shrink();

    final primaryStage = recommended.first;
    final theme = stageThemes[primaryStage] ?? 'sports';
    final color = TaikuColors.forTheme(theme);
    final emoji = stageEmoji[primaryStage] ?? '🏃';
    final title = stageTitle[primaryStage] ?? 'ステージ$primaryStage';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '🎯 今日のおすすめ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (parentTheme != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: TaikuColors.forTheme(parentTheme!).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _themeLabel(parentTheme!),
                  style: TextStyle(
                      fontSize: 11,
                      color: TaikuColors.forTheme(parentTheme!),
                      fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // メイン推奨カード
        GestureDetector(
          onTap: () {
            ref.read(currentStageProvider.notifier).state = primaryStage;
            Navigator.of(context).pushNamed('/quiz');
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                UkalabEmoji(emoji, size: 52),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1️⃣ おすすめ',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12),
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stage $primaryStage · ${_themeLabel(theme)}',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.play_circle_fill,
                    color: Colors.white, size: 44),
              ],
            ),
          ),
        ),

        // サブ推奨（2番・3番）
        if (recommended.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            children: recommended
                .skip(1)
                .take(2)
                .toList()
                .asMap()
                .entries
                .map((entry) {
              final rank = entry.key + 2;
              final stage = entry.value;
              final sTheme = stageThemes[stage] ?? 'sports';
              final sColor = TaikuColors.forTheme(sTheme);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: entry.key == 0 ? 0 : 6,
                      right: entry.key == 0 ? 6 : 0),
                  child: GestureDetector(
                    onTap: () {
                      ref.read(currentStageProvider.notifier).state = stage;
                      Navigator.of(context).pushNamed('/quiz');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: sColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: sColor.withValues(alpha: 0.3), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Text('$rank️⃣',
                              style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stageEmoji[stage] ?? '🏃',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                Text(
                                  stageTitle[stage] ?? 'ステージ$stage',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: sColor),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  String _themeLabel(String theme) {
    switch (theme) {
      case 'sports': return 'スポーツ';
      case 'disaster': return '防災';
      case 'nutrition': return '栄養';
      case 'career': return 'キャリア';
      case 'health': return '健康';
      case 'safety': return 'あんぜん';
      case 'environment': return '環境';
      case 'money': return 'お金';
      case 'values': return '価値観';
      case 'art': return '図工';
      case 'music': return '音楽';
      case 'home_ec': return '家庭科';
      case 'ict': return '情報';
      case 'experience': return '実体験';
      default: return theme;
    }
  }
}

class _WeeklyProgress extends StatelessWidget {
  final LiteracyProgress progress;
  final GradeLevel grade;

  const _WeeklyProgress({required this.progress, required this.grade});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
        ],
      ),
      child: LiteracyDashboardWidget(
        progress: progress,
        grade: grade,
        accentColor: TaikuColors.primary,
      ),
    );
  }
}

class _ThemeStageGrid extends ConsumerWidget {
  final GradeLevel grade;

  const _ThemeStageGrid({required this.grade});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(taikuProgressProvider);
    final progress = progressAsync.valueOrNull;
    final stages = stagesForGrade(grade);

    // テーマ別グループ化
    final themeGroups = <String, List<int>>{};
    for (final stage in stages) {
      final theme = stageThemes[stage] ?? 'sports';
      themeGroups.putIfAbsent(theme, () => []).add(stage);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ステージ一覧',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...themeGroups.entries.map((entry) {
          final theme = entry.key;
          final themeStages = entry.value;
          final color = TaikuColors.forTheme(theme);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _themeLabel(theme),
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: grade == GradeLevel.low ? 2 : 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: grade == GradeLevel.low ? 1.3 : 1.1,
                children: themeStages.map((stageNum) {
                  final stageProgress = progress?.stages[stageNum];
                  final isUnlocked =
                      progress?.isStageUnlocked(stageNum) ??
                          stageNum == stages.first;
                  final isCompleted = stageProgress?.isCompleted ?? false;

                  return _StageCard(
                    stageNum: stageNum,
                    grade: grade,
                    isUnlocked: isUnlocked,
                    isCompleted: isCompleted,
                    accuracy: stageProgress?.accuracy,
                    color: color,
                    onTap: isUnlocked
                        ? () {
                            ref
                                .read(currentStageProvider.notifier)
                                .state = stageNum;
                            Navigator.of(context).pushNamed('/quiz');
                          }
                        : () => ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text('ひとつ前のステージをクリアすると、あそべるようになるよ'),
                              duration: Duration(seconds: 2),
                            ),
                          ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          );
        }),
      ],
    );
  }

  String _themeLabel(String theme) {
    switch (theme) {
      case 'sports': return '⚽ スポーツ';
      case 'disaster': return '🛡️ 防災';
      case 'nutrition': return '🥗 栄養';
      case 'career': return '⭐ キャリア';
      case 'health': return '💪 健康';
      case 'safety': return '🚦 あんぜん';
      case 'environment': return '🌏 環境';
      case 'money': return '💴 お金';
      case 'values': return '💡 価値観';
      case 'art': return '🎨 図工';
      case 'music': return '🎵 音楽';
      case 'home_ec': return '🍳 家庭科';
      case 'ict': return '💻 情報';
      case 'experience': return '🌟 実体験';
      default: return theme;
    }
  }
}

class _StageCard extends StatelessWidget {
  final int stageNum;
  final GradeLevel grade;
  final bool isUnlocked;
  final bool isCompleted;
  final double? accuracy;
  final Color color;
  final VoidCallback? onTap;

  const _StageCard({
    required this.stageNum,
    required this.grade,
    required this.isUnlocked,
    required this.isCompleted,
    required this.accuracy,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = stageEmoji[stageNum] ?? '🏃';
    final title = stageTitle[stageNum] ?? 'ステージ$stageNum';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCompleted
              ? color.withValues(alpha: 0.12)
              : isUnlocked
                  ? Colors.white
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? color
                : isUnlocked
                    ? Colors.grey.shade200
                    : Colors.grey.shade200,
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: isUnlocked && !isCompleted
              ? [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06), blurRadius: 6)]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Text(isUnlocked ? emoji : '🔒',
                    style: TextStyle(
                        fontSize:
                            grade == GradeLevel.low ? 28 : 22)),
                if (isCompleted)
                  const Positioned(
                    top: -2,
                    right: -2,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: LiteracyColors.correct,
                      child: Icon(Icons.check, size: 10, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: grade == GradeLevel.low ? 11 : 10,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.black87 : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (accuracy != null && grade != GradeLevel.low) ...[
              const SizedBox(height: 4),
              Text(
                '${(accuracy! * 100).round()}%',
                style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── ③ きょうの空モード：天気バナー ───

class _WeatherBanner extends StatelessWidget {
  final dynamic weather;
  const _WeatherBanner({required this.weather});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 天気詳細 + おすすめ活動モーダル
        showModalBottomSheet<void>(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => _WeatherDetailSheet(weather: weather),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF90CAF9)),
        ),
        child: Row(
          children: [
            UkalabEmoji(weather.weatherEmoji, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                weather.recommendMessage,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1565C0),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF90CAF9), size: 20),
          ],
        ),
      ),
    );
  }
}

class _WeatherDetailSheet extends StatelessWidget {
  final dynamic weather;
  const _WeatherDetailSheet({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UkalabEmoji(weather.weatherEmoji, size: 56),
          const SizedBox(height: 8),
          Text(
            'きょうの空：${weather.weatherLabel}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            '${weather.temperature}℃',
            style: const TextStyle(fontSize: 32, color: Color(0xFF1565C0)),
          ),
          const SizedBox(height: 16),
          if (weather.alerts.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '警報が出ています。\n防災学習をしてみよう！',
                      style: const TextStyle(color: Color(0xFFC62828)),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          const Text(
            'きょうのおすすめテーマ：',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final theme in weather.recommendedThemes as List<String>)
                _ThemeChip(theme: theme),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String theme;
  const _ThemeChip({required this.theme});

  static const _map = {
    'sports': ('⚽', 'スポーツ', Color(0xFF2196F3)),
    'disaster': ('🛡️', '防災', Color(0xFFFF5722)),
    'nutrition': ('🥗', '栄養', Color(0xFF4CAF50)),
    'career': ('💼', 'キャリア', Color(0xFF9C27B0)),
  };

  @override
  Widget build(BuildContext context) {
    final info = _map[theme];
    if (info == null) return const SizedBox.shrink();
    final (emoji, label, color) = info;
    return Chip(
      label: Text('$emoji $label'),
      backgroundColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    );
  }
}

// ─── ⑦ ほしまる睡眠連動バナー ───

class _HoshimaruSleepBanner extends StatelessWidget {
  final GradeLevel grade;
  const _HoshimaruSleepBanner({required this.grade});

  @override
  Widget build(BuildContext context) {
    final isLow = grade == GradeLevel.low;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF311B92)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('😴', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLow ? 'ほしまるは ねているよ' : 'ほしまるは寝ています',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLow
                      ? 'きょうのべんきょうはおわり！おやすみ ⭐'
                      : '今日の学習はここまで。おやすみなさい ⭐',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Text('🌙', style: TextStyle(fontSize: 24)),
        ],
      ),
    );
  }
}

// ─── ① 親からのメッセージ通知バナー ───

class _DiaryNotificationBanner extends ConsumerWidget {
  final String profileName;
  final int count;
  final String profileId;

  const _DiaryNotificationBanner({
    required this.profileName,
    required this.count,
    required this.profileId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(parentDiaryProvider.notifier).markRead(profileId);
        _showMessages(context, ref);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFCC02), width: 2),
        ),
        child: Row(
          children: [
            const Text('💌', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'おとうさん・おかあさんから $count 件のメッセージ！',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'タップして見てみよう！',
                    style: TextStyle(fontSize: 11, color: Color(0xFF795548)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFFFFCC02),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessages(BuildContext context, WidgetRef ref) {
    final messages = ref.read(parentDiaryProvider.notifier).forProfile(profileId);
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💌 おとうさん・おかあさんより',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...messages.take(5).map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UkalabEmoji(m.emoji, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.message,
                            style: const TextStyle(fontSize: 14)),
                        Text(
                          '${m.fromName}より',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── ⑨ 防災の日バナー ───

class _DisasterDayBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => const DisasterDrillScreen(),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF5722), Color(0xFFFF9800)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF5722).withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🚨', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '今日はぼうさいの日！',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '家族みんなでミッションをやってみよう！',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}

// ─── ⑩ スポーツ図鑑バナー ───

class _SportEncyclopediaBanner extends StatelessWidget {
  final GradeLevel grade;
  const _SportEncyclopediaBanner({required this.grade});

  @override
  Widget build(BuildContext context) {
    final isLow = grade == GradeLevel.low;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/sports'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [TaikuColors.sports, Color(0xFFE65100)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: TaikuColors.sports.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text(
              '📚',
              style: TextStyle(fontSize: 36),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLow ? 'スポーツ ずかん' : 'スポーツ図鑑',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isLow
                        ? 'いろんなスポーツを しらべよう！'
                        : '20種類のスポーツを詳しく解説！',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}

// ─── まなぶコーナーバナー ───

class _LearnCornerBanner extends ConsumerWidget {
  final GradeLevel grade;
  const _LearnCornerBanner({required this.grade});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLow = grade == GradeLevel.low;

    return GestureDetector(
      onTap: () => ref.read(activeTabProvider.notifier).state = 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0277BD), Color(0xFF01579B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0277BD).withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('📖', style: TextStyle(fontSize: 34)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLow ? 'まなぶ コーナー' : 'まなぶコーナー',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isLow
                        ? 'ステージの せつめいを よもう！'
                        : '各ステージの解説と学習ポイントを確認！',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // テーマチップ
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MiniThemeChip('⚽'),
                    const SizedBox(width: 4),
                    _MiniThemeChip('🛡️'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MiniThemeChip('🥗'),
                    const SizedBox(width: 4),
                    _MiniThemeChip('⭐'),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}

class _MiniThemeChip extends StatelessWidget {
  final String emoji;
  const _MiniThemeChip(this.emoji);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: UkalabEmoji(emoji, size: 14),
      ),
    );
  }
}
