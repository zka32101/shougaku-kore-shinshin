import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stage explain images exist for stages 1..35', () {
    for (var i = 1; i <= 35; i++) {
      expect(File('assets/explain/stage_$i.jpg').existsSync(), isTrue,
          reason: 'stage_$i.jpg');
    }
  });
}
