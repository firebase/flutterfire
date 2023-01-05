// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: require_trailing_commas
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic>? mockMessageMap;

  late Map<String, dynamic> mockNullableMessageMap;

  group('RemoteMessage', () {
    setUp(() {
      mockMessageMap = {
        'senderId': 'senderId',
        'category': 'category',
        'collapseKey': 'collapseKey',
        'contentAvailable': true,
        'data': {
          'via': 'FlutterFire Cloud Messaging!!!',
          'count': 1,
        },
        'from': 'from',
        'messageId': 'messageId',
        'messageType': 'messageType',
        'mutableContent': true,
        'notification': {
          'title': 'Hello FlutterFire!',
          'body': 'This notification was created from unit tests!',
        },
        'sentTime': DateTime.now().millisecondsSinceEpoch,
        'threadId': 'threadId',
        'ttl': 30000
      };

      mockNullableMessageMap = {
        'senderId': null,
        'category': null,
        'collapseKey': null,
        'data': null,
        'from': null,
        'messageId': null,
        'messageType': null,
        'notification': null,
        'sentTime': null,
        'threadId': null,
        'ttl': null
      };
    });

    test('"RemoteMessage.fromMap" with every possible property expected', () {
      final message = RemoteMessage.fromMap(mockMessageMap!);

      expect(message.senderId, mockMessageMap!['senderId']);
      expect(message.category, mockMessageMap!['category']);
      expect(message.collapseKey, mockMessageMap!['collapseKey']);
      expect(message.contentAvailable, mockMessageMap!['contentAvailable']);
      expect(message.data, mockMessageMap!['data']);
      expect(message.from, mockMessageMap!['from']);
      expect(message.messageId, mockMessageMap!['messageId']);
      expect(message.messageType, mockMessageMap!['messageType']);
      expect(message.mutableContent, mockMessageMap!['mutableContent']);

      expect(message.notification, isA<RemoteNotification>());
      expect(
        message.notification!.title,
        mockMessageMap!['notification']['title'],
      );
      expect(
        message.notification!.body,
        mockMessageMap!['notification']['body'],
      );

      expect(message.sentTime, isA<DateTime>());
      expect(message.threadId, mockMessageMap!['threadId']);
      expect(message.ttl, mockMessageMap!['ttl']);
    });

    test(
        '"RemoteMessage.fromMap" with nullable properties mapped as null & default values invoked',
        () {
      final message = RemoteMessage.fromMap(mockNullableMessageMap);

      expect(message.senderId, mockNullableMessageMap['senderId']);
      expect(message.category, mockNullableMessageMap['category']);
      expect(message.collapseKey, mockNullableMessageMap['collapseKey']);
      expect(message.contentAvailable, false);
      expect(message.data, {});
      expect(message.from, mockNullableMessageMap['from']);
      expect(message.messageId, mockNullableMessageMap['messageId']);
      expect(message.messageType, mockNullableMessageMap['messageType']);
      expect(message.mutableContent, false);
      expect(message.notification, mockNullableMessageMap['notification']);
      expect(message.sentTime, null);
      expect(message.threadId, mockNullableMessageMap['threadId']);
      expect(message.ttl, mockNullableMessageMap['ttl']);
    });

    test('Use RemoteMessage constructor to create every available property',
        () {
      DateTime date = DateTime.now();

      final message = RemoteMessage(
        senderId: mockMessageMap!['senderId'],
        category: mockMessageMap!['category'],
        collapseKey: mockMessageMap!['collapseKey'],
        contentAvailable: mockMessageMap!['contentAvailable'],
        data: mockMessageMap!['data'],
        from: mockMessageMap!['from'],
        messageId: mockMessageMap!['messageId'],
        messageType: mockMessageMap!['messageType'],
        mutableContent: mockMessageMap!['mutableContent'],
        notification: RemoteNotification.fromMap({}),
        sentTime: date,
        threadId: mockMessageMap!['threadId'],
        ttl: mockMessageMap!['ttl'],
      );

      expect(message.senderId, mockMessageMap!['senderId']);
      expect(message.category, mockMessageMap!['category']);
      expect(message.collapseKey, mockMessageMap!['collapseKey']);
      expect(message.contentAvailable, mockMessageMap!['contentAvailable']);
      expect(message.data, mockMessageMap!['data']);
      expect(message.from, mockMessageMap!['from']);
      expect(message.messageId, mockMessageMap!['messageId']);
      expect(message.messageType, mockMessageMap!['messageType']);
      expect(message.mutableContent, mockMessageMap!['mutableContent']);

      expect(message.notification, isA<RemoteNotification>());

      expect(message.sentTime, date);
      expect(message.threadId, mockMessageMap!['threadId']);
      expect(message.ttl, mockMessageMap!['ttl']);
    });

    test(
        'Use RemoteMessage constructor with nullable properties passed as null & default values invoked',
        () {
      mockNullableMessageMap = {
        'senderId': null,
        'category': null,
        'collapseKey': null,
        'data': null,
        'from': null,
        'messageId': null,
        'messageType': null,
        'notification': null,
        'sentTime': null,
        'threadId': null,
        'ttl': null
      };

      RemoteMessage message = const RemoteMessage();

      expect(message.senderId, mockNullableMessageMap['senderId']);
      expect(message.category, mockNullableMessageMap['category']);
      expect(message.collapseKey, mockNullableMessageMap['collapseKey']);
      expect(message.contentAvailable, false);
      expect(message.data, {});
      expect(message.from, mockNullableMessageMap['from']);
      expect(message.messageId, mockNullableMessageMap['messageId']);
      expect(message.messageType, mockNullableMessageMap['messageType']);
      expect(message.mutableContent, false);
      expect(message.notification, mockNullableMessageMap['notification']);
      expect(message.sentTime, null);
      expect(message.threadId, mockNullableMessageMap['threadId']);
      expect(message.ttl, mockNullableMessageMap['ttl']);
    });

    test('"RemoteMessage.toMap" returns "RemoteMessage" as Map', () {
      final RemoteMessage remoteMessage = RemoteMessage(
        senderId: 'senderId',
        category: 'category',
        collapseKey: 'collapseKey',
        contentAvailable: true,
        data: {},
        from: 'from',
        messageId: 'messageId',
        messageType: 'messageType',
        mutableContent: true,
        notification: const RemoteNotification(
          title: 'notification_title',
          body: 'notification_body',
        ),
        sentTime: DateTime.now(),
        threadId: 'threadId',
        ttl: 30000,
      );

      final Map<String, dynamic> map = remoteMessage.toMap();

      expect(map['senderId'], remoteMessage.senderId);
      expect(map['category'], remoteMessage.category);
      expect(map['collapseKey'], remoteMessage.collapseKey);
      expect(map['contentAvailable'], remoteMessage.contentAvailable);
      expect(map['data'], remoteMessage.data);
      expect(map['from'], remoteMessage.from);
      expect(map['messageId'], remoteMessage.messageId);
      expect(map['messageType'], remoteMessage.messageType);
      expect(map['mutableContent'], remoteMessage.mutableContent);

      expect(
          map['notification'],
          RemoteNotification(
            title: remoteMessage.notification!.title,
            body: remoteMessage.notification!.body,
          ).toMap());

      expect(map['sentTime'], remoteMessage.sentTime!.millisecondsSinceEpoch);
      expect(map['threadId'], remoteMessage.threadId);
      expect(map['ttl'], remoteMessage.ttl);
    });
  });
}
