import 'package:flutter/material.dart';
import '../enums/grade_level.dart';
import '../enums/literacy_ui_level.dart';
import 'literacy_colors.dart';
import 'literacy_typography.dart';

/// フレームワーク §4: 学年別 ThemeData を生成するファクトリ
class LiteracyTheme {
  LiteracyTheme._();

  static ThemeData buildFor(GradeLevel grade, {Color? subjectColor}) {
    final primary = subjectColor ?? LiteracyColors.primaryFor(grade);
    final bg = LiteracyColors.backgroundFor(grade);
    final level = LiteracyUILevelExt.from(grade);
    final textTheme = LiteracyTypography.buildFor(grade);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        surface: Colors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: level.baseTextSize + 2,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: level.minButtonSize,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(level.cardBorderRadius),
          ),
          padding: _buttonPadding(level),
          textStyle: TextStyle(
            fontSize: level.baseTextSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: level.minButtonSize,
          side: BorderSide(color: primary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(level.cardBorderRadius),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: _cardElevation(level),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(level.cardBorderRadius),
        ),
      ),
      iconTheme: IconThemeData(
        size: level.baseTextSize + 8,
        color: primary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: level.baseTextSize - 3),
        unselectedLabelStyle: TextStyle(fontSize: level.baseTextSize - 4),
      ),
      sliderTheme: SliderThemeData(activeTrackColor: primary),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? primary : null,
        ),
      ),
    );
  }

  static EdgeInsets _buttonPadding(LiteracyUILevel level) {
    switch (level) {
      case LiteracyUILevel.simple:
        return const EdgeInsets.symmetric(horizontal: 28, vertical: 16);
      case LiteracyUILevel.structured:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case LiteracyUILevel.analytical:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
    }
  }

  static double _cardElevation(LiteracyUILevel level) {
    switch (level) {
      case LiteracyUILevel.simple: return 4;
      case LiteracyUILevel.structured: return 2;
      case LiteracyUILevel.analytical: return 1;
    }
  }
}
