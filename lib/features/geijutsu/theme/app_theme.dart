import 'package:flutter/material.dart';

// 小学コレ！芸術 - 虹色テーマ
const kPrimaryColor = Color(0xFFFF6B35);   // オレンジ（創造性）
const kPrimaryDark = Color(0xFFE55A25);
const kPrimaryLight = Color(0xFFFF8C5A);
const kBgLight = Color(0xFFFFF8F0);
const kTextDark = Color(0xFF1A1A2E);
const kTextMuted = Color(0xFF6B7280);

// 教科カラー
const kArtColor = Color(0xFFE74C3C);         // 図工：赤
const kArtColorLight = Color(0xFFFFEBEA);
const kMusicColor = Color(0xFF9B59B6);       // 音楽：紫
const kMusicColorLight = Color(0xFFF3E8FF);
const kHomeEcColor = Color(0xFF27AE60);      // 家庭科：緑
const kHomeEcColorLight = Color(0xFFE8F8F0);

// 12色テーマカラー
const kColorRed = Color(0xFFE74C3C);
const kColorOrange = Color(0xFFE67E22);
const kColorYellow = Color(0xFFF1C40F);
const kColorYellowGreen = Color(0xFF9CCC65);
const kColorGreen = Color(0xFF27AE60);
const kColorTeal = Color(0xFF16A085);
const kColorBlue = Color(0xFF2980B9);
const kColorPurple = Color(0xFF8E44AD);
const kColorPink = Color(0xFFE91E8C);
const kColorBrown = Color(0xFF795548);
const kColorGray = Color(0xFF78909C);
const kColorBlack = Color(0xFF2C3E50);

// 月→色のマッピング
const List<Map<String, dynamic>> kMonthColors = [
  {'name': '赤', 'color': kColorRed, 'hex': '#E74C3C', 'keywords': '情熱・エネルギー・行動'},
  {'name': '橙', 'color': kColorOrange, 'hex': '#E67E22', 'keywords': '温かみ・親切・親しみやすさ'},
  {'name': '黄', 'color': kColorYellow, 'hex': '#F1C40F', 'keywords': '楽しさ・光・希望'},
  {'name': '黄緑', 'color': kColorYellowGreen, 'hex': '#9CCC65', 'keywords': '新しさ・成長・爽やかさ'},
  {'name': '緑', 'color': kColorGreen, 'hex': '#27AE60', 'keywords': '安心・自然・バランス'},
  {'name': '青緑', 'color': kColorTeal, 'hex': '#16A085', 'keywords': '穏やかさ・リフレッシュ'},
  {'name': '青', 'color': kColorBlue, 'hex': '#2980B9', 'keywords': '冷静・深さ・広がり'},
  {'name': '紫', 'color': kColorPurple, 'hex': '#8E44AD', 'keywords': '神秘・創造性・高貴さ'},
  {'name': 'ピンク', 'color': kColorPink, 'hex': '#E91E8C', 'keywords': '優しさ・愛・優雅さ'},
  {'name': '茶', 'color': kColorBrown, 'hex': '#795548', 'keywords': '温もり・落ち着き・自然'},
  {'name': 'グレー', 'color': kColorGray, 'hex': '#78909C', 'keywords': 'バランス・洗練・静寂'},
  {'name': '黒白', 'color': kColorBlack, 'hex': '#2C3E50', 'keywords': '決意・選択・新しい一歩'},
];

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'BIZUDPGothic',
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimaryColor,
      primary: kPrimaryColor,
      secondary: kMusicColor,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: kBgLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: kPrimaryColor,
      unselectedItemColor: kTextMuted,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(fontFamily: 'BIZUDPGothic').copyWith(
      headlineLarge: const TextStyle(fontFamily: 'BIZUDPGothic', fontSize: 28, fontWeight: FontWeight.bold, color: kTextDark),
      headlineMedium: const TextStyle(fontFamily: 'BIZUDPGothic', fontSize: 22, fontWeight: FontWeight.bold, color: kTextDark),
      headlineSmall: const TextStyle(fontFamily: 'BIZUDPGothic', fontSize: 18, fontWeight: FontWeight.bold, color: kTextDark),
      bodyLarge: const TextStyle(fontFamily: 'BIZUDPGothic', fontSize: 16, color: kTextDark),
      bodyMedium: const TextStyle(fontFamily: 'BIZUDPGothic', fontSize: 14, color: kTextDark),
      bodySmall: const TextStyle(fontFamily: 'BIZUDPGothic', fontSize: 12, color: kTextMuted),
    ),
  );
}
