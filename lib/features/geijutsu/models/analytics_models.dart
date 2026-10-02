/// Model for daily activity data
class DailyActivityData {
  final int day;
  final int questionsAnswered;

  DailyActivityData({
    required this.day,
    required this.questionsAnswered,
  });
}

/// Model for accuracy trend data
class AccuracyTrendData {
  final int week;
  final double accuracy; // 0.0 - 1.0

  AccuracyTrendData({
    required this.week,
    required this.accuracy,
  });
}
