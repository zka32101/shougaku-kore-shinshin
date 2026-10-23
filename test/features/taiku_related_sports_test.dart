import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/features/taiku/data/sport_encyclopedia.dart';

void main() {
  test('スポーツ図鑑の各競技は、実在するステージにひも付く(またはどこにも付かない)', () {
    for (final s in allSports) {
      final st = s.relatedStage;
      if (st != null) expect(st, inInclusiveRange(1, 35), reason: s.id);
    }
    // まなびポイントでスポーツ説明カードが出るステージが複数ある
    final linked = allSports.map((e) => e.relatedStage).whereType<int>().toSet();
    expect(linked.length, greaterThanOrEqualTo(5));
  });
}
