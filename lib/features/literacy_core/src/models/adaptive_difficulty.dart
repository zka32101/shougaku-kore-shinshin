import '../enums/grade_level.dart';

/// フレームワーク §6.2: アダプティブ難易度アルゴリズム
class AdaptiveDifficulty {
  final GradeLevel grade;
  final int _windowSize;       // 直近N問で計算
  final List<bool> _history;   // 正誤履歴

  AdaptiveDifficulty({
    required this.grade,
    int windowSize = 10,
  })  : _windowSize = windowSize,
        _history = [];

  void record(bool isCorrect) {
    _history.add(isCorrect);
    if (_history.length > _windowSize) _history.removeAt(0);
  }

  double get currentAccuracy {
    if (_history.isEmpty) return grade.targetAccuracy;
    return _history.where((v) => v).length / _history.length;
  }

  /// 現在の正答率から次の問題難易度を +1/0/-1 で返す
  DifficultyAdjustment get nextAdjustment {
    final acc = currentAccuracy;
    final floor = grade.accuracyFloor;
    final ceiling = grade.accuracyCeiling;

    if (acc > ceiling) return DifficultyAdjustment.increase; // 簡単すぎ → 難しくする
    if (acc < floor) return DifficultyAdjustment.decrease;   // 難しすぎ → 易しくする
    return DifficultyAdjustment.maintain;
  }

  bool get isStruggling => currentAccuracy < grade.accuracyFloor;
  bool get isMastering => currentAccuracy > grade.accuracyCeiling;

  /// 弱点判定：直近の問題で連続不正解
  bool get needsHint {
    if (_history.length < 3) return false;
    final recent = _history.sublist(_history.length - 3);
    return recent.every((v) => !v);
  }

  void reset() => _history.clear();
}

enum DifficultyAdjustment { increase, maintain, decrease }

/// 学習セッション統計
class SessionStats {
  final String sessionId;
  final String subject;
  final GradeLevel grade;
  final DateTime startedAt;
  DateTime? completedAt;

  int totalQuestions = 0;
  int correctAnswers = 0;
  final Map<int, int> stageAttempts = {}; // stageNumber → attempts
  final Map<int, int> stageCorrect = {};  // stageNumber → correct

  SessionStats({
    required this.sessionId,
    required this.subject,
    required this.grade,
    required this.startedAt,
  });

  double get accuracy =>
      totalQuestions == 0 ? 0 : correctAnswers / totalQuestions;

  Duration get duration => (completedAt ?? DateTime.now()).difference(startedAt);

  void recordAnswer(int stageNumber, bool correct) {
    totalQuestions++;
    if (correct) correctAnswers++;
    stageAttempts[stageNumber] = (stageAttempts[stageNumber] ?? 0) + 1;
    if (correct) {
      stageCorrect[stageNumber] = (stageCorrect[stageNumber] ?? 0) + 1;
    }
  }

  double stageAccuracy(int stageNumber) {
    final attempts = stageAttempts[stageNumber] ?? 0;
    if (attempts == 0) return 0;
    return (stageCorrect[stageNumber] ?? 0) / attempts;
  }

  /// 弱点ステージ（正答率が目標以下）
  List<int> weakStages(double targetAccuracy) {
    return stageAttempts.keys
        .where((s) => stageAccuracy(s) < targetAccuracy)
        .toList()
      ..sort();
  }
}
