import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/analytics_models.dart';
import 'package:shougaku_kore_doutoku/widgets/furigana_text.dart';

/// Analytics Dashboard for displaying learning statistics
class AnalyticsDashboard extends StatelessWidget {
  final String userName;
  final int totalQuestions;
  final double averageAccuracy;
  final Duration totalTimeSpent;
  final List<DailyActivityData> dailyActivity;
  final List<AccuracyTrendData> accuracyTrend;

  const AnalyticsDashboard({
    required this.userName,
    required this.totalQuestions,
    required this.averageAccuracy,
    required this.totalTimeSpent,
    required this.dailyActivity,
    required this.accuracyTrend,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildMetricsGrid(context),
          const SizedBox(height: 24),
          _buildActivityChart(context),
          const SizedBox(height: 24),
          _buildAccuracyChart(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'がくしゅうのあゆみ',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'ユーザー: $userName',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildMetricCard(
            context,
            title: 'もんだい数',
            value: '$totalQuestions',
            icon: Icons.assignment,
          ),
          _buildMetricCard(
            context,
            title: 'せいかい率',
            value: '${(averageAccuracy * 100).toStringAsFixed(1)}%',
            icon: Icons.check_circle,
          ),
          _buildMetricCard(
            context,
            title: 'がくしゅう時間',
            value: _formatDuration(totalTimeSpent),
            icon: Icons.timer,
          ),
          _buildMetricCard(
            context,
            title: 'つづけている日数',
            value: '${dailyActivity.length}日',
            icon: Icons.calendar_today,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 12),
            FuriganaText(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart(BuildContext context) {
    if (dailyActivity.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'みっちゃくかつどう',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    barGroups: List.generate(
                      dailyActivity.length,
                      (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: dailyActivity[index].questionsAnswered.toDouble(),
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < dailyActivity.length) {
                              return FuriganaText(
                                _getDayLabel(dailyActivity[index].day),
                                style: const TextStyle(fontSize: 10),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}',
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccuracyChart(BuildContext context) {
    if (accuracyTrend.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FuriganaText(
                'せいかい率のすうじ',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          accuracyTrend.length,
                          (index) => FlSpot(
                            index.toDouble(),
                            accuracyTrend[index].accuracy * 100,
                          ),
                        ),
                        isCurved: true,
                        color: Colors.green,
                        dotData: FlDotData(show: true),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < accuracyTrend.length) {
                              return Text(
                                'W${accuracyTrend[index].week}',
                                style: const TextStyle(fontSize: 10),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}%',
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '$hours時間$minutes分';
    }
    return '$minutes分';
  }

  String _getDayLabel(int day) {
    const labels = ['', '月', '火', '水', '木', '金', '土', '日'];
    return day >= 1 && day <= 7 ? labels[day] : '';
  }
}
