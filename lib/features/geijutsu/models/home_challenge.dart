import 'dart:convert';

enum HomeChallengeLevel { lv1, lv2, lv3, lv4 }

class CookingEntry {
  final String menuName;
  final List<String> photoPaths;
  final String notes;
  CookingEntry({required this.menuName, required this.photoPaths, required this.notes});

  Map<String, dynamic> toJson() => {
    'menuName': menuName, 'photoPaths': photoPaths, 'notes': notes
  };
  factory CookingEntry.fromJson(Map<String, dynamic> j) => CookingEntry(
    menuName: j['menuName'] as String,
    photoPaths: List<String>.from(j['photoPaths'] ?? []),
    notes: j['notes'] as String,
  );
}

class FashionEntry {
  final String occasion;
  final List<String> photoPaths;
  final String notes;
  FashionEntry({required this.occasion, required this.photoPaths, required this.notes});

  Map<String, dynamic> toJson() => {
    'occasion': occasion, 'photoPaths': photoPaths, 'notes': notes
  };
  factory FashionEntry.fromJson(Map<String, dynamic> j) => FashionEntry(
    occasion: j['occasion'] as String,
    photoPaths: List<String>.from(j['photoPaths'] ?? []),
    notes: j['notes'] as String,
  );
}

class HomeChallenge {
  final String id;
  final int month;
  final HomeChallengeLevel level;
  final String colorName;
  final String colorHex;
  final CookingEntry? cooking;
  final FashionEntry? fashion;
  final String parentConversation;
  final String emotionalInsight;
  final List<String> badges;
  final DateTime createdAt;

  const HomeChallenge({
    required this.id,
    required this.month,
    required this.level,
    required this.colorName,
    required this.colorHex,
    this.cooking,
    this.fashion,
    this.parentConversation = '',
    this.emotionalInsight = '',
    this.badges = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'month': month,
    'level': level.index,
    'colorName': colorName,
    'colorHex': colorHex,
    'cooking': cooking?.toJson(),
    'fashion': fashion?.toJson(),
    'parentConversation': parentConversation,
    'emotionalInsight': emotionalInsight,
    'badges': badges,
    'createdAt': createdAt.toIso8601String(),
  };

  factory HomeChallenge.fromJson(Map<String, dynamic> j) => HomeChallenge(
    id: j['id'] as String,
    month: j['month'] as int,
    level: HomeChallengeLevel.values[j['level'] as int],
    colorName: j['colorName'] as String,
    colorHex: j['colorHex'] as String,
    cooking: j['cooking'] != null ? CookingEntry.fromJson(j['cooking']) : null,
    fashion: j['fashion'] != null ? FashionEntry.fromJson(j['fashion']) : null,
    parentConversation: j['parentConversation'] as String? ?? '',
    emotionalInsight: j['emotionalInsight'] as String? ?? '',
    badges: List<String>.from(j['badges'] ?? []),
    createdAt: DateTime.parse(j['createdAt'] as String),
  );
}

class HomeChallengeCollection {
  final List<HomeChallenge> items;
  HomeChallengeCollection(this.items);

  List<HomeChallenge> forMonth(int month) =>
      items.where((h) => h.month == month).toList();

  int get completedMonths =>
      List.generate(12, (i) => i + 1)
          .where((m) => forMonth(m).isNotEmpty)
          .length;

  String toJsonString() => jsonEncode(items.map((h) => h.toJson()).toList());

  factory HomeChallengeCollection.fromJsonString(String s) {
    final list = jsonDecode(s) as List;
    return HomeChallengeCollection(list.map((e) => HomeChallenge.fromJson(e)).toList());
  }
}
