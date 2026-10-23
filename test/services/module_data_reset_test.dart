import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shougaku_kore_doutoku/services/module_data_reset.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      // 体育
      'taiku_badges': ['a'],
      'taiku_streak': 3,
      'taiku_activity_memories': ['x'],
      'composition_cache': 'c',
      'HomeEcTopic.cook.1': true,
      'literacy_progress_taiku_u1': '{}',
      'taiku_child_profiles': '[]',
      'taiku_current_profile_id': 'p',
      'taiku_onboarded': true,
      // 芸術
      'badges': 'b0',
      'p1_badges': 'b1',
      'p1_artworks': 'a1',
      'p1_currentArtMonth': 4,
      'p1_topic_cook_act1': true,
      'profiles': '[{}]',
      'activeProfileId': 'p1',
      'onboardingDone': true,
      // アプリ全体
      'literacy_grade_level': 1,
      'local_story_completions_c1': '[]',
      'display_name': 'はな',
    });
  });

  test('体育のリセットは学習データだけを消し、プロフィールとアプリ全体の設定は残す', () async {
    final p = await SharedPreferences.getInstance();
    final removed = await ModuleDataReset.resetTaiku(p);
    expect(removed, 6);
    expect(p.containsKey('literacy_progress_taiku_u1'), isFalse);
    expect(p.containsKey('taiku_badges'), isFalse);
    expect(p.containsKey('taiku_streak'), isFalse);
    expect(p.containsKey('taiku_activity_memories'), isFalse);
    expect(p.containsKey('composition_cache'), isFalse);
    expect(p.containsKey('HomeEcTopic.cook.1'), isFalse);
    // 残るもの
    expect(p.containsKey('taiku_child_profiles'), isTrue);
    expect(p.containsKey('taiku_current_profile_id'), isTrue);
    expect(p.containsKey('taiku_onboarded'), isTrue);
    expect(p.getInt('literacy_grade_level'), 1);
    expect(p.containsKey('local_story_completions_c1'), isTrue);
    expect(p.getString('display_name'), 'はな');
    // 芸術のデータには触れない
    expect(p.containsKey('p1_badges'), isTrue);
  });

  test('芸術のリセットは記録だけを消し、プロフィールと体育・全体の設定は残す', () async {
    final p = await SharedPreferences.getInstance();
    final removed = await ModuleDataReset.resetGeijutsu(p);
    expect(removed, 5);
    for (final k in [
      'badges',
      'p1_badges',
      'p1_artworks',
      'p1_currentArtMonth',
      'p1_topic_cook_act1',
    ]) {
      expect(p.containsKey(k), isFalse, reason: k);
    }
    // 残るもの
    expect(p.containsKey('profiles'), isTrue);
    expect(p.containsKey('activeProfileId'), isTrue);
    expect(p.containsKey('onboardingDone'), isTrue);
    expect(p.containsKey('taiku_badges'), isTrue, reason: '体育の badges は消さない');
    expect(p.getInt('literacy_grade_level'), 1);
    expect(p.getString('display_name'), 'はな');
  });

  test('キーの判定: taiku_badges は芸術のキーではない', () {
    expect(ModuleDataReset.isGeijutsuDataKey('taiku_badges'), isFalse);
    expect(ModuleDataReset.isTaikuDataKey('badges'), isFalse);
    expect(ModuleDataReset.isTaikuDataKey('taiku_onboarded'), isFalse);
  });
}
