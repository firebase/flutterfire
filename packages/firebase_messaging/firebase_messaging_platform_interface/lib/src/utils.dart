// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';

/// Converts an [int] into it's [AndroidNotificationPriority] representation.
AndroidNotificationPriority convertToAndroidNotificationPriority(
    int? priority) {
  switch (priority) {
    case -2:
      return AndroidNotificationPriority.minimumPriority;
    case -1:
      return AndroidNotificationPriority.lowPriority;
    case 0:
      return AndroidNotificationPriority.defaultPriority;
    case 1:
      return AndroidNotificationPriority.highPriority;
    case 2:
      return AndroidNotificationPriority.maximumPriority;
    default:
      return AndroidNotificationPriority.defaultPriority;
  }
}

/// Converts an [int] into it's [AndroidNotificationVisibility] representation.
AndroidNotificationVisibility convertToAndroidNotificationVisibility(
    int? visibility) {
  switch (visibility) {
    case -1:
      return AndroidNotificationVisibility.secret;
    case 0:
      return AndroidNotificationVisibility.private;
    case 1:
      return AndroidNotificationVisibility.public;
    default:
      return AndroidNotificationVisibility.private;
  }
}

/// Converts an [int] into it's [AuthorizationStatus] representation.
AuthorizationStatus convertToAuthorizationStatus(int? status) {
  // Can be null on unsupported platforms, e.g. iOS < 10.
  if (status == null) {
    return AuthorizationStatus.notDetermined;
  }
  switch (status) {
    case -1:
      return AuthorizationStatus.notDetermined;
    case 0:
      return AuthorizationStatus.denied;
    case 1:
      return AuthorizationStatus.authorized;
    case 2:
      return AuthorizationStatus.provisional;
    default:
      return AuthorizationStatus.notDetermined;
  }
}

/// Converts an [int] into it's [AppleNotificationSetting] representation.
AppleNotificationSetting convertToAppleNotificationSetting(int? status) {
  // Can be null on unsupported platforms, e.g. iOS < 10.
  if (status == null) {
    return AppleNotificationSetting.notSupported;
  }
  switch (status) {
    case -1:
      return AppleNotificationSetting.notSupported;
    case 0:
      return AppleNotificationSetting.disabled;
    case 1:
      return AppleNotificationSetting.enabled;
    default:
      return AppleNotificationSetting.notSupported;
  }
}

/// Converts an [int] into its [AppleShowPreviewSetting] representation.
AppleShowPreviewSetting convertToAppleShowPreviewSetting(int? status) {
  switch (status) {
    case -1:
      return AppleShowPreviewSetting.notSupported;
    case 0:
      return AppleShowPreviewSetting.never;
    case 1:
      return AppleShowPreviewSetting.always;
    case 2:
      return AppleShowPreviewSetting.whenAuthenticated;
    default:
      return AppleShowPreviewSetting.notSupported;
  }
}

/// Converts a [Map] into it's [NotificationSettings] representation.
NotificationSettings convertToNotificationSettings(Map<String, int> map) {
  return NotificationSettings(
    authorizationStatus:
        convertToAuthorizationStatus(map['authorizationStatus']),
    alert: convertToAppleNotificationSetting(map['alert']),
    announcement: convertToAppleNotificationSetting(map['announcement']),
    badge: convertToAppleNotificationSetting(map['badge']),
    carPlay: convertToAppleNotificationSetting(map['carPlay']),
    lockScreen: convertToAppleNotificationSetting(map['lockScreen']),
    notificationCenter:
        convertToAppleNotificationSetting(map['notificationCenter']),
    showPreviews: convertToAppleShowPreviewSetting(map['showPreviews']),
    sound: convertToAppleNotificationSetting(map['sound']),
  );
}

// Default [NotificationSettings] for platforms which do not require permissions
const NotificationSettings defaultNotificationSettings = NotificationSettings(
  authorizationStatus: AuthorizationStatus.authorized,
  alert: AppleNotificationSetting.notSupported,
  announcement: AppleNotificationSetting.notSupported,
  badge: AppleNotificationSetting.notSupported,
  carPlay: AppleNotificationSetting.notSupported,
  lockScreen: AppleNotificationSetting.notSupported,
  notificationCenter: AppleNotificationSetting.notSupported,
  showPreviews: AppleShowPreviewSetting.notSupported,
  sound: AppleNotificationSetting.notSupported,
);
