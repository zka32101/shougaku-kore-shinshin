import 'package:shared_core/shared_core.dart' show CoinNotifier, CoinState, coinProvider;

import '../providers/local_avatar_provider.dart';

/// shared_core の [coinProvider] を、このアプリのコイン（[localAvatarProvider]）に
/// つなぐ。定着率施策（初回7日間のごほうび・週次チャレンジ）が付けるコインが、
/// アバターやキャラの購入に使うコインと同じ財布に入るようにする。
class LocalAvatarCoinNotifier extends CoinNotifier {
  @override
  CoinState build() =>
      CoinState(totalCoins: ref.read(localAvatarProvider).coins);

  @override
  Future<void> load() async {
    state = CoinState(totalCoins: ref.read(localAvatarProvider).coins);
  }

  @override
  Future<void> addCoins(int amount) async {
    await ref.read(localAvatarProvider.notifier).earnCoins(amount);
    state = CoinState(totalCoins: ref.read(localAvatarProvider).coins);
  }

  @override
  Future<bool> spendCoins(int amount) async {
    final ok = await ref.read(localAvatarProvider.notifier).spendCoins(amount);
    state = CoinState(totalCoins: ref.read(localAvatarProvider).coins);
    return ok;
  }

  @override
  Future<void> reset() async {
    state = CoinState(totalCoins: ref.read(localAvatarProvider).coins);
  }
}

/// ProviderScope に渡す override。
final coinBridgeOverride = coinProvider.overrideWith(LocalAvatarCoinNotifier.new);
