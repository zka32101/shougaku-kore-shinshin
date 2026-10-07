import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../literacy_core/literacy_core.dart';
import '../taiku_app.dart';
import '../providers/taiku_providers.dart';
import 'stage_learn_screen.dart';
import 'package:shougaku_kore_doutoku/widgets/ukalab_emoji.dart';

// ─── 全般説明画面（まなびのぜんたいマップ）───

class GeneralOverviewScreen extends ConsumerWidget {
  const GeneralOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grade = ref.watch(gradeLevelProvider);
    final isLow = grade == GradeLevel.low;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _OverviewAppBar(isLow: isLow),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _StatsBar(isLow: isLow),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _ThemeOverviewCard(
                        theme: 'sports',
                        color: TaikuColors.sports,
                        headerEmoji: '⚽',
                        headerTitle: isLow ? 'スポーツ' : 'スポーツ',
                        headerSub: isLow
                            ? 'たいいく・うんどうの きほんを まなぼう'
                            : '体育・運動の基礎から応用まで学ぼう',
                        gradeLabel: isLow ? 'しょうがく 1〜4ねん' : '小学1〜4年',
                        keypoints: isLow
                            ? [
                                'スポーツの ルールを しろう',
                                'からだを うごかす たのしさ',
                                'なかまと いっしょに あそぼう',
                                'じぶんの からだを しろう',
                              ]
                            : [
                                'スポーツの基本ルールと審判の仕組み',
                                '体を動かすことの健康効果',
                                'チームワークとフェアプレー精神',
                                'ウォームアップ・クールダウンの科学',
                              ],
                        stages: const [
                          _StageInfo(1, '⚽', 'スポーツのルール', GradeLevel.low),
                          _StageInfo(2, '🤸', 'からだを動かそう', GradeLevel.low),
                          _StageInfo(4, '👥', 'チームスポーツ', GradeLevel.mid),
                        ],
                        grade: grade,
                      ),
                      const SizedBox(height: 16),
                      _ThemeOverviewCard(
                        theme: 'disaster',
                        color: TaikuColors.disaster,
                        headerEmoji: '🛡️',
                        headerTitle: isLow ? 'ぼうさい・あんぜん' : '防災・安全',
                        headerSub: isLow
                            ? 'じぶんの いのちを まもる ちしきを まなぼう'
                            : '命を守る知識と行動を身につけよう',
                        gradeLabel: isLow ? 'しょうがく 3〜4ねん' : '小学3〜4年',
                        keypoints: isLow
                            ? [
                                'じしんや たいふうの とき どうする？',
                                'みずのそばでの あんぜん',
                                'ひなんする ばしょを しろう',
                                'AEDの つかいかた',
                              ]
                            : [
                                'ハザードマップで危険箇所を把握する',
                                '自助・共助・公助の役割分担',
                                '水難事故の予防と救助の基本',
                                'AEDの正しい使い方と心肺蘇生法',
                              ],
                        stages: const [
                          _StageInfo(5, '🛡️', '防災の基本', GradeLevel.mid),
                          _StageInfo(6, '🌊', '水の安全・救助', GradeLevel.mid),
                        ],
                        grade: grade,
                      ),
                      const SizedBox(height: 16),
                      _ThemeOverviewCard(
                        theme: 'nutrition',
                        color: TaikuColors.nutrition,
                        headerEmoji: '🥗',
                        headerTitle: isLow ? 'えいよう・けんこう' : '栄養・健康',
                        headerSub: isLow
                            ? 'たべもので からだを つよくしよう'
                            : '食事と体の関係を科学的に理解しよう',
                        gradeLabel: isLow ? 'しょうがく 3〜6ねん' : '小学3〜6年',
                        keypoints: isLow
                            ? [
                                'バランスのよい しょくじを しろう',
                                'スポーツのまえの たべかた',
                                'みずを のむ だいじさ',
                                'やさいや くだものの ちから',
                              ]
                            : [
                                '三大栄養素（炭水化物・タンパク質・脂質）の役割',
                                'グリコーゲンと運動エネルギーの関係',
                                '食育の意義と食品ロス削減',
                                'アスリートの食事管理と睡眠の科学',
                              ],
                        stages: const [
                          _StageInfo(3, '🥗', 'スポーツと栄養', GradeLevel.mid),
                          _StageInfo(7, '🍎', '栄養と健康', GradeLevel.mid),
                          _StageInfo(8, '💪', '食事とトレーニング', GradeLevel.high),
                        ],
                        grade: grade,
                      ),
                      const SizedBox(height: 16),
                      _ThemeOverviewCard(
                        theme: 'career',
                        color: TaikuColors.career,
                        headerEmoji: '⭐',
                        headerTitle: isLow ? 'しごと・みらい' : 'キャリア・未来',
                        headerSub: isLow
                            ? 'スポーツに かんけいする しごとを しろう'
                            : 'スポーツ科学とキャリアの可能性を探ろう',
                        gradeLabel: isLow ? 'しょうがく 5〜6ねん' : '小学5〜6年',
                        keypoints: isLow
                            ? [
                                'スポーツに かんけいする しごと',
                                'かがくで スポーツが わかる',
                                'けんこうな からだで ながいきしよう',
                                'せかいの スポーツを しろう',
                              ]
                            : [
                                'スポーツ解説者・審判・科学者などの職業',
                                '筋電図（EMG）・GPS・AIなどスポーツテクノロジー',
                                'ライフスキルと生涯スポーツの考え方',
                                'デュアルキャリアとグローバルなスポーツ外交',
                              ],
                        stages: const [
                          _StageInfo(9, '🔭', 'キャリア探索', GradeLevel.high),
                          _StageInfo(10, '🔬', 'スポーツ科学', GradeLevel.high),
                          _StageInfo(11, '🌟', '健康とキャリア総合', GradeLevel.high),
                          _StageInfo(12, '🌍', 'グローバルスポーツ・未来', GradeLevel.high),
                        ],
                        grade: grade,
                      ),
                      const SizedBox(height: 16),
                      _ThemeOverviewCard(
                        theme: 'health',
                        color: TaikuColors.health,
                        headerEmoji: '🏥',
                        headerTitle: isLow ? 'けんこう かんり' : 'けんこう管理',
                        headerSub: isLow
                            ? 'ねること・こころ・びょうきのよぼうを まなぼう'
                            : '睡眠・メンタル・病気予防の保健リテラシーを身につけよう',
                        gradeLabel: isLow ? 'しょうがく 1〜6ねん' : '小学1〜6年',
                        keypoints: isLow
                            ? [
                                'ねることで からだと あたまが なおる',
                                'ストレスの たいしょほうを おぼえよう',
                                'てあらいで びょうきをふせごう',
                                'バランスよい せいかつが けんこうのもと',
                              ]
                            : [
                                '睡眠と成長ホルモン・体内時計・睡眠負債の科学',
                                'セロトニン・レジリエンス・マインドフルネスによるメンタル管理',
                                '感染症予防の三原則とワクチンの仕組み',
                                '生活習慣病・受動喫煙・薬物乱用防止の知識',
                              ],
                        stages: const [
                          _StageInfo(13, '🌙', '睡眠と健康', GradeLevel.mid),
                          _StageInfo(14, '💆', '心の健康・ストレス', GradeLevel.mid),
                          _StageInfo(15, '🦠', '病気の予防・衛生', GradeLevel.mid),
                        ],
                        grade: grade,
                      ),
                      const SizedBox(height: 16),
                      _ThemeOverviewCard(
                        theme: 'safety',
                        color: TaikuColors.safety,
                        headerEmoji: '🚨',
                        headerTitle: isLow ? 'あんぜん・ぼうはん' : '安全・防犯',
                        headerSub: isLow
                            ? 'きけんをしって、じぶんとなかまをまもろう'
                            : '危険・犯罪・緊急時の対応力を身につけよう',
                        gradeLabel: isLow ? 'しょうがく 1〜6ねん' : '小学1〜6年',
                        keypoints: isLow
                            ? [
                                'ひや はさみ・でんきの きけんを しろう',
                                'しらないひとに ついていかない',
                                '119ばん・110ばんの かけかた',
                                'じぶんとなかまをまもるちしき',
                              ]
                            : [
                                '家庭内の危険物の正しい扱いと応急手当',
                                '不審者対応（いかのおすし）とSNS被害の防止',
                                'AED・CPR・止血などの緊急救命処置',
                                '119番・110番の正しい使い方と地震・火事の避難行動',
                              ],
                        stages: const [
                          _StageInfo(16, '⚠️', '危険なものから身を守る', GradeLevel.low),
                          _StageInfo(17, '🚨', '犯罪から身を守る', GradeLevel.mid),
                          _StageInfo(18, '🆘', '緊急時の対応', GradeLevel.high),
                        ],
                        grade: grade,
                      ),
                      const SizedBox(height: 16),
                      _ThemeOverviewCard(
                        theme: 'environment',
                        color: TaikuColors.environment,
                        headerEmoji: '🌱',
                        headerTitle: isLow ? 'かんきょう・ちきゅう' : '環境・SDGs',
                        headerSub: isLow
                            ? 'ちきゅうをまもるためにできることを まなぼう'
                            : '地球温暖化・SDGs・生物多様性・プラ問題を学ぼう',
                        gradeLabel: isLow ? 'しょうがく 3〜6ねん' : '小学3〜6年',
                        keypoints: isLow
                            ? [
                                'CO2が ふえると ちきゅうが あたたかくなる',
                                'ごみをわけると リサイクルできる',
                                'エコバッグで プラごみをへらそう',
                                'SDGsは せかい17のもくひょう',
                              ]
                            : [
                                '温室効果ガスと地球温暖化のメカニズム',
                                'SDGs17目標と自分たちにできること',
                                'プラスチック問題と食品ロスの実態',
                                '再生可能エネルギーとカーボンニュートラル',
                              ],
                        stages: const [
                          _StageInfo(19, '🌱', '環境・地球をまもろう', GradeLevel.mid),
                        ],
                        grade: grade,
                      ),
                      const SizedBox(height: 16),
                      _ThemeOverviewCard(
                        theme: 'money',
                        color: TaikuColors.money,
                        headerEmoji: '💰',
                        headerTitle: isLow ? 'お金のきほん' : 'お金・金融リテラシー',
                        headerSub: isLow
                            ? 'お金のつかいかたと たいせつさを まなぼう'
                            : 'お金の役割・貯蓄・税金・投資の基礎を身につけよう',
                        gradeLabel: isLow ? 'しょうがく 1〜6ねん' : '小学1〜6年',
                        keypoints: isLow
                            ? [
                                'お金は ひとのやくにたつことで もらえる',
                                'ほしいものより ひつようなものをさきに',
                                'ちょきんすると つかいたいときに つかえる',
                                'しょうひぜいは みんなのために つかわれる',
                              ]
                            : [
                                'ニーズとウォンツ（必要なものと欲しいもの）の区別',
                                '税金の仕組みと社会への役割',
                                '複利の力・早めに始める貯蓄の重要性',
                                'キャッシュレス決済の仕組みとリスク',
                              ],
                        stages: const [
                          _StageInfo(20, '💰', 'お金のきほん', GradeLevel.low),
                        ],
                        grade: grade,
                      ),
                      const SizedBox(height: 16),
                      _ThemeOverviewCard(
                        theme: 'values',
                        color: TaikuColors.values,
                        headerEmoji: '🤝',
                        headerTitle: isLow ? 'どうとく・たいせつなこと' : '道徳・人権・多様性',
                        headerSub: isLow
                            ? 'ひとのきもちをかんがえて、やさしくなろう'
                            : '人権・差別・多様性・共感力・公正さを学ぼう',
                        gradeLabel: isLow ? 'しょうがく 1〜6ねん' : '小学1〜6年',
                        keypoints: isLow
                            ? [
                                'いじめは ぜったいに ダメ',
                                'みんなちがって、みんないい（多様性）',
                                'うそをつかず、やくそくをまもる',
                                'ひとのきもちをかんがえよう',
                              ]
                            : [
                                'いじめ・差別は被害者に一切の責任がない',
                                'LGBTQ+・障がい・異文化への正しい理解',
                                '人権・ボランティア・民主的な対話',
                                '公正・公平・約束を守ることの社会的意義',
                              ],
                        stages: const [
                          _StageInfo(21, '🤝', '道徳・たがいにそんちょう', GradeLevel.mid),
                        ],
                        grade: grade,
                      ),
                      const SizedBox(height: 32),
                      _LearningFlowSection(isLow: isLow),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ヘッダー ───

class _OverviewAppBar extends StatelessWidget {
  final bool isLow;
  const _OverviewAppBar({required this.isLow});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0277BD),
                Color(0xFF1B5E20),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 46, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Text('📖', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isLow ? 'まなびの ぜんたい マップ' : 'まなびの全体マップ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              isLow
                                  ? '13つのテーマ・35ステージ・525もん'
                                  : '13テーマ・35ステージ・全525問の学習内容',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 9テーマチップ行
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: [
                      _HeaderChip('⚽', 'スポーツ', TaikuColors.sports),
                      _HeaderChip('🛡️', '防災', TaikuColors.disaster),
                      _HeaderChip('🥗', '栄養', TaikuColors.nutrition),
                      _HeaderChip('⭐', 'キャリア', TaikuColors.career),
                      _HeaderChip('🏥', 'けんこう', TaikuColors.health),
                      _HeaderChip('🚨', '安全', TaikuColors.safety),
                      _HeaderChip('🌱', '環境', TaikuColors.environment),
                      _HeaderChip('💰', 'お金', TaikuColors.money),
                      _HeaderChip('🤝', '道徳', TaikuColors.values),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  const _HeaderChip(this.emoji, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UkalabEmoji(emoji, size: 12),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 統計バー ───

class _StatsBar extends StatelessWidget {
  final bool isLow;
  const _StatsBar({required this.isLow});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem('13', isLow ? 'テーマ' : 'テーマ', Icons.category_outlined,
              const Color(0xFF6A1B9A)),
          _Divider(),
          _StatItem('35', isLow ? 'ステージ' : 'ステージ',
              Icons.layers_outlined, TaikuColors.primary),
          _Divider(),
          _StatItem('525', isLow ? 'もん' : '問', Icons.quiz_outlined,
              TaikuColors.nutrition),
          _Divider(),
          _StatItem('3', isLow ? 'がくねん' : '学年帯',
              Icons.school_outlined, TaikuColors.disaster),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _StatItem(this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey.shade200,
    );
  }
}

// ─── テーマ全般説明カード ───

class _StageInfo {
  final int num;
  final String emoji;
  final String title;
  final GradeLevel gradeLevel;
  const _StageInfo(this.num, this.emoji, this.title, this.gradeLevel);
}

class _ThemeOverviewCard extends ConsumerWidget {
  final String theme;
  final Color color;
  final String headerEmoji;
  final String headerTitle;
  final String headerSub;
  final String gradeLabel;
  final List<String> keypoints;
  final List<_StageInfo> stages;
  final GradeLevel grade;

  const _ThemeOverviewCard({
    required this.theme,
    required this.color,
    required this.headerEmoji,
    required this.headerTitle,
    required this.headerSub,
    required this.gradeLabel,
    required this.keypoints,
    required this.stages,
    required this.grade,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLow = grade == GradeLevel.low;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── テーマヘッダー ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.75)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                UkalabEmoji(headerEmoji, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        headerTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        headerSub,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    gradeLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── まなびのポイント ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: color, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      isLow ? 'まなびの ポイント' : 'まなびのポイント',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (int i = 0; i < keypoints.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            keypoints[i],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade800,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade100),

          // ── ステージ一覧 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.layers_outlined, color: color, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      isLow ? 'このテーマの ステージ' : 'このテーマのステージ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (final s in stages)
                  _StageRow(
                    info: s,
                    color: color,
                    grade: grade,
                    onTap: () {
                      ref.read(currentStageProvider.notifier).state = s.num;
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => StageLearnScreen(
                          stageNum: s.num,
                          emoji: s.emoji,
                          title: s.title,
                          theme: theme,
                          color: color,
                        ),
                      ));
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StageRow extends StatelessWidget {
  final _StageInfo info;
  final Color color;
  final GradeLevel grade;
  final VoidCallback onTap;

  const _StageRow({
    required this.info,
    required this.color,
    required this.grade,
    required this.onTap,
  });

  String get _gradeLabelShort {
    switch (info.gradeLevel) {
      case GradeLevel.low:
        return '低';
      case GradeLevel.mid:
        return '中';
      case GradeLevel.high:
        return '高';
    }
  }

  Color get _gradeColor {
    switch (info.gradeLevel) {
      case GradeLevel.low:
        return Colors.green.shade600;
      case GradeLevel.mid:
        return Colors.orange.shade700;
      case GradeLevel.high:
        return Colors.purple.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            UkalabEmoji(info.emoji, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Stage ${info.num}  ${info.title}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _gradeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$_gradeLabelShort学年',
                style: TextStyle(
                  fontSize: 9,
                  color: _gradeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_ios,
                size: 11, color: color.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}

// ─── まなびのながれ ───

class _LearningFlowSection extends StatelessWidget {
  final bool isLow;
  const _LearningFlowSection({required this.isLow});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade50,
            Colors.blue.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route_outlined,
                  color: Colors.indigo.shade700, size: 18),
              const SizedBox(width: 6),
              Text(
                isLow ? 'まなびの ながれ' : 'まなびのながれ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _FlowStep(
            num: '1',
            color: TaikuColors.sports,
            isLow: isLow,
            title: isLow ? 'ステージを まなぶ' : 'ステージを学ぶ',
            desc: isLow
                ? 'せつめいを よんで ポイントを おぼえよう'
                : '各ステージの学習ポイント・全問解説を読む',
          ),
          _FlowArrow(),
          _FlowStep(
            num: '2',
            color: TaikuColors.nutrition,
            isLow: isLow,
            title: isLow ? 'クイズに ちょうせん！' : 'クイズに挑戦！',
            desc: isLow
                ? 'まなんだことを クイズで たしかめよう'
                : '学んだことをクイズで確認・定着させる',
          ),
          _FlowArrow(),
          _FlowStep(
            num: '3',
            color: TaikuColors.career,
            isLow: isLow,
            title: isLow ? 'バッジを あつめよう！' : 'バッジを集めよう！',
            desc: isLow
                ? 'ステージを クリアして バッジを もらおう'
                : 'ステージクリアでバッジを獲得・コレクション',
          ),
          _FlowArrow(),
          _FlowStep(
            num: '4',
            color: TaikuColors.disaster,
            isLow: isLow,
            title: isLow ? 'まちがいを ふくしゅう' : 'まちがいを復習',
            desc: isLow
                ? 'まちがえた もんだいを もういちど やろう'
                : 'まちがいノートで弱点を克服・完全習得',
          ),
        ],
      ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  final String num;
  final Color color;
  final bool isLow;
  final String title;
  final String desc;

  const _FlowStep({
    required this.num,
    required this.color,
    required this.isLow,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: Text(
              num,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FlowArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 13, top: 4, bottom: 4),
      child: Icon(Icons.arrow_downward,
          size: 16, color: Colors.grey.shade400),
    );
  }
}
