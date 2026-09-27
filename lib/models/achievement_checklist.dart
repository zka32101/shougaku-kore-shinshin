import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// できたことチェックリストの項目カテゴリ
enum ChecklistCategory {
  lifeSkill, // 生活習慣
  kindness, // やさしさ
  honesty, // せいじつさ
  responsibility, // せきにんかん
  courage, // ゆうき
  respect, // そんちょう
  study, // がくしゅう
}

extension ChecklistCategoryX on ChecklistCategory {
  String get label {
    switch (this) {
      case ChecklistCategory.lifeSkill:
        return '生活';
      case ChecklistCategory.kindness:
        return 'やさしさ';
      case ChecklistCategory.honesty:
        return 'せいじつさ';
      case ChecklistCategory.responsibility:
        return 'せきにん';
      case ChecklistCategory.courage:
        return 'ゆうき';
      case ChecklistCategory.respect:
        return 'そんちょう';
      case ChecklistCategory.study:
        return 'がくしゅう';
    }
  }

  String get emoji {
    switch (this) {
      case ChecklistCategory.lifeSkill:
        return '🧦';
      case ChecklistCategory.kindness:
        return '💛';
      case ChecklistCategory.honesty:
        return '🤝';
      case ChecklistCategory.responsibility:
        return '📌';
      case ChecklistCategory.courage:
        return '🦁';
      case ChecklistCategory.respect:
        return '🙏';
      case ChecklistCategory.study:
        return '📚';
    }
  }

  Color get color {
    switch (this) {
      case ChecklistCategory.lifeSkill:
        return AppColors.virtueCooperation;
      case ChecklistCategory.kindness:
        return AppColors.virtueKindness;
      case ChecklistCategory.honesty:
        return AppColors.virtueHonesty;
      case ChecklistCategory.responsibility:
        return AppColors.virtueResponsibility;
      case ChecklistCategory.courage:
        return AppColors.virtueCourage;
      case ChecklistCategory.respect:
        return AppColors.virtueRespect;
      case ChecklistCategory.study:
        return AppColors.info;
    }
  }
}

/// 年齢（学年）に合わせて用意された「できたこと」チェックリストの1項目
class AchievementChecklistItem {
  final String id;
  final String title;
  final ChecklistCategory category;
  final int minGrade; // このアイテムが対象となる最小学年 (1-6)
  final int maxGrade; // このアイテムが対象となる最大学年 (1-6)

  const AchievementChecklistItem({
    required this.id,
    required this.title,
    required this.category,
    required this.minGrade,
    required this.maxGrade,
  });
}
