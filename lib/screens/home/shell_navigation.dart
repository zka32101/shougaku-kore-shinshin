import 'package:flutter/foundation.dart';

import 'home_screen.dart' show HomeSection;

/// 深い画面から、下のナビのタブを切り替えたいときの合図。
/// [MainShell] が受け取って該当タブへ移る(受け取ったら null に戻す)。
final ValueNotifier<HomeSection?> shellSectionRequest =
    ValueNotifier<HomeSection?>(null);
