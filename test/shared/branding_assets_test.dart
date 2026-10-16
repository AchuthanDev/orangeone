import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('native launch assets match the centralized supplied logo', () {
    final logo = File('assets/branding/app_logo.png').readAsBytesSync();
    expect(logo, isNotEmpty);
    for (final path in [
      'android/app/src/main/res/drawable-nodpi/app_logo.png',
      for (final scale in [1, 2, 3])
        'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@${scale}x.png',
    ]) {
      expect(File(path).readAsBytesSync(), orderedEquals(logo), reason: path);
    }
  });
}
