import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shougaku_kore_doutoku/features/shop/decor/decor_items.dart';
import 'package:shougaku_kore_doutoku/features/shop/decor/decor_provider.dart';
import 'package:shougaku_kore_doutoku/features/shop/decor/decor_screen.dart';
import 'package:shougaku_kore_doutoku/features/shop/decor/decor_scope.dart';
import 'package:shougaku_kore_doutoku/providers/local_avatar_provider.dart';

Future<ProviderContainer> _container({Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final c = ProviderContainer();
  addTearDown(c.dispose);
  await c.read(decorProvider.notifier).loaded;
  // localAvatarProvider の読み込み完了を待つ
  c.read(localAvatarProvider);
  await Future<void>.delayed(const Duration(milliseconds: 20));
  return c;
}

void main() {
  test('商品の画像・サムネイルがすべて存在し、IDは重複しない', () {
    final ids = <String>{};
    for (final i in kDecorItems) {
      expect(ids.add(i.id), true, reason: '重複: ${i.id}');
      expect(File(i.asset).existsSync(), true, reason: i.asset);
      expect(File(i.thumb).existsSync(), true, reason: i.thumb);
    }
    expect(kDecorItems.length, 18);
    expect(decorItemById('bg_shinshin')?.coinCost, 200);
  });

  test('季節の商品は現在の季節の分だけ売る', () {
    final winter = decorItemsForSale(DateTime(2026, 1, 10)).map((e) => e.id).toSet();
    expect(winter.containsAll({'bg_snow', 'effect_snow', 'frame_newyear', 'bg_space'}), true);
    expect(winter.contains('bg_sakura'), false);
    final summer = decorItemsForSale(DateTime(2026, 7, 10)).map((e) => e.id).toSet();
    expect(summer.contains('effect_waves'), true);
    expect(summer.contains('bg_snow'), false);
  });

  test('買うとコインが減り所持が保存される。コイン不足・二重購入は失敗', () async {
    final c = await _container(prefs: {'local_avatar_coins': 450});
    final n = c.read(decorProvider.notifier);
    final item = decorItemById('bg_space')!;
    expect(await n.purchase(item), true);
    expect(c.read(localAvatarProvider).coins, 250);
    expect(await n.purchase(item), false); // 二重購入
    expect(c.read(localAvatarProvider).coins, 250);
    expect(await n.purchase(decorItemById('bg_ocean')!), true);
    expect(await n.purchase(decorItemById('bg_forest')!), false); // 不足
    final p = await SharedPreferences.getInstance();
    expect(p.getStringList(DecorNotifier.kOwned), containsAll(['bg_space', 'bg_ocean']));
    expect(p.getInt('local_avatar_coins'), 50);
  });

  test('持っていないきせかえはつけられない', () async {
    final c = await _container();
    expect(await c.read(decorProvider.notifier).equip(decorItemById('bg_space')!), false);
    expect(c.read(decorProvider).background, isNull);
  });

  test('持っているきせかえをつけて、保存され、はずせる', () async {
    final c = await _container(prefs: {'decor_owned': ['bg_space', 'frame_star']});
    await c.read(decorProvider.notifier).loaded;
    final n = c.read(decorProvider.notifier);
    expect(await n.equip(decorItemById('bg_space')!), true);
    expect(await n.equip(decorItemById('frame_star')!), true);
    expect(c.read(activeDecorProvider).background, 'bg_space');
    expect(c.read(activeDecorProvider).frame, 'frame_star');
    final p = await SharedPreferences.getInstance();
    expect(p.getString('decor_background'), 'bg_space');
    await n.unequip(DecorKind.background);
    expect(c.read(activeDecorProvider).background, isNull);
    expect(p.getString('decor_background'), isNull);
    expect(c.read(activeDecorProvider).frame, 'frame_star');
  });

  test('保存されていても、持っていない・種類が違う・知らないIDは無視される', () async {
    final c = await _container(prefs: {
      'decor_background': 'bg_snow',
      'decor_frame': 'bg_space',
      'decor_effect': 'unknown',
      'decor_owned': ['bg_space'],
    });
    final a = c.read(activeDecorProvider);
    expect(a.background, isNull); // 持っていない
    expect(a.frame, isNull); // 種類が違う
    expect(a.effect, isNull); // 知らないID
  });

  testWidgets('背景をつけると、画面の背景色が透明になり、つけていなければ元の色のまま', (tester) async {
    Color? seen;
    Widget probe(bool bg) => MaterialApp(
          home: DecorScope(
            hasBackground: bg,
            child: Builder(builder: (context) {
              seen = DecorScope.pageBg(context, const Color(0xFFF7F9FC));
              return const SizedBox();
            }),
          ),
        );
    await tester.pumpWidget(probe(false));
    expect(seen, const Color(0xFFF7F9FC));
    await tester.pumpWidget(probe(true));
    expect(seen, Colors.transparent);
  });

  testWidgets('きせかえ画面: 持っていなければ案内、持っていればえらんでつけられる', (tester) async {
    final c = (await tester.runAsync(() => _container(prefs: {'decor_owned': ['bg_space', 'bg_ocean']})))!;
    await tester.runAsync(() => c.read(decorProvider.notifier).loaded);
    await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const MaterialApp(home: DecorScreen())));
    await tester.pump();
    expect(find.text('背景'), findsOneWidget);
    expect(find.text('宇宙の背景'), findsOneWidget);
    await tester.tap(find.text('宇宙の背景'));
    await tester.pump();
    expect(c.read(activeDecorProvider).background, 'bg_space');
    expect(find.text('✓ 宇宙の背景'), findsOneWidget);
    await tester.tap(find.text('なし').first);
    await tester.pump();
    expect(c.read(activeDecorProvider).background, isNull);

    final empty = (await tester.runAsync(() => _container()))!;
    await tester.pumpWidget(UncontrolledProviderScope(container: empty, child: const MaterialApp(home: DecorScreen())));
    await tester.pump();
    expect(find.textContaining('まだきせかえをもっていないよ'), findsOneWidget);
  });

  testWidgets('DecorBackdrop: 背景つきなら絵と膜を敷き、なければ子だけ', (tester) async {
    final c = (await tester.runAsync(() => _container(prefs: {'decor_owned': ['bg_space']})))!;
    Widget app() => UncontrolledProviderScope(
          container: c,
          child: MaterialApp(builder: (context, child) => DecorBackdrop(child: child!), home: const Scaffold(body: Text('こんにちは'))),
        );
    await tester.pumpWidget(app());
    await tester.pump();
    expect(find.byType(Image), findsNothing);
    await tester.runAsync(() => c.read(decorProvider.notifier).equip(decorItemById('bg_space')!));
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('こんにちは'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('波エフェクト: 画面高の12%以下・不透明度55%で、タップを通す', (tester) async {
    final c = (await tester.runAsync(() => _container(prefs: {'decor_owned': ['effect_waves']})))!;
    await tester.runAsync(() => c.read(decorProvider.notifier).equip(decorItemById('effect_waves')!));
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(builder: (context, child) => DecorBackdrop(child: child!), home: const Scaffold(body: Text('x'))),
    ));
    await tester.pump();
    final h = tester.getSize(find.byKey(const ValueKey('decor_waves'))).height;
    expect(h, lessThanOrEqualTo(tester.view.physicalSize.height / tester.view.devicePixelRatio * 0.12 + 0.01));
    final op = tester.widget<Opacity>(find.descendant(of: find.byKey(const ValueKey('decor_waves')), matching: find.byType(Opacity)));
    expect(op.opacity, closeTo(0.55, 0.01));
    expect(find.ancestor(of: find.byKey(const ValueKey('decor_waves')), matching: find.byType(IgnorePointer)), findsWidgets);
  });

  testWidgets('背景つきのときだけ、上端に暗い帯(ステータスバー用)と見出しの白地が出る', (tester) async {
    final c = (await tester.runAsync(() => _container(prefs: {'decor_owned': ['bg_space']})))!;
    late BuildContext inner;
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        builder: (context, child) => DecorBackdrop(child: child!),
        home: Scaffold(body: Builder(builder: (ctx) {
          inner = ctx;
          return const Text('x');
        })),
      ),
    ));
    await tester.pump();
    expect(find.byKey(const ValueKey('decor_status_scrim')), findsNothing);
    expect(DecorScope.chipBg(inner), Colors.transparent);
    await tester.runAsync(() => c.read(decorProvider.notifier).equip(decorItemById('bg_space')!));
    await tester.pump();
    expect(find.byKey(const ValueKey('decor_status_scrim')), findsOneWidget);
    expect(DecorScope.chipBg(inner).a > 0.5, true);
  });

  testWidgets('DecorFrame: 28px のアバターにはフレームが出る(小さすぎると出ない)', (tester) async {
    Widget app(double size) => MaterialApp(
          home: DecorScope(hasBackground: false, frameAsset: 'assets/shop/frame_star.webp', child: DecorFrame(size: size, child: const SizedBox())),
        );
    await tester.pumpWidget(app(28));
    expect(find.byType(Image), findsOneWidget);
    await tester.pumpWidget(app(20));
    expect(find.byType(Image), findsNothing);
  });
}
