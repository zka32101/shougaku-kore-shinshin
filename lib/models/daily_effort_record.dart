import 'achievement_checklist.dart';

/// 「今日、○○をした」という日々の取り組みの記録（端末内に保存）
class DailyEffortRecord {
  final String id;
  final String childId;
  final ChecklistCategory category;
  final String text;
  final DateTime recordedAt;

  const DailyEffortRecord({
    required this.id,
    required this.childId,
    required this.category,
    required this.text,
    required this.recordedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'childId': childId,
        'category': category.name,
        'text': text,
        'recordedAt': recordedAt.toIso8601String(),
      };

  factory DailyEffortRecord.fromJson(Map<String, dynamic> json) {
    return DailyEffortRecord(
      id: json['id'] as String,
      childId: json['childId'] as String,
      category: ChecklistCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => ChecklistCategory.kindness,
      ),
      text: json['text'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );
  }
}
