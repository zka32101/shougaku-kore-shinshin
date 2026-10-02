import '../enums/grade_level.dart';
import '../enums/content_literacy_type.dart';

/// 全教科共通の問題モデル基底クラス
class LiteracyQuestion {
  final String id;
  final String subject;           // 教科識別子 ('math', 'japanese', 'science', ...)
  final GradeLevel gradeLevel;
  final LiteracyStage stage;
  final ContentLiteracyType contentType;
  final int difficultyRank;       // 1-5（段階内での難易度）
  final String questionText;
  final List<String> choices;
  final int correctIndex;
  final String? hintText;         // 低学年向けヒント
  final String feedbackCorrect;   // 正解時フィードバック
  final String feedbackIncorrect; // 不正解時フィードバック
  final String? explanationDetail; // 高学年向け詳細解説
  final String? relatedQuestionId; // 同パターン問題（高学年向け）
  final bool hasVisualSupport;    // イラスト・図が必要か
  final Duration? timeLimit;      // テスト対策時の制限時間

  const LiteracyQuestion({
    required this.id,
    required this.subject,
    required this.gradeLevel,
    required this.stage,
    required this.contentType,
    required this.difficultyRank,
    required this.questionText,
    required this.choices,
    required this.correctIndex,
    required this.feedbackCorrect,
    required this.feedbackIncorrect,
    this.hintText,
    this.explanationDetail,
    this.relatedQuestionId,
    this.hasVisualSupport = false,
    this.timeLimit,
  });

  bool checkCorrect(int index) => index == correctIndex;

  /// フレームワーク §6.2: 学年別フィードバックテキストを取得
  LiteracyFeedbackContent feedbackFor(bool correct) {
    return LiteracyFeedbackContent(
      grade: gradeLevel,
      isCorrect: correct,
      mainText: correct ? feedbackCorrect : feedbackIncorrect,
      explanation: correct ? null : explanationDetail,
      relatedQuestionId: correct ? relatedQuestionId : null,
    );
  }
}

/// フレームワーク §6.2: 学年別フィードバック内容
class LiteracyFeedbackContent {
  final GradeLevel grade;
  final bool isCorrect;
  final String mainText;
  final String? explanation;
  final String? relatedQuestionId;

  const LiteracyFeedbackContent({
    required this.grade,
    required this.isCorrect,
    required this.mainText,
    this.explanation,
    this.relatedQuestionId,
  });

  /// フレームワーク §6.2: 低学年フィードバックテンプレート
  static LiteracyFeedbackContent lowCorrect(String subject) =>
      LiteracyFeedbackContent(
        grade: GradeLevel.low,
        isCorrect: true,
        mainText: 'ピンポン！すごい！',
      );

  static LiteracyFeedbackContent lowIncorrect(String subject) =>
      LiteracyFeedbackContent(
        grade: GradeLevel.low,
        isCorrect: false,
        mainText: 'もう一回！できるよ！',
      );
}
