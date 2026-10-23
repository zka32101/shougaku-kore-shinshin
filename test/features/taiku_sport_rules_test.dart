import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/features/taiku/data/sport_encyclopedia.dart';
import 'package:shougaku_kore_doutoku/features/taiku/widgets/sport_radar_chart.dart';

void main() {
  SportEntry find(String id) => allSports.firstWhere((e) => e.id == id);

  test('競技のIDは重複せず、カテゴリは一覧に実在する', () {
    final ids = allSports.map((e) => e.id).toList();
    expect(ids.toSet().length, ids.length);
    for (final s in allSports) {
      expect(sportCategories, contains(s.category), reason: s.id);
    }
  });

  test('跳び箱・マット運動・鉄棒・大縄跳び・鬼ごっこが載っている', () {
    for (final id in [
      'sp_vault',
      'sp_mat',
      'sp_horizontalbar',
      'sp_longrope',
      'sp_tag',
    ]) {
      final s = find(id);
      expect(s.basicRules, isNotEmpty, reason: id);
      expect(s.detailedRules.length, greaterThanOrEqualTo(4), reason: id);
      expect(s.playStyles, isNotEmpty, reason: id);
    }
    expect(getSportsByCategory('あそび').map((e) => e.id),
        containsAll(['sp_longrope', 'sp_tag']));
  });

  test('主要スポーツには「くわしいルール」と「いろいろな遊び方」がある', () {
    for (final id in [
      'sp_soccer',
      'sp_basketball',
      'sp_baseball',
      'sp_volleyball',
      'sp_dodgeball',
      'sp_tennis',
      'sp_badminton',
      'sp_tabletennis',
      'sp_rugby',
      'sp_handball',
      'sp_jumprope',
    ]) {
      final s = find(id);
      expect(s.detailedRules.length, greaterThanOrEqualTo(3), reason: id);
      expect(s.playStyles, isNotEmpty, reason: id);
    }
  });

  test('なわとびと鬼ごっこの遊び方が複数ある', () {
    expect(find('sp_jumprope').playStyles.length, greaterThanOrEqualTo(3));
    final tag = find('sp_tag').playStyles.map((e) => e.name).join();
    expect(tag, contains('氷鬼'));
    expect(tag, contains('色鬼'));
  });

  test('文字が空の項目がない', () {
    for (final s in allSports) {
      for (final r in s.detailedRules) {
        expect(r.trim(), isNotEmpty, reason: s.id);
      }
      for (final p in s.playStyles) {
        expect(p.name.trim(), isNotEmpty, reason: s.id);
        expect(p.how.trim(), isNotEmpty, reason: s.id);
      }
    }
  });

  test('新しい競技のレーダーチャートは標準値ではなく専用の値を持つ', () {
    for (final id in ['sp_vault', 'sp_mat', 'sp_horizontalbar', 'sp_longrope', 'sp_tag']) {
      expect(sportRadarValues(id, 1), isNot([1, 3, 3, 3, 3, 3]), reason: id);
    }
  });
}
