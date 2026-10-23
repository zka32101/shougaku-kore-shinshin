import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const themes = {
    'kindness',
    'honesty',
    'responsibility',
    'courage',
    'respect',
    'cooperation',
  };

  late List<Map<String, dynamic>> stories;

  setUpAll(() {
    final text = File('assets/stories/stories.json').readAsStringSync();
    stories = (jsonDecode(text) as List).cast<Map<String, dynamic>>();
  });

  test('ストーリーのIDは重複せず、テーマ・学年が正しい', () {
    final ids = stories.map((s) => s['id'] as String).toList();
    expect(ids.toSet().length, ids.length);
    for (final s in stories) {
      expect(themes, contains(s['theme']), reason: s['id'] as String);
      expect(s['gradeLevel'] as int, inInclusiveRange(1, 6),
          reason: s['id'] as String);
    }
  });

  test('どのストーリーも、選択肢が2つ以上あり、結果とふりかえりがある', () {
    for (final s in stories) {
      final content = s['content'] as Map<String, dynamic>;
      final choices = (content['choices'] as List).cast<Map<String, dynamic>>();
      expect(choices.length, greaterThanOrEqualTo(2),
          reason: s['id'] as String);
      final choiceIds = choices.map((c) => c['id']).toSet();
      expect(choiceIds.length, choices.length, reason: s['id'] as String);
      for (final c in choices) {
        expect(themes, contains(c['value']), reason: s['id'] as String);
        expect((c['branchContent'] as String).trim(), isNotEmpty);
        expect((c['reflection'] as String).trim(), isNotEmpty);
      }
    }
  });

  test('ネット・SNSのお話が、1〜6年の全学年にそろっている', () {
    const snsIds = [
      'local-story-42',
      'local-story-43',
      'local-story-44',
      'local-story-45',
      'local-story-46',
      'local-story-47',
      'local-story-48',
      'local-story-49',
      'local-story-50',
      'local-story-51',
    ];
    final sns = stories.where((s) => snsIds.contains(s['id'])).toList();
    expect(sns.length, snsIds.length);
    expect(sns.map((s) => s['gradeLevel']).toSet(), {1, 2, 3, 4, 5, 6});
  });

  test('各学年に、お話が5本以上ある', () {
    for (var g = 1; g <= 6; g++) {
      expect(stories.where((s) => s['gradeLevel'] == g).length,
          greaterThanOrEqualTo(5),
          reason: '$g年');
    }
  });
}
