// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';

/// Defines a handler for incoming remote message payloads.
typedef BackgroundMessageHandler = Future<void> Function(RemoteMessage message);

/// An enum representing a notification setting for this app on the device.
enum AppleNotificationSetting {
  /// This setting is currently disabled by the user.
  disabled,

  /// This setting is currently enabled.
  enabled,

  /// This setting is not supported on this device.
  ///
  /// Usually this means that the iOS version required for this setting has not been met,
  /// or the platform is not Apple.
  notSupported,
}

/// An enum representing the show previews notification setting for this app on the device.
enum AppleShowPreviewSetting {
  /// Always show previews even if the device is currently locked.
  always,

  /// Never show previews.
  never,

  /// This setting is not supported on this device.
  ///
  /// Usually this means that the iOS version required for this setting (iOS 11+) has not been met,
  /// or the platform is not Apple.
  notSupported,

  /// Only show previews when the device is unlocked.
  whenAuthenticated,
}

/// Represents the current status of the platforms notification permissions.
enum AuthorizationStatus {
  /// The app is authorized to create notifications.
  authorized,

  /// The app is not authorized to create notifications.
  denied,

  /// The app user has not yet chosen whether to allow the application to create
  /// notifications. Usually this status is returned prior to the first call
  /// of [requestPermission].
  notDetermined,

  /// The app is currently authorized to post non-interrupting user notifications.
  provisional,
}

/// An enum representing a notification priority on Android.
///
/// Note; on devices which have channel support (Android 8.0 (API level 26) +),
/// this value will be ignored. Instead, the channel "importance" level is used.
enum AndroidNotificationPriority {
  /// The application small icon will not show up in the status bar, or alert the user. The notification
  /// will be in a collapsed state in the notification shade and placed at the bottom of the list.
  minimumPriority,

  /// The application small icon will show in the device status bar, however the notification will
  /// not alert the user (no sound or vibration). The notification will show in it's expanded state
  /// when the notification shade is pulled down.
  lowPriority,

  /// When a notification is received, the device smallIcon will appear in the notification shade.
  /// When the user pulls down the notification shade, the content of the notification will be shown
  /// in it's expanded state.
  defaultPriority,

  /// Notifications will appear on-top of applications, allowing direct interaction without pulling
  /// own the notification shade. This level is used for urgent notifications, such as
  /// incoming phone calls, messages etc, which require immediate attention.
  highPriority,

  /// The highest priority level a notification can be set to.
  maximumPriority,
}

/// An enum representing the visibility level of a notification on Android.
enum AndroidNotificationVisibility {
  /// Do not reveal any part of this notification on a secure lock-screen.
  secret,

  /// Show this notification on all lock-screens, but conceal sensitive or private information on secure lock-screens.
  private,

  /// Show this notification in its entirety on all lock-screens.
  public,
}
