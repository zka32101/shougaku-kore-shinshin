import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shougaku_kore_doutoku/widgets/branded_splash.dart';

void main() {
  testWidgets('起動画面: 白背景・アイコン/シリーズロゴ/組織ロゴの3アセット（1枚構成）', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BrandedSplash()));
    await tester.pump();

    final assets = tester
        .widgetList<Image>(find.byType(Image))
        .map((i) => (i.image as AssetImage).assetName)
        .toSet();
    expect(assets, {
      'assets/branding/app_icon.png',
      'assets/branding/series_logo.png',
      'assets/branding/yourwish_logo.png',
    });
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFFFFFFFF));
    expect(splashBackground, const Color(0xFFFFFFFF));

    final icon = tester.getCenter(find.byKey(const ValueKey('splash_app_icon')));
    final series = tester.getCenter(find.byKey(const ValueKey('splash_series_logo')));
    final org = tester.getCenter(find.byKey(const ValueKey('splash_company_logo')));
    expect(series.dy, greaterThan(icon.dy));
    expect(org.dy, greaterThan(series.dy));
    expect(tester.takeException(), isNull);
  });

  testWidgets('起動画面: 小画面(360x600)でも溢れず、ロゴが大きい', (tester) async {
    tester.view.physicalSize = const Size(360, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: BrandedSplash()));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byKey(const ValueKey('splash_app_icon'))).width, 168);
    expect(tester.getSize(find.byKey(const ValueKey('splash_series_logo'))).width, 260);
    expect(tester.getSize(find.byKey(const ValueKey('splash_company_logo'))).height, 84);
  });
}
