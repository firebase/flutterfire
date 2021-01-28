// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A class representing iOS specific permissions which can be requested by your
/// application.
@Deprecated(
    "Using [IosNotificationSettings] is deprecated. Instead, call [requestPermission] directly with named arguments")
class IosNotificationSettings {
  // ignore: public_member_api_docs
  const IosNotificationSettings({
    this.sound = true,
    this.alert = true,
    this.badge = true,
    this.provisional = false,
  });

  /// Request permission to play sounds.
  final bool sound;

  /// Request permission to display alerts.
  final bool alert;

  /// Request permission to update the application badge.
  final bool badge;

  /// Request permission to provisionally create non-interrupting notifications.
  final bool provisional;

  /// Converts the settings into a [Map].
  Map<String, dynamic> toMap() {
    return <String, bool>{
      'sound': sound,
      'alert': alert,
      'badge': badge,
      'provisional': provisional
    };
  }

  @override
  String toString() => 'IosNotificationSettings(${toMap()})';
}
