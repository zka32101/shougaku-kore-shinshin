import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/models/avatar.dart';
import 'package:shougaku_kore_doutoku/providers/avatar_provider.dart';

Avatar _avatar(String id, {bool isDefault = false, int? price}) => Avatar(
      id: id,
      name: 'avatar $id',
      description: 'desc',
      imagePath: 'assets/images/avatars/$id.png',
      isDefault: isDefault,
      price: price,
      order: 1,
    );

ProviderContainer _container({
  required List<Avatar> avatars,
  UserAvatarInfo? info,
}) =>
    ProviderContainer(overrides: [
      allAvatarsProvider.overrideWith((ref) async => avatars),
      userAvatarInfoProvider.overrideWith((ref) => Stream.value(info)),
    ]);

void main() {
  group('isAvatarOwnedProvider', () {
    final avatars = [
      _avatar('free', isDefault: true),
      _avatar('paid', price: 120),
    ];

    test('default avatars are owned', () async {
      final container = _container(
        avatars: avatars,
        info: const UserAvatarInfo(userId: 'u1', selectedAvatarId: 'free'),
      );
      addTearDown(container.dispose);

      expect(await container.read(isAvatarOwnedProvider('free').future), isTrue);
    });

    test('purchasable avatars are owned only after purchase', () async {
      final notPurchased = _container(
        avatars: avatars,
        info: const UserAvatarInfo(userId: 'u1', selectedAvatarId: 'free'),
      );
      addTearDown(notPurchased.dispose);
      expect(
        await notPurchased.read(isAvatarOwnedProvider('paid').future),
        isFalse,
      );

      final purchased = _container(
        avatars: avatars,
        info: const UserAvatarInfo(
          userId: 'u1',
          selectedAvatarId: 'free',
          purchasedAvatarIds: ['paid'],
        ),
      );
      addTearDown(purchased.dispose);
      expect(
        await purchased.read(isAvatarOwnedProvider('paid').future),
        isTrue,
      );
    });

    test('unknown avatar id is reported as not owned (no exception)', () async {
      final container = _container(
        avatars: avatars,
        info: const UserAvatarInfo(userId: 'u1', selectedAvatarId: 'free'),
      );
      addTearDown(container.dispose);

      expect(
        await container.read(isAvatarOwnedProvider('does-not-exist').future),
        isFalse,
      );
    });

    test('nothing is owned when there is no user info', () async {
      final container = _container(avatars: avatars);
      addTearDown(container.dispose);

      expect(await container.read(isAvatarOwnedProvider('free').future), isFalse);
    });
  });
}
