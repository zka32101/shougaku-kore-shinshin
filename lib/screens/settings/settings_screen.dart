import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cross_promo_kit/cross_promo_kit.dart' show CrossPromoSection;
import 'package:shared_core/shared_core.dart'
    show AnalyticsDashboard, ScreenTimeSettingsWidget, requireParentalGate;
import '../../theme/app_theme.dart' show kPrimaryColor;
import '../../utils/guardian_gate.dart';
import '../../providers/audio_provider.dart';
import '../../providers/app_version_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/offline_sync_provider.dart';
import '../../providers/premium_provider.dart';
import '../profile/profile_management_screen.dart';
import '../../widgets/profile_edit_dialog.dart';
import '../../providers/user_profile_provider.dart';
import '../ranking/ranking_settings_screen.dart';
import 'help_screen.dart';
import 'module_data_reset_section.dart';
import 'privacy_policy_screen.dart';
import 'reminder_switch.dart';
import 'study_window_tile.dart';

/// 利用時間制限の設定画面を開く前に、保護者ゲートで確認する。
Future<void> _openScreenTimeSettings(BuildContext context) async {
  final passedGate = await requireParentalGate(
    context,
    title: '保護者確認',
    description: '利用時間の設定変更には、保護者の確認が必要です。',
  );
  if (!passedGate || !context.mounted) return;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('利用時間の設定')),
        body: const ScreenTimeSettingsWidget(primaryColor: kPrimaryColor),
      ),
    ),
  );
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final soundEnabled = ref.watch(isSoundEnabledProvider);
    final narrationEnabled = ref.watch(isNarrationEnabledProvider);
    final volumeLevel = ref.watch(volumeLevelProvider);
    final notifSettings = ref.watch(notificationSettingsProvider);
    final syncState = ref.watch(offlineSyncProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        elevation: 0,
        backgroundColor: const Color(0xFF9B59B6),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '設定'),
            Tab(text: '学習分析'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: 設定
          ListView(
            children: [
              // ─── プレミアム（無料期間・購読状態） ───
              const _PremiumCard(),

              // ─── オフライン同期状態 ───
              if (syncState.pendingCount > 0)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud_upload_outlined, color: Color(0xFF856404)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${syncState.pendingCount}件の未同期データがあります',
                      style: const TextStyle(color: Color(0xFF856404), fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.read(offlineSyncProvider.notifier).syncPendingItems(),
                    child: const Text('今すぐ同期'),
                  ),
                ],
              ),
            ),

          // プロフィール設定セクション
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'プロフィール',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            key: const Key('settings_profile_name_grade'),
            leading: const Icon(Icons.edit),
            title: const Text('プロフィール（なまえ・がくねん）'),
            subtitle: Text(ref.watch(displayNameProvider) ?? 'まだ きめていないよ'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => showProfileEditDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('お子様のプロフィール'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              if (!await confirmAdult(context,
                  purpose: 'お子様のプロフィールを変えたり消したりする操作です。')) {
                return;
              }
              if (!context.mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileManagementScreen(),
                ),
              );
            },
          ),

          // ─── ランキング設定セクション ───
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'ランキング',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF9B59B6)),
            title: const Text('ランキング設定'),
            subtitle: const Text('プライバシー設定'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              if (!await confirmAdult(context,
                  purpose: 'ランキングでの公開のしかたを変える操作です。')) {
                return;
              }
              if (!context.mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RankingSettingsScreen(),
                ),
              );
            },
          ),

          // ─── たいいく／げいじゅつのデータ管理 ───
          const ModuleDataResetSection(),

          // ─── 通知設定セクション ───
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('通知', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.notifications_outlined, color: Color(0xFF9B59B6)),
            title: const Text('デイリーリマインダー'),
            subtitle: const Text('毎日の学習をお知らせ'),
            trailing: Switch(
              value: notifSettings.dailyReminder,
              activeThumbColor: const Color(0xFF9B59B6),
              onChanged: (v) => ref
                  .read(notificationSettingsProvider.notifier)
                  .setDailyReminder(v),
            ),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.assessment_outlined, color: Color(0xFF9B59B6)),
            title: const Text('レポート通知'),
            subtitle: const Text('月次レポートが完成したとき'),
            trailing: Switch(
              value: notifSettings.reportReady,
              activeThumbColor: const Color(0xFF9B59B6),
              onChanged: (v) => ref
                  .read(notificationSettingsProvider.notifier)
                  .setReportReady(v),
            ),
          ),
          if (notifSettings.dailyReminder) ...[
            const Divider(height: 0),
            ListTile(
              leading: const Icon(Icons.access_time, color: Color(0xFF9B59B6)),
              title: const Text('リマインダー時刻'),
              trailing: TextButton(
                onPressed: () => _pickReminderTime(context, ref, notifSettings),
                child: Text(
                  '${notifSettings.reminderHour.toString().padLeft(2, '0')}:'
                  '${notifSettings.reminderMinute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          // 学習のおしらせ（端末のローカル通知）と勉強の時間帯。ON にする操作は保護者ゲート付き
          const ReminderSwitchTile(),
          const StudyWindowTile(),

          // 音声設定セクション
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '音声設定',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.volume_up),
            title: const Text('効果音'),
            trailing: Switch(
              value: soundEnabled,
              onChanged: (value) {
                ref
                    .read(audioControllerProvider.notifier)
                    .toggleSoundEnabled();
              },
            ),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.record_voice_over),
            title: const Text('ナレーション'),
            trailing: Switch(
              value: narrationEnabled,
              onChanged: (value) {
                ref
                    .read(audioControllerProvider.notifier)
                    .toggleNarrationEnabled();
              },
            ),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.volume_up_outlined),
            title: const Text('音量'),
            subtitle: Slider(
              value: volumeLevel,
              onChanged: (value) {
                ref
                    .read(audioControllerProvider.notifier)
                    .setVolume(value);
              },
              min: 0,
              max: 1,
            ),
          ),

          // アカウント・その他セクション
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'アカウント・その他',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('利用時間を設定する'),
            subtitle: const Text('1日の利用時間に上限を設定できます（保護者向け）'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _openScreenTimeSettings(context),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('ヘルプ'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpScreen()),
              );
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('プライバシーポリシー'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('このアプリについて'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: '小学コレ！心身',
                applicationVersion: ref.read(appVersionProvider).valueOrNull,
              );
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.apps_rounded),
            title: const Text('他のアプリを見る'),
            subtitle: const Text('小学コレ！シリーズの他の教科アプリを紹介します'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _openOtherApps,
          ),
          CrossPromoSection(
            currentAppId: 'com.yourwish.shougakukore.shinshin',
            currentCategory: '小学コレ',
            isChildDirected: true,
            beforeOpenStore: (context) => requireParentalGate(context),
          ),
              const SizedBox(height: 24),
            ],
          ),
          // Tab 2: 学習分析
          ref.watch(currentUserProvider).when(
                data: (user) => user == null
                    ? const Center(child: Text('ログインすると学習分析が表示されます'))
                    : AnalyticsDashboard(userId: user.uid),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('学習分析を読み込めませんでした')),
              ),
        ],
      ),
    );
  }

  Future<void> _openOtherApps() async {
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse('https://sites.google.com/view/yourwishapps'),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ページを ひらけませんでした。あとで もういちど ためしてね')),
      );
    }
  }

  Future<void> _pickReminderTime(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.reminderHour,
        minute: settings.reminderMinute,
      ),
    );
    if (picked != null) {
      ref.read(notificationSettingsProvider.notifier).setReminderTime(
        picked.hour,
        picked.minute,
      );
    }
  }

}

/// 無料期間の残り日数・購読状態を表示し、購入画面（/subscription）へ誘導する。
class _PremiumCard extends ConsumerWidget {
  const _PremiumCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premium = ref.watch(premiumProvider);

    final String title;
    final String subtitle;
    if (premium.isPremium) {
      title = 'プレミアム会員';
      subtitle = 'すべてのコンテンツが使えます。ありがとうございます！';
    } else if (premium.isTrialActive) {
      title = 'プレミアムを試し中';
      subtitle = '無料期間 あと${premium.trialDaysLeft}日';
    } else {
      title = 'プレミアムにアップグレード';
      subtitle = '無料期間は終了しました。月額¥300 / 年額¥2,400';
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ListTile(
        leading: const Text('⭐', style: TextStyle(fontSize: 28)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.of(context).pushNamed('/subscription'),
      ),
    );
  }
}
