// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';

/// Represents the devices notification settings.
class NotificationSettings {
  // ignore: public_member_api_docs
  const NotificationSettings(
      {required this.alert,
      required this.announcement,
      required this.authorizationStatus,
      required this.badge,
      required this.carPlay,
      required this.lockScreen,
      required this.notificationCenter,
      required this.showPreviews,
      required this.sound});

  /// Whether or not messages containing a notification will alert the user.
  ///
  /// Apple devices only.
  final AppleNotificationSetting alert;

  /// Whether or not messages containing a notification be announced to the user
  /// via 3rd party services such as Siri.
  ///
  /// Apple devices only.
  final AppleNotificationSetting announcement;

  /// The overall notification authorization status for the user.
  final AuthorizationStatus authorizationStatus;

  /// Whether or not messages containing a notification can update the application badge.
  ///
  /// Apple devices only.
  final AppleNotificationSetting badge;

  /// Whether or not messages containing a notification will be displayed in a
  /// CarPlay environment.
  ///
  /// Apple devices only.
  final AppleNotificationSetting carPlay;

  /// Whether or not messages containing a notification will be displayed on the
  /// device lock screen.
  ///
  /// Apple devices only.
  final AppleNotificationSetting lockScreen;

  /// Whether or not messages containing a notification will be displayed in the
  /// device notification center.
  ///
  /// Apple devices only.
  final AppleNotificationSetting notificationCenter;

  /// Whether or not messages containing a notification can displayed a previewed
  /// version to users.
  ///
  /// Apple devices only.
  final AppleShowPreviewSetting showPreviews;

  /// Whether or not messages containing a notification will trigger a sound.
  ///
  /// Apple devices only.
  final AppleNotificationSetting sound;
}
