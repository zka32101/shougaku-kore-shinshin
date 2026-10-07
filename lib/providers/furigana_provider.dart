import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/literacy_core/literacy_core.dart' show GradeLevel;
import '../features/literacy_core/src/providers/grade_provider.dart' show gradeLevelProvider;
import '../utils/furigana.dart';
import 'child_provider.dart';

/// 同梱のふりがな辞書(assets/furigana/words.json)。1回だけ読み込む。
final furiganaEngineProvider = FutureProvider<FuriganaEngine>((ref) async {
  final text = await rootBundle.loadString('assets/furigana/words.json');
  final map = (jsonDecode(text) as Map<String, dynamic>).cast<String, String>();
  return FuriganaEngine(map);
});

/// ふりがなの基準になる学年(1〜6)。
/// 選択中の子どもの学年を優先し、無ければ学年グループ(低/中/高)から推定。
final readingGradeProvider = Provider<int>((ref) {
  final child = ref.watch(currentChildProfileProvider).valueOrNull;
  if (child != null &&
      !child.id.startsWith('local') &&
      child.grade >= 1 &&
      child.grade <= 6) {
    return child.grade;
  }
  switch (ref.watch(gradeLevelProvider)) {
    case GradeLevel.low:
      return 2;
    case GradeLevel.mid:
      return 4;
    case GradeLevel.high:
      return 6;
  }
});
