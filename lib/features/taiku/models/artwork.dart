import 'dart:convert';

enum ArtLevel { lv1, lv2, lv3, lv4 }

class Artwork {
  final String id;
  final int month;
  final ArtLevel level;
  final String colorName;
  final String colorHex;
  final String title;
  final String description;
  final String? imagePath;
  final List<String> emotionKeywords;
  final List<String> techniques;
  final List<String> badges;
  final DateTime createdAt;

  const Artwork({
    required this.id,
    required this.month,
    required this.level,
    required this.colorName,
    required this.colorHex,
    required this.title,
    required this.description,
    this.imagePath,
    this.emotionKeywords = const [],
    this.techniques = const [],
    this.badges = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'month': month,
    'level': level.index,
    'colorName': colorName,
    'colorHex': colorHex,
    'title': title,
    'description': description,
    'imagePath': imagePath,
    'emotionKeywords': emotionKeywords,
    'techniques': techniques,
    'badges': badges,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Artwork.fromJson(Map<String, dynamic> j) => Artwork(
    id: j['id'] as String,
    month: j['month'] as int,
    level: ArtLevel.values[j['level'] as int],
    colorName: j['colorName'] as String,
    colorHex: j['colorHex'] as String,
    title: j['title'] as String,
    description: j['description'] as String,
    imagePath: j['imagePath'] as String?,
    emotionKeywords: List<String>.from(j['emotionKeywords'] ?? []),
    techniques: List<String>.from(j['techniques'] ?? []),
    badges: List<String>.from(j['badges'] ?? []),
    createdAt: DateTime.parse(j['createdAt'] as String),
  );
}

class ArtworkCollection {
  final List<Artwork> items;
  ArtworkCollection(this.items);

  List<Artwork> forMonth(int month) =>
      items.where((a) => a.month == month).toList();

  Artwork? latestForMonth(int month) {
    final list = forMonth(month)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.isEmpty ? null : list.first;
  }

  int get completedMonths =>
      List.generate(12, (i) => i + 1)
          .where((m) => forMonth(m).isNotEmpty)
          .length;

  String toJsonString() => jsonEncode(items.map((a) => a.toJson()).toList());

  factory ArtworkCollection.fromJsonString(String s) {
    final list = jsonDecode(s) as List;
    return ArtworkCollection(list.map((e) => Artwork.fromJson(e)).toList());
  }
}
