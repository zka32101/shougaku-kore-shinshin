import 'family_talk_prompts.dart';

/// 保護者が家族や先生に伝えるための、月のようすの文章をつくる。
///
/// 個人情報を減らすため、お子さんの名前や、お子さんが書いた「ひとこと」は含めない。
/// 入れるのは、年月・読んだお話の数・よく読んだテーマ・おうちで話す問いだけ。
String buildReportShareText({
  required int year,
  required int month,
  required int storyCount,
  required Map<String, int> themeCounts,
  required List<FamilyPrompt> prompts,
  required String Function(String theme) themeLabel,
}) {
  final themes = themeCounts.entries.where((e) => e.value > 0).toList()
    ..sort((a, b) {
      final c = b.value.compareTo(a.value);
      return c != 0 ? c : a.key.compareTo(b.key);
    });

  final b = StringBuffer()
    ..writeln('【小学コレ！ $year年$month月のようす】')
    ..writeln('読んだお話：$storyCount話');
  if (themes.isNotEmpty) {
    b.writeln(
        'よく読んだテーマ：${themes.take(3).map((e) => themeLabel(e.key)).join('、')}');
  }
  if (prompts.isNotEmpty) {
    b
      ..writeln()
      ..writeln('おうちで話してみよう');
    for (var i = 0; i < prompts.length; i++) {
      b.writeln('${i + 1}. ${prompts[i].question}');
    }
  }
  return b.toString().trimRight();
}
