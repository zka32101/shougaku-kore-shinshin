import '../services/local_reflection_store.dart';

/// 保護者向け「おうちで話してみよう」の問い1件。
class FamilyPrompt {
  final String question;

  /// どのテーマから出した問いか。全般の問いは null
  final String? theme;

  const FamilyPrompt(this.question, {this.theme});
}

/// テーマごとの問い（保護者がお子さんにたずねる言葉）。
const kFamilyPromptsByTheme = <String, List<String>>{
  'kindness': [
    '最近、誰かに優しくしてもらってうれしかったことはある？',
    '友達が困っていたら、どんなことができそう？',
    '優しくしたつもりが、相手にはうれしくなかったことはある？それはどうしてだと思う？',
  ],
  'honesty': [
    '正直に言うのがむずかしいのは、どんなとき？',
    '本当のことを言って良かったことはある？',
    'うそをついてしまったとき、どんな気持ちだった？',
  ],
  'responsibility': [
    '自分の役割で、最近がんばったことは何？',
    'やると決めたのにむずかしかったことは？どうしたらできそう？',
    '失敗したとき、どうするのがいいと思う？',
  ],
  'courage': [
    '勇気が出なかったけれど、やってみたことはある？',
    '友達がいやなことをされていたら、どうする？',
    '「やめて」と言えるのは、どんなとき？',
  ],
  'respect': [
    '「ありがとう」を伝えたい人は誰？',
    '言われてうれしかった言葉と、いやだった言葉は？',
    '自分と違う意見の人と、どうやって話す？',
  ],
  'cooperation': [
    'みんなで協力してうまくいったことはある？',
    '意見が分かれたとき、どうやって決める？',
    '友達と一緒にやるとき、自分の役割は何だと思う？',
  ],
};

/// ストーリーを読んでいない月や、足りないときの全般の問い。
const kFamilyGeneralPrompts = <String>[
  '今日いちばん楽しかったことは何？',
  '最近、考えさせられたお話はあった？',
  '「こんなとき、あなたならどうする？」と、身近な場面を1つ出して聞いてみよう。',
  '大人や先生の言うことで、「どうして？」と思ったことはある？',
];

/// その月に読んだお話のテーマ（[themeCounts]）と、お子さんの「考えてみよう」の記録から、
/// 保護者向けの問いを最大 [limit] 件つくる。
///
/// 同じ入力なら同じ結果になる（月が変わると、同じテーマでも別の問いが出る）。
List<FamilyPrompt> buildFamilyPrompts({
  required Map<String, int> themeCounts,
  required List<ReflectionEntry> reflections,
  required int year,
  required int month,
  int limit = 3,
}) {
  final result = <FamilyPrompt>[];

  // 1) お子さんが答えた「相手の気持ち」から、理由をたずねる問い
  for (final r in reflections) {
    if (result.length >= 1) break;
    final f = r.feeling == null ? null : kReflectionFeelings[r.feeling!];
    if (f == null || r.storyTitle.isEmpty) continue;
    result.add(FamilyPrompt(
      '「${r.storyTitle}」のお話で、相手の気持ちを「${f.$2}」${f.$1}と考えたよ。どうしてそう思ったのか、聞いてみよう。',
      theme: r.theme.isEmpty ? null : r.theme,
    ));
  }

  // 2) よく読んだテーマの順（同数ならテーマ名順）に、月ごとに違う問いを選ぶ
  final themes = themeCounts.entries
      .where((e) => e.value > 0 && kFamilyPromptsByTheme.containsKey(e.key))
      .toList()
    ..sort((a, b) {
      final c = b.value.compareTo(a.value);
      return c != 0 ? c : a.key.compareTo(b.key);
    });
  for (final t in themes) {
    if (result.length >= limit) break;
    final list = kFamilyPromptsByTheme[t.key]!;
    result.add(FamilyPrompt(list[(year * 12 + month) % list.length],
        theme: t.key));
  }

  // 3) まだ足りなければ、全般の問い
  var i = 0;
  while (result.length < limit && i < kFamilyGeneralPrompts.length) {
    result.add(FamilyPrompt(
        kFamilyGeneralPrompts[(year * 12 + month + i) % kFamilyGeneralPrompts.length]));
    i++;
  }
  return result.take(limit).toList();
}
