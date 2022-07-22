// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('chrome')

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:firebase_messaging_web/src/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('firebase_messaging_web utils', () {
    test('convertToAuthorizationStatus()', () {
      AuthorizationStatus grantedStatus =
          convertToAuthorizationStatus('granted');
      AuthorizationStatus deniedStatus = convertToAuthorizationStatus('denied');
      AuthorizationStatus defaultStatus =
          convertToAuthorizationStatus('default');
      AuthorizationStatus anyOtherStatus =
          convertToAuthorizationStatus('random string');

      expect(grantedStatus, AuthorizationStatus.authorized);
      expect(deniedStatus, AuthorizationStatus.denied);
      expect(defaultStatus, AuthorizationStatus.notDetermined);
      expect(anyOtherStatus, AuthorizationStatus.notDetermined);
    });

    test('getNotificationSettings()', () {
      NotificationSettings notification = getNotificationSettings('granted');

      expect(notification.authorizationStatus, AuthorizationStatus.authorized);
      expect(notification.alert, AppleNotificationSetting.notSupported);
      expect(notification.announcement, AppleNotificationSetting.notSupported);
      expect(notification.badge, AppleNotificationSetting.notSupported);
      expect(notification.carPlay, AppleNotificationSetting.notSupported);
      expect(notification.lockScreen, AppleNotificationSetting.notSupported);
      expect(notification.timeSensitive, AppleNotificationSetting.notSupported);
      expect(notification.criticalAlert, AppleNotificationSetting.notSupported);
      expect(
        notification.notificationCenter,
        AppleNotificationSetting.notSupported,
      );
      expect(notification.showPreviews, AppleShowPreviewSetting.notSupported);
      expect(notification.sound, AppleNotificationSetting.notSupported);

      NotificationSettings deniedNotification =
          getNotificationSettings('denied');
      NotificationSettings defaultNotification =
          getNotificationSettings('default');
      NotificationSettings randomNotification =
          getNotificationSettings('random string');

      expect(
        deniedNotification.authorizationStatus,
        AuthorizationStatus.denied,
      );
      expect(
        defaultNotification.authorizationStatus,
        AuthorizationStatus.notDetermined,
      );
      expect(
        randomNotification.authorizationStatus,
        AuthorizationStatus.notDetermined,
      );
    });
  });
}
