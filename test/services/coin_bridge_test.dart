import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_core/shared_core.dart' show coinProvider, weeklyChallengeProvider;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shougaku_kore_doutoku/providers/local_avatar_provider.dart';
import 'package:shougaku_kore_doutoku/services/coin_bridge.dart';
import 'package:shougaku_kore_doutoku/services/retention_hooks.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('shared_core の coinProvider に付けたコインがアプリのコインに入る', () async {
    final c = ProviderContainer(overrides: [coinBridgeOverride]);
    addTearDown(c.dispose);
    c.read(localAvatarProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await c.read(coinProvider.notifier).addCoins(50);
    expect(c.read(localAvatarProvider).coins, 50);
    expect(c.read(coinProvider).totalCoins, 50);
    expect(await c.read(coinProvider.notifier).spendCoins(20), isTrue);
    expect(c.read(localAvatarProvider).coins, 30);
  });

  test('週次チャレンジは3つのお話で達成しコインが入る', () async {
    final c = ProviderContainer(overrides: [coinBridgeOverride]);
    addTearDown(c.dispose);
    await initRetention(c);
    c.read(localAvatarProvider); // 保存済みコインの読み込みを待つ
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final w = c.read(weeklyChallengeProvider.notifier);
    expect(await w.recordCorrectAnswer(), 0);
    expect(await w.recordCorrectAnswer(), 0);
    expect(await w.recordCorrectAnswer(), kWeeklyStoryRewardCoins);
    expect(c.read(localAvatarProvider).coins, kWeeklyStoryRewardCoins);
  });
}
