// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'utils.dart';

/// A class representing a notification which has been construted and sent to the
/// device via FCM.
///
/// This class can be accessed via a [RemoteMessage.notification].
class RemoteNotification {
  // ignore: public_member_api_docs
  const RemoteNotification(
      {this.android,
      this.apple,
      this.web,
      this.title,
      this.titleLocArgs = const <String>[],
      this.titleLocKey,
      this.body,
      this.bodyLocArgs = const <String>[],
      this.bodyLocKey});

  /// Constructs a [RemoteNotification] from a raw Map.
  factory RemoteNotification.fromMap(Map<String, dynamic> map) {
    return RemoteNotification(
      title: map['title'],
      titleLocArgs: _toList(map['titleLocArgs']),
      titleLocKey: map['titleLocKey'],
      body: map['body'],
      bodyLocArgs: _toList(map['bodyLocArgs']),
      bodyLocKey: map['bodyLocKey'],
      android: map['android'] != null
          ? AndroidNotification.fromMap(
              Map<String, dynamic>.from(map['android']))
          : null,
      apple: map['apple'] != null
          ? AppleNotification.fromMap(Map<String, dynamic>.from(map['apple']))
          : null,
      web: map['web'] != null
          ? WebNotification.fromMap(Map<String, dynamic>.from(map['web']))
          : null,
    );
  }

  /// Returns the [RemoteNotification] as a raw Map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'titleLocArgs': titleLocArgs,
      'titleLocKey': titleLocKey,
      'body': body,
      'bodyLocArgs': bodyLocArgs,
      'bodyLocKey': bodyLocKey,
      'android': android?.toMap(),
      'apple': apple?.toMap(),
      'web': web?.toMap(),
    };
  }

  /// Android specific notification properties.
  final AndroidNotification? android;

  /// Apple specific notification properties.
  final AppleNotification? apple;

  /// Web specific notification properties.
  final WebNotification? web;

  /// The notification title.
  final String? title;

  /// Any arguments that should be formatted into the resource specified by titleLocKey.
  final List<String> titleLocArgs;

  /// The native localization key for the notification title.
  final String? titleLocKey;

  /// The notification body content.
  final String? body;

  /// Any arguments that should be formatted into the resource specified by bodyLocKey.
  final List<String> bodyLocArgs;

  /// The native localization key for the notification body content.
  final String? bodyLocKey;
}

/// Android specific properties of a [RemoteNotification].
///
/// This will only be populated if the current device is Android.
class AndroidNotification {
  // ignore: public_member_api_docs
  const AndroidNotification(
      {this.channelId,
      this.clickAction,
      this.color,
      this.count,
      this.imageUrl,
      this.link,
      this.priority = AndroidNotificationPriority.defaultPriority,
      this.smallIcon,
      this.sound,
      this.ticker,
      this.tag,
      this.visibility = AndroidNotificationVisibility.private});

  /// Constructs an [AndroidNotification] from a raw Map.
  factory AndroidNotification.fromMap(Map<String, dynamic> map) {
    return AndroidNotification(
      channelId: map['channelId'],
      clickAction: map['clickAction'],
      color: map['color'],
      count: map['count'],
      imageUrl: map['imageUrl'],
      link: map['link'],
      priority: convertToAndroidNotificationPriority(map['priority']),
      smallIcon: map['smallIcon'],
      sound: map['sound'],
      ticker: map['ticker'],
      tag: map['tag'],
      visibility: convertToAndroidNotificationVisibility(map['visibility']),
    );
  }

  /// Returns the [AndroidNotification] as a raw Map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'channelId': channelId,
      'clickAction': clickAction,
      'color': color,
      'count': count,
      'imageUrl': imageUrl,
      'link': link,
      'priority': convertAndroidNotificationPriorityToInt(priority),
      'smallIcon': smallIcon,
      'sound': sound,
      'ticker': ticker,
      'tag': tag,
      'visibility': convertAndroidNotificationVisibilityToInt(visibility),
    };
  }

  /// The channel the notification is delivered on.
  final String? channelId;

  /// A spcific click action was defined for the notification.
  ///
  /// This property is not required to handle user interaction.
  final String? clickAction;

  /// The color of the notification.
  final String? color;

  /// The current notification count for the application.
  final int? count;

  /// The image URL for the notification.
  ///
  /// Will be `null` if the notification did not include an image.
  final String? imageUrl;

  // ignore: public_member_api_docs
  final String? link;

  /// The priority for the notifcation.
  ///
  /// This property only has impact on devices running Android 8.0 (API level 26) +.
  /// Later than this, they use the channel importance instead.
  final AndroidNotificationPriority priority;

  /// The resource file name of the small icon shown in the notification.
  final String? smallIcon;

  /// The resource file name of the sound used to alert users to the incoming notification.
  final String? sound;

  /// Ticker text for the notification, used for accessibility purposes.
  final String? ticker;

  /// The visibility level of the notification.
  final AndroidNotificationVisibility visibility;

  /// The tag of the notification.
  final String? tag;
}

/// Apple specific properties of a [RemoteNotification].
///
/// This will only be populated if the current device is Apple based (iOS/MacOS).
class AppleNotification {
  // ignore: public_member_api_docs
  const AppleNotification(
      {this.badge,
      this.sound,
      this.imageUrl,
      this.subtitle,
      this.subtitleLocArgs = const <String>[],
      this.subtitleLocKey});

  /// Constructs an [AppleNotification] from a raw Map.
  factory AppleNotification.fromMap(Map<String, dynamic> map) {
    return AppleNotification(
      badge: map['badge'],
      subtitle: map['subtitle'],
      subtitleLocArgs: _toList(map['subtitleLocArgs']),
      subtitleLocKey: map['subtitleLocKey'],
      imageUrl: map['imageUrl'],
      sound: map['sound'] == null
          ? null
          : AppleNotificationSound.fromMap(
              Map<String, dynamic>.from(map['sound'])),
    );
  }

  /// Returns the [AppleNotification] as a raw Map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'badge': badge,
      'subtitle': subtitle,
      'subtitleLocArgs': subtitleLocArgs,
      'subtitleLocKey': subtitleLocKey,
      'imageUrl': imageUrl,
      'sound': sound?.toMap(),
    };
  }

  /// The value which sets the application badge.
  final String? badge;

  /// Sound values for the incoming notification.
  final AppleNotificationSound? sound;

  /// The image URL for the notification.
  ///
  /// Will be `null` if the notification did not include an image.
  final String? imageUrl;

  /// Any subtile text on the notification.
  final String? subtitle;

  /// Any arguments that should be formatted into the resource specified by subtitleLocKey.
  final List<String> subtitleLocArgs;

  /// The native localization key for the notification subtitle.
  final String? subtitleLocKey;
}

/// Represents the sound property for [AppleNotification]
class AppleNotificationSound {
  // ignore: public_member_api_docs
  const AppleNotificationSound(
      {this.critical = false, this.name, this.volume = 0});

  /// Constructs an [AppleNotificationSound] from a raw Map.
  factory AppleNotificationSound.fromMap(Map<String, dynamic> map) {
    return AppleNotificationSound(
      critical: map['critical'] ?? false,
      name: map['name'],
      volume: map['volume'] ?? 0,
    );
  }

  /// Returns the [AppleNotificationSound] as a raw Map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'critical': critical,
      'name': name,
      'volume': volume,
    };
  }

  /// Whether or not the notification sound was critical.
  final bool critical;

  /// The resource name of the sound played.
  final String? name;

  /// The volume of the sound.
  ///
  /// This value is a number between 0.0 & 1.0.
  final num volume;
}

// Utility to correctly cast lists
List<String> _toList(dynamic value) {
  if (value == null) {
    return <String>[];
  }

  return List<String>.from(value);
}

/// Web specific properties of a [RemoteNotification].
class WebNotification {
  const WebNotification({
    this.analyticsLabel,
    this.image,
    this.link,
  });

  /// Constructs a [WebNotification] from a raw Map.
  factory WebNotification.fromMap(Map<String, dynamic> map) {
    return WebNotification(
      analyticsLabel: map['analyticsLabel'],
      image: map['image'],
      link: map['link'],
    );
  }

  /// Returns the [WebNotification] as a raw Map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'analyticsLabel': analyticsLabel,
      'image': image,
      'link': link,
    };
  }

  /// Optional message label for custom analytics.
  final String? analyticsLabel;

  /// The image URL for the notification.
  ///
  /// Will be `null` if the notification did not include an image.
  final String? image;

  /// The url which is typically being navigated to when the notification is clicked.
  final String? link;
}
