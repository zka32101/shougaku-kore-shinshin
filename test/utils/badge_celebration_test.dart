import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/utils/badge_celebration.dart';

void main() {
  test('初回(通知済み未記録)は何も通知しない', () {
    expect(detectNewBadgeIds(earned: ['a', 'b'], notified: null), isEmpty);
  });
  test('新規IDのみ返す', () {
    expect(detectNewBadgeIds(earned: ['a', 'b', 'c'], notified: {'a'}),
        ['b', 'c']);
  });
  test('重複なし・増えなければ空', () {
    expect(detectNewBadgeIds(earned: ['b', 'b'], notified: {'a'}), ['b']);
    expect(detectNewBadgeIds(earned: ['a'], notified: {'a'}), isEmpty);
  });
}
