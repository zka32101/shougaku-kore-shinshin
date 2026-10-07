import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shougaku_kore_doutoku/features/geijutsu/providers/app_providers.dart';

Future<ProviderContainer> _container(Map<String, Object> init) async {
  SharedPreferences.setMockInitialValues(init);
  geijutsuPrefs = await SharedPreferences.getInstance();
  final c = ProviderContainer();
  addTearDown(c.dispose);
  return c;
}

const _one =
    '[{"id":"old1","name":"てst","avatarEmoji":"🎨","createdAt":"2026-01-01T00:00:00.000","grade":0}]';
const _two =
    '[{"id":"a","name":"A","avatarEmoji":"🎨","createdAt":"2026-01-01T00:00:00.000","grade":0},'
    '{"id":"b","name":"B","avatarEmoji":"🎵","createdAt":"2026-01-01T00:00:00.000","grade":0}]';

void main() {
  test('プロフィール未選択でも自動で内部プロフィールが作られる', () async {
    final c = await _container({});
    final s = c.read(profileProvider);
    expect(s.profiles.length, 1);
    expect(s.activeId, isNotEmpty);
    expect(s.active, isNotNull);
  });

  test('既存の1プロフィールはIDを維持し(データ保持)自動選択される', () async {
    final c = await _container({
      'profiles': _one,
      'old1_artworks': '{"x":1}',
    });
    expect(c.read(profileProvider).activeId, 'old1');
    expect(geijutsuPrefs!.getString('old1_artworks'), isNotNull);
  });

  test('複数あれば最後に使ったものを使い、全て残す', () async {
    final c = await _container({'profiles': _two, 'activeProfileId': 'b'});
    expect(c.read(profileProvider).activeId, 'b');
    expect(c.read(profileProvider).profiles.length, 2);
  });

  test('activeIdが無効なら先頭にフォールバック', () async {
    final c = await _container({'profiles': _two, 'activeProfileId': 'zzz'});
    expect(c.read(profileProvider).activeId, 'a');
  });

  test('表示名はアプリ全体のプロフィール、無ければ既定値', () async {
    final c = await _container({});
    c.listen(geijutsuDisplayProvider, (_, _) {});
    expect(c.read(geijutsuDisplayProvider).name, 'ユーザー'); // 読み込み前は既定値
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final d = c.read(geijutsuDisplayProvider);
    expect(d.name, '子ども1'); // アプリ全体の既定プロフィール
    expect(d.avatarEmoji, '👦');
    expect(d.avatarEmoji, isNotEmpty);
  });
}
