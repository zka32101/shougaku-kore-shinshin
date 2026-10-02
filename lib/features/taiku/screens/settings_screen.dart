import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../literacy_core/literacy_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../taiku_app.dart';
import '../providers/taiku_providers.dart';
import 'about_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final grade = ref.watch(gradeLevelProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: TaikuColors.primary,
        title: const Text(
          '⚙ 設定',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 学年設定
          _Section(
            title: '学年',
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: GradeSelectorWidget(
                    selected: grade,
                    onSelected: (g) {
                      ref.read(gradeLevelProvider.notifier).setGrade(g);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                  child: Text(
                    '学年グループを変更すると、表示されるステージが変わります。',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // アプリ情報
          _Section(
            title: 'アプリ情報',
            child: Column(
              children: [
                const _InfoTile(label: 'アプリ名', value: '体験・体育コレ！'),
                const _InfoTile(label: 'バージョン', value: 'v2.0'),
                const _InfoTile(label: '対象', value: '小学1〜6年生'),
                const _InfoTile(label: 'コンテンツ', value: '525問・150語彙・31競技・142活動'),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TaikuColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('このアプリについて'),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const AboutScreen(),
                      ));
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // データリセット
          _Section(
            title: 'データ管理',
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('学習データをリセット'),
                    onPressed: () => _confirmReset(context, ref),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '※ バッジ・進捗・テーマ設定がリセットされます。',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // フッター
          Center(
            child: Text(
              '© 2026 Petit Studio · 体験・体育コレ！',
              style: TextStyle(
                  fontSize: 11, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データをリセットしますか？'),
        content: const Text('バッジ・進捗・テーマ設定がすべて消えます。この操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              ref.invalidate(taikuProgressProvider);
              ref.invalidate(acquiredBadgesProvider);
              ref.invalidate(parentThemeProvider);
              if (context.mounted) {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pushReplacementNamed('/onboarding');
              }
            },
            child: const Text('リセット', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700),
            ),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
