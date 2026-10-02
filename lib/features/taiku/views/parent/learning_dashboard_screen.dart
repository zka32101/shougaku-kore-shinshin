import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../taiku_app.dart';

/// 学習進捗ダッシュボード画面
/// 3つのゲーム（AITruth, CrimeQuiz, SafetyRisk）の成績を総合スコア、
/// 7日間のトレンドグラフ、弱点分野の自動検出で表示
class LearningDashboardScreen extends ConsumerStatefulWidget {
  const LearningDashboardScreen({super.key});

  @override
  ConsumerState<LearningDashboardScreen> createState() =>
      _LearningDashboardScreenState();
}

class _LearningDashboardScreenState
    extends ConsumerState<LearningDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // ダミーデータ
  static const _gameNames = ['AITruth', 'CrimeQuiz', 'SafetyRisk'];
  static const _gameEmojis = ['🤖', '🔍', '⚠️'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// ダミーデータ: 過去7日間のスコア（各ゲーム）
  List<List<int>> _get7DayScores() {
    return [
      [65, 72, 68, 75, 78, 82, 85], // AITruth
      [58, 62, 65, 70, 72, 75, 80], // CrimeQuiz
      [70, 68, 72, 75, 73, 78, 80], // SafetyRisk
    ];
  }

  /// 総合スコア（3つのゲームの平均）
  int _calculateOverallScore() {
    final scores = _get7DayScores();
    final latestScores = scores.map((s) => s.last).toList();
    return (latestScores.reduce((a, b) => a + b) / latestScores.length)
        .toInt();
  }

  /// スコアに応じた色を返す
  Color _scoreColor(int score) {
    if (score >= 80) return Colors.green; // 高
    if (score >= 65) return Colors.orange; // 中
    return Colors.red; // 低
  }

  /// 弱点分野を自動検出
  /// 最新スコアが低いゲームを弱点として返す
  List<Map<String, dynamic>> _detectWeaknesses() {
    final scores = _get7DayScores();
    final latest = scores
        .asMap()
        .entries
        .map((e) => {
              'game': _gameNames[e.key],
              'emoji': _gameEmojis[e.key],
              'score': e.value.last,
              'trend': _calculateTrend(e.value),
            })
        .toList();

    // スコアでソート（低い順）
    latest.sort((a, b) => (a['score'] as int).compareTo(b['score'] as int));
    return latest.take(2).toList(); // 最も弱い2つを返す
  }

  /// トレンド計算（前日比）
  int _calculateTrend(List<int> scores) {
    if (scores.length < 2) return 0;
    return scores.last - scores[scores.length - 2];
  }

  /// 7日のラベル（日付）
  List<String> _get7DayLabels() {
    final now = DateTime.now();
    return List.generate(
      7,
      (i) {
        final date = now.subtract(Duration(days: 6 - i));
        return '${date.month}/${date.day}';
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── ヘッダー ───
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            backgroundColor: TaikuColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 16, bottom: 14, right: 16),
              title: const Text(
                '📊 学習進捗ダッシュボード',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // ─── コンテンツ ───
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 総合スコアカード
                  _OverallScoreCard(
                    score: _calculateOverallScore(),
                    color: _scoreColor(_calculateOverallScore()),
                    animation: _animationController,
                  ),
                  const SizedBox(height: 24),

                  // ゲーム別成績グラフ（過去7日間）
                  _GameScoresChart(
                    scores: _get7DayScores(),
                    labels: _get7DayLabels(),
                    gameNames: _gameNames,
                    gameEmojis: _gameEmojis,
                    animation: _animationController,
                  ),
                  const SizedBox(height: 24),

                  // 弱点分野の自動検出
                  _WeaknessDetectionCard(
                    weaknesses: _detectWeaknesses(),
                    animation: _animationController,
                  ),
                  const SizedBox(height: 24),

                  // アクションボタン
                  _ActionButtons(
                    onDetailsTapped: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('詳細画面を開きました')),
                      );
                    },
                    onGoalSetTapped: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('目標設定画面を開きました')),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────
// 総合スコアカード
// ─────────────────────────────────────

class _OverallScoreCard extends StatelessWidget {
  final int score;
  final Color color;
  final AnimationController animation;

  const _OverallScoreCard({
    required this.score,
    required this.color,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.9), color.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '総合スコア',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '今週',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'pts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ScoreEvaluation(score: score),
          ],
        ),
      ),
    );
  }
}

class _ScoreEvaluation extends StatelessWidget {
  final int score;

  const _ScoreEvaluation({required this.score});

  @override
  Widget build(BuildContext context) {
    String evaluation;
    String emoji;

    if (score >= 80) {
      evaluation = '素晴らしい！継続力を保ちましょう';
      emoji = '🌟';
    } else if (score >= 65) {
      evaluation = '好調です。弱点を克服しましょう';
      emoji = '📈';
    } else {
      evaluation = '基礎を固めるチャンスです';
      emoji = '💪';
    }

    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            evaluation,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────
// ゲーム別成績グラフ（過去7日間のトレンド）
// ─────────────────────────────────────

class _GameScoresChart extends StatelessWidget {
  final List<List<int>> scores;
  final List<String> labels;
  final List<String> gameNames;
  final List<String> gameEmojis;
  final AnimationController animation;

  const _GameScoresChart({
    required this.scores,
    required this.labels,
    required this.gameNames,
    required this.gameEmojis,
    required this.animation,
  });

  static const _colors = [
    Color(0xFF2196F3), // 青
    Color(0xFFFF9800), // オレンジ
    Color(0xFF4CAF50), // 緑
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📈 ゲーム別成績（過去7日間）',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // グラフエリア
          SizedBox(
            height: 200,
            child: _LineChartWidget(
              scores: scores,
              colors: _colors,
              animation: animation,
            ),
          ),
          const SizedBox(height: 20),

          // 日付ラベル
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: labels
                .map((label) => Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),

          // ゲーム別の詳細
          ...List.generate(
            gameNames.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GameScoreRow(
                emoji: gameEmojis[index],
                name: gameNames[index],
                score: scores[index].last,
                trend: scores[index].last - scores[index][scores[index].length - 2],
                color: _colors[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartWidget extends StatelessWidget {
  final List<List<int>> scores;
  final List<Color> colors;
  final AnimationController animation;

  const _LineChartWidget({
    required this.scores,
    required this.colors,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(
        scores: scores,
        colors: colors,
        animation: animation,
      ),
      size: Size.infinite,
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<List<int>> scores;
  final List<Color> colors;
  final Animation<double> animation;

  _LineChartPainter({
    required this.scores,
    required this.colors,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 16.0;
    final graphWidth = size.width - (padding * 2);
    final graphHeight = size.height - (padding * 2);

    // グリッドラインを描画
    _drawGrid(canvas, size, padding);

    // 各ゲームの線を描画
    for (int gameIndex = 0; gameIndex < scores.length; gameIndex++) {
      _drawLine(
        canvas,
        scores[gameIndex],
        colors[gameIndex],
        padding,
        graphWidth,
        graphHeight,
        animation.value,
      );
    }
  }

  void _drawGrid(Canvas canvas, Size size, double padding) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 0.5;

    // 水平グリッドライン
    for (int i = 0; i <= 4; i++) {
      final y = padding + (size.height - padding * 2) * i / 4;
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        paint,
      );
    }
  }

  void _drawLine(
    Canvas canvas,
    List<int> gameScores,
    Color color,
    double padding,
    double graphWidth,
    double graphHeight,
    double progress,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = color
      ..strokeWidth = 3;

    for (int i = 0; i < gameScores.length - 1; i++) {
      final displayIndex = (gameScores.length - 1) * progress;
      if (i > displayIndex) break;

      final x1 = padding + (graphWidth / (gameScores.length - 1)) * i;
      final y1 = padding +
          graphHeight -
          ((gameScores[i] - 50) / 50) * graphHeight * 0.8;

      final x2 = padding + (graphWidth / (gameScores.length - 1)) * (i + 1);
      final y2 = padding +
          graphHeight -
          ((gameScores[i + 1] - 50) / 50) * graphHeight * 0.8;

      // 進捗に応じてラインを描画
      if (i < displayIndex) {
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      } else if (i == displayIndex.toInt()) {
        final fraction = displayIndex - i;
        final lerpX = x1 + (x2 - x1) * fraction;
        final lerpY = y1 + (y2 - y1) * fraction;
        canvas.drawLine(Offset(x1, y1), Offset(lerpX, lerpY), paint);
      }

      // ポイントを描画
      canvas.drawCircle(Offset(x1, y1), 3, pointPaint);
    }

    // 最後のポイント
    if (progress >= 1.0) {
      final lastY = padding +
          graphHeight -
          ((gameScores.last - 50) / 50) * graphHeight * 0.8;
      final lastX = padding + graphWidth;
      canvas.drawCircle(Offset(lastX, lastY), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter oldDelegate) => true;
}

class _GameScoreRow extends StatelessWidget {
  final String emoji;
  final String name;
  final int score;
  final int trend;
  final Color color;

  const _GameScoreRow({
    required this.emoji,
    required this.name,
    required this.score,
    required this.trend,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isTrendUp = trend >= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'スコア: $score pts',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isTrendUp
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  isTrendUp ? '📈' : '📉',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 4),
                Text(
                  '${isTrendUp ? '+' : ''}$trend',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isTrendUp ? Colors.green : Colors.red,
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

// ─────────────────────────────────────
// 弱点分野の自動検出
// ─────────────────────────────────────

class _WeaknessDetectionCard extends StatelessWidget {
  final List<Map<String, dynamic>> weaknesses;
  final AnimationController animation;

  const _WeaknessDetectionCard({
    required this.weaknesses,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('🎯', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text(
                  '弱点分野（自動検出）',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '改善が必要な分野です。重点的に学習しましょう',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            ...weaknesses.asMap().entries.map((entry) {
              final index = entry.key;
              final weakness = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < weaknesses.length - 1 ? 12 : 0,
                ),
                child: _WeaknessItem(
                  emoji: weakness['emoji'] as String,
                  game: weakness['game'] as String,
                  score: weakness['score'] as int,
                  trend: weakness['trend'] as int,
                ),
              );
            }),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Text('💡', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '苦手な分野は基礎から学び直すと効果的です',
                      style: TextStyle(fontSize: 12),
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

class _WeaknessItem extends StatelessWidget {
  final String emoji;
  final String game;
  final int score;
  final int trend;

  const _WeaknessItem({
    required this.emoji,
    required this.game,
    required this.score,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    Color scoreColor;
    if (score >= 80) {
      scoreColor = Colors.green;
    } else if (score >= 65) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                game,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '現在のスコア: $score pts',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: scoreColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            score >= 80 ? '要継続' : score >= 65 ? '要改善' : '要注力',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────
// アクションボタン
// ─────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final VoidCallback onDetailsTapped;
  final VoidCallback onGoalSetTapped;

  const _ActionButtons({
    required this.onDetailsTapped,
    required this.onGoalSetTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onDetailsTapped,
            icon: const Icon(Icons.bar_chart),
            label: const Text('詳細を見る'),
            style: ElevatedButton.styleFrom(
              backgroundColor: TaikuColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onGoalSetTapped,
            icon: const Icon(Icons.flag),
            label: const Text('目標設定'),
            style: OutlinedButton.styleFrom(
              foregroundColor: TaikuColors.primary,
              side: const BorderSide(color: TaikuColors.primary, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
