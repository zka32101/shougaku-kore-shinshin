// Firebase の接続設定。
//
// 鍵などの値はリポジトリに置かず、ビルド時に `--dart-define` で渡す
// （GitHub Actions では Secrets から渡す。build-release.yml を参照）。
// 渡さなかった場合は PLACEHOLDER_ の値になり、Firebase には接続できない。


import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;

class DefaultFirebaseOptions {
  static const _androidApiKey = String.fromEnvironment(
      'FIREBASE_ANDROID_API_KEY',
      defaultValue: 'PLACEHOLDER_ANDROID_API_KEY_REPLACE_WITH_REAL_KEY');
  static const _androidAppId = String.fromEnvironment(
      'FIREBASE_ANDROID_APP_ID',
      defaultValue: 'PLACEHOLDER_ANDROID_APP_ID');
  static const _iosApiKey = String.fromEnvironment('FIREBASE_IOS_API_KEY',
      defaultValue: 'PLACEHOLDER_IOS_API_KEY_REPLACE_WITH_REAL_KEY');
  static const _iosAppId = String.fromEnvironment('FIREBASE_IOS_APP_ID',
      defaultValue: 'PLACEHOLDER_IOS_APP_ID');
  static const _iosClientId = String.fromEnvironment('FIREBASE_IOS_CLIENT_ID',
      defaultValue: 'PLACEHOLDER_IOS_CLIENT_ID');
  static const _messagingSenderId = String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: 'PLACEHOLDER_MESSAGING_SENDER_ID');

  static FirebaseOptions get currentPlatform {
    if (identical(defaultTargetPlatform, TargetPlatform.android)) {
      return android;
    }
    if (identical(defaultTargetPlatform, TargetPlatform.iOS)) {
      return ios;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: _androidApiKey,
    appId: _androidAppId,
    messagingSenderId: _messagingSenderId,
    projectId: 'shougaku-kore-doutoku',
    databaseURL: 'https://shougaku-kore-doutoku.firebaseio.com',
    storageBucket: 'shougaku-kore-doutoku.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: _iosApiKey,
    appId: _iosAppId,
    messagingSenderId: _messagingSenderId,
    projectId: 'shougaku-kore-doutoku',
    databaseURL: 'https://shougaku-kore-doutoku.firebaseio.com',
    storageBucket: 'shougaku-kore-doutoku.appspot.com',
    iosClientId: _iosClientId,
    iosBundleId: 'jp.petitworks.shougakuKoreDoutoku',
  );
}

