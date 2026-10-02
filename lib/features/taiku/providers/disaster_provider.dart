import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/disaster_mission.dart';

/// ⑨ 防災の日ドリル：プロバイダー
final disasterMissionProvider =
    StateNotifierProvider<DisasterMissionNotifier, DisasterMissionState>((ref) {
  return DisasterMissionNotifier();
});

class DisasterMissionState {
  final DisasterMission? mission;
  final Map<String, bool> completions; // taskId -> isCompleted
  final bool isCertificateEarned;

  const DisasterMissionState({
    this.mission,
    this.completions = const {},
    this.isCertificateEarned = false,
  });

  DisasterMissionState copyWith({
    DisasterMission? mission,
    Map<String, bool>? completions,
    bool? isCertificateEarned,
  }) =>
      DisasterMissionState(
        mission: mission ?? this.mission,
        completions: completions ?? this.completions,
        isCertificateEarned: isCertificateEarned ?? this.isCertificateEarned,
      );

  int get completedCount => completions.values.where((v) => v).length;
  bool get isAllDone =>
      mission != null && completedCount >= mission!.tasks.length;
}

class DisasterMissionNotifier extends StateNotifier<DisasterMissionState> {
  static const _kKey = 'taiku_disaster_mission';

  DisasterMissionNotifier() : super(const DisasterMissionState()) {
    _load();
  }

  Future<void> _load() async {
    final mission = getTodaysMission();
    if (mission == null) {
      state = const DisasterMissionState();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final saved = prefs.getString('${_kKey}_$today');
    Map<String, bool> completions = {};

    if (saved != null) {
      final decoded = jsonDecode(saved) as Map<String, dynamic>;
      completions = decoded.map((k, v) => MapEntry(k, v as bool));
    }

    final earned = prefs.getBool('${_kKey}_cert_$today') ?? false;

    state = DisasterMissionState(
      mission: mission,
      completions: completions,
      isCertificateEarned: earned,
    );
  }

  Future<void> toggleTask(String taskId) async {
    if (state.mission == null) return;
    final updated = Map<String, bool>.from(state.completions);
    updated[taskId] = !(updated[taskId] ?? false);

    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    await prefs.setString(
      '${_kKey}_$today',
      jsonEncode(updated),
    );

    final allDone = updated.values.where((v) => v).length >=
        state.mission!.tasks.length;

    if (allDone && !state.isCertificateEarned) {
      await prefs.setBool('${_kKey}_cert_$today', true);
      state = state.copyWith(
        completions: updated,
        isCertificateEarned: true,
      );
    } else {
      state = state.copyWith(completions: updated);
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}_${now.month}_${now.day}';
  }
}

/// 今日が防災の日かどうか
final isDisasterDayProvider = Provider<bool>((ref) => isDisasterDay());

/// 今日のミッション（null = 通常日）
final todaysMissionProvider = Provider<DisasterMission?>((ref) => getTodaysMission());
