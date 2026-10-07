import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/features/geijutsu/models/badge.dart';
import 'package:shougaku_kore_doutoku/features/taiku/providers/taiku_providers.dart';
import 'package:shougaku_kore_doutoku/models/badge.dart';
import 'package:shougaku_kore_doutoku/widgets/badge_emblem.dart';

void main() {
  test('道徳・体育・芸術の全バッジに共通意匠の対応があり、画像が存在する', () {
    final ids = <String>[
      ...kDoutokuBadges.map((b) => b.id),
      ...allBadges.map((b) => b.id),
      ...BadgeCollection.allDefinitions.map((d) => d['id']!),
    ];
    expect(kDoutokuBadges.length, 10);
    expect(allBadges.length, 46);
    expect(BadgeCollection.allDefinitions.length, 35);
    for (final id in ids) {
      final name = BadgeEmblem.emblemOf(id);
      expect(name, isNotNull, reason: id);
      expect(File('assets/badges/badge_$name.webp').existsSync(), true, reason: '$id -> $name');
    }
  });

  testWidgets('対応のあるバッジは画像、ないバッジは絵文字で出る', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Column(children: [
          BadgeEmblem(badgeId: 'streak_3', fallbackEmoji: '🔥'),
          BadgeEmblem(badgeId: 'unknown_badge', fallbackEmoji: '🔥'),
        ]),
      ),
    ));
    await tester.pump();
    expect(find.byType(Image), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  test('体育のステージバッジ(stage_N_clear)は番号が取れ、他のバッジは null', () {
    expect(BadgeEmblem.stageLabelOf('stage_1_clear'), '1');
    expect(BadgeEmblem.stageLabelOf('stage_21_clear'), '21');
    expect(BadgeEmblem.stageLabelOf('streak_3'), isNull);
    expect(BadgeEmblem.stageLabelOf('stage_x_clear'), isNull);
  });

  testWidgets('ステージバッジは番号を重ねて表示する', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: BadgeEmblem(badgeId: 'stage_12_clear', fallbackEmoji: '🏁', size: 48)),
    ));
    await tester.pump();
    expect(find.text('12'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
