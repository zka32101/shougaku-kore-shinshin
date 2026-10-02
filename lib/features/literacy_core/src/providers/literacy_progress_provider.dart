import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../enums/grade_level.dart';
import '../models/literacy_progress.dart';
import '../models/adaptive_difficulty.dart';
import '../models/literacy_badge.dart';

/// 教科別進捗プロバイダーファクトリ
/// 使用例: ref.watch(literacyProgressProvider('math'))
final literacyProgressProvider = StateNotifierProvider.family<
    LiteracyProgressNotifier, AsyncValue<LiteracyProgress>, String>(
  (ref, subject) => LiteracyProgressNotifier(subject: subject),
);

class LiteracyProgressNotifier
    extends StateNotifier<AsyncValue<LiteracyProgress>> {
  final String subject;

  LiteracyProgressNotifier({required this.subject})
      : super(const AsyncValue.loading()) {
    _load();
  }

  String _key(String userId) => 'literacy_progress_${subject}_$userId';

  Future<void> _load({String userId = 'local'}) async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_key(userId));
      if (json != null) {
        state = AsyncValue.data(_fromJson(jsonDecode(json)));
      } else {
        state = AsyncValue.data(LiteracyProgress(
          userId: userId,
          subject: subject,
          grade: GradeLevel.low,
          stages: {},
          dailyRecords: [],
        ));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> recordAnswer({
    required int stageNumber,
    required bool isCorrect,
    required GradeLevel grade,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final existing = current.stages[stageNumber] ??
        StageProgress(
          stageNumber: stageNumber,
          totalAttempts: 0,
          correctAnswers: 0,
          isCompleted: false,
        );

    final updated = existing.copyWith(
      totalAttempts: existing.totalAttempts + 1,
      correctAnswers: existing.correctAnswers + (isCorrect ? 1 : 0),
    );

    // フレームワーク §6.2: 正答率が目標を超えたら段階クリア
    final shouldComplete =
        !existing.isCompleted && updated.accuracy >= grade.accuracyFloor;

    final badge = shouldComplete
        ? LiteracyBadgeFactory.find(subject, stageNumber)
        : null;

    final newStages = Map<int, StageProgress>.from(current.stages);
    newStages[stageNumber] = shouldComplete
        ? updated.copyWith(isCompleted: true, earnedBadgeId: badge?.emoji)
        : updated;

    final newProgress = current.copyWith(stages: newStages);
    state = AsyncValue.data(newProgress);
    await _save(newProgress);
  }

  Future<void> addDailyRecord(DailyRecord record) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final newRecords = [...current.dailyRecords, record];
    // 直近60日のみ保持
    final pruned = newRecords.length > 60
        ? newRecords.sublist(newRecords.length - 60)
        : newRecords;

    final newProgress = current.copyWith(dailyRecords: pruned);
    state = AsyncValue.data(newProgress);
    await _save(newProgress);
  }

  Future<void> _save(LiteracyProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(progress.userId), jsonEncode(_toJson(progress)));
  }

  // ---- JSON シリアライズ ----

  Map<String, dynamic> _toJson(LiteracyProgress p) => {
        'userId': p.userId,
        'subject': p.subject,
        'gradeIndex': p.grade.index,
        'stages': {
          for (final e in p.stages.entries) '${e.key}': _stageToJson(e.value),
        },
        'dailyRecords': p.dailyRecords.map(_recordToJson).toList(),
      };

  LiteracyProgress _fromJson(Map<String, dynamic> j) => LiteracyProgress(
        userId: j['userId'] as String,
        subject: j['subject'] as String,
        grade: GradeLevel.values[j['gradeIndex'] as int],
        stages: {
          for (final e in (j['stages'] as Map<String, dynamic>).entries)
            int.parse(e.key): _stageFromJson(e.value as Map<String, dynamic>),
        },
        dailyRecords: (j['dailyRecords'] as List)
            .map((r) => _recordFromJson(r as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> _stageToJson(StageProgress s) => {
        'stageNumber': s.stageNumber,
        'totalAttempts': s.totalAttempts,
        'correctAnswers': s.correctAnswers,
        'isCompleted': s.isCompleted,
        'completedAt': s.completedAt?.toIso8601String(),
        'earnedBadgeId': s.earnedBadgeId,
      };

  StageProgress _stageFromJson(Map<String, dynamic> j) => StageProgress(
        stageNumber: j['stageNumber'] as int,
        totalAttempts: j['totalAttempts'] as int,
        correctAnswers: j['correctAnswers'] as int,
        isCompleted: j['isCompleted'] as bool,
        completedAt: j['completedAt'] != null
            ? DateTime.parse(j['completedAt'] as String)
            : null,
        earnedBadgeId: j['earnedBadgeId'] as String?,
      );

  Map<String, dynamic> _recordToJson(DailyRecord r) => {
        'date': r.date.toIso8601String(),
        'minutesStudied': r.minutesStudied,
        'questionsAnswered': r.questionsAnswered,
        'correctAnswers': r.correctAnswers,
      };

  DailyRecord _recordFromJson(Map<String, dynamic> j) => DailyRecord(
        date: DateTime.parse(j['date'] as String),
        minutesStudied: j['minutesStudied'] as int,
        questionsAnswered: j['questionsAnswered'] as int,
        correctAnswers: j['correctAnswers'] as int,
      );
}

/// アダプティブ難易度プロバイダー（セッション内のみ）
final adaptiveDifficultyProvider =
    Provider.family<AdaptiveDifficulty, GradeLevel>(
  (ref, grade) => AdaptiveDifficulty(grade: grade),
);
