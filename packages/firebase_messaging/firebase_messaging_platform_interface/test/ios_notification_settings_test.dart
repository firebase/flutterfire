// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/src/ios_notification_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IosNotificationSettings', () {
    test('toMap()', () {
      // ignore: deprecated_member_use_from_same_package
      final settings = IosNotificationSettings(sound: false, alert: false);
      final settingsMap = settings.toMap();
      expect(settingsMap, isA<Map<String, dynamic>>());
      expect(settingsMap['sound'], isFalse);
      expect(settingsMap['alert'], isFalse);
    });
  });
}
