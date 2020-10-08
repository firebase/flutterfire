// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';

class NotificationSettings {
  const NotificationSettings(
      {this.alert,
      this.announcement,
      this.authorizationStatus,
      this.badge,
      this.carPlay,
      this.lockScreen,
      this.notificationCenter,
      this.showPreviews,
      this.sound});

  final AppleNotificationSetting alert;

  final AppleNotificationSetting announcement;

  final AuthorizationStatus authorizationStatus;

  final AppleNotificationSetting badge;

  final AppleNotificationSetting carPlay;

  /// Whether the application supports custom management of notification settings.
  // final AppleNotificationSetting inAppNotificationSettings;

  final AppleNotificationSetting lockScreen;

  final AppleNotificationSetting notificationCenter;
  final AppleShowPreviewSetting showPreviews;
  final AppleNotificationSetting sound;
}
