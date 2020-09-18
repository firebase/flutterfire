// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';

class RemoteMessage {
  const RemoteMessage(
      {this.senderId,
      this.category,
      this.collapseKey,
      this.contentAvailable,
      this.data,
      this.from,
      this.messageId,
      this.messageType,
      this.mutableContent,
      this.notification,
      this.sentTime,
      this.threadId,
      this.ttl});

  ///
  final String senderId;

  /// The iOS category this notification is assigned to.
  final String category;

  /// The collapse key a message was sent with. Used to override existing messages with the same key.
  final String collapseKey;

  /// Whether the iOS APNs message was configured as a background update notification.
  final bool contentAvailable;

  /// Any additional data sent with the message.
  final Map<String, String> data;

  /// The topic name or message identifier.
  final String from;

  /// A unique ID assigned to every message.
  final String messageId;

  /// The message type of the message.
  final String messageType;

  /// Whether the iOS APNs `mutable-content` property on the message was set
  /// allowing the app to modify the notification via app extensions.
  final bool mutableContent;

  /// Additional Notification data sent with the message
  final Notification notification;

  /// The time the message was sent, represented as a [DateTime].
  final DateTime sentTime;

  /// An iOS app specific identifier used for notification grouping.
  final String threadId;

  /// The time to live for the message in seconds.
  final int ttl;

  /// Returns the [RemoteMessage] as a [Map].
  ///
  /// If no [senderId] has been provided, the [FirebaseApp] sender ID will be
  /// used.
  Map<String, dynamic> toMap(String messagingSenderId) {
    return <String, dynamic>{
      'to': senderId ?? '$messagingSenderId@fcm.googleapis.com',
      'category': category,
      'collapseKey': collapseKey,
      'contentAvailable': contentAvailable,
      'data': data,
      'from': from,
      'messageId': messageId,
      'mutableContent': mutableContent,
      'notification': notification?.toMap(),
      'sentTime': sentTime?.millisecondsSinceEpoch,
      'threadId': threadId,
      'ttl': ttl,
    };
  }
}
