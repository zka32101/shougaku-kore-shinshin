import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/providers/premium_provider.dart';

void main() {
  test('体育: ステージ10まで無料、11〜30は有料、特別ステージ31〜33は無料、34以降は有料', () {
    expect(isFreeTaikuStage(1), isTrue);
    expect(isFreeTaikuStage(10), isTrue);
    expect(isFreeTaikuStage(11), isFalse);
    expect(isFreeTaikuStage(30), isFalse);
    expect(isFreeTaikuStage(31), isTrue);
    expect(isFreeTaikuStage(33), isTrue);
    expect(isFreeTaikuStage(34), isFalse);
  });
}
