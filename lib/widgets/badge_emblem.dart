import 'package:flutter/material.dart';
import 'package:shougaku_kore_doutoku/widgets/ukalab_emoji.dart';

/// 実績バッジの共通意匠（assets/badges/badge_<意匠>.webp）。対応が無い・読めないバッジは従来の絵文字で出す。
///
/// 意匠への対応は design/小学コレ！/共通/実績バッジ_意匠対応表_2026-10-07.md（心身）。
/// 道徳・体育・芸術/家庭科でバッジIDが重複するもの(streak_3 等)は同じ意匠。
class BadgeEmblem extends StatelessWidget {
  const BadgeEmblem({super.key, required this.badgeId, required this.fallbackEmoji, this.size = 32});

  final String badgeId;
  final String fallbackEmoji;
  final double size;

  static const Map<String, String> emblemMap = {
    'kindness_1': 'heart',
    'kindness_3': 'heart',
    'honesty_1': 'heart',
    'honesty_3': 'heart',
    'courage_1': 'heart',
    'courage_3': 'heart',
    'respect_1': 'heart',
    'first_story': 'first_step',
    'story_5': 'challenge',
    'story_10': 'challenge',
    'stage_1_clear': 'challenge',
    'stage_2_clear': 'challenge',
    'stage_3_clear': 'challenge',
    'stage_4_clear': 'challenge',
    'stage_5_clear': 'challenge',
    'stage_6_clear': 'challenge',
    'stage_7_clear': 'challenge',
    'stage_8_clear': 'challenge',
    'stage_9_clear': 'challenge',
    'stage_10_clear': 'challenge',
    'stage_11_clear': 'challenge',
    'stage_12_clear': 'challenge',
    'stage_13_clear': 'clock',
    'stage_14_clear': 'heart',
    'stage_15_clear': 'challenge',
    'stage_16_clear': 'challenge',
    'stage_17_clear': 'challenge',
    'stage_18_clear': 'challenge',
    'stage_19_clear': 'challenge',
    'stage_20_clear': 'challenge',
    'stage_21_clear': 'heart',
    'grade_low': 'gradcap',
    'grade_mid': 'gradcap',
    'grade_high': 'gradcap',
    'streak_3': 'streak',
    'streak_7': 'streak',
    'streak_14': 'streak',
    'streak_30': 'streak',
    'streak_60': 'streak',
    'streak_100': 'streak',
    'activity_1': 'first_step',
    'activity_5': 'collection',
    'activity_10': 'collection',
    'activity_disaster': 'heart',
    'activity_sports': 'challenge',
    'activity_parent': 'handshake',
    'perfect_score': 'perfect',
    'perfect_3': 'perfect',
    'all_stages_low': 'gradcap',
    'all_stages_mid': 'gradcap',
    'all_stages_high': 'gradcap',
    'sports_all': 'master',
    'disaster_all': 'master',
    'nutrition_all': 'master',
    'career_all': 'master',
    'all_clear': 'gradcap',
    'art_diagnosis': 'first_step',
    'art_m1_lv1': 'challenge',
    'art_m1_lv2': 'pencil',
    'art_m1_lv3': 'challenge',
    'art_m1_lv4': 'master',
    'art_m12_complete': 'gradcap',
    'art_appreciation': 'book',
    'art_shape_play': 'pencil',
    'music_diagnosis': 'first_step',
    'music_s1': 'levelup',
    'music_s2': 'levelup',
    'music_s3': 'levelup',
    'music_s4': 'levelup',
    'music_s8': 'gem',
    'music_free_piano': 'first_step',
    'music_theme_compose_spring': 'pencil',
    'music_theme_compose_summer': 'pencil',
    'music_theme_compose_autumn': 'pencil',
    'music_theme_compose_winter': 'pencil',
    'music_rhythm': 'challenge',
    'music_appreciation': 'book',
    'home_diagnosis': 'first_step',
    'home_m1_cooking': 'challenge',
    'home_m1_fashion': 'challenge',
    'home_m12_complete': 'gradcap',
    'home_tidying_complete': 'challenge',
    'home_cleaning_complete': 'challenge',
    'home_shopping_complete': 'challenge',
    'home_chores_complete': 'challenge',
    'home_eco_complete': 'heart',
    'home_nutrition': 'book',
    'home_sewing': 'pencil',
  };

  /// バッジIDに対応する意匠名。なければ null。
  static String? emblemOf(String badgeId) => emblemMap[badgeId];

  static final RegExp _stageId = RegExp(r'^stage_(\d+)_clear$');

  /// 体育のステージバッジ（stage_N_clear）は、同じ意匠が並ぶので番号 N を重ねて区別する。
  /// 該当しなければ null。
  static String? stageLabelOf(String badgeId) => _stageId.firstMatch(badgeId)?.group(1);

  @override
  Widget build(BuildContext context) {
    final name = emblemMap[badgeId];
    if (name == null) return UkalabEmoji(fallbackEmoji, size: size);
    final image = Image.asset(
      'assets/badges/badge_$name.webp',
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
      errorBuilder: (context, error, stackTrace) => UkalabEmoji(fallbackEmoji, size: size),
    );
    final label = stageLabelOf(badgeId);
    if (label == null) return image;
    // 右下に小さな丸で番号を重ねる
    final d = size * 0.42;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: image),
          Positioned(
            right: -size * 0.04,
            bottom: -size * 0.04,
            child: Container(
              width: d,
              height: d,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF16B79A), width: size * 0.04 < 1 ? 1 : size * 0.04),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: d * (label.length > 1 ? 0.5 : 0.62),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F7F6B),
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
