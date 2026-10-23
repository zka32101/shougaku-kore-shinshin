import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../providers/child_provider.dart';
import '../../providers/today_pick_provider.dart';
import '../../services/local_reflection_store.dart' show kReflectionFeelings;
import '../../utils/guardian_gate.dart';
import '../hub/guardian_hub_screen.dart';
import '../hub/records_hub_screen.dart';
import '../story/story_learning_screen.dart';
import '../../constants/app_styles.dart';
import '../../widgets/avatar_display_widget.dart';
import '../../widgets/profile_name_card.dart';
import '../../widgets/plan_card.dart';
import '../../providers/user_profile_provider.dart';
import '../../features/shop/decor/decor_scope.dart';
import '../../utils/sound_effects_utils.dart';
import '../settings/settings_screen.dart';
import '../library/library_screen.dart';
import '../../features/taiku/taiku_app.dart' show TaikuModule;
import '../../features/geijutsu/geijutsu_app.dart' show GeijutsuModule;
import '../characters/character_collection_screen.dart';
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

  /// 保護者向けのページは、大人であることを確認してから開く。
  Future<void> _openGuardian(BuildContext context) async {
    final ok = await confirmAdult(context, purpose: '保護者のかた向けのページです。');
    if (!ok || !context.mounted) return;
    _push(context, const GuardianHubScreen());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learn = <HomeItem>[
      HomeItem('📖', 'どうとく ストーリー', '道徳の学習', const Color(0xFF1E88E5),
          () => _open(context, HomeSection.doutoku, const LibraryScreen())),
      HomeItem('⛹️', 'たいいく・けんこう', 'スポーツ・防災・栄養', const Color(0xFFE64A19),
          () => _open(context, HomeSection.taiku, const TaikuModule())),
      HomeItem('🎨', 'げいじゅつ', '図工・音楽・家庭科', const Color(0xFFD81B60),
          () => _open(context, HomeSection.geijutsu, const GeijutsuModule())),
    ];
    final more = <HomeItem>[
      HomeItem('🐾', 'キャラずかん', 'キャラを そだてよう', const Color(0xFF43A047),
          () => _open(context, HomeSection.characters,
              const CharacterCollectionScreen())),
      HomeItem('📚', 'きろく', 'バッジ・ノート・ランキング', const Color(0xFFF9A825),
          () => _push(context, const RecordsHubScreen())),
      HomeItem('👪', 'ほごしゃ', '見まもり・レポート', const Color(0xFF00897B),
          () => _openGuardian(context)),
      HomeItem('⚙️', 'せってい', 'アプリ設定', const Color(0xFF757575),
          () => _push(context, const SettingsScreen())),
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
            const _RevisitCard(),
            const SizedBox(height: 20),
            const _SectionLabel('まなぶ'),
            for (final item in learn)
              HomeButton(item: item, height: 96, titleSize: 22),
            const SizedBox(height: 12),
            const _SectionLabel('ひろげる・ふりかえる'),
            for (final item in more)
              HomeButton(item: item, height: 72, titleSize: 18),
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
          if (ref.watch(todayCandidatesProvider).length > 1)
            TextButton.icon(
              key: const Key('today_pick_choose'),
              onPressed: () => _chooseStory(context, ref, child.id),
              icon: const Icon(Icons.swap_horiz, size: 18),
              label: const Text('ほかの おはなしから えらぶ'),
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

/// 「もういちど かんがえてみよう」：1週間以上前に考えたお話を、もう一度すすめる。
class _RevisitCard extends ConsumerWidget {
  const _RevisitCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(selectedChildProvider).valueOrNull;
    if (child == null) return const SizedBox.shrink();
    final pick = ref.watch(revisitPickProvider(child.id)).valueOrNull;
    if (pick == null) return const SizedBox.shrink();
    final feeling = pick.entry.feeling == null
        ? null
        : kReflectionFeelings[pick.entry.feeling!];

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
        child: InkWell(
          key: const Key('revisit_card'),
          borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => StoryLearningScreen(
                storyId: pick.entry.storyId,
                childId: child.id,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Text('🔁', style: TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'もういちど かんがえてみよう',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '「${pick.entry.storyTitle}」',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        feeling == null
                            ? '${pick.daysAgo}にちまえに かんがえたよ。いまは どう おもう？'
                            : '${pick.daysAgo}にちまえは「${feeling.$2}」${feeling.$1}と おもったよ。いまは どう？',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFF2E7D32)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 3つの候補から、親子で相談して読むお話を選ぶ。
void _chooseStory(BuildContext context, WidgetRef ref, String childId) {
  final picks = ref.read(todayCandidatesProvider);
  showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'きょうは どの おはなしに する？',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'おうちの人と いっしょに えらんでみよう',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          for (final p in picks)
            ListTile(
              key: Key('today_candidate_${p.story.id}'),
              leading: const Icon(Icons.menu_book),
              title: Text(p.story.title),
              subtitle: (p.story.description ?? '').isEmpty
                  ? null
                  : Text(p.story.description!,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
              onTap: () {
                Navigator.of(sheetContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => StoryLearningScreen(
                      storyId: p.story.id,
                      childId: childId,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    ),
  );
}

/// ホームや「きろく」「ほごしゃ」の画面に並べるメニュー1件。
class HomeItem {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const HomeItem(this.icon, this.title, this.subtitle, this.color, this.onTap);
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
/// メニュー1件を表す大きなボタン。
class HomeButton extends ConsumerWidget {
  final HomeItem item;
  final double height;
  final double titleSize;

  const HomeButton({
    super.key,
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
