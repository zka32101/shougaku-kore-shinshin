import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';

/// Firebase.initializeApp() をプラットフォーム呼び出し無しで通せるようにする。
///
/// AvatarService など、コンストラクタで FirebaseFirestore.instance /
/// FirebaseAuth.instance を取得するクラスを、ネットワーク無しでテストするために使う。
/// setUpAll で一度だけ呼ぶ。
Future<void> setupFirebaseForTest() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }
}
