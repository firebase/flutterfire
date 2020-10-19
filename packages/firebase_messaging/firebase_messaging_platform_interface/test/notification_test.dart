// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:firebase_messaging_platform_interface/src/notification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Notification', () {
    test('new instance', () {
      const testTitle = 'test notification';
      final notification = Notification(title: testTitle);
      expect(notification.title, equals(testTitle));
    });
  });

  group('AndroidNotification', () {
    test('new instance', () {
      const testChannelId = 'fooId';
      final notification = AndroidNotification(
          channelId: testChannelId,
          priority: AndroidNotificationPriority.lowPriority);
      expect(notification.channelId, equals(testChannelId));
    });
  });

  group('AppleNotification', () {
    test('new instance', () {
      const testSubtitle = 'bar';
      final notification = AppleNotification(subtitle: testSubtitle);
      expect(notification.subtitle, equals(testSubtitle));
    });
  });

  group('AppleNotificationCriticalSound', () {
    test('new instance', () {
      const testCritical = false;
      final iosCriticalSound =
          AppleNotificationCriticalSound(critical: testCritical);
      expect(iosCriticalSound, equals(testCritical));
    });
  });
}
