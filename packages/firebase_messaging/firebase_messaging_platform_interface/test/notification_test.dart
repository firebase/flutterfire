// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:firebase_messaging_platform_interface/src/notification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$Notification', () {
    test('toMap()', () {
      const testTitle = 'test notification';
      final notification = Notification(title: testTitle);
      final notificationMap = notification.toMap();
      expect(notificationMap, isA<Map<String, dynamic>>());
      expect(notificationMap['title'], equals(testTitle));
    });
  });

  group('$AndroidNotification', () {
    test('toMap()', () {
      const testChannelId = 'fooId';
      final notification = AndroidNotification(
          channelId: testChannelId, priority: NotificationPriority.low);
      final notificationMap = notification.toMap();
      expect(notificationMap, isA<Map<String, dynamic>>());
      expect(notificationMap['channelId'], equals(testChannelId));
    });
  });

  group('$IOSNotification', () {
    test('toMap()', () {
      const testSubtitle = 'bar';
      final notification = IOSNotification(subtitle: testSubtitle);
      final notificationMap = notification.toMap();
      expect(notificationMap, isA<Map<String, dynamic>>());
      expect(notificationMap['subtitle'], equals(testSubtitle));
    });
  });

  group('$NotificationIOSCriticalSound', () {
    test('toMap()', () {
      const testCritical = false;
      final iosCriticalSound =
          new NotificationIOSCriticalSound(critical: testCritical);
      final iosCriticalSoundMap = iosCriticalSound.toMap();
      expect(iosCriticalSoundMap, isA<Map<String, dynamic>>());
      expect(iosCriticalSoundMap['critical'], equals(testCritical));
    });
  });
}
