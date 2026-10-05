import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_models.dart';
import '../widgets/analytics_dashboard.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
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
              const _SectionHeader(title: 'プロフィール'),
              _ProfileTile(),
              const Divider(),
              const _SectionHeader(title: 'アプリ情報'),
              ListTile(
                leading: const Text('🎨', style: TextStyle(fontSize: 24)),
                title: const Text('小学コレ！芸術'),
                subtitle: const Text('バージョン 1.0.0'),
              ),
              const Divider(),
              const _SectionHeader(title: 'プライバシー'),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('プライバシーポリシー'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('利用規約'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(),
              const _SectionHeader(title: 'サポート'),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('使い方ガイド'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.mail),
                title: const Text('お問い合わせ'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
          // Tab 2: 学習分析
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AnalyticsDashboard(
              userName: ref.watch(profileProvider).active?.name ?? 'ユーザー',
              totalQuestions: 0,
              averageAccuracy: 0.0,
              totalTimeSpent: Duration.zero,
              dailyActivity: _generateDailyActivity(),
              accuracyTrend: _generateAccuracyTrend(),
            ),
          ),
        ],
      ),
    );
  }

  List<DailyActivityData> _generateDailyActivity() {
    return [
      DailyActivityData(day: 1, questionsAnswered: 0),
      DailyActivityData(day: 2, questionsAnswered: 0),
      DailyActivityData(day: 3, questionsAnswered: 0),
      DailyActivityData(day: 4, questionsAnswered: 0),
      DailyActivityData(day: 5, questionsAnswered: 0),
      DailyActivityData(day: 6, questionsAnswered: 0),
      DailyActivityData(day: 7, questionsAnswered: 0),
    ];
  }

  List<AccuracyTrendData> _generateAccuracyTrend() {
    return [
      AccuracyTrendData(week: 1, accuracy: 0.0),
      AccuracyTrendData(week: 2, accuracy: 0.0),
      AccuracyTrendData(week: 3, accuracy: 0.0),
      AccuracyTrendData(week: 4, accuracy: 0.0),
    ];
  }
}

class _ProfileTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final active = profileState.active;
    return ListTile(
      leading: Text(
        active?.avatarEmoji ?? '🧒',
        style: const TextStyle(fontSize: 28),
      ),
      title: Text(
        active?.name ?? 'プロフィールなし',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('${profileState.profiles.length}人が利用中'),
      trailing: const Icon(Icons.swap_horiz),
      onTap: () => Navigator.pushNamed(
        context,
        '/profile-select',
        arguments: true,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1,
        ),
      ),
    );
  }
}
