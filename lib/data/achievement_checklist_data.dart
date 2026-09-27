import '../models/achievement_checklist.dart';

/// 学年に合わせてあらかじめ用意された「できたこと」チェックリスト
/// 1-2年生・3-4年生・5-6年生の3段階で、発達段階に合った項目を用意している。
const List<AchievementChecklistItem> achievementChecklistItems = [
  // ===== 1-2年生 (低学年) =====
  AchievementChecklistItem(
    id: 'low_greeting',
    title: 'じぶんから「おはよう」「ありがとう」が言えた',
    category: ChecklistCategory.kindness,
    minGrade: 1,
    maxGrade: 2,
  ),
  AchievementChecklistItem(
    id: 'low_dress',
    title: 'じぶんでふくをきがえられた',
    category: ChecklistCategory.lifeSkill,
    minGrade: 1,
    maxGrade: 2,
  ),
  AchievementChecklistItem(
    id: 'low_tidy',
    title: 'つかったものをじぶんでかたづけた',
    category: ChecklistCategory.responsibility,
    minGrade: 1,
    maxGrade: 2,
  ),
  AchievementChecklistItem(
    id: 'low_share',
    title: 'おもちゃやどうぐをともだちにかしてあげた',
    category: ChecklistCategory.kindness,
    minGrade: 1,
    maxGrade: 2,
  ),
  AchievementChecklistItem(
    id: 'low_sorry',
    title: 'わるいことをしたとき「ごめんね」が言えた',
    category: ChecklistCategory.honesty,
    minGrade: 1,
    maxGrade: 2,
  ),
  AchievementChecklistItem(
    id: 'low_wait',
    title: 'じゅんばんをまもれた',
    category: ChecklistCategory.respect,
    minGrade: 1,
    maxGrade: 2,
  ),
  AchievementChecklistItem(
    id: 'low_try_new',
    title: 'はじめてのことにちょうせんしてみた',
    category: ChecklistCategory.courage,
    minGrade: 1,
    maxGrade: 2,
  ),
  AchievementChecklistItem(
    id: 'low_homework',
    title: 'しゅくだいをじぶんからやろうとした',
    category: ChecklistCategory.study,
    minGrade: 1,
    maxGrade: 2,
  ),
  AchievementChecklistItem(
    id: 'low_greeting_neighbor',
    title: 'ちかくの人にじぶんからあいさつができた',
    category: ChecklistCategory.respect,
    minGrade: 1,
    maxGrade: 2,
  ),
  AchievementChecklistItem(
    id: 'low_brush',
    title: 'はみがきや手あらいをじぶんでできた',
    category: ChecklistCategory.lifeSkill,
    minGrade: 1,
    maxGrade: 2,
  ),

  // ===== 3-4年生 (中学年) =====
  AchievementChecklistItem(
    id: 'mid_schedule',
    title: 'じかんわりをじぶんでよういできた',
    category: ChecklistCategory.responsibility,
    minGrade: 3,
    maxGrade: 4,
  ),
  AchievementChecklistItem(
    id: 'mid_help_friend',
    title: 'こまっているともだちをたすけた',
    category: ChecklistCategory.kindness,
    minGrade: 3,
    maxGrade: 4,
  ),
  AchievementChecklistItem(
    id: 'mid_admit_mistake',
    title: 'じぶんのまちがいをすなおにみとめられた',
    category: ChecklistCategory.honesty,
    minGrade: 3,
    maxGrade: 4,
  ),
  AchievementChecklistItem(
    id: 'mid_speak_up',
    title: 'クラスで手をあげて意見を言えた',
    category: ChecklistCategory.courage,
    minGrade: 3,
    maxGrade: 4,
  ),
  AchievementChecklistItem(
    id: 'mid_different_opinion',
    title: '友だちとちがう意見でもさいごまで話を聞けた',
    category: ChecklistCategory.respect,
    minGrade: 3,
    maxGrade: 4,
  ),
  AchievementChecklistItem(
    id: 'mid_chores',
    title: 'おうちのお手伝いを自分から見つけてやった',
    category: ChecklistCategory.responsibility,
    minGrade: 3,
    maxGrade: 4,
  ),
  AchievementChecklistItem(
    id: 'mid_review',
    title: 'テストや宿題をじぶんで見直しできた',
    category: ChecklistCategory.study,
    minGrade: 3,
    maxGrade: 4,
  ),
  AchievementChecklistItem(
    id: 'mid_keep_promise',
    title: 'ともだちとのやくそくをまもれた',
    category: ChecklistCategory.honesty,
    minGrade: 3,
    maxGrade: 4,
  ),
  AchievementChecklistItem(
    id: 'mid_new_challenge',
    title: 'にがてなことにも自分からちょうせんした',
    category: ChecklistCategory.courage,
    minGrade: 3,
    maxGrade: 4,
  ),
  AchievementChecklistItem(
    id: 'mid_thank_family',
    title: 'かぞくに「ありがとう」の気もちをつたえた',
    category: ChecklistCategory.kindness,
    minGrade: 3,
    maxGrade: 4,
  ),

  // ===== 5-6年生 (高学年) =====
  AchievementChecklistItem(
    id: 'high_lead',
    title: '係活動や当番の仕事を最後までやりとげた',
    category: ChecklistCategory.responsibility,
    minGrade: 5,
    maxGrade: 6,
  ),
  AchievementChecklistItem(
    id: 'high_help_lower',
    title: '下級生や小さい子にやさしく接した',
    category: ChecklistCategory.kindness,
    minGrade: 5,
    maxGrade: 6,
  ),
  AchievementChecklistItem(
    id: 'high_honest_report',
    title: '都合が悪いことでも正直に話せた',
    category: ChecklistCategory.honesty,
    minGrade: 5,
    maxGrade: 6,
  ),
  AchievementChecklistItem(
    id: 'high_stand_up',
    title: 'まちがっていると思ったことに「おかしい」と言えた',
    category: ChecklistCategory.courage,
    minGrade: 5,
    maxGrade: 6,
  ),
  AchievementChecklistItem(
    id: 'high_diversity',
    title: '自分とちがう考え方や文化を受け入れられた',
    category: ChecklistCategory.respect,
    minGrade: 5,
    maxGrade: 6,
  ),
  AchievementChecklistItem(
    id: 'high_plan_study',
    title: '自分で学習計画を立てて取り組んだ',
    category: ChecklistCategory.study,
    minGrade: 5,
    maxGrade: 6,
  ),
  AchievementChecklistItem(
    id: 'high_self_manage',
    title: '自分の持ち物や時間を自分で管理できた',
    category: ChecklistCategory.responsibility,
    minGrade: 5,
    maxGrade: 6,
  ),
  AchievementChecklistItem(
    id: 'high_apologize_properly',
    title: '相手の気持ちを考えてきちんと謝れた',
    category: ChecklistCategory.honesty,
    minGrade: 5,
    maxGrade: 6,
  ),
  AchievementChecklistItem(
    id: 'high_volunteer',
    title: '誰かのために進んで行動した',
    category: ChecklistCategory.kindness,
    minGrade: 5,
    maxGrade: 6,
  ),
  AchievementChecklistItem(
    id: 'high_new_activity',
    title: '新しい活動やチームに自分からとびこんだ',
    category: ChecklistCategory.courage,
    minGrade: 5,
    maxGrade: 6,
  ),
];

List<AchievementChecklistItem> checklistItemsForGrade(int grade) {
  return achievementChecklistItems
      .where((item) => grade >= item.minGrade && grade <= item.maxGrade)
      .toList();
}
