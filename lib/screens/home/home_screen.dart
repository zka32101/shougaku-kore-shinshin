import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../widgets/avatar_display_widget.dart';
import '../../utils/sound_effects_utils.dart';
import '../../utils/accessibility_utils.dart';
import '../../utils/animation_constants.dart';
import '../../widgets/animations/index.dart';
import '../ranking/ranking_screen.dart';
import '../settings/settings_screen.dart';
import '../library/library_screen.dart';
import '../report/report_screen.dart';
import '../../features/taiku/taiku_app.dart' show TaikuModule;
import '../../features/geijutsu/geijutsu_app.dart' show GeijutsuModule;
import '../badge/badge_showcase_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../checklist/achievement_checklist_screen.dart';
import '../checklist/daily_record_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItems = [
      (icon: '📖', title: 'ストーリー', subtitle: '道徳の学習', screen: const LibraryScreen()),
      (icon: '🏆', title: 'ランキング', subtitle: '成績を確認', screen: const RankingScreen()),
      (icon: '📈', title: 'ダッシュボード', subtitle: '学習統計', screen: const DashboardScreen()),
      (icon: '🎖️', title: 'バッジ図鑑', subtitle: 'バッジを集める', screen: const BadgeShowcaseScreen()),
      (icon: '📊', title: 'レポート', subtitle: '成長を分析', screen: const ReportScreen()),
      (icon: '⚙️', title: '設定', subtitle: 'アプリ設定', screen: const SettingsScreen()),
      (icon: '⛹️', title: '体育・健康', subtitle: 'スポーツ・防災・栄養', screen: const TaikuModule()),
      (icon: '🎨', title: '芸術', subtitle: '図工・音楽・家庭科', screen: const GeijutsuModule()),
      (icon: '✅', title: 'できたことチェック', subtitle: '成長を確認', screen: const AchievementChecklistScreen()),
      (icon: '📝', title: 'きょうのきろく', subtitle: '日々の取り組み', screen: const DailyRecordScreen()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('小学コレ！心身'),
        backgroundColor: AppColors.bgSecondary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: AnimatedFadeInScale(
        duration: AnimationDurations.medium,
        beginScale: 0.95,
        endScale: 1.0,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Avatar panel in header
                AnimatedSlideIn(
                  direction: SlideDirection.fromBottom,
                  duration: AnimationDurations.medium,
                  delay: Duration(milliseconds: 100),
                  child: const AvatarPanel(
                    userName: 'ユーザー',
                  ),
                ),
                const SizedBox(height: 32),

                // Main menu grid
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    // 長いサブタイトル（例: スポーツ・防災・栄養）でも収まる高さ
                    childAspectRatio: 0.78,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    return AnimatedSlideIn(
                      direction: SlideDirection.fromBottom,
                      duration: AnimationDurations.medium,
                      delay: Duration(milliseconds: 200 + (index * 75)),
                      child: _MenuCard(
                        icon: item.icon,
                        title: item.title,
                        subtitle: item.subtitle,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => item.screen),
                          );
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ホーム画面のメニューカード
class _MenuCard extends ConsumerStatefulWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  ConsumerState<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends ConsumerState<_MenuCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AnimationDurations.short,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AnimationCurves.snappyEasing),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    _handleTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  void _handleTap() {
    // メニュー選択音を再生
    SoundEffectsUtils(ref).playButtonTapSound();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AccessibilityUtils.semanticButton(
          label: widget.title,
          hint: widget.subtitle,
          onPressed: _handleTap,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppStyles.paddingMedium),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.icon,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: AppStyles.paddingMedium),
                  Text(
                    widget.title,
                    style: AppStyles.headingSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppStyles.paddingSmall),
                  Text(
                    widget.subtitle,
                    style: AppStyles.bodySmall,
                    textAlign: TextAlign.center,
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
