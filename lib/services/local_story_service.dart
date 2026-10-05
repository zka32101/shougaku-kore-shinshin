import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../data/seed_stories.dart';
import '../models/story.dart';

/// アプリに同梱したストーリー（オフライン・サーバー未接続時の読み込み元）。
class LocalStoryService {
  LocalStoryService._();

  static List<Map<String, dynamic>>? _raw;

  static Future<List<Map<String, dynamic>>> _load() async {
    final cached = _raw;
    if (cached != null) return cached;
    final text = await rootBundle.loadString('assets/stories/stories.json');
    final list = (jsonDecode(text) as List).cast<Map<String, dynamic>>();
    // 既存のシードストーリー(3〜4年生)も合わせる。週番号は並び順から割り当てる。
    final seeds = [
      for (var i = 0; i < kSeedStoriesJson.length; i++)
        {...kSeedStoriesJson[i], 'weekNumber': (i % 4) + 1},
    ];
    return _raw = [...list, ...seeds];
  }

  static Story _toStory(Map<String, dynamic> m, {bool withContent = true}) {
    final now = DateTime.utc(2026, 1, 1).toIso8601String();
    return Story.fromJson({
      ...m,
      if (!withContent) 'content': null,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  static Future<List<Story>> stories({
    String? theme,
    int? gradeLevel,
    bool? isPremium,
  }) async {
    final raw = await _load();
    return [
      for (final m in raw)
        if ((theme == null || m['theme'] == theme) &&
            (gradeLevel == null || m['gradeLevel'] == gradeLevel) &&
            (isPremium == null || m['isPremium'] == isPremium))
          _toStory(m, withContent: false),
    ];
  }

  static Future<List<Story>> weekly(int weekNumber) async {
    final raw = await _load();
    final week = ((weekNumber - 1) % 4) + 1;
    return [
      for (final m in raw)
        if (m['weekNumber'] == week) _toStory(m, withContent: false),
    ];
  }

  static Future<Story?> detail(String id) async {
    final raw = await _load();
    for (final m in raw) {
      if (m['id'] == id) return _toStory(m);
    }
    return null;
  }
}
