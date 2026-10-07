import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/data/shinshin_characters.dart';
import 'package:shougaku_kore_doutoku/data/shinshin_unlocks.dart';

void main() {
  test('全16体に解放条件があり、最初は数体だけ見える', () {
    for (final c in kShinshinCharacters) {
      expect(kShinshinUnlockStories.containsKey(c.id), isTrue, reason: c.id);
    }
    final initial = kShinshinCharacters
        .where((c) => isCharacterUnlocked(c.id, storiesCleared: 0))
        .length;
    expect(initial, 5);
    expect(
        kShinshinCharacters
            .where((c) => isCharacterUnlocked(c.id, storiesCleared: 30))
            .length,
        16);
  });

  test('コインからクリア数へ換算(1ストーリー=10コイン)', () {
    expect(storiesClearedFromCoins(0), 0);
    expect(storiesClearedFromCoins(35), 3);
  });

  test('育てたキャラは条件に関わらず見える(既存ユーザー保護)', () {
    expect(isCharacterUnlocked('shinshin_13', storiesCleared: 0), isFalse);
    expect(isCharacterUnlocked('shinshin_13', storiesCleared: 0, level: 3),
        isTrue);
  });

  test('ヒント文', () {
    expect(unlockHint('shinshin_03', 1), contains('3 かい'));
    expect(unlockHint('shinshin_03', 1), contains('あと 2'));
  });
}
