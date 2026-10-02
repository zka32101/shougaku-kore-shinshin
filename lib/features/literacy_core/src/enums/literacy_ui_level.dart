import 'package:flutter/material.dart';
import 'grade_level.dart';

/// フレームワーク §4: UI/UX複雑さレベル
enum LiteracyUILevel {
  /// Level 1: シンプル・ビジュアル重視（低学年）
  simple,

  /// Level 2: 情報構造化・グラフ導入（中学年）
  structured,

  /// Level 3: データ分析・複合表示（高学年）
  analytical,
}

extension LiteracyUILevelExt on LiteracyUILevel {
  static LiteracyUILevel from(GradeLevel grade) {
    switch (grade) {
      case GradeLevel.low: return LiteracyUILevel.simple;
      case GradeLevel.mid: return LiteracyUILevel.structured;
      case GradeLevel.high: return LiteracyUILevel.analytical;
    }
  }

  /// フレームワーク §4: ボタン最小サイズ
  Size get minButtonSize {
    switch (this) {
      case LiteracyUILevel.simple: return const Size(48, 48);
      case LiteracyUILevel.structured: return const Size(32, 32);
      case LiteracyUILevel.analytical: return const Size(24, 24);
    }
  }

  /// フレームワーク §4: 基本テキストサイズ
  double get baseTextSize {
    switch (this) {
      case LiteracyUILevel.simple: return 18;
      case LiteracyUILevel.structured: return 15;
      case LiteracyUILevel.analytical: return 13;
    }
  }

  /// フレームワーク §4: 1画面に表示する最大要素数
  int get maxElementsPerScreen {
    switch (this) {
      case LiteracyUILevel.simple: return 3;
      case LiteracyUILevel.structured: return 8;
      case LiteracyUILevel.analytical: return 15;
    }
  }

  /// フレームワーク §4: 選択肢の最大数
  int get maxChoices {
    switch (this) {
      case LiteracyUILevel.simple: return 4;
      case LiteracyUILevel.structured: return 6;
      case LiteracyUILevel.analytical: return 6;
    }
  }

  /// フレームワーク §4: グラフ表示の可否
  bool get showGraphs {
    switch (this) {
      case LiteracyUILevel.simple: return false;
      case LiteracyUILevel.structured: return true;
      case LiteracyUILevel.analytical: return true;
    }
  }

  /// フレームワーク §4: 複合グラフの可否
  bool get showComplexGraphs {
    switch (this) {
      case LiteracyUILevel.simple: return false;
      case LiteracyUILevel.structured: return false;
      case LiteracyUILevel.analytical: return true;
    }
  }

  /// フレームワーク §4: アニメーション強度（0.0-1.0）
  double get animationIntensity {
    switch (this) {
      case LiteracyUILevel.simple: return 1.0;
      case LiteracyUILevel.structured: return 0.5;
      case LiteracyUILevel.analytical: return 0.1;
    }
  }

  /// フレームワーク §4: サウンド設定
  bool get soundOnByDefault {
    switch (this) {
      case LiteracyUILevel.simple: return true;
      case LiteracyUILevel.structured: return false;
      case LiteracyUILevel.analytical: return false;
    }
  }

  /// フレームワーク §4: ダークモード対応
  bool get supportsDarkMode {
    switch (this) {
      case LiteracyUILevel.simple: return false;
      case LiteracyUILevel.structured: return false;
      case LiteracyUILevel.analytical: return true;
    }
  }

  /// フレームワーク §4: カードの角丸半径
  double get cardBorderRadius {
    switch (this) {
      case LiteracyUILevel.simple: return 24;
      case LiteracyUILevel.structured: return 16;
      case LiteracyUILevel.analytical: return 8;
    }
  }

  /// フレームワーク §4: 情報テキスト最大文字数
  int get maxDescriptionLength {
    switch (this) {
      case LiteracyUILevel.simple: return 16;
      case LiteracyUILevel.structured: return 50;
      case LiteracyUILevel.analytical: return 200;
    }
  }
}
