/// 兄弟協力クエストのデータモデル
class SiblingQuest {
  final String id;
  final String emoji;
  final String title;
  final String description;
  final String themeKey;
  final int targetCount;
  final Map<String, int> progress; // profileId -> count
  final bool completed;
  final DateTime createdAt;
  final DateTime? completedAt;

  const SiblingQuest({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.themeKey,
    required this.targetCount,
    required this.progress,
    required this.completed,
    required this.createdAt,
    this.completedAt,
  });

  double get totalProgress {
    if (progress.isEmpty) return 0;
    final total = progress.values.fold(0, (s, v) => s + v);
    final max = targetCount * progress.length;
    return max == 0 ? 0 : (total / max).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'emoji': emoji,
    'title': title,
    'description': description,
    'themeKey': themeKey,
    'targetCount': targetCount,
    'progress': progress,
    'completed': completed,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'completedAt': completedAt?.millisecondsSinceEpoch,
  };

  static SiblingQuest fromJson(Map<String, dynamic> json) {
    final raw = json['progress'] as Map<String, dynamic>? ?? {};
    return SiblingQuest(
      id: json['id'] as String,
      emoji: json['emoji'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      themeKey: json['themeKey'] as String,
      targetCount: json['targetCount'] as int,
      progress: raw.map((k, v) => MapEntry(k, v as int)),
      completed: json['completed'] as bool,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      completedAt: json['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'] as int)
          : null,
    );
  }

  SiblingQuest copyWith({
    Map<String, int>? progress,
    bool? completed,
    DateTime? completedAt,
  }) =>
      SiblingQuest(
        id: id,
        emoji: emoji,
        title: title,
        description: description,
        themeKey: themeKey,
        targetCount: targetCount,
        progress: progress ?? this.progress,
        completed: completed ?? this.completed,
        createdAt: createdAt,
        completedAt: completedAt ?? this.completedAt,
      );
}

const List<Map<String, dynamic>> kSiblingQuestTemplates = [
  {
    'emoji': '⚽',
    'title': 'いっしょにスポーツ！',
    'description': 'みんなで3回ずつ運動ステージをクリアしよう',
    'themeKey': 'sports',
    'targetCount': 3,
  },
  {
    'emoji': '🛡️',
    'title': 'ぼうさい家族クエスト',
    'description': 'みんなで防災ステージを2回ずつクリアしよう',
    'themeKey': 'disaster',
    'targetCount': 2,
  },
  {
    'emoji': '🥗',
    'title': '栄養バランス大作戦',
    'description': 'みんなで栄養ステージを3回ずつクリアしよう',
    'themeKey': 'nutrition',
    'targetCount': 3,
  },
  {
    'emoji': '🏆',
    'title': 'きょうだい学習チャレンジ',
    'description': 'みんなでキャリアステージを5回ずつクリアしよう',
    'themeKey': 'career',
    'targetCount': 5,
  },
];
