// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Notification', () {
    test('new instance', () {
      const testTitle = 'test notification';
      final notification = RemoteNotification(title: testTitle);
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

  group('AppleNotificationSound', () {
    test('new instance', () {
      const testCritical = false;
      final iosSound = AppleNotificationSound(critical: testCritical);
      expect(iosSound.critical, equals(testCritical));
    });
  });
}
