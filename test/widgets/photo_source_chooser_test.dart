import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shougaku_kore_doutoku/widgets/photo_source_chooser.dart';

void main() {
  Future<ImageSource?> open(WidgetTester tester, Key key) async {
    ImageSource? result;
    var done = false;
    await tester.pumpWidget(MaterialApp(
      // 入れ子の Navigator の中から開いても、ダイアログだけが閉じることを確認する
      home: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute<void>(
          builder: (ctx) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showPhotoSourceDialog(ctx);
                  done = true;
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('カメラでとる'), findsOneWidget);
    expect(find.text('アルバムからえらぶ'), findsOneWidget);
    await tester.tap(find.byKey(key));
    await tester.pumpAndSettle();
    expect(done, isTrue);
    expect(find.text('open'), findsOneWidget, reason: 'screen stays open');
    return result;
  }

  testWidgets('camera button returns ImageSource.camera', (tester) async {
    expect(await open(tester, const Key('photo_source_camera')),
        ImageSource.camera);
  });

  testWidgets('gallery button returns ImageSource.gallery', (tester) async {
    expect(await open(tester, const Key('photo_source_gallery')),
        ImageSource.gallery);
  });

  testWidgets('later returns null', (tester) async {
    expect(await open(tester, const Key('photo_source_later')), isNull);
  });

  testWidgets('pickPhotoWithMessage shows a friendly message on denial',
      (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      })),
    ));
    XFile? file = XFile('x');
    final f = pickPhotoWithMessage(
      ctx,
      ImageSource.camera,
      pick: (_) async => throw PlatformException(code: 'camera_access_denied'),
    ).then((v) => file = v);
    await tester.pump();
    await f;
    await tester.pump();
    expect(file, isNull);
    expect(find.textContaining('カメラが つかえないよ'), findsOneWidget);
  });

  testWidgets('pickPhotoWithMessage passes the chosen source through',
      (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      })),
    ));
    ImageSource? seen;
    final got = await pickPhotoWithMessage(
      ctx,
      ImageSource.gallery,
      pick: (s) async {
        seen = s;
        return XFile('photo.jpg');
      },
    );
    expect(seen, ImageSource.gallery);
    expect(got?.path, 'photo.jpg');
  });
}
