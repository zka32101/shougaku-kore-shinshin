import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 体育モジュールの入口。心身の起動画面が既に出ているため、独自の
/// 起動画面は出さず、初回確認だけして直ちにホーム/オンボーディングへ進む。
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final hasOnboarded = prefs.getBool('taiku_onboarded') ?? false;
    if (!mounted) return;
    Navigator.of(context)
        .pushReplacementNamed(hasOnboarded ? '/home' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.shrink());
}
