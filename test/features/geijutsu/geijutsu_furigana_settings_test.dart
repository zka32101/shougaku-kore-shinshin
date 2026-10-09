import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shougaku_kore_doutoku/features/geijutsu/providers/app_providers.dart';
import 'package:shougaku_kore_doutoku/features/geijutsu/screens/home_ec/home_ec_hub_screen.dart';
import 'package:shougaku_kore_doutoku/features/geijutsu/screens/art/color_diagnosis_screen.dart';
import 'package:shougaku_kore_doutoku/features/geijutsu/screens/music/music_hub_screen.dart';
import 'package:shougaku_kore_doutoku/features/geijutsu/screens/settings_screen.dart';
import 'package:shougaku_kore_doutoku/screens/settings/help_screen.dart';
import 'package:shougaku_kore_doutoku/screens/settings/privacy_policy_screen.dart';
import 'package:shougaku_kore_doutoku/widgets/furigana_text.dart';

Future<void> _pump(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(1080, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  geijutsuPrefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(ProviderScope(child: MaterialApp(home: home)));
  await tester.pumpAndSettle();
}

void main() {
  group('芸術の画面でFuriganaTextが使われる', () {
    final screens = <String, Widget>{
      'HomeEcHub': const HomeEcHubScreen(),
      'ColorDiagnosis': const ColorDiagnosisScreen(),
      'MusicHub': const MusicHubScreen(),
    };
    for (final e in screens.entries) {
      testWidgets(e.key, (tester) async {
        await _pump(tester, e.value);
        expect(find.byType(FuriganaText), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('芸術の設定メニュー', () {
    setUp(() => PackageInfo.setMockInitialValues(
          appName: 'x',
          packageName: 'x',
          version: '9.8.7',
          buildNumber: '1',
          buildSignature: '',
        ));

    testWidgets('実バージョンを表示し、利用規約(未実装)は出さない', (tester) async {
      await _pump(tester, const SettingsScreen());
      expect(find.text('バージョン 9.8.7'), findsOneWidget);
      expect(find.textContaining('利用規約'), findsNothing);
    });

    for (final c in <String, Type>{
      'プライバシーポリシー': PrivacyPolicyScreen,
      '使い方ガイド': HelpScreen,
      'お問い合わせ': HelpScreen,
    }.entries) {
      testWidgets('${c.key} をタップすると画面が開く', (tester) async {
        await _pump(tester, const SettingsScreen());
        final tile = find.widgetWithText(ListTile, c.key);
        await tester.ensureVisible(tile);
        await tester.tap(tile);
        await tester.pumpAndSettle();
        expect(find.byType(c.value), findsOneWidget);
      });
    }
  });
}
