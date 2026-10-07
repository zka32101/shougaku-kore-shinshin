/// 学年(1〜6)を 低/中/高学年 に分類するユーティリティ。
enum GradeBand { low, mid, high }

extension GradeBandExt on GradeBand {
  String get label {
    switch (this) {
      case GradeBand.low:
        return '低学年';
      case GradeBand.mid:
        return '中学年';
      case GradeBand.high:
        return '高学年';
    }
  }

  String get rangeLabel {
    switch (this) {
      case GradeBand.low:
        return '低学年(1-2年)';
      case GradeBand.mid:
        return '中学年(3-4年)';
      case GradeBand.high:
        return '高学年(5-6年)';
    }
  }
}

/// 小学校の一般的な区分: 低(1-2) / 中(3-4) / 高(5-6)。
GradeBand gradeBandOf(int grade) {
  if (grade <= 2) return GradeBand.low;
  if (grade <= 4) return GradeBand.mid;
  return GradeBand.high;
}

/// ストーリーの学年目安ラベル(例: 「中学年」)。
String gradeBandLabel(int grade) => gradeBandOf(grade).label;
