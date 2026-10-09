import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shougaku_kore_doutoku/features/shop/title/title_items.dart';
import 'package:shougaku_kore_doutoku/features/shop/title/title_plate.dart';
import 'package:shougaku_kore_doutoku/features/shop/title/title_provider.dart';
import 'package:shougaku_kore_doutoku/providers/local_avatar_provider.dart';

void main() {
  test('称号は8個・コイン5個(100〜500)・達成3個、IDは重複しない', () {
    expect(kTitleItems.length, 8);
    expect({for (final t in kTitleItems) t.id}.length, 8);
    final coin = kTitleItems.where((t) => t.isCoin).toList();
    expect(coin.length, 5);
    for (final t in coin) {
      expect(t.coinCost, inInclusiveRange(100, 500));
    }
    for (final t in kTitleItems.where((t) => !t.isCoin)) {
      expect(t.condition, isNotEmpty);
    }
    expect(File('assets/title_plate/plate_shinshin.webp').existsSync(), true);
  });

  test('達成称号の判定は進捗値だけで決まる', () {
    final first = titleItemById('title_first')!;
    final story = titleItemById('title_story')!;
    final sodate = titleItemById('title_sodate')!;
    expect(isAchievementUnlocked(first, const TitleStats()), false);
    expect(isAchievementUnlocked(first, const TitleStats(storiesCleared: 1)), true);
    expect(isAchievementUnlocked(story, const TitleStats(storiesCleared: 9)), false);
    expect(isAchievementUnlocked(story, const TitleStats(storiesCleared: 10)), true);
    expect(isAchievementUnlocked(sodate, const TitleStats(maxCharacterLevel: 2)), false);
    expect(isAchievementUnlocked(sodate, const TitleStats(maxCharacterLevel: 3)), true);
  });

  test('ホームに出す称号名: 未選択/未所持/不明IDは null', () {
    const stats = TitleStats();
    expect(equippedTitleName(null, owned: {}, stats: stats), isNull);
    expect(equippedTitleName('title_genki', owned: {}, stats: stats), isNull);
    expect(equippedTitleName('title_genki', owned: {'title_genki'}, stats: stats), 'げんきいっぱい');
    expect(equippedTitleName('nope', owned: {'nope'}, stats: stats), isNull);
    expect(equippedTitleName('title_first', owned: {}, stats: stats), isNull);
    expect(equippedTitleName('title_first', owned: {}, stats: const TitleStats(storiesCleared: 1)), 'はじめのいっぽ');
  });

  test('購入はコインを使い、足りなければ失敗。装着は保存される', () async {
    SharedPreferences.setMockInitialValues({'local_avatar_coins': 120});
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await c.read(titleProvider.notifier).loaded;
    c.read(localAvatarProvider);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final n = c.read(titleProvider.notifier);
    final genki = titleItemById('title_genki')!;
    expect(await n.equip(genki), false);
    expect(await n.purchase(titleItemById('title_champion')!), false);
    expect(await n.purchase(genki), true);
    expect(c.read(localAvatarProvider).coins, 20);
    expect(await n.purchase(genki), false);
    expect(await n.equip(genki), true);
    expect(c.read(equippedTitleNameProvider), 'げんきいっぱい');
    final p = await SharedPreferences.getInstance();
    expect(p.getString(TitleNotifier.kEquipped), 'title_genki');
    await n.unequip();
    expect(c.read(equippedTitleNameProvider), isNull);
  });

  testWidgets('プレートは称号名を表示し、狭くてもoverflowしない', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: TitlePlate(name: 'しんしんチャンピオンのながいなまえ'))),
    ));
    expect(find.text('しんしんチャンピオンのながいなまえ'), findsOneWidget);
    expect(tester.getSize(find.byKey(const ValueKey('title_plate'))).width, 110);
    expect(tester.takeException(), isNull);
  });

  testWidgets('HomeTitlePlate: 未選択は何も出さない', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: Scaffold(body: HomeTitlePlate())),
    ));
    await tester.pump();
    expect(find.byKey(const ValueKey('title_plate')), findsNothing);
  });

  testWidgets('HomeTitlePlate: 装着中の称号が出る', (tester) async {
    SharedPreferences.setMockInitialValues({
      'title_owned': ['title_genki'],
      'title_equipped': 'title_genki',
    });
    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(home: Scaffold(body: HomeTitlePlate())),
    ));
    await tester.pumpAndSettle();
    expect(find.text('げんきいっぱい'), findsOneWidget);
  });
}
