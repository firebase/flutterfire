// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'utils.dart';

class RemoteNotification {
  const RemoteNotification(
      {this.android,
      this.apple,
      this.title,
      this.titleLocArgs,
      this.titleLocKey,
      this.body,
      this.bodyLocArgs,
      this.bodyLocKey});

  factory RemoteNotification.fromMap(Map<String, dynamic> map) {
    AndroidNotification _android;
    AppleNotification _apple;

    if (map['android'] != null) {
      _android = AndroidNotification(
        channelId: map['android']['channelId'],
        clickAction: map['android']['clickAction'],
        color: map['android']['color'],
        count: map['android']['count'],
        imageUrl: map['android']['imageUrl'],
        link: map['android']['link'],
        priority:
            convertToAndroidNotificationPriority(map['android']['priority']),
        smallIcon: map['android']['smallIcon'],
        sound: map['android']['sound'],
        ticker: map['android']['ticker'],
        visibility: convertToAndroidNotificationVisibility(
            map['android']['visibility']),
      );
    }

    if (map['apple'] != null) {
      _apple = AppleNotification(
          badge: map['apple']['badge'],
          sound: map['apple']['sound'],
          subtitle: map['apple']['subtitle'],
          subtitleLocArgs: map['apple']['subtitleLocArgs'] ?? [],
          subtitleLocKey: map['apple']['subtitleLocKey'],
          criticalSound: map['apple']['criticalSound'] == null
              ? null
              : AppleNotificationCriticalSound(
                  critical: map['apple']['criticalSound']['critical'],
                  name: map['apple']['criticalSound']['name'],
                  volume: map['apple']['criticalSound']['volume']));
    }

    return RemoteNotification(
      title: map['title'],
      titleLocArgs: map['titleLocArgs'] ?? [],
      titleLocKey: map['titleLocKey'],
      body: map['body'],
      bodyLocArgs: map['bodyLocArgs'] ?? [],
      bodyLocKey: map['bodyLocKey'],
      android: _android,
      apple: _apple,
    );
  }

  /// Android specific notification properties.
  final AndroidNotification android;

  /// Apple specific notification properties.
  final AppleNotification apple;

  /// The notification title.
  final String title;

  /// Any arguments that should be formatted into the resource specified by titleLocKey.
  final List<String> titleLocArgs;

  /// The native localization key for the notification title.
  final String titleLocKey;

  /// The notification body content.
  final String body;

  /// Any arguments that should be formatted into the resource specified by bodyLocKey.
  final List<String> bodyLocArgs;

  /// The native localization key for the notification body content.
  final String bodyLocKey;
}

class AndroidNotification {
  const AndroidNotification(
      {this.channelId,
      this.clickAction,
      this.color,
      this.count,
      this.imageUrl,
      this.link,
      this.priority,
      this.smallIcon,
      this.sound,
      this.ticker,
      this.visibility});

  /// The channel the notification is delivered on.
  final String channelId;

  final String clickAction;

  /// The color of the notification.
  final String color;

  final int count;

  final String imageUrl;

  final String link;

  final AndroidNotificationPriority priority;

  final String smallIcon;

  final String sound;

  final String ticker;

  final AndroidNotificationVisibility visibility;
}

class AppleNotification {
  const AppleNotification(
      {this.badge,
      this.sound,
      this.criticalSound,
      this.subtitle,
      this.subtitleLocArgs,
      this.subtitleLocKey});

  final String badge;

  final String sound;

  final AppleNotificationCriticalSound criticalSound;

  final String subtitle;

  final List<String> subtitleLocArgs;

  final String subtitleLocKey;
}

class AppleNotificationCriticalSound {
  const AppleNotificationCriticalSound({this.critical, this.name, this.volume});

  final bool critical;

  final String name;

  final num volume;
}
