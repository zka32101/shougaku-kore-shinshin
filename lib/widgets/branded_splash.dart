import 'package:flutter/material.dart';

/// 起動画面の背景色（白固定。ダークモードでも変えない）。
/// android の values/colors.xml の splash_background と同じ値にする。
const Color splashBackground = Color(0xFFFFFFFF);

/// 小学コレ！シリーズ共通の起動画面（1枚構成）。
///
/// 白背景。中央にアプリアイコン + 小さな読み込み表示、下寄りにシリーズロゴ、
/// 最下部に組織ロゴ。起動中の画面（初期化前）とアプリ内スプラッシュの両方で
/// このウィジェットを使い、見た目を1枚に揃える。
class BrandedSplash extends StatelessWidget {
  const BrandedSplash({super.key});

  static const Color _progressColor = Color(0xFF263250);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: splashBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        'assets/branding/app_icon.png',
                        key: const ValueKey('splash_app_icon'),
                        width: 168,
                        height: 168,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: _progressColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Image.asset(
              'assets/branding/series_logo.png',
              key: const ValueKey('splash_series_logo'),
              width: 260,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Image.asset(
              'assets/branding/yourwish_logo.png',
              key: const ValueKey('splash_company_logo'),
              height: 84,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
