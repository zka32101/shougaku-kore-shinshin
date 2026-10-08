import 'package:flutter/material.dart';

import 'branded_splash.dart';

/// 起動中の読み込み画面（初期化の前に出す）。
///
/// アプリ内の起動画面（SplashScreen）と同じ [BrandedSplash] を使い、
/// 起動画面が2枚に見えないよう1枚の見た目に揃える。
class StartupSplash extends StatelessWidget {
  const StartupSplash({super.key});

  @override
  Widget build(BuildContext context) => const BrandedSplash();
}
