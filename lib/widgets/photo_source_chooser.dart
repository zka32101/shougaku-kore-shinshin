import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// 写真の入手方法（カメラでとる / アルバムからえらぶ）をえらぶダイアログ。
///
/// 「あとで」でとじたときは null を返す。
/// ダイアログ自身の context で pop する（入れ子 Navigator 内の画面から呼んでも
/// 画面側の Navigator を誤って pop しない）。
Future<ImageSource?> showPhotoSourceDialog(
  BuildContext context, {
  String title = '📷 しゃしんを のこそう！',
  String? message,
}) {
  return showDialog<ImageSource>(
    context: context,
    builder: (dctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (message != null) ...[
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
          ],
          ElevatedButton.icon(
            key: const Key('photo_source_camera'),
            icon: const Icon(Icons.camera_alt),
            label: const Text('カメラでとる'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dctx, ImageSource.camera),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            key: const Key('photo_source_gallery'),
            icon: const Icon(Icons.photo_library),
            label: const Text('アルバムからえらぶ'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            onPressed: () => Navigator.pop(dctx, ImageSource.gallery),
          ),
          const SizedBox(height: 4),
          TextButton(
            key: const Key('photo_source_later'),
            onPressed: () => Navigator.pop(dctx),
            child: const Text('あとで'),
          ),
        ],
      ),
    ),
  );
}

/// 画像を取得する関数の型（テストでは差し替える）。
typedef PhotoPickFn = Future<XFile?> Function(ImageSource source);

Future<XFile?> _defaultPick(ImageSource source) => ImagePicker()
    .pickImage(source: source, imageQuality: 80, maxWidth: 1600);

/// 画像を取得する。失敗（カメラ権限なし・カメラなし等）は、子ども向けの
/// やさしいメッセージを出して null を返す。キャンセルも null。
///
/// アルバムは Android の「フォトピッカー」を使うので、ストレージ権限は不要。
Future<XFile?> pickPhotoWithMessage(
  BuildContext context,
  ImageSource source, {
  PhotoPickFn? pick,
}) async {
  try {
    return await (pick ?? _defaultPick)(source);
  } on PlatformException catch (e) {
    final msg = switch (e.code) {
      'camera_access_denied' =>
        'カメラが つかえないよ。おうちの人と「せってい」で カメラを ゆるしてね',
      'photo_access_denied' =>
        'しゃしんが ひらけないよ。おうちの人と「せってい」で ゆるしてね',
      'no_available_camera' =>
        'カメラが みつからないよ。「アルバムからえらぶ」を つかってね',
      _ => 'しゃしんを ひらけなかったよ。もういちど ためしてね',
    };
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 4)),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('しゃしんを ひらけなかったよ。もういちど ためしてね')),
      );
    }
  }
  return null;
}
