import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shougaku_kore_doutoku/data/shinshin_characters.dart';
import 'package:shougaku_kore_doutoku/providers/character_provider.dart';
import 'package:shougaku_kore_doutoku/providers/local_avatar_provider.dart';
import 'package:shougaku_kore_doutoku/screens/characters/character_collection_screen.dart';

Future<ProviderContainer> _container({int coins = 0}) async {
  SharedPreferences.setMockInitialValues({'local_avatar_coins': coins});
  final c = ProviderContainer();
  c.read(localAvatarProvider);
  c.read(shinshinCharacterProvider);
  await c.read(shinshinCharacterProvider.notifier).loaded;
  await Future<void>.delayed(const Duration(milliseconds: 50));
  return c;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('16体・全レベルの画像ファイルが存在する', () {
    expect(kShinshinCharacters.length, 16);
    expect(kShinshinCharacters.map((c) => c.id).toSet().length, 16);
    for (final c in kShinshinCharacters) {
      expect(File(c.imageAsset!).existsSync(), true, reason: c.id);
      for (var l = 2; l <= 5; l++) {
        expect(File(c.levelImages![l]!).existsSync(), true,
            reason: '${c.id} $l');
        expect(c.imageAssetForLevel(l), contains('_lv$l'));
      }
      expect(c.imageAssetForLevel(1), c.imageAsset);
    }
  });

  test('pubspecにassets/characters/が登録されている', () {
    expect(File('pubspec.yaml').readAsStringSync(),
        contains('assets/characters/'));
  });

  test('レベルアップのコスト 50/100/200/500', () {
    expect([2, 3, 4, 5].map(shinshinLevelUpCost), [50, 100, 200, 500]);
  });

  test('コイン不足は失敗しレベルもコインも変わらない', () async {
    final c = await _container(coins: 49);
    final err =
        await c.read(shinshinCharacterProvider.notifier).levelUp('shinshin_01');
    expect(err, contains('コインが足りません'));
    expect(c.read(shinshinCharacterProvider).levelOf('shinshin_01'), 1);
    expect(c.read(localAvatarProvider).coins, 49);
  });

  test('レベルアップでコインを消費し、永続化される。MAXで止まる', () async {
    final c = await _container(coins: 900);
    final n = c.read(shinshinCharacterProvider.notifier);
    for (var i = 0; i < 4; i++) {
      expect(await n.levelUp('shinshin_03'), isNull);
    }
    expect(c.read(shinshinCharacterProvider).levelOf('shinshin_03'), 5);
    expect(c.read(localAvatarProvider).coins, 50);
    expect(await n.levelUp('shinshin_03'), contains('MAX'));
    final p = await SharedPreferences.getInstance();
    expect(p.getString('shinshin_char_states'), contains('"shinshin_03":5'));
    expect(p.getInt('local_avatar_coins'), 50);

    final c2 = ProviderContainer();
    c2.read(shinshinCharacterProvider);
    await c2.read(shinshinCharacterProvider.notifier).loaded;
    expect(c2.read(shinshinCharacterProvider).levelOf('shinshin_03'), 5);
    expect(c2.read(shinshinCharacterProvider).levelOf('shinshin_01'), 1);
  });

  testWidgets('図鑑: 詳細シートが小画面でも溢れず、不足時はボタン無効', (tester) async {
    SharedPreferences.setMockInitialValues({'local_avatar_coins': 10});
    tester.view.physicalSize = const Size(360, 560);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(
        child: MaterialApp(home: CharacterCollectionScreen())));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('coinBalance')), findsOneWidget);
    await tester.tap(find.byKey(const Key('tile_shinshin_01')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('shortageText')), findsOneWidget);
    final btn = tester
        .widget<ButtonStyleButton>(find.byKey(const Key('levelUpButton')));
    expect(btn.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
