import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../literacy_core/literacy_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../streak_dates.dart';
import '../data/taiku_questions.dart';

export '../../literacy_core/literacy_core.dart'
    show gradeLevelProvider, GradeLevelNotifier, literacyUILevelProvider;

// ─── アクティブタブ（RootShell） ───

final activeTabProvider = StateProvider<int>((ref) => 0);

// ─── 現在のステージ ───

final currentStageProvider = StateProvider<int>((ref) => 1);

// ─── ステージの問題リスト ───

final stageQuestionsProvider = Provider<List<TaikuQuestion>>((ref) {
  final stage = ref.watch(currentStageProvider);
  final grade = ref.watch(gradeLevelProvider);
  final all = getQuestionsForStage(stage);
  final gradeFiltered = all.where((q) => q.gradeLevel == grade).toList();
  // 学年フィルタで空の場合は全問返す（防災ステージは複数学年対応）
  return gradeFiltered.isNotEmpty ? gradeFiltered : all;
});

// ─── 体育コレ！進捗 ───

final taikuProgressProvider =
    StateNotifierProvider<LiteracyProgressNotifier, AsyncValue<LiteracyProgress>>(
  (ref) => LiteracyProgressNotifier(subject: 'taiku'),
);

// ─── 親ダッシュボード: 月間テーマ ───

const _kThemeKey = 'taiku_parent_theme';
const _kThemeSetKey = 'taiku_theme_set';

final parentThemeProvider =
    StateNotifierProvider<ParentThemeNotifier, String?>((ref) {
  return ParentThemeNotifier();
});

class ParentThemeNotifier extends StateNotifier<String?> {
  ParentThemeNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_kThemeKey);
  }

  Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, theme);
    await prefs.setBool(_kThemeSetKey, true);
    state = theme;
  }

  Future<void> clearTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kThemeKey);
    await prefs.remove(_kThemeSetKey);
    state = null;
  }
}

// ─── ストリーク（連続学習）管理 ───

class StreakState {
  final int currentStreak;
  final int longestStreak;
  final String lastStudyDate; // 'yyyy-MM-dd'
  final int totalStudyDays;
  final int totalStudyMinutes;
  final List<String> studyDates; // 'yyyy-MM-dd'(直近180日)

  const StreakState({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastStudyDate = '',
    this.totalStudyDays = 0,
    this.totalStudyMinutes = 0,
    this.studyDates = const [],
  });

  StreakState copyWith({
    int? currentStreak,
    int? longestStreak,
    String? lastStudyDate,
    int? totalStudyDays,
    int? totalStudyMinutes,
    List<String>? studyDates,
  }) =>
      StreakState(
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        lastStudyDate: lastStudyDate ?? this.lastStudyDate,
        totalStudyDays: totalStudyDays ?? this.totalStudyDays,
        totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
        studyDates: studyDates ?? this.studyDates,
      );

  Set<DateTime> get studyDaySet => studyDatesToSet(studyDates);
}

class StreakNotifier extends StateNotifier<StreakState> {
  static const _kStreak = 'taiku_streak';
  static const _kLongest = 'taiku_longest_streak';
  static const _kLastDate = 'taiku_last_study_date';
  static const _kTotalDays = 'taiku_total_study_days';
  static const _kTotalMin = 'taiku_total_study_minutes';
  static const _kStudyDates = 'taiku_study_dates';

  StreakNotifier() : super(const StreakState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final streak = prefs.getInt(_kStreak) ?? 0;
    final lastStr = prefs.getString(_kLastDate) ?? '';
    var dates = prefs.getStringList(_kStudyDates);
    if (dates == null) {
      // 初回のみ: 現在の連続日数と最終学習日から最終日までN日をバックフィル
      // (この連続は「学習(クイズ完了)した日」基準なので実態と一致する)
      final last = parseStudyDate(lastStr);
      dates = last == null ? <String>[] : backfillStudyDates(streak, last);
      if (dates.isNotEmpty) await prefs.setStringList(_kStudyDates, dates);
    }
    state = StreakState(
      currentStreak: streak,
      longestStreak: prefs.getInt(_kLongest) ?? 0,
      lastStudyDate: lastStr,
      totalStudyDays: prefs.getInt(_kTotalDays) ?? 0,
      totalStudyMinutes: prefs.getInt(_kTotalMin) ?? 0,
      studyDates: normalizeStudyDates(dates, DateTime.now()),
    );
  }

  /// クイズ完了時に呼び出す（addMinutes: 今回の学習時間分）
  Future<void> recordStudy({int addMinutes = 0}) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final last = state.lastStudyDate;

    int newStreak = state.currentStreak;
    int newDays = state.totalStudyDays;

    if (last == today) {
      // 今日すでに学習済み → ストリーク変更なし
    } else if (last == _yesterdayString()) {
      // 昨日学習 → ストリーク継続
      newStreak++;
      newDays++;
    } else {
      // 2日以上空いた → リセット
      newStreak = 1;
      newDays++;
    }

    final newLongest = newStreak > state.longestStreak ? newStreak : state.longestStreak;
    final newMin = state.totalStudyMinutes + addMinutes;

    await prefs.setInt(_kStreak, newStreak);
    await prefs.setInt(_kLongest, newLongest);
    await prefs.setString(_kLastDate, today);
    await prefs.setInt(_kTotalDays, newDays);
    await prefs.setInt(_kTotalMin, newMin);
    final newDates = addStudyDate(state.studyDates, DateTime.now());
    await prefs.setStringList(_kStudyDates, newDates);

    state = StreakState(
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastStudyDate: today,
      totalStudyDays: newDays,
      totalStudyMinutes: newMin,
      studyDates: newDates,
    );
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _yesterdayString() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
  }
}

final streakProvider =
    StateNotifierProvider<StreakNotifier, StreakState>((ref) {
  return StreakNotifier();
});

// ─── スマート推奨エンジン（オフライン版 v2.0） ───

/// 推奨ステージを計算（設計書v2.0の重み付け）
final recommendedStagesProvider = Provider<List<int>>((ref) {
  final grade = ref.watch(gradeLevelProvider);
  final parentTheme = ref.watch(parentThemeProvider);
  final progressAsync = ref.watch(taikuProgressProvider);
  final progress = progressAsync.valueOrNull;
  final available = stagesForGrade(grade);

  if (progress == null) return available.take(3).toList();

  final scores = <int, double>{};
  for (final stageNum in available) {
    final stageProgress = progress.stages[stageNum];
    final accuracy = stageProgress?.accuracy ?? 0.5;
    final isCompleted = stageProgress?.isCompleted ?? false;

    // 親テーマ適合度（50%）
    double parentScore = 0.3;
    if (parentTheme != null) {
      final theme = stageThemes[stageNum] ?? '';
      parentScore = (theme == parentTheme) ? 1.0 : 0.2;
    }

    // AI適応度（35%）: 正答率が低いほど高スコア
    final aiScore = isCompleted ? (1.0 - accuracy) * 0.7 + 0.1 : 0.8;

    // 興味マッチ度（10%）: 未完了ステージを優先
    final interestScore = isCompleted ? 0.3 : 0.8;

    // 総合スコア
    scores[stageNum] = parentScore * 0.50 + aiScore * 0.35 + interestScore * 0.10 + 0.05;
  }

  final sorted = available.toList()
    ..sort((a, b) => scores[b]!.compareTo(scores[a]!));

  return sorted.take(3).toList();
});

// ─── クイズ状態 ───

class QuizState {
  final List<TaikuQuestion> questions;
  final int currentIndex;
  final int? selectedChoice;
  final bool isAnswered;
  final List<bool> results;
  final DateTime startTime;

  QuizState({
    required this.questions,
    this.currentIndex = 0,
    this.selectedChoice,
    this.isAnswered = false,
    this.results = const [],
    DateTime? startTime,
  }) : startTime = startTime ?? DateTime.now();

  TaikuQuestion? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  bool get isComplete => currentIndex >= questions.length;
  int get correctCount => results.where((r) => r).length;
  double get accuracy => results.isEmpty ? 0 : correctCount / results.length;

  /// 経過時間（分）
  int get elapsedMinutes =>
      DateTime.now().difference(startTime).inSeconds ~/ 60 + 1;

  QuizState copyWith({
    int? currentIndex,
    int? selectedChoice,
    bool? isAnswered,
    List<bool>? results,
  }) =>
      QuizState(
        questions: questions,
        currentIndex: currentIndex ?? this.currentIndex,
        selectedChoice: selectedChoice ?? this.selectedChoice,
        isAnswered: isAnswered ?? this.isAnswered,
        results: results ?? this.results,
        startTime: startTime,
      );
}

class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier(List<TaikuQuestion> questions)
      : super(QuizState(questions: questions));

  void selectChoice(int index) {
    if (state.isAnswered) return;
    state = state.copyWith(selectedChoice: index, isAnswered: true);
  }

  void nextQuestion() {
    final isCorrect =
        state.selectedChoice == state.currentQuestion?.correctIndex;
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      selectedChoice: null,
      isAnswered: false,
      results: [...state.results, isCorrect],
    );
  }
}

/// まちがいノートの復習クイズ用オーバーライド（nullなら通常クイズ）
final reviewQuestionsOverrideProvider =
    StateProvider<List<TaikuQuestion>?>((ref) => null);

final quizNotifierProvider =
    StateNotifierProvider.autoDispose<QuizNotifier, QuizState>((ref) {
  final override = ref.read(reviewQuestionsOverrideProvider);
  if (override != null) {
    Future(() {
      try {
        ref.read(reviewQuestionsOverrideProvider.notifier).state = null;
      } catch (_) {}
    });
    return QuizNotifier(override);
  }
  final questions = ref.watch(stageQuestionsProvider);
  return QuizNotifier(questions);
});

// ─── バッジ定義（設計書v2.0 40+種） ───

class TaikuBadge {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final String category; // 'stage' | 'grade' | 'streak' | 'activity' | 'special'

  const TaikuBadge({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.category,
  });
}

const allBadges = <TaikuBadge>[
  // ── ステージクリアバッジ（12種）──
  TaikuBadge(
    id: 'stage_1_clear', emoji: '⚽', title: 'ルールマスター',
    description: 'スポーツのルールを完璧に学んだ！', category: 'stage',
  ),
  TaikuBadge(
    id: 'stage_2_clear', emoji: '🏃', title: '運動チャレンジャー',
    description: 'からだを動かすことの大切さを学んだ！', category: 'stage',
  ),
  TaikuBadge(
    id: 'stage_3_clear', emoji: '🥗', title: '栄養博士見習い',
    description: 'スポーツと栄養の関係を学んだ！', category: 'stage',
  ),
  TaikuBadge(
    id: 'stage_4_clear', emoji: '🏆', title: 'チームワークスター',
    description: 'チームスポーツの極意を習得！', category: 'stage',
  ),
  TaikuBadge(
    id: 'stage_5_clear', emoji: '🛡️', title: '防災の戦士',
    description: '防災の基本知識を身につけた！', category: 'stage',
  ),
  TaikuBadge(
    id: 'stage_6_clear', emoji: '💧', title: '水の守り人',
    description: '水の安全と救助技術を学んだ！', category: 'stage',
  ),
  TaikuBadge(
    id: 'stage_7_clear', emoji: '🥦', title: '健康の探究者',
    description: '栄養と健康の秘密を解き明かした！', category: 'stage',
  ),
  TaikuBadge(
    id: 'stage_8_clear', emoji: '💪', title: 'トレーニング科学者',
    description: '食事とトレーニングの科学を学んだ！', category: 'stage',
  ),
  TaikuBadge(
    id: 'stage_9_clear', emoji: '⭐', title: 'キャリア探検家',
    description: 'スポーツ関連のキャリアを探索した！', category: 'stage',
  ),
  TaikuBadge(
    id: 'stage_10_clear', emoji: '🔬', title: 'スポーツ科学者',
    description: 'スポーツ科学の最前線を学んだ！', category: 'stage',
  ),
  TaikuBadge(
    id: 'stage_11_clear', emoji: '🌟', title: '総合健康マスター',
    description: '健康とキャリアの総合力を身につけた！', category: 'stage',
  ),
  TaikuBadge(
    id: 'stage_12_clear', emoji: '🌏', title: 'グローバルアスリート',
    description: 'グローバルスポーツの視点を身につけた！', category: 'stage',
  ),
  TaikuBadge(
    id: 'stage_13_clear', emoji: '🌙', title: 'スリープマスター',
    description: '睡眠と生活リズムの科学を習得した！', category: 'stage',
  ),
  TaikuBadge(
    id: 'stage_14_clear', emoji: '💆', title: 'メンタルヘルスガイド',
    description: 'ストレス対処とこころの健康を学んだ！', category: 'stage',
  ),
  TaikuBadge(
    id: 'stage_15_clear', emoji: '🦠', title: '予防医学博士',
    description: '感染症予防と衛生管理の知識を獲得！', category: 'stage',
  ),
  TaikuBadge(
    id: 'stage_16_clear', emoji: '⚠️', title: '安全知識マスター',
    description: '家庭・外出先の危険を見抜く力を身につけた！', category: 'stage',
  ),
  TaikuBadge(
    id: 'stage_17_clear', emoji: '🚨', title: '防犯エキスパート',
    description: '犯罪から身を守る知識と行動力を習得！', category: 'stage',
  ),
  TaikuBadge(
    id: 'stage_18_clear', emoji: '🆘', title: '救急レスキュー',
    description: '緊急時の正しい対応と命を救う知識を獲得！', category: 'stage',
  ),
  TaikuBadge(
    id: 'stage_19_clear', emoji: '🌱', title: 'エコチャンピオン',
    description: '環境・SDGs・地球の未来を守る知識を習得！', category: 'stage',
  ),
  TaikuBadge(
    id: 'stage_20_clear', emoji: '💰', title: 'マネーマスター',
    description: 'お金の使い方・貯金・税金のきほんを身につけた！', category: 'stage',
  ),
  TaikuBadge(
    id: 'stage_21_clear', emoji: '🤝', title: '道徳スカウト',
    description: '人権・多様性・共感力・公正さを学んだ！', category: 'stage',
  ),

  // ── 段階バッジ（3種）──
  TaikuBadge(
    id: 'grade_low', emoji: '🏅', title: '基礎スポーツマスター',
    description: '低学年の体育・防災を完走！基礎力完成！', category: 'grade',
  ),
  TaikuBadge(
    id: 'grade_mid', emoji: '🏆', title: '応用思考力者',
    description: '中学年の複合知識を制覇！', category: 'grade',
  ),
  TaikuBadge(
    id: 'grade_high', emoji: '👑', title: 'ホリスティック学習者',
    description: '知識×実践×キャリア視点を統合！', category: 'grade',
  ),

  // ── ストリークバッジ（6種）──
  TaikuBadge(
    id: 'streak_3', emoji: '🔥', title: '3日連続！',
    description: '3日連続で学習した！', category: 'streak',
  ),
  TaikuBadge(
    id: 'streak_7', emoji: '🔥🔥', title: '1週間チャンピオン',
    description: '7日連続で学習した！', category: 'streak',
  ),
  TaikuBadge(
    id: 'streak_14', emoji: '⚡', title: '2週間ファイター',
    description: '14日連続で学習した！', category: 'streak',
  ),
  TaikuBadge(
    id: 'streak_30', emoji: '🌈', title: '1ヶ月マスター',
    description: '30日連続で学習した！', category: 'streak',
  ),
  TaikuBadge(
    id: 'streak_60', emoji: '💎', title: '2ヶ月レジェンド',
    description: '60日連続で学習した！', category: 'streak',
  ),
  TaikuBadge(
    id: 'streak_100', emoji: '🦁', title: '100日の猛者',
    description: '100日連続学習！圧倒的な継続力！', category: 'streak',
  ),

  // ── 実体験バッジ（6種）──
  TaikuBadge(
    id: 'activity_1', emoji: '🎯', title: 'はじめての体験',
    description: '初めての実体験チャレンジを達成！', category: 'activity',
  ),
  TaikuBadge(
    id: 'activity_5', emoji: '🌱', title: '体験の芽',
    description: '5つの実体験を達成！', category: 'activity',
  ),
  TaikuBadge(
    id: 'activity_10', emoji: '🌿', title: '体験コレクター',
    description: '10の実体験を達成！', category: 'activity',
  ),
  TaikuBadge(
    id: 'activity_disaster', emoji: '🆘', title: '防災ヒーロー',
    description: '防災系の実体験を3つ達成！', category: 'activity',
  ),
  TaikuBadge(
    id: 'activity_sports', emoji: '🏅', title: 'スポーツ実践者',
    description: 'スポーツ系の実体験を5つ達成！', category: 'activity',
  ),
  TaikuBadge(
    id: 'activity_parent', emoji: '👨‍👩‍👧', title: '親子チャレンジャー',
    description: '親子で一緒に実体験を5つ達成！', category: 'activity',
  ),

  // ── 特別バッジ（10種）──
  TaikuBadge(
    id: 'perfect_score', emoji: '💯', title: 'パーフェクト！',
    description: '全問正解を達成！', category: 'special',
  ),
  TaikuBadge(
    id: 'perfect_3', emoji: '✨', title: 'パーフェクトハット',
    description: '3回連続で全問正解！', category: 'special',
  ),
  TaikuBadge(
    id: 'all_stages_low', emoji: '🌟', title: '低学年制覇',
    description: '低学年のステージをすべてクリア！', category: 'special',
  ),
  TaikuBadge(
    id: 'all_stages_mid', emoji: '🌟🌟', title: '中学年制覇',
    description: '中学年のステージをすべてクリア！', category: 'special',
  ),
  TaikuBadge(
    id: 'all_stages_high', emoji: '🌟🌟🌟', title: '高学年制覇',
    description: '高学年のステージをすべてクリア！', category: 'special',
  ),
  TaikuBadge(
    id: 'sports_all', emoji: '🏆', title: 'スポーツ完全制覇',
    description: 'スポーツ系のステージを全部クリア！', category: 'special',
  ),
  TaikuBadge(
    id: 'disaster_all', emoji: '🛡️', title: '防災マスター',
    description: '防災系のステージを全部クリア！', category: 'special',
  ),
  TaikuBadge(
    id: 'nutrition_all', emoji: '🥗', title: '栄養の達人',
    description: '栄養系のステージを全部クリア！', category: 'special',
  ),
  TaikuBadge(
    id: 'career_all', emoji: '⭐', title: 'キャリア博士',
    description: 'キャリア系のステージを全部クリア！', category: 'special',
  ),
  TaikuBadge(
    id: 'all_clear', emoji: '🎊', title: '体育コレ完全制覇！',
    description: '全12ステージをクリアした伝説のプレイヤー！', category: 'special',
  ),
];

// ─── バッジ獲得管理 ───

final acquiredBadgesProvider =
    StateNotifierProvider<AcquiredBadgesNotifier, List<String>>((ref) {
  return AcquiredBadgesNotifier();
});

class AcquiredBadgesNotifier extends StateNotifier<List<String>> {
  AcquiredBadgesNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList('taiku_badges') ?? [];
  }

  Future<bool> awardBadge(String badgeId) async {
    if (state.contains(badgeId)) return false;
    final prefs = await SharedPreferences.getInstance();
    final updated = [...state, badgeId];
    await prefs.setStringList('taiku_badges', updated);
    state = updated;
    return true;
  }

  Future<void> checkAndAwardBadges({
    required LiteracyProgress progress,
    required int stage,
    required double accuracy,
    required StreakState streak,
    required int activityCount,
  }) async {
    // ステージクリアバッジ
    if (accuracy >= 0.6) await awardBadge('stage_${stage}_clear');

    // パーフェクトバッジ
    if (accuracy >= 1.0) await awardBadge('perfect_score');

    // ストリークバッジ
    final s = streak.currentStreak;
    if (s >= 3) await awardBadge('streak_3');
    if (s >= 7) await awardBadge('streak_7');
    if (s >= 14) await awardBadge('streak_14');
    if (s >= 30) await awardBadge('streak_30');
    if (s >= 60) await awardBadge('streak_60');
    if (s >= 100) await awardBadge('streak_100');

    // 実体験バッジ
    if (activityCount >= 1) await awardBadge('activity_1');
    if (activityCount >= 5) await awardBadge('activity_5');
    if (activityCount >= 10) await awardBadge('activity_10');

    // テーマ制覇バッジ
    final completed = progress.stages.entries
        .where((e) => e.value.isCompleted)
        .map((e) => e.key)
        .toSet();

    if ({1, 2, 4}.every(completed.contains)) await awardBadge('sports_all');
    if ({5, 6}.every(completed.contains)) await awardBadge('disaster_all');
    if ({3, 7, 8}.every(completed.contains)) await awardBadge('nutrition_all');
    if ({9, 10, 11, 12}.every(completed.contains)) await awardBadge('career_all');

    if ({1, 2, 5}.every(completed.contains)) await awardBadge('all_stages_low');
    if ({3, 4, 5, 6, 7}.every(completed.contains)) await awardBadge('all_stages_mid');
    if ({8, 9, 10, 11, 12}.every(completed.contains)) await awardBadge('all_stages_high');

    final allStages = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12};
    if (allStages.every(completed.contains)) await awardBadge('all_clear');
  }
}

// ─── 実体験完了数管理 ───

final activityCountProvider =
    StateNotifierProvider<ActivityCountNotifier, int>((ref) {
  return ActivityCountNotifier();
});

class ActivityCountNotifier extends StateNotifier<int> {
  static const _kKey = 'taiku_activity_count';

  ActivityCountNotifier() : super(0) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_kKey) ?? 0;
  }

  Future<void> increment() async {
    final prefs = await SharedPreferences.getInstance();
    final newVal = state + 1;
    await prefs.setInt(_kKey, newVal);
    state = newVal;
  }
}
