// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';

typedef void RemoteMessageHandler(RemoteMessage message);

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

enum NotificationPriority {
  min,
  low,
  def,
  high,
  max,
}

enum NotificationVisibility {
  secret,
  private,
  public,
}
