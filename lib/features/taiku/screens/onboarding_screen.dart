import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../literacy_core/literacy_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../taiku_app.dart';
import 'package:shougaku_kore_doutoku/widgets/ukalab_emoji.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'ようこそ！\n体育・健康へ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '小学1〜6年生向け学習アプリ。\n学年を選んでスタートしよう！',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '📚 学べること',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._features.map((f) => _FeatureItem(
                    emoji: f.$1,
                    title: f.$2,
                    desc: f.$3,
                    color: f.$4,
                  )),
              const Spacer(),
              const Text(
                '学年を選んでください',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GradeSelectorWidget(
                selected: ref.watch(gradeLevelProvider),
                onSelected: (g) {
                  ref.read(gradeLevelProvider.notifier).setGrade(g);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TaikuColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('taiku_onboarded', true);
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/home');
                    }
                  },
                  child: const Text(
                    'はじめる！',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  static const _features = [
    (
      '⚽',
      'スポーツ',
      'ルール・チームワーク・体の動かし方',
      TaikuColors.sports,
    ),
    (
      '🛡️',
      '防災',
      '地震・火事・水難から身を守る',
      TaikuColors.disaster,
    ),
    (
      '🥗',
      '栄養',
      '食事・体づくり・健康習慣',
      TaikuColors.nutrition,
    ),
    (
      '⭐',
      'キャリア',
      'スポーツの職業・科学・未来',
      TaikuColors.career,
    ),
  ];
}

class _FeatureItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;
  final Color color;

  const _FeatureItem({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: UkalabEmoji(emoji, size: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color)),
                Text(desc,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
