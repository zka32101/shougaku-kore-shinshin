enum HomeEcTopic { tidying, cleaning, shopping, chores, eco }

class HomeEcActivity {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final bool completed;
  final DateTime? completedAt;
  final List<String> photoPaths;
  final String? notes;

  const HomeEcActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.completed = false,
    this.completedAt,
    this.photoPaths = const [],
    this.notes,
  });

  HomeEcActivity copyWith({
    String? id,
    String? title,
    String? description,
    String? emoji,
    bool? completed,
    DateTime? completedAt,
    List<String>? photoPaths,
    String? notes,
  }) => HomeEcActivity(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    emoji: emoji ?? this.emoji,
    completed: completed ?? this.completed,
    completedAt: completedAt ?? this.completedAt,
    photoPaths: photoPaths ?? this.photoPaths,
    notes: notes ?? this.notes,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'emoji': emoji,
    'completed': completed,
    'completedAt': completedAt?.toIso8601String(),
    'photoPaths': photoPaths,
    'notes': notes,
  };

  factory HomeEcActivity.fromJson(Map<String, dynamic> j) => HomeEcActivity(
    id: j['id'] as String,
    title: j['title'] as String,
    description: j['description'] as String,
    emoji: j['emoji'] as String,
    completed: j['completed'] as bool? ?? false,
    completedAt: j['completedAt'] != null ? DateTime.parse(j['completedAt'] as String) : null,
    photoPaths: List<String>.from(j['photoPaths'] ?? []),
    notes: j['notes'] as String?,
  );
}

class HomeEcTopicData {
  final HomeEcTopic id;
  final String emoji;
  final String name;
  final String why;
  final List<String> whyPoints;
  final List<HomeEcActivity> activities;

  const HomeEcTopicData({
    required this.id,
    required this.emoji,
    required this.name,
    required this.why,
    required this.whyPoints,
    required this.activities,
  });
}

// トピック定義
final homeEcTopics = {
  HomeEcTopic.tidying: HomeEcTopicData(
    id: HomeEcTopic.tidying,
    emoji: '🗂️',
    name: '整理整頓',
    why: '整理整頓は「考える力」を育てます',
    whyPoints: [
      '物の場所を決めることで、「どこに何があるか」を論理的に考える力が育ちます',
      'きれいな空間では集中力が高まり、勉強や遊びの効率がアップします',
      '不要な物を手放す判断力は、大人になっても必要な「決断力」の練習です',
      '自分の部屋を管理することで、自立心と責任感が芽生えます',
    ],
    activities: [
      HomeEcActivity(id: 'sort', title: '持ち物を「必要・不要」に分ける', description: '1年使っていない物はどうする？考えてみよう', emoji: '📦'),
      HomeEcActivity(id: 'place', title: '物の定位置を決める', description: '「ここに戻す」を決めると片付けが楽になる', emoji: '📍'),
      HomeEcActivity(id: 'label', title: '引き出し・棚にラベルを貼る', description: 'どこに何があるか一目でわかるようにしよう', emoji: '🏷️'),
      HomeEcActivity(id: 'desk', title: '学習机を整理する', description: '毎日使う場所だから特にきれいに！', emoji: '📚'),
      HomeEcActivity(id: 'report', title: '家族に「整理整頓した場所」を報告する', description: 'どこをどう片付けたか伝えてみよう', emoji: '💬'),
    ],
  ),
  HomeEcTopic.cleaning: HomeEcTopicData(
    id: HomeEcTopic.cleaning,
    emoji: '🧹',
    name: '清掃',
    why: '清掃は「健康」と「感謝の心」を育てます',
    whyPoints: [
      '清潔な環境はウイルスや細菌を減らし、家族全員の健康を守ります',
      '汚れに気づいて掃除する習慣は、問題発見能力（注意力）を鍛えます',
      '家を掃除することで「住む場所を大切にする心」と家族への感謝が生まれます',
      '掃除道具の正しい使い方を学ぶことで、安全に作業する力が育ちます',
    ],
    activities: [
      HomeEcActivity(id: 'sweep', title: '床の掃き掃除をする', description: 'ほうきやモップで床をきれいにしよう', emoji: '🧹'),
      HomeEcActivity(id: 'wipe', title: 'テーブルや窓を拭き掃除する', description: '雑巾を絞る力加減も練習！', emoji: '🧽'),
      HomeEcActivity(id: 'vacuum', title: '掃除機をかける', description: '隅までしっかりかけるとピカピカ！', emoji: '🌀'),
      HomeEcActivity(id: 'bathroom', title: '洗面台・シンクを磨く', description: '水垢はどうすれば落ちる？調べてみよう', emoji: '🚿'),
      HomeEcActivity(id: 'schedule', title: '1週間の清掃スケジュールを作る', description: 'どの曜日に何を掃除するか計画しよう', emoji: '📅'),
    ],
  ),
  HomeEcTopic.shopping: HomeEcTopicData(
    id: HomeEcTopic.shopping,
    emoji: '🛒',
    name: '買い物とお金',
    why: 'お金の知識は「賢い判断力」を育てます',
    whyPoints: [
      'お金の価値を知ることで、物を大切にする気持ちと感謝の心が育ちます',
      '予算を立てて買い物する習慣は、目標に向けて計画する力の基礎になります',
      '比較して買う力（消費者リテラシー）は、将来の生活を豊かにします',
      'おつりの計算などの実践的な算数は、生きた学びになります',
    ],
    activities: [
      HomeEcActivity(id: 'list', title: '買い物リストを作って買いに行く', description: '何が必要かリストアップしてから買おう', emoji: '📋'),
      HomeEcActivity(id: 'budget', title: '500円でおやつを買う', description: '予算内でどれが一番お得？計算してみよう', emoji: '💴'),
      HomeEcActivity(id: 'compare', title: '同じ商品で値段を比べる', description: 'スーパーとコンビニ、どちらが安い？', emoji: '🔍'),
      HomeEcActivity(id: 'change', title: 'おつりを暗算で確かめる', description: '1000円で480円買ったらおつりは？', emoji: '🧮'),
      HomeEcActivity(id: 'save', title: '1週間のお小遣い帳をつける', description: '何にいくら使ったか記録しよう', emoji: '📒'),
    ],
  ),
  HomeEcTopic.chores: HomeEcTopicData(
    id: HomeEcTopic.chores,
    emoji: '🍳',
    name: '家庭の仕事',
    why: '家庭の仕事は「協力する心」と「生きる力」を育てます',
    whyPoints: [
      '料理・洗濯・食器洗いは、一人暮らしになっても絶対に必要なスキルです',
      '家族の仕事を分担することで「みんなで支え合う」という協力の精神が育ちます',
      '手伝いを通じて家族への感謝が深まり、思いやりの心が豊かになります',
      '包丁や火の扱いなど、安全管理の知識も日常生活で非常に大切です',
    ],
    activities: [
      HomeEcActivity(id: 'cooking', title: '簡単な料理を1品作る', description: 'サラダ・卵料理など、簡単なものから挑戦！', emoji: '🍳'),
      HomeEcActivity(id: 'dishes', title: '食器を洗って片付ける', description: '食後は自分の食器くらい洗えると◎', emoji: '🍽️'),
      HomeEcActivity(id: 'laundry', title: '洗濯物をたたんで片付ける', description: 'Tシャツやタオルのたたみ方を覚えよう', emoji: '👕'),
      HomeEcActivity(id: 'groceries', title: '食材の買い出しを手伝う', description: '何が必要かリストを見ながら選ぼう', emoji: '🛍️'),
      HomeEcActivity(id: 'plan', title: '1日の家族の食事メニューを提案する', description: 'バランスを考えてメニューを考えてみよう', emoji: '📝'),
    ],
  ),
  HomeEcTopic.eco: HomeEcTopicData(
    id: HomeEcTopic.eco,
    emoji: '🌱',
    name: '環境の配慮',
    why: '環境への配慮は「地球市民の責任」を育てます',
    whyPoints: [
      '地球温暖化や資源不足は今の子どもたちが大人になる頃に直面する問題です',
      'ゴミの分別・節電・節水などの小さな行動が地球を守る大きな力になります',
      '環境問題を学ぶことで、科学的な思考力と問題解決力が育ちます',
      'エコな行動を選ぶ力は、将来の消費行動や職業選択にも影響します',
    ],
    activities: [
      HomeEcActivity(id: 'recycle', title: 'ゴミを分別して捨てる', description: 'どの種類にゴミを分けるか理解しよう', emoji: '♻️'),
      HomeEcActivity(id: 'save_water', title: 'シャワー時間を短縮する', description: '1分短縮で、お水がどれだけ救える？', emoji: '💧'),
      HomeEcActivity(id: 'save_electricity', title: '電気を消す習慣をつける', description: '使わない部屋の電気は消そう', emoji: '💡'),
      HomeEcActivity(id: 'eco_shop', title: 'エコバッグを持ってお買い物', description: 'レジ袋をもらわないようにしよう', emoji: '🛍️'),
      HomeEcActivity(id: 'plant', title: '植物を育てる、または学ぶ', description: '自然と触れ合って環境の大切さを感じよう', emoji: '🌿'),
    ],
  ),
};
