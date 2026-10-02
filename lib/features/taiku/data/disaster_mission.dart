/// ⑨ かぞくぼうさいの日ドリル：9/1・3/11 年2回ミッション
class DisasterMissionTask {
  final String id;
  final String title;
  final String description;
  final String emoji;
  bool isCompleted;
  String? photoPath; // ② 体験アルバムと連携

  DisasterMissionTask({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.isCompleted = false,
    this.photoPath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'isCompleted': isCompleted,
        'photoPath': photoPath,
      };
}

enum DisasterMissionType { earthquake, tsunami }

class DisasterMission {
  final DisasterMissionType type;
  final String title;
  final String subtitle;
  final String emoji;
  final List<DisasterMissionTask> tasks;

  const DisasterMission({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.tasks,
  });

  int get completedCount => tasks.where((t) => t.isCompleted).length;
  bool get isAllCompleted => completedCount == tasks.length;
  double get progress => tasks.isEmpty ? 0 : completedCount / tasks.length;
}

/// 9/1 防災の日：地震対応ミッション
final earthquake911Mission = DisasterMission(
  type: DisasterMissionType.earthquake,
  title: '防災の日ミッション',
  subtitle: '9月1日は防災の日。家族で防災を確認しよう！',
  emoji: '🚨',
  tasks: [
    DisasterMissionTask(
      id: 'check_route',
      title: '避難経路を確認する',
      description: '家から近くの避難場所まで実際に歩いてみよう',
      emoji: '🗺️',
    ),
    DisasterMissionTask(
      id: 'family_talk',
      title: '家族で話し合う',
      description: '「もし地震が来たら」を全員で話し合おう',
      emoji: '👨‍👩‍👧',
    ),
    DisasterMissionTask(
      id: 'assign_roles',
      title: '役割を決める',
      description: '火を消す・赤ちゃんを抱っこする・犬を連れる、など役割分担',
      emoji: '📋',
    ),
    DisasterMissionTask(
      id: 'check_supplies',
      title: '防災グッズをチェック',
      description: '水・食料・懐中電灯・電池・救急セットがあるか確認',
      emoji: '🎒',
    ),
    DisasterMissionTask(
      id: 'meetup_spot',
      title: '集合場所を決める',
      description: '電話が使えないときの集合場所（2か所以上）を決めよう',
      emoji: '📍',
    ),
  ],
);

/// 3/11 東日本大震災メモリアルミッション
final tsunami311Mission = DisasterMission(
  type: DisasterMissionType.tsunami,
  title: '3月11日 防災ミッション',
  subtitle: '東日本大震災から学び、家族で備えよう',
  emoji: '🌊',
  tasks: [
    DisasterMissionTask(
      id: 'learn_311',
      title: '3月11日について学ぶ',
      description: '東日本大震災のことを家族で話し合おう',
      emoji: '📖',
    ),
    DisasterMissionTask(
      id: 'tsunami_route',
      title: '津波から逃げる道を確認',
      description: '高台への避難経路・高さを確認しよう（沿岸地域は必須！）',
      emoji: '🏃',
    ),
    DisasterMissionTask(
      id: 'neighbor_check',
      title: '近所の人と声をかけ合う',
      description: '地域のつながりが命を救う。近所の方に「よろしく」を',
      emoji: '🤝',
    ),
    DisasterMissionTask(
      id: 'water_stock',
      title: '水の備蓄を確認',
      description: '1人1日3L×3日分が目安。家族4人で36L！',
      emoji: '💧',
    ),
    DisasterMissionTask(
      id: 'memorial',
      title: '14:46に黙祷する',
      description: '14時46分、震災発生時刻に全員で1分間黙祷しよう',
      emoji: '🕯️',
    ),
  ],
);

/// 今日のミッションを返す（9/1 or 3/11 の場合のみ non-null）
DisasterMission? getTodaysMission() {
  final now = DateTime.now();
  if (now.month == 9 && now.day == 1) return earthquake911Mission;
  if (now.month == 3 && now.day == 11) return tsunami311Mission;
  return null;
}

/// 今日がぼうさいの日かどうか
bool isDisasterDay() => getTodaysMission() != null;
