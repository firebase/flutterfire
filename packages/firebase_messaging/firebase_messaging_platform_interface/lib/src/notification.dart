// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';

import 'utils.dart';

class Notification {
  const Notification(
      {this.android,
      this.ios,
      this.title,
      this.titleLocArgs,
      this.titleLocKey,
      this.body,
      this.bodyLocArgs,
      this.bodyLocKey});

  final AndroidNotification android;

  final IOSNotification ios;

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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'android': android?.toMap(),
      'ios': ios?.toMap(),
      'title': title,
      'titleLocArgs': titleLocArgs,
      'titleLocKey': titleLocKey,
      'body': body,
      'bodyLocArgs': bodyLocArgs,
      'bodyLocKey': bodyLocKey,
    };
  }
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

  ///
  final int count;

  final String imageUrl;

  final String link;

  final NotificationPriority priority;

  final String smallIcon;

  final String sound;

  final String ticker;

  final NotificationVisibility visibility;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'channelId': channelId,
      'clickAction': clickAction,
      'color': color,
      'imageUrl': imageUrl,
      'link': link,
      'priority': convertFromNotificationPriority(priority),
      'smallIcon': smallIcon,
      'sound': sound,
      'ticker': ticker,
      'visibility': visibility.index,
    };
  }
}

class IOSNotification {
  const IOSNotification(
      {this.badge,
      this.sound,
      this.criticalSound,
      this.subtitle,
      this.subtitleLocArgs,
      this.subtitleLocKey});

  final String badge;

  final String sound;

  final NotificationIOSCriticalSound criticalSound;

  final String subtitle;

  final List<String> subtitleLocArgs;

  final String subtitleLocKey;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'badge': badge,
      'sound': sound,
      'criticalSound': criticalSound?.toMap(),
      'subtitle': subtitle,
      'subtitleLocArgs': subtitleLocArgs,
      'subtitleLocKey': subtitleLocKey,
    };
  }
}

class NotificationIOSCriticalSound {
  const NotificationIOSCriticalSound({this.critical, this.name, this.volume});

  final bool critical;

  final String name;

  final num volume;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'critical': critical,
      'namename': name,
      'volume': volume,
    };
  }
}
