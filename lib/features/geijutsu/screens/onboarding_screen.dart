import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../providers/app_providers.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import 'package:shougaku_kore_doutoku/widgets/ukalab_emoji.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardPage(
      emoji: '🎨',
      title: '色彩で表現する\n図工チャレンジ',
      desc: '12ヶ月・12色のテーマに挑戦！\n色の感情を探して、絵に描いて、\nあなただけの表現を見つけよう。',
      color: Color(0xFFE74C3C),
    ),
    _OnboardPage(
      emoji: '🎵',
      title: 'あなたが作曲家！\n音楽チャレンジ',
      desc: '5音のメロディから始まって\nリズム・コード・ドラムを加えて\nあなたの曲を完成させよう！',
      color: Color(0xFF9B59B6),
    ),
    _OnboardPage(
      emoji: '🍳',
      title: '色彩料理と\nファッション！',
      desc: '毎月のカラーテーマで\n「赤い料理」「赤い服」を作って\n親子で色彩ライフを楽しもう。',
      color: Color(0xFF27AE60),
    ),
    _OnboardPage(
      emoji: '⭐',
      title: 'バッジを集めて\nアーティストへ！',
      desc: '完成した作品や楽曲で\nバッジを獲得！\n12ヶ月後は色彩絵師へ成長！',
      color: Color(0xFFFF6B35),
    ),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(settingsProvider.notifier).setOnboardingDone(true);
    if (!mounted) return;
    await _showProfileSetup();
  }

  Future<void> _showProfileSetup() async {
    String name = '';
    String avatar = UserProfile.kDefaultAvatars[0];
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Column(
            children: [
              Text('🎨', style: TextStyle(fontSize: 40)),
              SizedBox(height: 8),
              Text('プロフィールを作ろう！',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('アバターを選ぼう',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: UserProfile.kDefaultAvatars.take(12).map((e) =>
                    GestureDetector(
                      onTap: () => setDlgState(() => avatar = e),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: avatar == e
                              ? kPrimaryColor.withValues(alpha: 0.2)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: avatar == e
                              ? Border.all(color: kPrimaryColor, width: 2)
                              : null,
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                  ).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  autofocus: true,
                  maxLength: 10,
                  decoration: InputDecoration(
                    labelText: '名前',
                    hintText: '例: まこ、たろう',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kPrimaryColor),
                    ),
                  ),
                  onChanged: (v) => name = v,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final n = name.trim();
                if (n.isEmpty) return;
                final profile = UserProfile(
                  id: const Uuid().v4(),
                  name: n,
                  avatarEmoji: avatar,
                  createdAt: DateTime.now(),
                  grade: 0,
                );
                await ref.read(profileProvider.notifier).addProfile(profile);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('はじめる！',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ],
        ),
      ),
    );
    if (mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => _buildPage(_pages[i]),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _page == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _page == i ? Colors.white : Colors.white54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    onPressed: _page < _pages.length - 1
                        ? () => _pageCtrl.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut)
                        : _finish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _pages[_page].color,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27)),
                    ),
                    child: Text(
                      _page < _pages.length - 1 ? '次へ ▶' : 'はじめる！',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_page < _pages.length - 1)
            Positioned(
              top: 56,
              right: 20,
              child: TextButton(
                onPressed: _finish,
                child: const Text('スキップ', style: TextStyle(color: Colors.white70)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardPage page) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            page.color,
            page.color.withValues(alpha: 0.7),
            page.color.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UkalabEmoji(page.emoji, size: 96),
              const SizedBox(height: 32),
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                page.desc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardPage {
  final String emoji;
  final String title;
  final String desc;
  final Color color;
  const _OnboardPage({
    required this.emoji, required this.title,
    required this.desc, required this.color,
  });
}
