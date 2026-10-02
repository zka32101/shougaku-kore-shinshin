import 'package:flutter/material.dart';
import '../enums/grade_level.dart';
import '../models/literacy_progress.dart';
import '../theme/literacy_colors.dart';

/// フレームワーク §4: 学年別ダッシュボードウィジェット
///
/// 低学年: データ表示なし（バッジ・スター中心）
/// 中学年: 週別学習時間・得意/苦手単元（簡易グラフ）
/// 高学年: 詳細統計・単元別正答率・推奨学習順序
class LiteracyDashboardWidget extends StatelessWidget {
  final LiteracyProgress progress;
  final GradeLevel grade;
  final Color? accentColor;

  const LiteracyDashboardWidget({
    super.key,
    required this.progress,
    required this.grade,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    switch (grade) {
      case GradeLevel.low:
        return _LowGradeDashboard(progress: progress, accentColor: accentColor);
      case GradeLevel.mid:
        return _MidGradeDashboard(progress: progress, accentColor: accentColor);
      case GradeLevel.high:
        return _HighGradeDashboard(progress: progress, accentColor: accentColor);
    }
  }
}

/// 低学年: バッジ獲得数・レベルのみ表示（データ非表示）
class _LowGradeDashboard extends StatelessWidget {
  final LiteracyProgress progress;
  final Color? accentColor;

  const _LowGradeDashboard({required this.progress, this.accentColor});

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? LiteracyColors.lowPrimary;
    final completedStages = progress.stages.values.where((s) => s.isCompleted).length;

    return Column(
      children: [
        // 進捗サークル
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$completedStages',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                'クリア！',
                style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // バッジリスト（獲得済み）
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: progress.stages.values
              .where((s) => s.isCompleted && s.earnedBadgeId != null)
              .map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(s.earnedBadgeId ?? '🏅', style: const TextStyle(fontSize: 16)),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

/// 中学年: 週別時間・得意/苦手単元（フレームワーク §4 Level2）
class _MidGradeDashboard extends StatelessWidget {
  final LiteracyProgress progress;
  final Color? accentColor;

  const _MidGradeDashboard({required this.progress, this.accentColor});

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? LiteracyColors.midPrimary;
    final records = progress.last7Days;
    final totalMinutes = records.fold(0, (s, r) => s + r.minutesStudied);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 今週の学習時間ヘッダー
        Text(
          '今週の学習時間',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 8),
        // 簡易棒グラフ
        _WeeklyBarChart(records: records, color: color),
        const SizedBox(height: 4),
        Text(
          '合計 $totalMinutes分',
          style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 16),
        // 目標達成度バー
        _GoalProgressBar(
          current: totalMinutes,
          goal: GradeLevel.mid.dailyMinutes * 7,
          color: color,
        ),
        const SizedBox(height: 16),
        // 得意/苦手単元
        _StageStrengthRow(progress: progress, color: color),
      ],
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  final List<DailyRecord> records;
  final Color color;

  const _WeeklyBarChart({required this.records, required this.color});

  @override
  Widget build(BuildContext context) {
    const days = ['月', '火', '水', '木', '金', '土', '日'];
    final maxMin = records.isEmpty ? 1 : records.map((r) => r.minutesStudied).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final record = records.length > i ? records[i] : null;
          final minutes = record?.minutesStudied ?? 0;
          final ratio = maxMin == 0 ? 0.0 : minutes / maxMin;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('$minutes', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                  const SizedBox(height: 2),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: ratio * 48 + 4,
                    decoration: BoxDecoration(
                      color: ratio > 0 ? color : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(days[i], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _GoalProgressBar extends StatelessWidget {
  final int current;
  final int goal;
  final Color color;

  const _GoalProgressBar({required this.current, required this.goal, required this.color});

  @override
  Widget build(BuildContext context) {
    final ratio = (current / goal).clamp(0.0, 1.0);
    final pct = (ratio * 100).round();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('目標達成度', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('$pct%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _StageStrengthRow extends StatelessWidget {
  final LiteracyProgress progress;
  final Color color;

  const _StageStrengthRow({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    final accuracyMap = progress.stageAccuracyMap;
    if (accuracyMap.isEmpty) return const SizedBox.shrink();

    final sorted = accuracyMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final best = sorted.first;
    final worst = sorted.last;

    return Row(
      children: [
        Expanded(
          child: _StrengthChip(
            label: '得意な単元',
            stageNumber: best.key,
            accuracy: best.value,
            isStrong: true,
            color: LiteracyColors.correct,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StrengthChip(
            label: '頑張ろう',
            stageNumber: worst.key,
            accuracy: worst.value,
            isStrong: false,
            color: LiteracyColors.warning,
          ),
        ),
      ],
    );
  }
}

class _StrengthChip extends StatelessWidget {
  final String label;
  final int stageNumber;
  final double accuracy;
  final bool isStrong;
  final Color color;

  const _StrengthChip({
    required this.label,
    required this.stageNumber,
    required this.accuracy,
    required this.isStrong,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(
            'ステージ $stageNumber',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          Text(
            '${(accuracy * 100).round()}%',
            style: TextStyle(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }
}

/// 高学年: 詳細統計ダッシュボード（フレームワーク §4 Level3）
class _HighGradeDashboard extends StatelessWidget {
  final LiteracyProgress progress;
  final Color? accentColor;

  const _HighGradeDashboard({required this.progress, this.accentColor});

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? LiteracyColors.highPrimary;
    final accuracyMap = progress.stageAccuracyMap;
    final weakStages = accuracyMap.entries
        .where((e) => e.value < GradeLevel.high.accuracyFloor)
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 学習時間サマリー
        _HighSummaryRow(progress: progress, color: color),
        const SizedBox(height: 16),
        // 単元別正答率テーブル
        const Text(
          '単元別成績（正答率）',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        const SizedBox(height: 6),
        _StageAccuracyTable(accuracyMap: accuracyMap, progress: progress),
        const SizedBox(height: 16),
        // 推奨学習順序（弱点ベース）
        if (weakStages.isNotEmpty) ...[
          const Text(
            '推奨学習順序',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          _RecommendList(weakStages: weakStages),
        ],
      ],
    );
  }
}

class _HighSummaryRow extends StatelessWidget {
  final LiteracyProgress progress;
  final Color color;

  const _HighSummaryRow({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    final records = progress.last7Days;
    final totalMin = records.fold(0, (s, r) => s + r.minutesStudied);
    final avgMin = records.isEmpty ? 0 : totalMin ~/ records.length;

    return Row(
      children: [
        _StatCell(label: '平均学習', value: '$avgMin分/日', color: color),
        _StatCell(label: '累計', value: '$totalMin分', color: color),
        _StatCell(
          label: 'クリア段階',
          value: '${progress.stages.values.where((s) => s.isCompleted).length}/12',
          color: color,
        ),
      ].map((w) => Expanded(child: w)).toList() as List<Widget>,
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCell({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _StageAccuracyTable extends StatelessWidget {
  final Map<int, double> accuracyMap;
  final LiteracyProgress progress;

  const _StageAccuracyTable({required this.accuracyMap, required this.progress});

  @override
  Widget build(BuildContext context) {
    final entries = accuracyMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    if (entries.isEmpty) return const SizedBox.shrink();

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(3),
      },
      border: TableBorder.all(color: Colors.grey.shade100, width: 1),
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade50),
          children: ['単元', '正答率', '習熟度'].map((h) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(h, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          )).toList(),
        ),
        ...entries.take(6).map((e) {
          final mastery = progress.masteryOf(e.key);
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Text('ステージ${e.key}', style: const TextStyle(fontSize: 12)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Text('${(e.value * 100).round()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: e.value >= 0.80 ? LiteracyColors.correct : LiteracyColors.warning,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  children: List.generate(4, (i) => Icon(
                    i < mastery.stars ? Icons.diamond : Icons.diamond_outlined,
                    size: 10,
                    color: i < mastery.stars ? LiteracyColors.highPrimary : Colors.grey.shade300,
                  )),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _RecommendList extends StatelessWidget {
  final List<MapEntry<int, double>> weakStages;

  const _RecommendList({required this.weakStages});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: weakStages.take(3).toList().asMap().entries.map((e) {
        final rank = e.key + 1;
        final stage = e.value.key;
        final acc = e.value.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: LiteracyColors.highPrimary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text('$rank', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ステージ $stage（正答率 ${(acc * 100).round()}%）',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
