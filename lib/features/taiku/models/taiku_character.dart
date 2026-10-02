class TaikuCharacter {
  final int id;
  final String nameJp;
  final String category;
  final String assetPath;

  const TaikuCharacter({
    required this.id,
    required this.nameJp,
    required this.category,
    required this.assetPath,
  });
}

const taikuCharacters = [
  TaikuCharacter(id: 1, nameJp: 'ハシルくん', category: '基礎運動', assetPath: 'assets/taiku/images/characters/1_ハシルくん_512.png'),
  TaikuCharacter(id: 2, nameJp: 'トブちゃん', category: '基礎運動', assetPath: 'assets/taiku/images/characters/2_トブちゃん_512.png'),
  TaikuCharacter(id: 3, nameJp: 'ナゲルくん', category: '基礎運動', assetPath: 'assets/taiku/images/characters/3_ナゲルくん_512.png'),
  TaikuCharacter(id: 4, nameJp: 'オヨグちゃん', category: '基礎運動', assetPath: 'assets/taiku/images/characters/4_オヨグちゃん_512.png'),
  TaikuCharacter(id: 5, nameJp: 'サッカーくん', category: '球技・チームスポーツ', assetPath: 'assets/taiku/images/characters/5_サッカーくん_512.png'),
  TaikuCharacter(id: 6, nameJp: 'バスケちゃん', category: '球技・チームスポーツ', assetPath: 'assets/taiku/images/characters/6_バスケちゃん_512.png'),
  TaikuCharacter(id: 7, nameJp: 'ヤキュウくん', category: '球技・チームスポーツ', assetPath: 'assets/taiku/images/characters/7_ヤキュウくん_512.png'),
  TaikuCharacter(id: 8, nameJp: 'バレーちゃん', category: '球技・チームスポーツ', assetPath: 'assets/taiku/images/characters/8_バレーちゃん_512.png'),
  TaikuCharacter(id: 9, nameJp: 'タイソウちゃん', category: '体操・個人種目', assetPath: 'assets/taiku/images/characters/9_タイソウちゃん_512.png'),
  TaikuCharacter(id: 10, nameJp: 'ジュウドウくん', category: '体操・個人種目', assetPath: 'assets/taiku/images/characters/10_ジュウドウくん_512.png'),
  TaikuCharacter(id: 11, nameJp: 'マラソンくん', category: '体操・個人種目', assetPath: 'assets/taiku/images/characters/11_マラソンくん_512.png'),
  TaikuCharacter(id: 12, nameJp: 'スケートちゃん', category: '体操・個人種目', assetPath: 'assets/taiku/images/characters/12_スケートちゃん_512.png'),
  TaikuCharacter(id: 13, nameJp: 'キャンプくん', category: '体験活動', assetPath: 'assets/taiku/images/characters/13_キャンプくん_512.png'),
  TaikuCharacter(id: 14, nameJp: 'リョウリちゃん', category: '体験活動', assetPath: 'assets/taiku/images/characters/14_リョウリちゃん_512.png'),
  TaikuCharacter(id: 15, nameJp: 'ノウギョウくん', category: '体験活動', assetPath: 'assets/taiku/images/characters/15_ノウギョウくん_512.png'),
  TaikuCharacter(id: 16, nameJp: 'モノヅクリちゃん', category: '体験活動', assetPath: 'assets/taiku/images/characters/16_モノヅクリちゃん_512.png'),
];
