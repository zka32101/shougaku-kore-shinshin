import 'package:json_annotation/json_annotation.dart';

part 'analytics_model.g.dart';

@JsonSerializable()
class DailyStats {
  final String date; // YYYY-MM-DD
  final int questsCompleted;
  final int correctAnswers;
  final int totalAnswers;
  final int coinsEarned;
  final int studyMinutes;
  final Map<String, dynamic> categoryStats; // {categoryId: {correct, total}}

  DailyStats({
    required this.date,
    required this.questsCompleted,
    required this.correctAnswers,
    required this.totalAnswers,
    required this.coinsEarned,
    required this.studyMinutes,
    required this.categoryStats,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) =>
      _$DailyStatsFromJson(json);

  Map<String, dynamic> toJson() => _$DailyStatsToJson(this);
}

@JsonSerializable()
class MonthlyStats {
  final String month; // YYYY-MM
  final int totalQuestsCompleted;
  final int totalCorrectAnswers;
  final int totalAnswers;
  final double accuracyRate; // 0.0 ~ 1.0
  final int totalStudyMinutes;
  final int totalCoinsEarned;
  final int studyDaysCount; // 学習した日数
  final Map<String, dynamic> categoryStats; // {categoryId: {correct, total, accuracy}}

  MonthlyStats({
    required this.month,
    required this.totalQuestsCompleted,
    required this.totalCorrectAnswers,
    required this.totalAnswers,
    required this.accuracyRate,
    required this.totalStudyMinutes,
    required this.totalCoinsEarned,
    required this.studyDaysCount,
    required this.categoryStats,
  });

  double get accuracyPercentage => accuracyRate * 100;

  factory MonthlyStats.fromJson(Map<String, dynamic> json) =>
      _$MonthlyStatsFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlyStatsToJson(this);
}
