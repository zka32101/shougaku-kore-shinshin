import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../literacy_core/literacy_core.dart';
import '../taiku_app.dart';
import 'package:shougaku_kore_doutoku/widgets/ukalab_emoji.dart';

/// 「このアプリについて」説明画面 — 充実した説明と美しいUI
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grade = ref.watch(gradeLevelProvider);
    final isLow = grade == GradeLevel.low;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── ヘッダー ──
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: TaikuColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE64A19), Color(0xFFBF360C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('🏃', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 8),
                        Text(
                          isLow ? 'このアプリについて' : 'このアプリについて',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isLow ? '体育・健康 v2.0' : '体育・健康 — 小学生向け体育・保健学習アプリ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // ── コンテンツ ──
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  // ── クイック統計 ──
                  _StatsCard(isLow: isLow),
                  const SizedBox(height: 24),

                  // ── 主な機能 ──
                  _FeatureSection(isLow: isLow),
                  const SizedBox(height: 24),

                  // ── 学習構成 ──
                  _CurriculumSection(isLow: isLow),
                  const SizedBox(height: 24),

                  // ── 学習の進め方 ──
                  _LearningFlowSection(isLow: isLow),
                  const SizedBox(height: 24),

                  // ── 対象学年 ──
                  _GradeSection(isLow: isLow),
                  const SizedBox(height: 24),

                  // ── 親向け機能 ──
                  _ParentFeaturesSection(isLow: isLow),
                  const SizedBox(height: 24),

                  // ── 開発元 ──
                  _DeveloperSection(isLow: isLow),
                  const SizedBox(height: 24),

                  // ── お問い合わせ ──
                  _ContactSection(isLow: isLow),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── クイック統計カード ──
class _StatsCard extends StatelessWidget {
  final bool isLow;
  const _StatsCard({required this.isLow});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.green.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                isLow ? 'アプリの すがた' : 'コンテンツ統計',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            children: [
              _StatItem('35', isLow ? 'ステージ' : 'ステージ'),
              _StatItem('525', isLow ? 'もん' : '問'),
              _StatItem('150', isLow ? 'ことば' : '語彙'),
              _StatItem('31', isLow ? 'きょう' : '競技'),
              _StatItem('142', isLow ? 'たいけん' : '体験'),
              _StatItem('44', isLow ? 'バッジ' : 'バッジ'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String number;
  final String label;
  const _StatItem(this.number, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF558B2F)),
        ),
      ],
    );
  }
}

// ── 主な機能セクション ──
class _FeatureSection extends StatelessWidget {
  final bool isLow;
  const _FeatureSection({required this.isLow});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      emoji: '✨',
      title: isLow ? 'おもな きのう' : '主な機能',
      color: Colors.orange,
      child: Column(
        children: [
          _FeatureItem(
            emoji: '📚',
            title: isLow ? 'クイズ' : 'クイズ学習',
            desc: isLow
                ? '525もんの もんだい。ぜんぶ かいせつ付き！'
                : '35ステージ×15問＝525問。全て詳細解説付き。',
          ),
          _FeatureItem(
            emoji: '📖',
            title: isLow ? 'ことば' : 'キーワード用語集',
            desc: isLow
                ? 'だいじな ことばが ぜんぶで 75ことば'
                : '各ステージ5つの重要用語。タップで定義を表示。',
          ),
          _FeatureItem(
            emoji: '⚽',
            title: isLow ? '図鑑' : 'スポーツ図鑑',
            desc: isLow
                ? '31しゅるいの スポーツを しょうかい'
                : '31競技の基本ルール・起源・スキルを網羅。',
          ),
          _FeatureItem(
            emoji: '🎯',
            title: isLow ? 'たいけん' : '実体験チャレンジ',
            desc: isLow
                ? '142の じっさいを やってみよう！'
                : '142の体験活動。学習を現実に繋ぎます。',
          ),
          _FeatureItem(
            emoji: '🏅',
            title: isLow ? 'バッジ' : 'バッジシステム',
            desc: isLow
                ? '38しゅるいの あちーぶめんと'
                : '学習進度・連続学習・実体験を可視化。',
          ),
          _FeatureItem(
            emoji: '📷',
            title: isLow ? 'アルバム' : '体験アルバム',
            desc: isLow
                ? 'しゃしんを きろくしよう'
                : '撮影した写真でポートフォリオを作成。',
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;
  const _FeatureItem({required this.emoji, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UkalabEmoji(emoji, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 学習構成セクション ──
class _CurriculumSection extends StatelessWidget {
  final bool isLow;
  const _CurriculumSection({required this.isLow});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      emoji: '📚',
      title: isLow ? 'がくしゅうの もくじ' : '学習構成',
      color: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isLow
                ? '13つの テーマ × 35ステージで、わかりやすく まなべます'
                : '13テーマ × 35ステージで体系的に学習できます。',
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          _ThemeRow('⚽', 'スポーツ', 'Stage 1,2,4'),
          _ThemeRow('🛡️', 'ぼうさい・あんぜん', 'Stage 5,6'),
          _ThemeRow('🥗', 'えいよう・けんこう', 'Stage 3,7,8'),
          _ThemeRow('⭐', 'きゃりあ・みらい', 'Stage 9-12'),
          _ThemeRow('🏥', 'けんこうかんり', 'Stage 13-15'),
          _ThemeRow('🚨', 'あんぜん・ぼうはん', 'Stage 16-18'),
          _ThemeRow('🌱', 'かんきょう・SDGs ★NEW', 'Stage 19'),
          _ThemeRow('💰', 'お金のきほん ★NEW', 'Stage 20'),
          _ThemeRow('🤝', 'どうとく・じんけん ★NEW', 'Stage 21'),
        ],
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  final String emoji;
  final String name;
  final String stages;
  const _ThemeRow(this.emoji, this.name, this.stages);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          UkalabEmoji(emoji, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              stages,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 学習フロー ──
class _LearningFlowSection extends StatelessWidget {
  final bool isLow;
  const _LearningFlowSection({required this.isLow});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      emoji: '🎯',
      title: isLow ? 'まなびかた' : '推奨学習フロー',
      color: Colors.green,
      child: Column(
        children: [
          _FlowStep(1, '⚙️', isLow ? 'ステージえらぶ' : 'ステージ選択'),
          _FlowArrow(),
          _FlowStep(2, '📖', isLow ? 'ポイント・ことばを よむ' : 'キーワード・解説を確認'),
          _FlowArrow(),
          _FlowStep(3, '❓', isLow ? 'クイズに ちょうせん' : 'クイズで理解度確認'),
          _FlowArrow(),
          _FlowStep(4, '🏃', isLow ? 'じっさいに やってみる' : '実体験で学習を実践'),
          _FlowArrow(),
          _FlowStep(5, '🏆', isLow ? 'バッジをあつめる' : 'バッジで達成感を得る'),
        ],
      ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  final int num;
  final String emoji;
  final String label;
  const _FlowStep(this.num, this.emoji, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$num',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 8),
          UkalabEmoji(emoji, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Icon(Icons.arrow_downward, color: Colors.green.shade400, size: 18),
    );
  }
}

// ── 対象学年 ──
class _GradeSection extends StatelessWidget {
  final bool isLow;
  const _GradeSection({required this.isLow});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      emoji: '👥',
      title: isLow ? 'たいしょう' : '対象学年',
      color: Colors.purple,
      child: Text(
        isLow
            ? 'しょうがく 1ねん～6ねん\n\nがくねん別に もんだい・ことばが ちがうので\nあなたの がくねんで まなべます！'
            : '小学1年生～6年生\n\n全35ステージは3段階の難易度に対応。お子さんの学年・レベルに応じて学習を進められます。',
        style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.6),
      ),
    );
  }
}

// ── 親向け機能 ──
class _ParentFeaturesSection extends StatelessWidget {
  final bool isLow;
  const _ParentFeaturesSection({required this.isLow});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      emoji: '👨‍👩‍👧',
      title: isLow ? 'おやむけ' : 'おうちの方へ',
      color: Colors.red,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isLow
                ? '親メニューで、お子さんの\nがくしゅう しんちょくが みられます！'
                : '「親メニュー」タブでお子さんの学習状況をご確認できます。',
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.6),
          ),
          const SizedBox(height: 12),
          _ParentFeature('📈', isLow ? '進捗（しんちょく）' : '学習進捗',
              isLow ? 'ステージごとの できた％' : 'ステージ別の達成率・正答率'),
          _ParentFeature('📊', isLow ? '分析' : 'テーマ分析',
              isLow ? 'とくいな ぶんや、あい な ぶんや' : '得意・苦手な領域を可視化'),
          _ParentFeature('📅', isLow ? '月間（がっかん）' : '月間レポート',
              isLow ? 'がくしゅう じかん、バッジ' : '学習時間・連続日数・バッジ数'),
          _ParentFeature('📷', isLow ? 'アルバム' : '体験写真',
              isLow ? 'じっさいの しょうこ' : 'お子さんの実体験を共有'),
        ],
      ),
    );
  }
}

class _ParentFeature extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;
  const _ParentFeature(this.emoji, this.title, this.desc);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UkalabEmoji(emoji, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  desc,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 開発元 ──
class _DeveloperSection extends StatelessWidget {
  final bool isLow;
  const _DeveloperSection({required this.isLow});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      emoji: '🛠️',
      title: isLow ? '開発元' : '開発・配信',
      color: Colors.indigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Petit Works Apps',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isLow
                ? 'しょうがくせいの すぽーつ・けんこう・あんぜんを\nたいけん・がくしゅうできるアプリを つくっています。'
                : '小学生向けの教育アプリを多数開発・配信しています。\nお子さんの「好奇心」「挑戦心」「達成感」を大切にした\nコンテンツ設計を心がけています。',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ── お問い合わせ ──
class _ContactSection extends StatelessWidget {
  final bool isLow;
  const _ContactSection({required this.isLow});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      emoji: '💬',
      title: isLow ? 'ご いけん' : 'ご意見・ご要望',
      color: Colors.teal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isLow
                ? 'このアプリについての ご いけん・ご ほうこく、\nなんでも おおせください！'
                : 'アプリの改善に向けたご意見・ご要望・不具合報告は\n以下のメールアドレスまでお気軽にお送りください。',
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.6),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Text('📧', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText(
                    'funvestment1@gmail.com',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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

// ── 通用セクションカード ──
class _SectionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final Color color;
  final Widget child;

  const _SectionCard({
    required this.emoji,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
              UkalabEmoji(emoji, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
