/// フレームワーク §2: 学年別認知段階マッピング
enum GradeLevel {
  /// 小1-3: 具体的操作期。視覚・聴覚的学習、短い集中力
  low,

  /// 小4-5: 論理的思考の発達。グラフ・比較の導入
  mid,

  /// 小6: 形式的操作期。データ分析・統計・受験意識
  high,
}

extension GradeLevelExt on GradeLevel {
  String get label {
    switch (this) {
      case GradeLevel.low: return '低学年（小1-3）';
      case GradeLevel.mid: return '中学年（小4-5）';
      case GradeLevel.high: return '高学年（小6）';
    }
  }

  String get shortLabel {
    switch (this) {
      case GradeLevel.low: return '低学年';
      case GradeLevel.mid: return '中学年';
      case GradeLevel.high: return '高学年';
    }
  }

  /// 1-6年生の数値から学年グループに変換
  static GradeLevel fromGrade(int grade) {
    if (grade <= 3) return GradeLevel.low;
    if (grade <= 5) return GradeLevel.mid;
    return GradeLevel.high;
  }

  /// フレームワーク §6.2: 学習内容リテラシー - 目標正答率
  double get targetAccuracy {
    switch (this) {
      case GradeLevel.low: return 0.85;   // 85%以上
      case GradeLevel.mid: return 0.775;  // 70-85%の中央値
      case GradeLevel.high: return 0.675; // 60-75%（受験対策）
    }
  }

  /// フレームワーク §6.2: アダプティブ難易度の下限
  double get accuracyFloor {
    switch (this) {
      case GradeLevel.low: return 0.85;
      case GradeLevel.mid: return 0.70;
      case GradeLevel.high: return 0.60;
    }
  }

  /// フレームワーク §6.2: アダプティブ難易度の上限
  double get accuracyCeiling {
    switch (this) {
      case GradeLevel.low: return 1.00;
      case GradeLevel.mid: return 0.85;
      case GradeLevel.high: return 0.75;
    }
  }

  /// 1日推奨学習時間（分）
  int get dailyMinutes {
    switch (this) {
      case GradeLevel.low: return 10;
      case GradeLevel.mid: return 20;
      case GradeLevel.high: return 25;
    }
  }

  /// 1セッションの標準問題数
  int get sessionQuestionCount {
    switch (this) {
      case GradeLevel.low: return 10;
      case GradeLevel.mid: return 5;
      case GradeLevel.high: return 3;
    }
  }
}
