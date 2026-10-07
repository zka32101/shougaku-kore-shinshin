import '../enums/grade_level.dart';

/// ユーザーの学習進捗（教科横断・永続化）
class LiteracyProgress {
  final String userId;
  final String subject;
  final GradeLevel grade;
  final Map<int, StageProgress> stages; // stageNumber → progress
  final List<DailyRecord> dailyRecords;

  const LiteracyProgress({
    required this.userId,
    required this.subject,
    required this.grade,
    required this.stages,
    required this.dailyRecords,
  });

  /// フレームワーク §6.2: 段階スキップ不可 - 次に進める段階
  int get nextUnlockedStage {
    for (int i = 1; i <= 12; i++) {
      final progress = stages[i];
      if (progress == null || !progress.isCompleted) return i;
    }
    return 12;
  }

  /// すべてのステージを最初から遊べる（ロックしない）。
  bool isStageUnlocked(int stageNumber) => true;

  /// 今週の学習時間（分）
  int get weeklyMinutes {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return dailyRecords
        .where((r) => r.date.isAfter(weekStart))
        .fold(0, (sum, r) => sum + r.minutesStudied);
  }

  /// 直近7日の記録（グラフ用）
  List<DailyRecord> get last7Days {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return dailyRecords.where((r) => r.date.isAfter(cutoff)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// 単元別正答率（高学年ダッシュボード用）
  Map<int, double> get stageAccuracyMap {
    return {
      for (final e in stages.entries)
        e.key: e.value.accuracy,
    };
  }

  /// フレームワーク §6.3: 理解度の深さ指標（4段階）
  MasteryLevel masteryOf(int stageNumber) {
    final p = stages[stageNumber];
    if (p == null) return MasteryLevel.none;
    return p.masteryLevel;
  }

  LiteracyProgress copyWith({Map<int, StageProgress>? stages, List<DailyRecord>? dailyRecords}) {
    return LiteracyProgress(
      userId: userId,
      subject: subject,
      grade: grade,
      stages: stages ?? this.stages,
      dailyRecords: dailyRecords ?? this.dailyRecords,
    );
  }
}

class StageProgress {
  final int stageNumber;
  final int totalAttempts;
  final int correctAnswers;
  final bool isCompleted;       // 合格基準クリア済み
  final DateTime? completedAt;
  final String? earnedBadgeId;

  const StageProgress({
    required this.stageNumber,
    required this.totalAttempts,
    required this.correctAnswers,
    required this.isCompleted,
    this.completedAt,
    this.earnedBadgeId,
  });

  double get accuracy =>
      totalAttempts == 0 ? 0 : correctAnswers / totalAttempts;

  /// フレームワーク §6.3: 理解度4段階
  MasteryLevel get masteryLevel {
    if (totalAttempts == 0) return MasteryLevel.none;
    final acc = accuracy;
    if (acc >= 0.95) return MasteryLevel.create;
    if (acc >= 0.80) return MasteryLevel.apply;
    if (acc >= 0.65) return MasteryLevel.understand;
    return MasteryLevel.know;
  }

  StageProgress copyWith({int? totalAttempts, int? correctAnswers, bool? isCompleted, String? earnedBadgeId}) {
    return StageProgress(
      stageNumber: stageNumber,
      totalAttempts: totalAttempts ?? this.totalAttempts,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: (isCompleted ?? this.isCompleted) && completedAt == null
          ? DateTime.now()
          : completedAt,
      earnedBadgeId: earnedBadgeId ?? this.earnedBadgeId,
    );
  }
}

/// フレームワーク §6.3: 理解度の深さ（親向けレポート）
enum MasteryLevel {
  none,        // 未着手
  know,        // 知識（正答率 <65%）
  understand,  // 理解（65-80%）
  apply,       // 習熟（80-95%）
  create,      // 創造（95%+）
}

extension MasteryLevelExt on MasteryLevel {
  String get label {
    switch (this) {
      case MasteryLevel.none: return '未着手';
      case MasteryLevel.know: return '知識';
      case MasteryLevel.understand: return '理解';
      case MasteryLevel.apply: return '習熟';
      case MasteryLevel.create: return '創造';
    }
  }

  int get stars {
    switch (this) {
      case MasteryLevel.none: return 0;
      case MasteryLevel.know: return 1;
      case MasteryLevel.understand: return 2;
      case MasteryLevel.apply: return 3;
      case MasteryLevel.create: return 4;
    }
  }
}

class DailyRecord {
  final DateTime date;
  final int minutesStudied;
  final int questionsAnswered;
  final int correctAnswers;

  const DailyRecord({
    required this.date,
    required this.minutesStudied,
    required this.questionsAnswered,
    required this.correctAnswers,
  });

  double get accuracy =>
      questionsAnswered == 0 ? 0 : correctAnswers / questionsAnswered;
}
