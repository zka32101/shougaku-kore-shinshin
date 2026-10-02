import 'package:flutter/material.dart';
import '../enums/grade_level.dart';

/// フレームワーク §4: 学年別カラーパレット
class LiteracyColors {
  LiteracyColors._();

  // 学年別メインカラー
  static const lowPrimary = Color(0xFFFF7043);   // オレンジ - 活発・遊び感覚
  static const midPrimary = Color(0xFF26A69A);   // ティール - 整理・分析
  static const highPrimary = Color(0xFF3F51B5);  // インディゴ - 深化・戦略

  // 教科別アクセントカラー（全学年共通）
  static const mathColor = Color(0xFFE91E63);
  static const japaneseColor = Color(0xFFF39C12);
  static const scienceColor = Color(0xFF4CAF50);
  static const socialColor = Color(0xFF2196F3);
  static const programmingColor = Color(0xFF9C27B0);
  static const moralColor = Color(0xFFFF9800);
  static const englishColor = Color(0xFF00BCD4);

  // ステータスカラー（学年共通）
  static const correct = Color(0xFF4CAF50);
  static const incorrect = Color(0xFFF44336);
  static const neutral = Color(0xFF9E9E9E);
  static const warning = Color(0xFFFF9800);

  // 背景
  static const bgLow = Color(0xFFFFF8E1);    // 温かみのある黄白
  static const bgMid = Color(0xFFF1F8E9);    // 清潔な薄緑
  static const bgHigh = Color(0xFFECEFF1);   // クールな薄灰

  static Color primaryFor(GradeLevel grade) {
    switch (grade) {
      case GradeLevel.low: return lowPrimary;
      case GradeLevel.mid: return midPrimary;
      case GradeLevel.high: return highPrimary;
    }
  }

  static Color backgroundFor(GradeLevel grade) {
    switch (grade) {
      case GradeLevel.low: return bgLow;
      case GradeLevel.mid: return bgMid;
      case GradeLevel.high: return bgHigh;
    }
  }

  /// フレームワーク §4 Level1: 低学年は最大6色
  static const lowPalette = [
    Color(0xFFFF7043),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFFEB3B),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
  ];

  /// フレームワーク §4 Level2: 中学年は最大8色（教科別）
  static const midPalette = [
    Color(0xFF26A69A),
    Color(0xFF66BB6A),
    Color(0xFF42A5F5),
    Color(0xFFFFA726),
    Color(0xFFEC407A),
    Color(0xFFAB47BC),
    Color(0xFF26C6DA),
    Color(0xFF8D6E63),
  ];

  /// フレームワーク §4 Level3: 高学年はモノトーン基調＋アクセント
  static const highPalette = [
    Color(0xFF3F51B5),
    Color(0xFF607D8B),
    Color(0xFF78909C),
    Color(0xFF90A4AE),
    Color(0xFF3F51B5), // accent
  ];
}
