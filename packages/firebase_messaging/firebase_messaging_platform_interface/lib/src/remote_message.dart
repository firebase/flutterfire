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
      this.actionIdentifier,
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
      senderId: map['senderId']?.toString(),
      category: map['category']?.toString(),
      actionIdentifier: map['actionIdentifier']?.toString(),
      collapseKey: map['collapseKey']?.toString(),
      contentAvailable: _asBool(map['contentAvailable']),
      data: map['data'] is Map
          ? Map<String, dynamic>.from(map['data'] as Map)
          : <String, dynamic>{},
      from: map['from']?.toString(),
      // Note: using toString on messageId as it can be an int or string when being sent from native.
      messageId: map['messageId']?.toString(),
      messageType: map['messageType']?.toString(),
      mutableContent: _asBool(map['mutableContent']),
      notification: map['notification'] is Map
          ? RemoteNotification.fromMap(
              Map<String, dynamic>.from(map['notification'] as Map))
          : null,
      sentTime: _parseSentTime(map['sentTime']),
      threadId: map['threadId']?.toString(),
      ttl: _asInt(map['ttl']),
    );
  }

  static bool _asBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value == 'true' || value == '1';
    return false;
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _parseSentTime(Object? value) {
    final int? raw = _asInt(value);
    if (raw == null) return null;
    const int maxEpochMs = 8640000000000000;
    if (raw < -maxEpochMs || raw > maxEpochMs) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(raw);
  }

  /// Returns the [RemoteMessage] as a raw Map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderId': senderId,
      'category': category,
      'actionIdentifier': actionIdentifier,
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

  /// The Apple notification action identifier used to open the app.
  final String? actionIdentifier;

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
