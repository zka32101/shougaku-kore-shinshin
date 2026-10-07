import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/features/geijutsu/models/artwork.dart';
import 'package:shougaku_kore_doutoku/features/geijutsu/models/home_challenge.dart';
import 'package:shougaku_kore_doutoku/features/geijutsu/screens/memory_screen.dart';

Artwork _a(String id, int month, int day, {String title = ''}) => Artwork(
      id: id,
      month: month,
      level: ArtLevel.lv2,
      colorName: '赤',
      colorHex: '#FF0000',
      title: title,
      description: 'せつめい',
      createdAt: DateTime(2026, month, day),
    );

void main() {
  test('図工の作品を月ごとに並べて、過去の月も見返せる', () {
    final list = artMemories(ArtworkCollection([
      _a('c', 3, 1),
      _a('a', 1, 5, title: 'はじめて'),
      _a('b', 1, 9),
    ]));
    expect(list.map((e) => e.id), ['b', 'a', 'c']); // 1月(新しい順) → 3月
    expect(list[1].title, 'はじめて');
    expect(list[0].title, '作品 Lv2');
    final g = groupMemories(list);
    expect(g.keys, [1, 3]);
    expect(g[1]!.length, 2);
  });

  test('家庭科の記録も見返せる', () {
    final c = HomeChallengeCollection([
      HomeChallenge(
        id: 'h1',
        month: 2,
        level: HomeChallengeLevel.lv1,
        colorName: '橙',
        colorHex: '#FFA500',
        cooking: CookingEntry(menuName: 'たまごやき', photoPaths: [], notes: 'うまくできた'),
        createdAt: DateTime(2026, 2, 3),
      ),
    ]);
    final l = homeMemories(c);
    expect(l.single.title, 'たまごやき');
    expect(l.single.lines.first, contains('うまくできた'));
  });
}
