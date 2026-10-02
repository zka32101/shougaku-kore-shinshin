/// ② 体験アルバム：活動完了時の写真・動画記録
class ActivityMemory {
  final String id;
  final String activityId;
  final String activityTitle;
  final String theme; // 'sports' | 'disaster' | 'nutrition' | 'career'
  final int relatedStage;
  final DateTime completedAt;
  final String? imagePath;
  final String? note;

  const ActivityMemory({
    required this.id,
    required this.activityId,
    required this.activityTitle,
    required this.theme,
    required this.relatedStage,
    required this.completedAt,
    this.imagePath,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'activityId': activityId,
        'activityTitle': activityTitle,
        'theme': theme,
        'relatedStage': relatedStage,
        'completedAt': completedAt.toIso8601String(),
        'imagePath': imagePath,
        'note': note,
      };

  factory ActivityMemory.fromJson(Map<String, dynamic> json) => ActivityMemory(
        id: json['id'] as String,
        activityId: json['activityId'] as String,
        activityTitle: json['activityTitle'] as String,
        theme: json['theme'] as String,
        relatedStage: json['relatedStage'] as int,
        completedAt: DateTime.parse(json['completedAt'] as String),
        imagePath: json['imagePath'] as String?,
        note: json['note'] as String?,
      );

  String get themeEmoji {
    switch (theme) {
      case 'sports':
        return '⚽';
      case 'disaster':
        return '🛡️';
      case 'nutrition':
        return '🥗';
      case 'career':
        return '💼';
      default:
        return '⭐';
    }
  }

  String get themeLabel {
    switch (theme) {
      case 'sports':
        return 'スポーツ';
      case 'disaster':
        return '防災';
      case 'nutrition':
        return '栄養';
      case 'career':
        return 'キャリア';
      default:
        return 'その他';
    }
  }
}
