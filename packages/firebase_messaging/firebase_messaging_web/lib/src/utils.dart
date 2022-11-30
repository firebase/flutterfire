// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';

import 'interop/messaging.dart';

/// Converts an [String] into it's [AuthorizationStatus] representation.
///
/// See https://developer.mozilla.org/en-US/docs/Web/API/Notification/requestPermission
/// for more information.
AuthorizationStatus convertToAuthorizationStatus(String? status) {
  switch (status) {
    case 'granted':
      return AuthorizationStatus.authorized;
    case 'denied':
      return AuthorizationStatus.denied;
    case 'default':
      return AuthorizationStatus.notDetermined;
    default:
      return AuthorizationStatus.notDetermined;
  }
}

/// Returns a [NotificationSettings] instance for all Web platforms devices.
NotificationSettings getNotificationSettings(String? status) {
  return NotificationSettings(
    authorizationStatus: convertToAuthorizationStatus(status),
    alert: AppleNotificationSetting.notSupported,
    announcement: AppleNotificationSetting.notSupported,
    badge: AppleNotificationSetting.notSupported,
    carPlay: AppleNotificationSetting.notSupported,
    lockScreen: AppleNotificationSetting.notSupported,
    notificationCenter: AppleNotificationSetting.notSupported,
    showPreviews: AppleShowPreviewSetting.notSupported,
    sound: AppleNotificationSetting.notSupported,
    timeSensitive: AppleNotificationSetting.notSupported,
    criticalAlert: AppleNotificationSetting.notSupported,
  );
}

/// Converts a messaging [MessagePayload] into a Map.
Map<String, dynamic> messagePayloadToMap(MessagePayload messagePayload) {
  String? senderId;
  int? sentTime;
  Map<String, dynamic> data = {};

  if (messagePayload.data != null) {
    messagePayload.data!.forEach((key, value) {
      if (key == 'google.c.a.c_id') {
        senderId = value as String;
      }

      if (key == 'google.c.a.ts') {
        int seconds = int.tryParse(value as String)!;
        sentTime = seconds * 1000; // sentTime is ms
      }

      // Skip any internal keys
      if (!key.startsWith('aps') &&
          !key.startsWith('gcm.') &&
          !key.startsWith('google.')) {
        data[key] = value;
      }
    });
  }

  return <String, dynamic>{
    'senderId': senderId,
    'category': null,
    'collapseKey': messagePayload.collapseKey,
    'contentAvailable': null,
    'data': data,
    'from': messagePayload.from,
    'messageId': messagePayload.messageId,
    'mutableContent': null,
    'notification': messagePayload.notification == null
        ? null
        : notificationPayloadToMap(
            messagePayload.notification!, messagePayload.fcmOptions),
    'sentTime': sentTime,
    'threadId': null,
    'ttl': null,
  };
}

/// Converts a messaging [NotificationPayload] into a Map.
///
/// Since [FcmOptions] are web specific, we pass these down to the upper layer
/// as web properties.
Map<String, dynamic> notificationPayloadToMap(
    NotificationPayload notificationPayload, FcmOptions? fcmOptions) {
  return <String, dynamic>{
    'title': notificationPayload.title,
    'body': notificationPayload.body,
    'web': <String, dynamic>{
      'image': notificationPayload.image,
      'analyticsLabel': fcmOptions?.analyticsLabel,
      'link': fcmOptions?.link,
    },
  };
}
