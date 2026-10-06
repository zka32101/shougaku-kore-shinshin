/// 動物アバター（プロフィール画像）。16種。
///
/// - id 1〜4 : 最初から使える
/// - id 5〜16: ストーリーなどでためたコインで購入
class AnimalAvatar {
  final int id;
  final String name;

  /// 購入に必要なコイン。null = 無料（最初から使える）
  final int? priceCoins;

  const AnimalAvatar(this.id, this.name, [this.priceCoins]);

  bool get isFree => priceCoins == null;

  String get imageAsset => 'assets/avatars/avatar_$id.jpg';
}

const List<AnimalAvatar> kAnimalAvatars = [
  AnimalAvatar(1, '茶色クマ'),
  AnimalAvatar(2, '黒猫'),
  AnimalAvatar(3, 'パンダ'),
  AnimalAvatar(4, 'キツネ'),
  AnimalAvatar(5, 'ウサギ', 150),
  AnimalAvatar(6, 'トラ', 150),
  AnimalAvatar(7, 'ライオン', 150),
  AnimalAvatar(8, 'カエル', 150),
  AnimalAvatar(9, 'アヒル', 150),
  AnimalAvatar(10, 'ブタ', 120),
  AnimalAvatar(11, 'コアラ', 120),
  AnimalAvatar(12, 'キリン', 120),
  AnimalAvatar(13, 'カンガルー', 200),
  AnimalAvatar(14, 'イヌ', 200),
  AnimalAvatar(15, 'アライグマ', 200),
  AnimalAvatar(16, 'ナマケモノ', 200),
];

AnimalAvatar animalAvatarById(int id) =>
    kAnimalAvatars.firstWhere((a) => a.id == id, orElse: () => kAnimalAvatars.first);
