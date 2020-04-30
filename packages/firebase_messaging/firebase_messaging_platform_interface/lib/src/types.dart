// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_messaging_platform_interface;

typedef Future<dynamic> MessageHandler(Map<String, dynamic> message);

class IosNotificationSettings {
  const IosNotificationSettings({
    this.sound = true,
    this.alert = true,
    this.badge = true,
    this.provisional = false,
  });

  IosNotificationSettings._fromMap(Map<String, bool> settings)
      : sound = settings['sound'],
        alert = settings['alert'],
        badge = settings['badge'],
        provisional = settings['provisional'];

  final bool sound;
  final bool alert;
  final bool badge;
  final bool provisional;

  @visibleForTesting
  Map<String, dynamic> toMap() {
    return <String, bool>{
      'sound': sound,
      'alert': alert,
      'badge': badge,
      'provisional': provisional,
    };
  }

  @override
  String toString() => 'PushNotificationSettings ${toMap()}';
}
