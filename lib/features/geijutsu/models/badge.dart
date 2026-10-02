import 'dart:convert';

class AppBadge {
  final String id;
  final String name;
  final String description;
  final String subject; // art, music, home_ec, common
  final String iconEmoji;
  final String rarity; // 'normal', 'rare', 'superRare'
  final DateTime earnedAt;

  const AppBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.subject,
    required this.iconEmoji,
    required this.rarity,
    required this.earnedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'description': description,
    'subject': subject, 'iconEmoji': iconEmoji,
    'rarity': rarity,
    'earnedAt': earnedAt.toIso8601String(),
  };

  factory AppBadge.fromJson(Map<String, dynamic> j) => AppBadge(
    id: j['id'] as String,
    name: j['name'] as String,
    description: j['description'] as String,
    subject: j['subject'] as String,
    iconEmoji: j['iconEmoji'] as String,
    rarity: j['rarity'] as String? ?? 'normal',
    earnedAt: DateTime.parse(j['earnedAt'] as String),
  );
}

class BadgeCollection {
  final List<AppBadge> items;
  BadgeCollection(this.items);

  List<AppBadge> forSubject(String subject) =>
      items.where((b) => b.subject == subject).toList();

  bool has(String id) => items.any((b) => b.id == id);

  String toJsonString() => jsonEncode(items.map((b) => b.toJson()).toList());

  factory BadgeCollection.fromJsonString(String s) {
    final list = jsonDecode(s) as List;
    return BadgeCollection(list.map((e) => AppBadge.fromJson(e)).toList());
  }

  static const List<Map<String, String>> allDefinitions = [
    // 図工
    {'id': 'art_diagnosis', 'name': '色彩診断マスター', 'subject': 'art', 'emoji': '🎨', 'desc': '色彩タイプ診断を完了した', 'rarity': 'normal'},
    {'id': 'art_m1_lv1', 'name': '赤の探検家', 'subject': 'art', 'emoji': '🔴', 'desc': '赤い物を探して撮影した', 'rarity': 'normal'},
    {'id': 'art_m1_lv2', 'name': '赤の表現者', 'subject': 'art', 'emoji': '🎭', 'desc': '赤だけで情熱を描いた', 'rarity': 'normal'},
    {'id': 'art_m1_lv3', 'name': '対比の大師', 'subject': 'art', 'emoji': '⚔️', 'desc': '赤×黒で葛藤を表現した', 'rarity': 'rare'},
    {'id': 'art_m1_lv4', 'name': '赤の哲学者', 'subject': 'art', 'emoji': '🏆', 'desc': '赤の世界を完全制覇した', 'rarity': 'rare'},
    {'id': 'art_m12_complete', 'name': '色彩絵師', 'subject': 'art', 'emoji': '🌈', 'desc': '12ヶ月の色彩旅を完走した', 'rarity': 'superRare'},
    {'id': 'art_appreciation', 'name': '名画探偵', 'subject': 'art', 'emoji': '🖼️', 'desc': '名画鑑賞クイズを完了した', 'rarity': 'rare'},
    {'id': 'art_shape_play', 'name': '形の魔法使い', 'subject': 'art', 'emoji': '🔷', 'desc': '形あそびで作品を作った', 'rarity': 'normal'},
    // 音楽
    {'id': 'music_diagnosis', 'name': '音感タイプ発見', 'subject': 'music', 'emoji': '🎵', 'desc': '音感タイプ診断を完了した', 'rarity': 'normal'},
    {'id': 'music_s1', 'name': '5音メロディスト', 'subject': 'music', 'emoji': '🎹', 'desc': '5音で初メロディを作曲した', 'rarity': 'normal'},
    {'id': 'music_s2', 'name': 'リズムマスター', 'subject': 'music', 'emoji': '🥁', 'desc': 'リズムパターンを加えた', 'rarity': 'normal'},
    {'id': 'music_s3', 'name': 'ハーモニスト', 'subject': 'music', 'emoji': '🎸', 'desc': '伴奏コードを追加した', 'rarity': 'rare'},
    {'id': 'music_s4', 'name': 'グルーヴマスター', 'subject': 'music', 'emoji': '🔥', 'desc': 'ドラムトラックを追加した', 'rarity': 'rare'},
    {'id': 'music_s8', 'name': 'マスタープロデューサー', 'subject': 'music', 'emoji': '👑', 'desc': 'フルミックス楽曲を完成させた', 'rarity': 'superRare'},
    {'id': 'music_free_piano', 'name': 'ピアノ探検家', 'subject': 'music', 'emoji': '🎹', 'desc': 'フリーピアノで音楽を楽しんだ', 'rarity': 'normal'},
    {'id': 'music_theme_compose_spring', 'name': '春のテーマ作曲家', 'subject': 'music', 'emoji': '🌸', 'desc': '春のテーマ曲を作曲した', 'rarity': 'rare'},
    {'id': 'music_theme_compose_summer', 'name': '夏のテーマ作曲家', 'subject': 'music', 'emoji': '☀️', 'desc': '夏のテーマ曲を作曲した', 'rarity': 'rare'},
    {'id': 'music_theme_compose_autumn', 'name': '秋のテーマ作曲家', 'subject': 'music', 'emoji': '🍂', 'desc': '秋のテーマ曲を作曲した', 'rarity': 'rare'},
    {'id': 'music_theme_compose_winter', 'name': '冬のテーマ作曲家', 'subject': 'music', 'emoji': '❄️', 'desc': '冬のテーマ曲を作曲した', 'rarity': 'rare'},
    {'id': 'music_rhythm', 'name': 'リズム達人', 'subject': 'music', 'emoji': '🥁', 'desc': 'リズムゲームをクリアした', 'rarity': 'rare'},
    {'id': 'music_appreciation', 'name': '音楽鑑賞家', 'subject': 'music', 'emoji': '🎻', 'desc': '音楽鑑賞の感想を書いた', 'rarity': 'normal'},
    // 家庭科
    {'id': 'home_diagnosis', 'name': '色彩ライフ診断完了', 'subject': 'home_ec', 'emoji': '🏠', 'desc': '家庭の色彩診断を完了した', 'rarity': 'normal'},
    {'id': 'home_m1_cooking', 'name': '赤の料理人', 'subject': 'home_ec', 'emoji': '🍳', 'desc': '赤い料理を作って撮影した', 'rarity': 'normal'},
    {'id': 'home_m1_fashion', 'name': '赤のスタイリスト', 'subject': 'home_ec', 'emoji': '👗', 'desc': '赤いファッションをコーデした', 'rarity': 'normal'},
    {'id': 'home_m12_complete', 'name': '色彩ライフプロデューサー', 'subject': 'home_ec', 'emoji': '🌟', 'desc': '12ヶ月の色彩ライフを完走した', 'rarity': 'superRare'},
    {'id': 'home_tidying_complete', 'name': '整理整頓マスター', 'subject': 'home_ec', 'emoji': '🗂️', 'desc': '整理整頓チャレンジを完了した', 'rarity': 'normal'},
    {'id': 'home_cleaning_complete', 'name': '清掃マスター', 'subject': 'home_ec', 'emoji': '🧹', 'desc': '清掃チャレンジを完了した', 'rarity': 'normal'},
    {'id': 'home_shopping_complete', 'name': 'お買い物名人', 'subject': 'home_ec', 'emoji': '🛒', 'desc': '買い物とお金チャレンジを完了した', 'rarity': 'normal'},
    {'id': 'home_chores_complete', 'name': '家事名人', 'subject': 'home_ec', 'emoji': '🍳', 'desc': '家庭の仕事チャレンジを完了した', 'rarity': 'normal'},
    {'id': 'home_eco_complete', 'name': 'エコ活動家', 'subject': 'home_ec', 'emoji': '🌱', 'desc': '環境の配慮チャレンジを完了した', 'rarity': 'normal'},
    {'id': 'home_nutrition', 'name': '栄養博士', 'subject': 'home_ec', 'emoji': '🥗', 'desc': '栄養バランスを学んだ', 'rarity': 'rare'},
    {'id': 'home_sewing', 'name': '裁縫見習い', 'subject': 'home_ec', 'emoji': '🧵', 'desc': '手縫い基礎をマスターした', 'rarity': 'rare'},
    // 共通
    {'id': 'streak_3', 'name': '3日連続！', 'subject': 'common', 'emoji': '🔥', 'desc': '3日連続でアプリを使った', 'rarity': 'normal'},
    {'id': 'streak_7', 'name': '一週間の達人', 'subject': 'common', 'emoji': '⚡', 'desc': '7日連続でアプリを使った', 'rarity': 'rare'},
    {'id': 'streak_30', 'name': '30日の伝説', 'subject': 'common', 'emoji': '🌟', 'desc': '30日連続でアプリを使った', 'rarity': 'superRare'},
  ];
}
