import 'dart:convert';

class UserProfile {
  final String id;
  final String name;
  final String avatarEmoji;
  final DateTime createdAt;
  final int grade;

  const UserProfile({
    required this.id,
    required this.name,
    required this.avatarEmoji,
    required this.createdAt,
    required this.grade,
  });

  static const kDefaultAvatars = [
    '🧒', '👦', '👧', '🧑', '👩', '👨',
    '🎨', '🎵', '⭐', '🌟', '🐱', '🐶',
    '🦊', '🐼', '🦁', '🐸', '🌈', '🎈',
  ];

  static const kGradeLabels = [
    '未設定', '1年生', '2年生', '3年生', '4年生', '5年生', '6年生',
  ];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarEmoji': avatarEmoji,
    'createdAt': createdAt.toIso8601String(),
    'grade': grade,
  };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
    id: j['id'] as String,
    name: j['name'] as String,
    avatarEmoji: j['avatarEmoji'] as String,
    createdAt: DateTime.parse(j['createdAt'] as String),
    grade: j['grade'] as int? ?? 0,
  );

  UserProfile copyWith({String? name, String? avatarEmoji, int? grade}) => UserProfile(
    id: id,
    name: name ?? this.name,
    avatarEmoji: avatarEmoji ?? this.avatarEmoji,
    createdAt: createdAt,
    grade: grade ?? this.grade,
  );
}

class ProfileState {
  final List<UserProfile> profiles;
  final String activeId;

  const ProfileState({required this.profiles, required this.activeId});

  factory ProfileState.empty() =>
      const ProfileState(profiles: [], activeId: '');

  UserProfile? get active =>
      profiles.where((p) => p.id == activeId).firstOrNull;

  ProfileState copyWith({List<UserProfile>? profiles, String? activeId}) =>
      ProfileState(
        profiles: profiles ?? this.profiles,
        activeId: activeId ?? this.activeId,
      );

  String toProfilesJson() =>
      jsonEncode(profiles.map((p) => p.toJson()).toList());

  static List<UserProfile> profilesFromJson(String s) =>
      (jsonDecode(s) as List).map((e) => UserProfile.fromJson(e)).toList();
}
