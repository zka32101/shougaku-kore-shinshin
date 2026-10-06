import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shougaku_kore_doutoku/models/animal_avatar.dart';
import 'package:shougaku_kore_doutoku/providers/local_avatar_provider.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('16 animals: first 4 free, 12 paid with coin prices', () {
    expect(kAnimalAvatars.length, 16);
    expect(kAnimalAvatars.where((a) => a.isFree).length, 4);
    expect(kAnimalAvatars.take(4).every((a) => a.isFree), isTrue);
    expect(kAnimalAvatars.skip(4).every((a) => (a.priceCoins ?? 0) > 0), isTrue);
  });

  test('cannot buy without enough coins; buying spends coins and selects', () async {
    final n = LocalAvatarNotifier();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final rabbit = animalAvatarById(5);
    expect(await n.purchase(rabbit), isFalse);
    expect(n.state.coins, 0);
    await n.earnCoins(200);
    expect(await n.purchase(rabbit), isTrue);
    expect(n.state.coins, 50);
    expect(n.state.selectedId, 5);
    expect(n.state.isOwned(rabbit), isTrue);
    // 持っていないアバターは選べない
    expect(await n.select(animalAvatarById(9)), isFalse);
    // 無料は選べる
    expect(await n.select(animalAvatarById(2)), isTrue);
  });

  test('state is restored from storage', () async {
    final n = LocalAvatarNotifier();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await n.earnCoins(150);
    await n.purchase(animalAvatarById(6));
    final n2 = LocalAvatarNotifier();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(n2.state.coins, 0);
    expect(n2.state.ownedIds, {6});
    expect(n2.state.selectedId, 6);
  });
}
