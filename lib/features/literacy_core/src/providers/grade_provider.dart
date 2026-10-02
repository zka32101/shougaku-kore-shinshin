import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../enums/grade_level.dart';
import '../enums/literacy_ui_level.dart';

const _kGradeKey = 'literacy_grade_level';

/// 選択中の学年グループ（アプリ横断で共有）
final gradeLevelProvider = StateNotifierProvider<GradeLevelNotifier, GradeLevel>((ref) {
  return GradeLevelNotifier();
});

class GradeLevelNotifier extends StateNotifier<GradeLevel> {
  GradeLevelNotifier() : super(GradeLevel.low) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_kGradeKey);
    if (index != null && index < GradeLevel.values.length) {
      state = GradeLevel.values[index];
    }
  }

  Future<void> setGrade(GradeLevel grade) async {
    state = grade;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kGradeKey, grade.index);
  }

  Future<void> setGradeFromNumber(int grade) async {
    await setGrade(GradeLevelExt.fromGrade(grade));
  }
}

/// 現在の学年に対応する UI レベル
final literacyUILevelProvider = Provider<LiteracyUILevel>((ref) {
  final grade = ref.watch(gradeLevelProvider);
  return LiteracyUILevelExt.from(grade);
});
