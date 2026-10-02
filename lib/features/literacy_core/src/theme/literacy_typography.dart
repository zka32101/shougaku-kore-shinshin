import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../enums/grade_level.dart';
import '../enums/literacy_ui_level.dart';

/// フレームワーク §4: 学年別タイポグラフィ
class LiteracyTypography {
  LiteracyTypography._();

  static TextTheme buildFor(GradeLevel grade) {
    final level = LiteracyUILevelExt.from(grade);
    final base = level.baseTextSize;
    final color = const Color(0xFF2C3E50);
    final muted = const Color(0xFF7F8C8D);

    // 低学年は丸みのあるフォント、高学年はコンパクト
    final fontFamily = grade == GradeLevel.low
        ? GoogleFonts.mPlusRounded1c
        : GoogleFonts.notoSansJp;

    return TextTheme(
      displayLarge: fontFamily(fontSize: base + 14, fontWeight: FontWeight.bold, color: color),
      displayMedium: fontFamily(fontSize: base + 10, fontWeight: FontWeight.bold, color: color),
      displaySmall: fontFamily(fontSize: base + 6, fontWeight: FontWeight.bold, color: color),
      headlineLarge: fontFamily(fontSize: base + 8, fontWeight: FontWeight.bold, color: color),
      headlineMedium: fontFamily(fontSize: base + 4, fontWeight: FontWeight.bold, color: color),
      headlineSmall: fontFamily(fontSize: base + 2, fontWeight: FontWeight.bold, color: color),
      titleLarge: fontFamily(fontSize: base + 2, fontWeight: FontWeight.w600, color: color),
      titleMedium: fontFamily(fontSize: base, fontWeight: FontWeight.w600, color: color),
      titleSmall: fontFamily(fontSize: base - 1, fontWeight: FontWeight.w500, color: color),
      bodyLarge: fontFamily(fontSize: base, color: color),
      bodyMedium: fontFamily(fontSize: base - 1, color: color),
      bodySmall: fontFamily(fontSize: base - 2, color: muted),
      labelLarge: fontFamily(fontSize: base, fontWeight: FontWeight.bold, color: color),
      labelMedium: fontFamily(fontSize: base - 1, fontWeight: FontWeight.w500, color: color),
      labelSmall: fontFamily(fontSize: base - 2, color: muted),
    );
  }

  /// 問題文テキストサイズ（重要：読みやすさ最優先）
  static double questionTextSize(GradeLevel grade) {
    switch (grade) {
      case GradeLevel.low: return 22;
      case GradeLevel.mid: return 18;
      case GradeLevel.high: return 16;
    }
  }

  /// 選択肢ボタン内テキストサイズ
  static double choiceTextSize(GradeLevel grade) {
    switch (grade) {
      case GradeLevel.low: return 20;
      case GradeLevel.mid: return 16;
      case GradeLevel.high: return 14;
    }
  }

  /// フィードバックテキストサイズ
  static double feedbackTextSize(GradeLevel grade) {
    switch (grade) {
      case GradeLevel.low: return 18;
      case GradeLevel.mid: return 15;
      case GradeLevel.high: return 13;
    }
  }
}
