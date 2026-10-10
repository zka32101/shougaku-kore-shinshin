import '../../shop/decor/decor_scope.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import '../../../widgets/furigana_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../literacy_core/literacy_core.dart';
import '../data/activity_catalog.dart';
import '../data/taiku_questions.dart';
import '../taiku_app.dart';
import '../providers/taiku_providers.dart';
import '../providers/child_profiles_provider.dart';
import '../providers/sibling_quest_provider.dart';
import '../../../reward_assets.dart';
import 'activity_screen.dart';
import 'package:shougaku_kore_doutoku/widgets/ukalab_emoji.dart';
import 'package:shougaku_kore_doutoku/widgets/scroll_fill.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quiz = ref.read(quizNotifierProvider);
      if (quiz.accuracy >= 0.8) {
        _confetti.play();
        _checkAndAwardBadges(quiz);
      }
    });
  }

  void _checkAndAwardBadges(QuizState quiz) {
    final stage = ref.read(currentStageProvider);
    final progress = ref.read(taikuProgressProvider).valueOrNull;
    final streak = ref.read(streakProvider);
    final activityCount = ref.read(activityCountProvider);
    final notifier = ref.read(acquiredBadgesProvider.notifier);
    if (progress != null) {
      notifier.checkAndAwardBadges(
        progress: progress,
        stage: stage,
        accuracy: quiz.accuracy,
        streak: streak,
        activityCount: activityCount,
      );
    }
    // ストリーク更新
    ref.read(streakProvider.notifier).recordStudy(
      addMinutes: quiz.elapsedMinutes,
    );
    // ⑤ 兄弟クエスト進捗更新
    final currentProfile = ref.read(currentChildProfileProvider);
    if (currentProfile != null) {
      final theme = stageThemes[stage] ?? 'sports';
      ref.read(siblingQuestProvider.notifier).addProgress(
        currentProfile.id,
        theme,
      );
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = ref.watch(quizNotifierProvider);
    final stage = ref.watch(currentStageProvider);
    final grade = ref.watch(gradeLevelProvider);
    final theme = stageThemes[stage] ?? 'sports';
    final color = TaikuColors.forTheme(theme);

    final accuracy = quiz.accuracy;
    final isPerfect = accuracy >= 1.0;
    final isGood = accuracy >= 0.6;

    final emoji = isPerfect ? '🎉' : isGood ? '😊' : '💪';
    final message = grade == GradeLevel.low
        ? (isPerfect ? 'かんぺき！すごい！！' : isGood ? 'よくできたね！' : 'またちょうせんしよう！')
        : (isPerfect ? '完璧！全問正解！' : isGood ? 'よくできました！' : '次は頑張ろう！');

    return Scaffold(
      backgroundColor: DecorScope.pageBg(context, LiteracyColors.backgroundFor(grade)),
      body: Stack(
        children: [
          SafeArea(
            child: ScrollFill(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // 結果表示
                  UkalabEmoji(emoji, size: 72),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: grade == GradeLevel.low ? 24 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stageTitle[stage] ?? 'ステージ$stage',
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade600),
                  ),
                  if (isGood) ...[
                    const SizedBox(height: 12),
                    Image.asset(
                      rewardStickerAsset(
                          quiz.correctCount, quiz.questions.length),
                      key: const Key('reward_sticker'),
                      width: 72,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 12),
                  ] else
                    const SizedBox(height: 32),

                  // スコアカード
                  _ScoreCard(
                    correct: quiz.correctCount,
                    total: quiz.questions.length,
                    accuracy: accuracy,
                    color: color,
                    grade: grade,
                  ),
                  const SizedBox(height: 16),

                  // ステージまとめカード
                  _StageSummaryCard(stage: stage, grade: grade, color: color),
                  const SizedBox(height: 16),

                  // 実体験カード
                  _ActivitySuggestion(stage: stage, grade: grade, color: color),

                  const Spacer(),

                  // 実体験ボタン（活動がある場合のみ）
                  if (getActivitiesForStage(stage).isNotEmpty) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) =>
                                ActivityScreen(stage: stage),
                          ));
                        },
                        icon: const Icon(Icons.directions_run),
                        label: Text(
                          grade == GradeLevel.low
                              ? '🌟 じっさいにやってみよう！'
                              : '🌟 実体験チャレンジへ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // ボタン
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: color),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed('/quiz');
                          },
                          child: Text(
                            grade == GradeLevel.low
                                ? 'もう一回！'
                                : 'もう一度挑戦',
                            style: TextStyle(
                                color: color, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed('/home');
                          },
                          child: Text(
                            grade == GradeLevel.low
                                ? 'たいいくの トップへ'
                                : 'たいいくのトップに戻る',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 20,
              maxBlastForce: 15,
              minBlastForce: 5,
              emissionFrequency: 0.05,
              gravity: 0.2,
              colors: const [
                TaikuColors.sports,
                TaikuColors.disaster,
                TaikuColors.nutrition,
                TaikuColors.career,
                Colors.white,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final int correct;
  final int total;
  final double accuracy;
  final Color color;
  final GradeLevel grade;

  const _ScoreCard({
    required this.correct,
    required this.total,
    required this.accuracy,
    required this.color,
    required this.grade,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 12)
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ScoreStat(
            label: grade == GradeLevel.low ? 'せいかい' : '正解数',
            value: '$correct / $total',
            color: LiteracyColors.correct,
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          _ScoreStat(
            label: grade == GradeLevel.low ? 'せいかいりつ' : '正解率',
            value: '${(accuracy * 100).round()}%',
            color: color,
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          _ScoreStat(
            label: grade == GradeLevel.low ? 'ひょうか' : '評価',
            value: accuracy >= 1.0
                ? '⭐⭐⭐'
                : accuracy >= 0.6
                    ? '⭐⭐'
                    : '⭐',
            color: Colors.amber,
          ),
        ],
      ),
    );
  }
}

class _ScoreStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ScoreStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }
}

class _ActivitySuggestion extends StatelessWidget {
  final int stage;
  final GradeLevel grade;
  final Color color;

  const _ActivitySuggestion({
    required this.stage,
    required this.grade,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activity = _getActivity(stage);
    if (activity == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌟', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                grade == GradeLevel.low
                    ? 'じっさいに やってみよう！'
                    : '実体験チャレンジ！',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            activity,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  String? _getActivity(int stage) {
    const activities = {
      1: '家族でサッカーのルールクイズをしてみよう！',
      2: '今日10分間、外で体を動かしてみよう！',
      3: '今日の夕食の「三色食品群」を確認してみよう！',
      4: '友達と一緒に協力ゲームをやってみよう！',
      5: '家の防災グッズを家族で確認しよう！',
      6: 'プールや川に行くときのルールを家族で話し合おう！',
      7: '今日の食事の栄養バランスを振り返ろう！',
      8: '30分のウォーキング後に食事の記録をつけてみよう！',
      9: '「なりたい仕事」を1つ決めて調べてみよう！',
      10: 'スポーツ中継を見て、動きを分析してみよう！',
      11: '「自分の健康目標」を1つ立ててみよう！',
      12: 'パラスポーツをYouTubeで見て感想を話し合おう！',
      13: '今夜の就寝時間と起床時間を決めて実行しよう！',
      14: '「嬉しかったこと」を3つ日記に書いてみよう！',
      15: '正しい手洗いの30秒を家族で練習しよう！',
      16: 'いえのなかのきけんなものを家族でさがして、ちゃんとしまおう！',
      17: '「いかのおすし」を家族で声に出して練習しよう！',
      18: '家族の緊急連絡先の電話番号を3つ覚えよう！',
      19: '家のごみを今日から種類ごとに正しく分別してみよう！',
      20: '今月のお小遣い帳を作って、1週間つけてみよう！',
      21: '「ありがとう」を今日5人に伝えてみよう！',
      22: '家でできるエコ活動を3つ選んで実践してみよう！',
      23: '1日の電気使用量をチェックして節電できる場所を探そう！',
      24: '銀行口座の通帳（もしあれば）で利息がつく仕組みを確認しよう！',
      25: '近所の公共施設（図書館・公園等）税金で作られているか確認しよう！',
      26: '身近にある「バリアフリー」の工夫を5つ探してみよう！',
      27: '広島・長崎の被爆体験について家族と話し合ってみよう！',
    };
    return activities[stage];
  }
}

// ─── ステージまとめカード ───

const _stageSummaries = <int, List<(String, String)>>{
  1: [
    ('⚖️', 'ルールがあるからスポーツは公平に楽しめる'),
    ('👩‍⚖️', '審判はフェアな試合を守る大切な役割'),
    ('🤝', 'フェアプレーの精神がスポーツを豊かにする'),
  ],
  2: [
    ('🔥', 'ウォームアップで体温を上げて怪我を防ぐ'),
    ('💨', '有酸素運動で心肺機能を鍛えることができる'),
    ('❄️', 'クールダウンで疲労物質を早く流す'),
  ],
  3: [
    ('🍚', '運動前は糖質（グリコーゲン）を蓄えることが重要'),
    ('🥩', '運動後30分以内のタンパク質補給が筋肉を回復させる'),
    ('💧', '水分補給を忘れると集中力・体力が大幅に落ちる'),
  ],
  4: [
    ('📋', 'フォーメーションはチームの作戦の基本'),
    ('📣', 'コミュニケーションがチームを強くする'),
    ('🤝', '個人の得意を活かした連携がチームワークの鍵'),
  ],
  5: [
    ('🗺️', 'ハザードマップで自宅周辺の危険を把握しよう'),
    ('🎒', '非常用持ち出し袋は今すぐ準備できる最高の備え'),
    ('👥', '自助→共助→公助の順で助け合うことが防災の基本'),
  ],
  6: [
    ('🌊', '「ういてまつ」が命を救う最初の行動'),
    ('⚡', 'AEDは自動で使える。迷わず使って命を救う'),
    ('🫀', '心肺蘇生法（CPR）は毎分100〜120回のペース'),
  ],
  7: [
    ('🍽️', '三大栄養素（糖質・脂質・タンパク質）がエネルギーと体を作る'),
    ('🥦', 'ビタミン・ミネラルで体の調子を整える'),
    ('🌱', '食育は「食を通じて命・健康・文化を学ぶ」教育'),
  ],
  8: [
    ('💪', 'トレーニング後の「超回復」で筋肉が成長する'),
    ('😴', '良質な睡眠が成長ホルモンを分泌させ体を強くする'),
    ('🍱', 'PFCバランスを意識した食事がアスリートの基本'),
  ],
  9: [
    ('🔭', 'スポーツ業界の職業は選手以外にも数十種類ある'),
    ('📊', 'スポーツアナリストがデータで試合を変える'),
    ('🎯', 'デュアルキャリアで競技と人生を両立できる'),
  ],
  10: [
    ('📡', 'GPSとセンサーが選手の動きをリアルタイム計測'),
    ('🔬', 'バイオメカニクスで最も効率的な動きを科学的に分析'),
    ('🧠', 'スポーツ心理学で「ゾーン」状態を引き出せる'),
  ],
  11: [
    ('🌟', 'ライフスキルはスポーツで磨ける一生使える能力'),
    ('🪴', 'レジリエンス（回復力）が困難を乗り越える力になる'),
    ('❤️', '生涯スポーツで健康寿命を延ばすことができる'),
  ],
  12: [
    ('🏅', 'オリンピック精神「より速く・より高く・より強く・共に」'),
    ('♿', 'パラリンピックが「全ての人のスポーツ」を証明する'),
    ('🤖', 'AIがスポーツの戦術・審判・トレーニングを進化させている'),
  ],
  13: [
    ('🌙', '子どもに必要な睡眠は9〜11時間。成長ホルモンは深い眠りで出る'),
    ('📱', 'スマホのブルーライトはメラトニンを減らし睡眠の質を下げる'),
    ('☀️', '朝に日光を浴びると体内時計がリセットされ生活リズムが整う'),
  ],
  14: [
    ('😤', '怒りを感じたら6秒待つ。衝動的な行動を防ぐアンガーマネジメント'),
    ('🧘', 'マインドフルネス・深呼吸が副交感神経を優位にしリラックスさせる'),
    ('💪', '失敗から立ち直る「レジリエンス」は練習で育てられる能力'),
  ],
  15: [
    ('🦠', '感染症予防の三原則：感染源を絶つ・経路を絶つ・抵抗力を高める'),
    ('💉', 'ワクチンは弱めた病原体で免疫記憶を作る最も効果的な予防法'),
    ('🦷', '虫歯は菌が糖から酸を作り歯を溶かすことで発生。フッ素で予防'),
  ],
  16: [
    ('⚠️', '火・刃物・電気は「必ずおとなと」が鉄則。一人で使わない'),
    ('🚿', 'やけどはすぐに流水で10〜20分冷やす。バター・氷の直接当てはNG'),
    ('🔒', '鍵・プライベートゾーン・知らない人からのお菓子——家族の秘密を守る'),
  ],
  17: [
    ('🚸', '「いかのおすし」：いかない・乗らない・大声・すぐ逃げる・知らせる'),
    ('📵', 'SNSに個人情報（住所・学校・顔）を投稿しない。ネットの友達は知らない人'),
    ('🤝', '「秘密にして」と言われた体への接触は必ず信頼できる大人に話す'),
  ],
  18: [
    ('📞', '119番=火事・救急、110番=犯罪・事故。まず場所と状況を伝える'),
    ('⚡', 'AEDは音声ガイドに従えば誰でも使える。ためらわず使って命を救う'),
    ('🫀', '心肺蘇生法（CPR）は胸の真ん中を1分100〜120回。救急隊が来るまで続ける'),
  ],
  19: [
    ('🌡️', '地球の平均気温は産業革命以降約1.1℃上昇。このペースが続くと深刻な影響が出る'),
    ('♻️', 'SDGsは「誰一人取り残さない」社会のための17の世界共通目標（2030年まで）'),
    ('🌊', 'プラスチックごみは海の生き物から食物連鎖で人間にも影響。エコバッグが大切'),
  ],
  20: [
    ('💴', 'お金は物々交換の不便さを解消するために生まれた「交換の道具」'),
    ('🏦', '銀行に預けると安全に保管され利子がつく。早めの貯金が将来を豊かにする'),
    ('📊', 'ニーズ（必要なもの）を先に確保してからウォンツ（欲しいもの）を考えるのが賢い使い方'),
  ],
  21: [
    ('🤝', '人権はすべての人が生まれながらに持つ普遍的な権利。誰にも奪えない'),
    ('🌈', '多様性を認め合うことで、社会はもっと豊かになる。違いは強さ'),
    ('💬', '嘘をつかず・約束を守り・共感する心が、信頼関係と良い社会の基盤'),
  ],
  22: [
    ('♻️', '3R（リデュース・リユース・リサイクル）が資源を無駄にしない基本'),
    ('🌍', 'SDGsの17目標は「誰一人取り残さない」持続可能な世界への道標'),
    ('🍱', 'フードロス削減と「もったいない」精神が地球と食料問題の解決につながる'),
  ],
  23: [
    ('🌡️', '地球温暖化はCO2増加が主因で、海面上昇・異常気象を引き起こす'),
    ('☀️', '再生可能エネルギーへの転換がカーボンニュートラル実現の鍵'),
    ('🌊', 'マイクロプラスチックは食物連鎖を通じて人間にも影響する深刻な問題'),
  ],
  24: [
    ('💹', '複利の力で長期投資の効果は雪だるま式に大きくなる'),
    ('📉', '分散投資でリスクを管理し、インフレから資産を守る'),
    ('📱', 'フィンテックが金融サービスを民主化し、誰もがアクセスしやすくなった'),
  ],
  25: [
    ('🏛️', '税金は道路・学校・医療など社会の基盤を支える「社会の会費」'),
    ('👴', '年金・社会保険は世代を超えた助け合いで日本社会を支える柱'),
    ('📊', 'GDP・累進課税・財政を理解することが民主主義社会の市民として重要'),
  ],
  26: [
    ('✊', '人権はすべての人が持つ権利。差別・偏見はその尊厳を侵害する'),
    ('👁️', 'アンコンシャス・バイアスに気づくことが平等な社会への第一歩'),
    ('🌏', '難民・LGBTQ+・障がい者の権利を守ることが真の多様性ある社会の実現'),
  ],
  27: [
    ('🕊️', '平和は「戦争がない」だけでなく、構造的暴力・貧困・差別もない状態'),
    ('☢️', '核兵器の廃絶と被爆体験の継承が唯一の被爆国日本の使命'),
    ('🤲', '対話・交渉・仲裁で紛争を解決し、平和を構築することが市民の責任'),
  ],
  28: [
    ('🎨', '色の三原色を混ぜると様々な色が作れる。補色を使うと絵が引き立つ'),
    ('🖼️', '遠近法を使うと絵に奥行きが生まれ、印象派は光の瞬間を捉えた'),
    ('✨', '美術鑑賞では作者の意図・時代背景を考えることで理解が深まる'),
  ],
  29: [
    ('✂️', 'はさみ・ボンド・粘土など道具の正しい使い方と安全が工作の基本'),
    ('🏛️', 'バウハウスは芸術と機能を統合。著作権は作者の権利を守る大切な仕組み'),
    ('🌟', 'インスタレーション・パブリックアートなど現代アートは空間全体を使う表現'),
  ],
  30: [
    ('🎵', 'ドレミは7つの音。音符は音の長さを示し、テンポは速さを表す'),
    ('🎤', '腹式呼吸で歌い、タンギングでリコーダーの音をはっきり出す'),
    ('🎼', '和音・転調・音楽の三要素を理解すると音楽がもっと楽しくなる'),
  ],
  31: [
    ('🎸', 'バイオリン4弦・ピアノ88鍵・金管楽器は唇の振動で音を出す'),
    ('🌍', 'ジャズはアメリカ生まれ・雅楽は日本の宮廷音楽。世界の音楽は多様'),
    ('🎭', '長調は明るく短調は暗い。即興演奏はジャズの魂、交響曲は4楽章で構成'),
  ],
  32: [
    ('🍽️', '一汁三菜は和食の基本スタイル。旬の食材は栄養価が高くおいしい'),
    ('🥗', '五大栄養素をバランスよく。食中毒予防は手洗い・温度管理・加熱が基本'),
    ('🌱', 'フードロス削減・地産地消は食と環境を守る大切な行動'),
  ],
  33: [
    ('🧵', '玉結び・なみ縫い・ボタン付けを覚えると衣類を自分で直せる'),
    ('🏠', '整理整頓・掃除・家事分担は快適で安全な家づくりの基本'),
    ('♻️', 'エコな生活・サステナブルファッション・住まいの安全が現代の家庭科'),
  ],
  34: [
    ('💡', 'プログラムは順次・分岐・繰り返しの3構造でできている'),
    ('🤖', 'AIは大量のデータから学習する。IoTはあらゆる機器がネットでつながる世界'),
    ('🧠', 'プログラミング的思考は問題を分解して手順を考える力。全ての問題解決に役立つ'),
  ],
  35: [
    ('🔐', 'パスワードは長く複雑に。個人情報はネットで公開しない'),
    ('⚠️', 'フィッシング詐欺・マルウェア・ネットいじめから身を守る知識が大切'),
    ('🌐', 'AI倫理・デジタルデバイド・デジタルウェルビーイングが現代社会の重要課題'),
  ],
};

class _StageSummaryCard extends StatelessWidget {
  final int stage;
  final GradeLevel grade;
  final Color color;

  const _StageSummaryCard({
    required this.stage,
    required this.grade,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final summaries = _stageSummaries[stage];
    if (summaries == null) return const SizedBox.shrink();
    final isLow = grade == GradeLevel.low;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_rounded, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                isLow ? 'このステージで まなんだこと' : 'このステージの学びまとめ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final (emoji, text) in summaries) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UkalabEmoji(emoji, size: 15),
                const SizedBox(width: 8),
                Expanded(
                  child: FuriganaText(
                    text,
                    style: TextStyle(
                      fontSize: isLow ? 12 : 11.5,
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

// acquiredBadgesNotifier を再公開
final acquiredBadgesNotifier = acquiredBadgesProvider;
