import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../providers/child_provider.dart';
import '../../providers/today_pick_provider.dart';
import '../growth/growth_note_screen.dart';
import '../story/story_learning_screen.dart';
import '../../constants/app_styles.dart';
import '../../widgets/avatar_display_widget.dart';
import '../../widgets/profile_name_card.dart';
import '../../widgets/plan_card.dart';
import '../../providers/user_profile_provider.dart';
import '../../features/shop/decor/decor_scope.dart';
import '../../utils/sound_effects_utils.dart';
import '../ranking/ranking_screen.dart';
import '../settings/settings_screen.dart';
import '../library/library_screen.dart';
import '../report/report_screen.dart';
import '../../features/taiku/taiku_app.dart' show TaikuModule;
import '../../features/geijutsu/geijutsu_app.dart' show GeijutsuModule;
import '../badge/badge_showcase_screen.dart';
import '../characters/character_collection_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../checklist/achievement_checklist_screen.dart';
import '../checklist/daily_record_screen.dart';
import 'package:shougaku_kore_doutoku/widgets/ukalab_emoji.dart';

/// 下のナビゲーションバー／ホームのボタンから切り替えるセクション。
/// [MainShell] のタブ番号と同じ並び。
enum HomeSection { home, doutoku, taiku, geijutsu, characters }

/// ホーム画面。大きく読みやすいボタンで、いつでも目的の場所へ行ける。
///
/// [onSelectSection] が渡されたとき（[MainShell] 内）は、どうとく／たいいく／げいじゅつ／
/// キャラずかんを下のナビのタブとして開く。渡されないとき（単体表示・テスト）は
/// 画面を push する。
class HomeScreen extends ConsumerWidget {
  final ValueChanged<HomeSection>? onSelectSection;

  const HomeScreen({super.key, this.onSelectSection});

  void _open(BuildContext context, HomeSection section, Widget fallback) {
    final cb = onSelectSection;
    if (cb != null) {
      cb(section);
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => fallback));
    }
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learn = <_HomeItem>[
      _HomeItem('📖', 'どうとく ストーリー', '道徳の学習', const Color(0xFF1E88E5),
          () => _open(context, HomeSection.doutoku, const LibraryScreen())),
      _HomeItem('⛹️', 'たいいく・けんこう', 'スポーツ・防災・栄養', const Color(0xFFE64A19),
          () => _open(context, HomeSection.taiku, const TaikuModule())),
      _HomeItem('🎨', 'げいじゅつ', '図工・音楽・家庭科', const Color(0xFFD81B60),
          () => _open(context, HomeSection.geijutsu, const GeijutsuModule())),
    ];
    final more = <_HomeItem>[
      _HomeItem('🐾', 'キャラずかん', 'キャラを そだてよう', const Color(0xFF43A047),
          () => _open(context, HomeSection.characters,
              const CharacterCollectionScreen())),
      _HomeItem('🎖️', 'バッジ', 'バッジを集める', const Color(0xFFF9A825),
          () => _push(context, const BadgeShowcaseScreen())),
      _HomeItem('📓', 'せいちょうノート', 'かんがえた ことを みかえそう', const Color(0xFF2E7D32),
          () => _push(context, const GrowthNoteScreen())),
      _HomeItem('🏆', 'ランキング', '成績を確認', const Color(0xFF8E24AA),
          () => _push(context, const RankingScreen())),
      _HomeItem('📊', 'ほごしゃ レポート', '成長を分析', const Color(0xFF00897B),
          () => _push(context, const ReportScreen())),
      _HomeItem('📈', 'ダッシュボード', '学習統計', const Color(0xFF3949AB),
          () => _push(context, const DashboardScreen())),
      _HomeItem('✅', 'できたことチェック', '成長を確認', const Color(0xFF6D4C41),
          () => _push(context, const AchievementChecklistScreen())),
      _HomeItem('📝', 'きょうのきろく', '日々の取り組み', const Color(0xFF546E7A),
          () => _push(context, const DailyRecordScreen())),
      _HomeItem('⚙️', 'せってい', 'アプリ設定', const Color(0xFF757575),
          () => _push(context, const SettingsScreen())),
    ];
    // 体育・芸術それぞれの記録（以前は各画面の上にあった専用メニュー）
    final records = <_HomeItem>[
      _HomeItem('🏅', 'たいいくのバッジ', 'たいいくで あつめた', const Color(0xFFE64A19),
          () => _push(context,
              const TaikuModule(initialRoute: '/badges', standalone: true))),
      _HomeItem('📷', 'たいいくのアルバム', '体験のきろく', const Color(0xFFFF6D00),
          () => _push(context,
              const TaikuModule(initialRoute: '/album', standalone: true))),
      _HomeItem('👪', 'たいいくの ほごしゃ', '見まもりページ', const Color(0xFF00838F),
          () => _push(context,
              const TaikuModule(initialRoute: '/parent', standalone: true))),
      _HomeItem('⭐', 'げいじゅつのバッジ', 'げいじゅつで あつめた', const Color(0xFFD81B60),
          () => _push(context,
              const GeijutsuModule(initialRoute: '/badges', standalone: true))),
      _HomeItem('👪', 'げいじゅつの ほごしゃ', '見まもりページ', const Color(0xFFAD1457),
          () => _push(context,
              const GeijutsuModule(initialRoute: '/parent', standalone: true))),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('小学コレ！心身'),
        backgroundColor: AppColors.bgSecondary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // アバター（コインつき）ヘッダー
            AvatarPanel(userName: ref.watch(displayNameProvider)),
            const ProfileNameCard(),
            const PlanCard(),
            const SizedBox(height: 12),
            _TodayPickCard(
              onOpenTaiku: onSelectSection == null
                  ? null
                  : () => onSelectSection!(HomeSection.taiku),
            ),
            const SizedBox(height: 20),
            const _SectionLabel('まなぶ'),
            for (final item in learn)
              _HomeButton(item: item, height: 96, titleSize: 22),
            const SizedBox(height: 12),
            const _SectionLabel('ひろげる・ふりかえる'),
            for (final item in more)
              _HomeButton(item: item, height: 72, titleSize: 18),
            const SizedBox(height: 12),
            const _SectionLabel('たいいく・げいじゅつの きろく'),
            for (final item in records)
              _HomeButton(item: item, height: 72, titleSize: 18),
          ],
        ),
      ),
    );
  }
}

/// 「きょうのおすすめ」：その日に読むお話を1つ出す。タップでそのまま読み始められる。
class _TodayPickCard extends ConsumerWidget {
  final VoidCallback? onOpenTaiku;
  const _TodayPickCard({this.onOpenTaiku});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pick = ref.watch(todayPickProvider);
    final child = ref.watch(selectedChildProvider).valueOrNull;
    if (pick == null || child == null) return const SizedBox.shrink();

    const color = Color(0xFFF9A825);
    return Container(
      key: const Key('today_pick_card'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pick.isReview ? '⭐ きょうの ふくしゅう' : '⭐ きょうの おすすめ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE65100),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => StoryLearningScreen(
                  storyId: pick.story.id,
                  childId: child.id,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.menu_book, color: color, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pick.story.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if ((pick.story.description ?? '').isNotEmpty)
                          Text(
                            pick.story.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: color),
                ],
              ),
            ),
          ),
          if (onOpenTaiku != null) ...[
            const Divider(height: 16),
            TextButton.icon(
              key: const Key('today_pick_taiku'),
              onPressed: onOpenTaiku,
              icon: const Icon(Icons.directions_run, size: 18),
              label: const Text('たいいくの まなびも やってみよう'),
            ),
          ],
        ],
      ),
    );
  }
}

class _HomeItem {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _HomeItem(this.icon, this.title, this.subtitle, this.color, this.onTap);
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: DecorScope.chipBg(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              text,
              style: AppStyles.headingSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
}

/// 横いっぱいの大きなボタン（絵 ＋ ラベル ＋ 説明）
class _HomeButton extends ConsumerWidget {
  final _HomeItem item;
  final double height;
  final double titleSize;

  const _HomeButton({
    required this.item,
    required this.height,
    required this.titleSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        label: item.title,
        hint: item.subtitle,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
            onTap: () {
              SoundEffectsUtils(ref).playButtonTapSound();
              item.onTap();
            },
            child: Container(
              constraints: BoxConstraints(minHeight: height),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                // 背景つきのときだけ不透明の白地にして、絵が透けて文字が読みにくくなるのを防ぐ
                color: (DecorScope.maybeOf(context)?.hasBackground ?? false)
                    ? Colors.white
                    : null,
                borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
                border: Border.all(
                    color: item.color.withValues(alpha: 0.5), width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    width: height * 0.62,
                    height: height * 0.62,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: UkalabEmoji(item.icon, size: height * 0.4),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 幅の狭い端末でも「ー」だけ次の行に落ちないよう1行に収める
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            item.title,
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: item.color, size: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
