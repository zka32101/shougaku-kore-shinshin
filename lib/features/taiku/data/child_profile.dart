import '../../literacy_core/literacy_core.dart';

/// 子どもプロフィール
class ChildProfile {
  final String id; // UUID
  final String name; // 名前
  final GradeLevel gradeLevel; // 学年
  final String color; // プロフィールカラー（hex）
  final String emoji; // アバターキャラ
  final DateTime createdAt;

  const ChildProfile({
    required this.id,
    required this.name,
    required this.gradeLevel,
    required this.color,
    required this.emoji,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'gradeLevel': gradeLevel.index,
    'color': color,
    'emoji': emoji,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  static ChildProfile fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      gradeLevel: GradeLevel.values[json['gradeLevel'] as int],
      color: json['color'] as String,
      emoji: json['emoji'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }

  ChildProfile copyWith({
    String? id,
    String? name,
    GradeLevel? gradeLevel,
    String? color,
    String? emoji,
    DateTime? createdAt,
  }) =>
      ChildProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        gradeLevel: gradeLevel ?? this.gradeLevel,
        color: color ?? this.color,
        emoji: emoji ?? this.emoji,
        createdAt: createdAt ?? this.createdAt,
      );
}

/// プロフィール管理状態
class ChildProfilesState {
  final List<ChildProfile> profiles;
  final String currentProfileId; // 現在選択中のプロフィール ID

  const ChildProfilesState({
    required this.profiles,
    required this.currentProfileId,
  });

  ChildProfile? get currentProfile =>
      profiles.where((p) => p.id == currentProfileId).firstOrNull;

  ChildProfilesState copyWith({
    List<ChildProfile>? profiles,
    String? currentProfileId,
  }) =>
      ChildProfilesState(
        profiles: profiles ?? this.profiles,
        currentProfileId: currentProfileId ?? this.currentProfileId,
      );
}
