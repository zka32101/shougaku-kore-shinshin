import '../enums/grade_level.dart';

/// フレームワーク §5: 全教科共通バッジシステム
class LiteracyBadge {
  final String id;
  final String subject;
  final GradeLevel grade;
  final int stageNumber;
  final String name;
  final String description;
  final String emoji;
  final BadgeRarity rarity;

  const LiteracyBadge({
    required this.id,
    required this.subject,
    required this.grade,
    required this.stageNumber,
    required this.name,
    required this.description,
    required this.emoji,
    this.rarity = BadgeRarity.common,
  });
}

enum BadgeRarity {
  common,   // 通常（各段階クリア）
  rare,     // レア（高正答率クリア）
  epic,     // エピック（連続クリア・高学年到達）
  legendary // 伝説（全段階制覇）
}

extension BadgeRarityExt on BadgeRarity {
  String get label {
    switch (this) {
      case BadgeRarity.common: return 'コモン';
      case BadgeRarity.rare: return 'レア';
      case BadgeRarity.epic: return 'エピック';
      case BadgeRarity.legendary: return 'レジェンド';
    }
  }
}

/// フレームワーク §5: 教科別バッジ定義ファクトリ
class LiteracyBadgeFactory {
  LiteracyBadgeFactory._();

  // 算数コレ！バッジ（フレームワーク §5.1）
  static const math = [
    LiteracyBadge(id: 'math_1', subject: 'math', grade: GradeLevel.low, stageNumber: 1, name: 'かぞえじゃそん', description: '1〜10を数えられた！', emoji: '🔢'),
    LiteracyBadge(id: 'math_2', subject: 'math', grade: GradeLevel.low, stageNumber: 2, name: '足し算マスター', description: '足し算が得意！', emoji: '➕'),
    LiteracyBadge(id: 'math_3', subject: 'math', grade: GradeLevel.low, stageNumber: 3, name: '繰り上がり名人', description: '繰り上がりもOK！', emoji: '🏆'),
    LiteracyBadge(id: 'math_4', subject: 'math', grade: GradeLevel.mid, stageNumber: 4, name: '九九マスター', description: '9×9を制覇！', emoji: '✖️'),
    LiteracyBadge(id: 'math_5', subject: 'math', grade: GradeLevel.mid, stageNumber: 5, name: '割り算スター', description: '割り算も得意！', emoji: '➗'),
    LiteracyBadge(id: 'math_6', subject: 'math', grade: GradeLevel.mid, stageNumber: 6, name: '分数マスター', description: '分数を理解！', emoji: '🍕'),
    LiteracyBadge(id: 'math_7', subject: 'math', grade: GradeLevel.mid, stageNumber: 7, name: '小数達人', description: '小数もバッチリ！', emoji: '📊'),
    LiteracyBadge(id: 'math_8', subject: 'math', grade: GradeLevel.mid, stageNumber: 8, name: '方程式への道', description: '未知数に挑戦！', emoji: '🔍'),
    LiteracyBadge(id: 'math_9', subject: 'math', grade: GradeLevel.high, stageNumber: 9, name: '関数マスター', description: 'y=2x+1を理解！', emoji: '📈', rarity: BadgeRarity.rare),
    LiteracyBadge(id: 'math_10', subject: 'math', grade: GradeLevel.high, stageNumber: 10, name: '受験対応', description: '受験算数に挑戦！', emoji: '🎓', rarity: BadgeRarity.rare),
    LiteracyBadge(id: 'math_11', subject: 'math', grade: GradeLevel.high, stageNumber: 11, name: '統計マスター', description: '平均・中央値を制覇！', emoji: '📉', rarity: BadgeRarity.epic),
    LiteracyBadge(id: 'math_12', subject: 'math', grade: GradeLevel.high, stageNumber: 12, name: '確率アナリスト', description: '確率計算の達人！', emoji: '🎲', rarity: BadgeRarity.epic),
  ];

  // 国語コレ！バッジ（フレームワーク §5.2）
  static const japanese = [
    LiteracyBadge(id: 'jpn_1', subject: 'japanese', grade: GradeLevel.low, stageNumber: 1, name: 'ひらがなマスター', description: 'ひらがな80字を制覇！', emoji: 'あ'),
    LiteracyBadge(id: 'jpn_2', subject: 'japanese', grade: GradeLevel.low, stageNumber: 2, name: 'カタカナ達人', description: 'カタカナもバッチリ！', emoji: 'ア'),
    LiteracyBadge(id: 'jpn_3', subject: 'japanese', grade: GradeLevel.low, stageNumber: 3, name: '語彙くん', description: '50語マスター！', emoji: '📖'),
    LiteracyBadge(id: 'jpn_4', subject: 'japanese', grade: GradeLevel.low, stageNumber: 4, name: '文の構造の友', description: '主語・述語を理解！', emoji: '📝'),
    LiteracyBadge(id: 'jpn_5', subject: 'japanese', grade: GradeLevel.low, stageNumber: 5, name: '読書家', description: '短編読解クリア！', emoji: '📚'),
    LiteracyBadge(id: 'jpn_6', subject: 'japanese', grade: GradeLevel.mid, stageNumber: 6, name: '要約名人', description: '30字要約ができた！', emoji: '✏️'),
    LiteracyBadge(id: 'jpn_7', subject: 'japanese', grade: GradeLevel.mid, stageNumber: 7, name: '説明文の達人', description: '筆者の意図を読解！', emoji: '🔬'),
    LiteracyBadge(id: 'jpn_8', subject: 'japanese', grade: GradeLevel.mid, stageNumber: 8, name: '物語マスター', description: '登場人物の心情を理解！', emoji: '💭', rarity: BadgeRarity.rare),
    LiteracyBadge(id: 'jpn_9', subject: 'japanese', grade: GradeLevel.high, stageNumber: 9, name: '批判的読者', description: '論説文を評価できる！', emoji: '🧐', rarity: BadgeRarity.rare),
    LiteracyBadge(id: 'jpn_10', subject: 'japanese', grade: GradeLevel.high, stageNumber: 10, name: '論理マスター', description: '論理構造を分析！', emoji: '🧩', rarity: BadgeRarity.epic),
    LiteracyBadge(id: 'jpn_11', subject: 'japanese', grade: GradeLevel.high, stageNumber: 11, name: '作家', description: '段落構成をマスター！', emoji: '✍️', rarity: BadgeRarity.epic),
    LiteracyBadge(id: 'jpn_12', subject: 'japanese', grade: GradeLevel.high, stageNumber: 12, name: '表現マスター', description: '全教科の国語力を制覇！', emoji: '🏅', rarity: BadgeRarity.legendary),
  ];

  // 理科コレ！バッジ（フレームワーク §5.3）
  static const science = [
    LiteracyBadge(id: 'sci_1', subject: 'science', grade: GradeLevel.low, stageNumber: 1, name: '自然博士', description: '生き物観察クリア！', emoji: '🌱'),
    LiteracyBadge(id: 'sci_2', subject: 'science', grade: GradeLevel.low, stageNumber: 2, name: '季節マスター', description: '四季を理解！', emoji: '🌸'),
    LiteracyBadge(id: 'sci_3', subject: 'science', grade: GradeLevel.low, stageNumber: 3, name: '天気予報士', description: '気象の基礎を習得！', emoji: '☁️'),
    LiteracyBadge(id: 'sci_4', subject: 'science', grade: GradeLevel.low, stageNumber: 4, name: 'からだ博士', description: '身体の器官を理解！', emoji: '🫀'),
    LiteracyBadge(id: 'sci_5', subject: 'science', grade: GradeLevel.low, stageNumber: 5, name: '栄養士', description: '栄養素をマスター！', emoji: '🥗'),
    LiteracyBadge(id: 'sci_6', subject: 'science', grade: GradeLevel.mid, stageNumber: 6, name: '生態系マスター', description: '食物連鎖を理解！', emoji: '🦁'),
    LiteracyBadge(id: 'sci_7', subject: 'science', grade: GradeLevel.mid, stageNumber: 7, name: '環境守り手', description: '生態系バランスを理解！', emoji: '🌍'),
    LiteracyBadge(id: 'sci_8', subject: 'science', grade: GradeLevel.mid, stageNumber: 8, name: '物理マスター', description: '力・エネルギーを習得！', emoji: '⚡', rarity: BadgeRarity.rare),
    LiteracyBadge(id: 'sci_9', subject: 'science', grade: GradeLevel.high, stageNumber: 9, name: '化学博士', description: '酸化・燃焼を理解！', emoji: '🔥', rarity: BadgeRarity.rare),
    LiteracyBadge(id: 'sci_10', subject: 'science', grade: GradeLevel.high, stageNumber: 10, name: '実験マスター', description: '実験データを分析！', emoji: '🧪', rarity: BadgeRarity.epic),
    LiteracyBadge(id: 'sci_11', subject: 'science', grade: GradeLevel.high, stageNumber: 11, name: '地学者', description: '地層・天体を習得！', emoji: '🌏', rarity: BadgeRarity.epic),
    LiteracyBadge(id: 'sci_12', subject: 'science', grade: GradeLevel.high, stageNumber: 12, name: '総合科学者', description: '小学理科を完全制覇！', emoji: '🔭', rarity: BadgeRarity.legendary),
  ];

  // プログラミングコレ！バッジ（フレームワーク §5.4）
  static const programming = [
    LiteracyBadge(id: 'prog_1', subject: 'programming', grade: GradeLevel.low, stageNumber: 1, name: 'プログラマー1級', description: 'シーケンスを理解！', emoji: '🤖'),
    LiteracyBadge(id: 'prog_2', subject: 'programming', grade: GradeLevel.low, stageNumber: 2, name: 'ループマスター', description: '繰り返しを習得！', emoji: '🔄'),
    LiteracyBadge(id: 'prog_3', subject: 'programming', grade: GradeLevel.low, stageNumber: 3, name: 'ゲームクリエイター1級', description: 'キャラを動かせた！', emoji: '🎮'),
    LiteracyBadge(id: 'prog_4', subject: 'programming', grade: GradeLevel.mid, stageNumber: 4, name: 'アルゴリズマー', description: '条件分岐をマスター！', emoji: '🔀'),
    LiteracyBadge(id: 'prog_5', subject: 'programming', grade: GradeLevel.mid, stageNumber: 5, name: 'データ使い', description: '配列を理解！', emoji: '📋'),
    LiteracyBadge(id: 'prog_6', subject: 'programming', grade: GradeLevel.mid, stageNumber: 6, name: 'Pythonマスター', description: 'Python基礎を習得！', emoji: '🐍', rarity: BadgeRarity.rare),
    LiteracyBadge(id: 'prog_7', subject: 'programming', grade: GradeLevel.mid, stageNumber: 7, name: 'データ分析師', description: 'データ処理ができる！', emoji: '📊', rarity: BadgeRarity.rare),
    LiteracyBadge(id: 'prog_8', subject: 'programming', grade: GradeLevel.high, stageNumber: 8, name: 'クラス設計師', description: 'OOPを理解！', emoji: '🏗️', rarity: BadgeRarity.rare),
    LiteracyBadge(id: 'prog_9', subject: 'programming', grade: GradeLevel.high, stageNumber: 9, name: 'APIエンジニア', description: 'API連携ができる！', emoji: '🔌', rarity: BadgeRarity.epic),
    LiteracyBadge(id: 'prog_10', subject: 'programming', grade: GradeLevel.high, stageNumber: 10, name: 'ソフトウェアエンジニア', description: 'アルゴリズムの達人！', emoji: '💻', rarity: BadgeRarity.epic),
    LiteracyBadge(id: 'prog_11', subject: 'programming', grade: GradeLevel.high, stageNumber: 11, name: 'AIプログラマー', description: 'AIと協働できる！', emoji: '🧠', rarity: BadgeRarity.legendary),
    LiteracyBadge(id: 'prog_12', subject: 'programming', grade: GradeLevel.high, stageNumber: 12, name: '未来の創造者', description: 'プログラミング完全制覇！', emoji: '🚀', rarity: BadgeRarity.legendary),
  ];

  // 道徳コレ！バッジ（フレームワーク §5.5）
  static const moral = [
    LiteracyBadge(id: 'mor_1', subject: 'moral', grade: GradeLevel.low, stageNumber: 1, name: '友達の友', description: '友達を大事にできる！', emoji: '🤝'),
    LiteracyBadge(id: 'mor_2', subject: 'moral', grade: GradeLevel.low, stageNumber: 2, name: 'ルール守り', description: '約束を守れる！', emoji: '📜'),
    LiteracyBadge(id: 'mor_3', subject: 'moral', grade: GradeLevel.low, stageNumber: 3, name: '感情マスター', description: '自分の気持ちを知れる！', emoji: '💕'),
    LiteracyBadge(id: 'mor_4', subject: 'moral', grade: GradeLevel.low, stageNumber: 4, name: '家族の味方', description: '家族を大切にできる！', emoji: '🏠'),
    LiteracyBadge(id: 'mor_5', subject: 'moral', grade: GradeLevel.low, stageNumber: 5, name: '地域の一員', description: '地域とつながれる！', emoji: '🌇'),
    LiteracyBadge(id: 'mor_6', subject: 'moral', grade: GradeLevel.mid, stageNumber: 6, name: '学級リーダー', description: '学級委員の役割を理解！', emoji: '⭐'),
    LiteracyBadge(id: 'mor_7', subject: 'moral', grade: GradeLevel.mid, stageNumber: 7, name: '公正の守り手', description: '公正・公平を理解！', emoji: '⚖️'),
    LiteracyBadge(id: 'mor_8', subject: 'moral', grade: GradeLevel.mid, stageNumber: 8, name: '多様性リーダー', description: '多様性を受け入れられる！', emoji: '🌈', rarity: BadgeRarity.rare),
    LiteracyBadge(id: 'mor_9', subject: 'moral', grade: GradeLevel.mid, stageNumber: 9, name: '思いやり名人', description: '他者を思いやれる！', emoji: '💝', rarity: BadgeRarity.rare),
    LiteracyBadge(id: 'mor_10', subject: 'moral', grade: GradeLevel.high, stageNumber: 10, name: 'キャリアビルダー', description: 'キャリア意識を持てた！', emoji: '🎯', rarity: BadgeRarity.rare),
    LiteracyBadge(id: 'mor_11', subject: 'moral', grade: GradeLevel.high, stageNumber: 11, name: '倫理的思想家', description: '倫理的判断ができる！', emoji: '🤔', rarity: BadgeRarity.epic),
    LiteracyBadge(id: 'mor_12', subject: 'moral', grade: GradeLevel.high, stageNumber: 12, name: '夢実現者', description: '自己実現への道を歩む！', emoji: '✨', rarity: BadgeRarity.legendary),
  ];

  static List<LiteracyBadge> forSubject(String subject) {
    switch (subject) {
      case 'math': return math;
      case 'japanese': return japanese;
      case 'science': return science;
      case 'programming': return programming;
      case 'moral': return moral;
      default: return [];
    }
  }

  static LiteracyBadge? find(String subject, int stageNumber) {
    return forSubject(subject)
        .where((b) => b.stageNumber == stageNumber)
        .firstOrNull;
  }
}
