/// 親子交換日記メッセージ
class DiaryMessage {
  final String id;
  final String fromName;
  final String toProfileId;
  final String message;
  final String emoji;
  final DateTime createdAt;
  final bool read;

  const DiaryMessage({
    required this.id,
    required this.fromName,
    required this.toProfileId,
    required this.message,
    required this.emoji,
    required this.createdAt,
    required this.read,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromName': fromName,
    'toProfileId': toProfileId,
    'message': message,
    'emoji': emoji,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'read': read,
  };

  static DiaryMessage fromJson(Map<String, dynamic> json) => DiaryMessage(
    id: json['id'] as String,
    fromName: json['fromName'] as String,
    toProfileId: json['toProfileId'] as String,
    message: json['message'] as String,
    emoji: json['emoji'] as String,
    createdAt:
        DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    read: json['read'] as bool,
  );

  DiaryMessage copyWith({bool? read}) => DiaryMessage(
    id: id,
    fromName: fromName,
    toProfileId: toProfileId,
    message: message,
    emoji: emoji,
    createdAt: createdAt,
    read: read ?? this.read,
  );
}

const List<Map<String, String>> kDiaryTemplates = [
  {'emoji': '⭐', 'message': 'よく頑張ったね！今日もかっこよかったよ。'},
  {'emoji': '🔥', 'message': '毎日続けているね。すごいぞ！'},
  {'emoji': '🤗', 'message': 'いつも応援しているよ。一緒に頑張ろう！'},
  {'emoji': '🏆', 'message': '難しいことにも挑戦できたね。誇りに思うよ！'},
  {'emoji': '💪', 'message': 'また明日も一緒に学ぼうね。楽しみにしているよ！'},
  {'emoji': '🌟', 'message': 'あなたの成長がとても嬉しい。これからも応援するよ！'},
  {'emoji': '🎉', 'message': 'バッジ獲得おめでとう！本当によく頑張ったね。'},
  {'emoji': '🏃', 'message': '運動と学習を両立できているね。すてきだよ！'},
];
