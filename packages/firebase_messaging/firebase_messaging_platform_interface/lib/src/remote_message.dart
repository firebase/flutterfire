// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';

/// A class representing a message sent from Firebase Cloud Messaging.
class RemoteMessage {
  // ignore: public_member_api_docs
  const RemoteMessage(
      {this.senderId,
      this.category,
      this.collapseKey,
      this.contentAvailable = false,
      this.data = const <String, dynamic>{},
      this.from,
      this.messageId,
      this.messageType,
      this.mutableContent = false,
      this.notification,
      this.sentTime,
      this.threadId,
      this.ttl});

  /// Constructs a [RemoteMessage] from a raw Map.
  factory RemoteMessage.fromMap(Map<String, dynamic> map) {
    return RemoteMessage(
      senderId: map['senderId'],
      category: map['category'],
      collapseKey: map['collapseKey'],
      contentAvailable: map['contentAvailable'] ?? false,
      data: map['data'] == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(map['data']),
      from: map['from'],
      // Note: using toString on messageId as it can be an int or string when being sent from native.
      messageId: map['messageId']?.toString(),
      messageType: map['messageType'],
      mutableContent: map['mutableContent'] ?? false,
      notification: map['notification'] == null
          ? null
          : RemoteNotification.fromMap(
              Map<String, dynamic>.from(map['notification'])),
      // Note: using toString on sentTime as it can be an int or string when being sent from native.
      sentTime: map['sentTime'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              int.parse(map['sentTime'].toString())),
      threadId: map['threadId'],
      ttl: map['ttl'],
    );
  }

  /// Returns the [RemoteMessage] as a raw Map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderId': senderId,
      'category': category,
      'collapseKey': collapseKey,
      'contentAvailable': contentAvailable,
      'data': data,
      'from': from,
      'messageId': messageId,
      'messageType': messageType,
      'mutableContent': mutableContent,
      'notification': notification?.toMap(),
      'sentTime': sentTime?.millisecondsSinceEpoch,
      'threadId': threadId,
      'ttl': ttl,
    };
  }

  /// The ID of the upstream sender location.
  final String? senderId;

  /// The iOS category this notification is assigned to.
  final String? category;

  /// The collapse key a message was sent with. Used to override existing messages with the same key.
  final String? collapseKey;

  /// Whether the iOS APNs message was configured as a background update notification.
  final bool contentAvailable;

  /// Any additional data sent with the message.
  final Map<String, dynamic> data;

  /// The topic name or message identifier.
  final String? from;

  /// A unique ID assigned to every message.
  final String? messageId;

  /// The message type of the message.
  final String? messageType;

  /// Whether the iOS APNs `mutable-content` property on the message was set
  /// allowing the app to modify the notification via app extensions.
  final bool mutableContent;

  /// Additional Notification data sent with the message.
  final RemoteNotification? notification;

  /// The time the message was sent, represented as a [DateTime].
  final DateTime? sentTime;

  /// An iOS app specific identifier used for notification grouping.
  final String? threadId;

  /// The time to live for the message in seconds.
  final int? ttl;
}
