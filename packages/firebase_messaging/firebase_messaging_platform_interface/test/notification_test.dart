// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic>? mockNotificationMap;
  Map<String, dynamic>? mockNullNotificationMap;

  group('RemoteNotification', () {
    setUp(() {
      mockNotificationMap = {
        'title': 'title',
        'titleLocArgs': ['titleLocArgs'],
        'titleLocKey': 'titleLocKey',
        'body': 'body',
        'bodyLocArgs': ['bodyLocArgs'],
        'bodyLocKey': 'bodyLocKey',
        'android': {},
        'apple': {},
      };

      mockNullNotificationMap = {
        'title': null,
        'titleLocKey': null,
        'body': null,
        'bodyLocKey': null,
        'android': null,
        'apple': null,
      };
    });
    test('"RemoteNotification.fromMap" with every possible property expected',
        () {
      RemoteNotification notification =
          RemoteNotification.fromMap(mockNotificationMap!);

      expect(notification.title, mockNotificationMap!['title']);
      expect(notification.titleLocArgs, mockNotificationMap!['titleLocArgs']);
      expect(notification.titleLocKey, mockNotificationMap!['titleLocKey']);
      expect(notification.body, mockNotificationMap!['body']);
      expect(notification.bodyLocArgs, mockNotificationMap!['bodyLocArgs']);
      expect(notification.bodyLocKey, mockNotificationMap!['bodyLocKey']);
      expect(notification.android, isA<AndroidNotification>());
      expect(notification.apple, isA<AppleNotification>());
    });

    test(
        '"RemoteNotification.fromMap" with nullable properties mapped as null & default values invoked',
        () {
      RemoteNotification notification =
          RemoteNotification.fromMap(mockNullNotificationMap!);

      expect(notification.title, mockNullNotificationMap!['title']);
      expect(notification.titleLocArgs, []);
      expect(notification.titleLocKey, mockNullNotificationMap!['titleLocKey']);
      expect(notification.body, mockNullNotificationMap!['body']);
      expect(notification.bodyLocArgs, []);
      expect(notification.bodyLocKey, mockNullNotificationMap!['bodyLocKey']);
      expect(notification.android, null);
      expect(notification.apple, null);
    });

    test(
        'Use RemoteMessage.fromMap constructor to create every available property',
        () {
      RemoteNotification notification = RemoteNotification(
          android: const AndroidNotification(),
          apple: const AppleNotification(),
          title: mockNotificationMap!['title'],
          titleLocArgs: mockNotificationMap!['titleLocArgs'],
          titleLocKey: mockNotificationMap!['titleLocKey'],
          body: mockNotificationMap!['body'],
          bodyLocArgs: mockNotificationMap!['bodyLocArgs'],
          bodyLocKey: mockNotificationMap!['bodyLocKey']);

      expect(notification.title, mockNotificationMap!['title']);
      expect(notification.titleLocArgs, mockNotificationMap!['titleLocArgs']);
      expect(notification.titleLocKey, mockNotificationMap!['titleLocKey']);
      expect(notification.body, mockNotificationMap!['body']);
      expect(notification.bodyLocArgs, mockNotificationMap!['bodyLocArgs']);
      expect(notification.bodyLocKey, mockNotificationMap!['bodyLocKey']);
      expect(notification.android, isA<AndroidNotification>());
      expect(notification.apple, isA<AppleNotification>());
    });

    test(
        'Use RemoteMessage constructor with nullable properties mapped as null & default values invoked',
        () {
      RemoteNotification notification = const RemoteNotification();

      expect(notification.title, null);
      expect(notification.titleLocArgs, []);
      expect(notification.titleLocKey, null);
      expect(notification.body, null);
      expect(notification.bodyLocArgs, []);
      expect(notification.bodyLocKey, null);
      expect(notification.android, null);
      expect(notification.apple, null);
    });
  });

  group('AndroidNotification', () {
    test('new instance', () {
      Map<String, dynamic>? mockAndroidNotificationMap = {
        'channelId': 'channelId',
        'clickAction': 'clickAction',
        'color': 'color',
        'count': 5,
        'imageUrl': 'imageUrl',
        'link': 'link',
        'priority': AndroidNotificationPriority.lowPriority,
        'smallIcon': 'smallIcon',
        'sound': 'sound',
        'ticker': 'ticker',
        'tag': 'tag',
        'visibility': AndroidNotificationVisibility.public,
      };

      AndroidNotification notification = AndroidNotification(
          channelId: mockAndroidNotificationMap['channelId'],
          clickAction: mockAndroidNotificationMap['clickAction'],
          color: mockAndroidNotificationMap['color'],
          count: mockAndroidNotificationMap['count'],
          imageUrl: mockAndroidNotificationMap['imageUrl'],
          link: mockAndroidNotificationMap['link'],
          priority: mockAndroidNotificationMap['priority'],
          smallIcon: mockAndroidNotificationMap['smallIcon'],
          sound: mockAndroidNotificationMap['sound'],
          ticker: mockAndroidNotificationMap['ticker'],
          visibility: mockAndroidNotificationMap['visibility']);

      expect(notification.channelId, mockAndroidNotificationMap['channelId']);
      expect(
          notification.clickAction, mockAndroidNotificationMap['clickAction']);
      expect(notification.color, mockAndroidNotificationMap['color']);
      expect(notification.count, mockAndroidNotificationMap['count']);
      expect(notification.imageUrl, mockAndroidNotificationMap['imageUrl']);
      expect(notification.link, mockAndroidNotificationMap['link']);
      expect(notification.priority, mockAndroidNotificationMap['priority']);
      expect(notification.smallIcon, mockAndroidNotificationMap['smallIcon']);
      expect(notification.sound, mockAndroidNotificationMap['sound']);
      expect(notification.ticker, mockAndroidNotificationMap['ticker']);
      expect(notification.visibility, mockAndroidNotificationMap['visibility']);
    });
  });

  group('AppleNotification', () {
    test('new instance', () {
      Map<String, dynamic>? mockAppleNotificationMap = {
        'badge': 'badge',
        'sound': const AppleNotificationSound(),
        'imageUrl': 'imageUrl',
        'subtitle': 'subtitle',
        'subtitleLocArgs': ['subtitleLocArgs'],
        'subtitleLocKey': 'subtitleLocKey'
      };

      AppleNotification notification = AppleNotification(
          badge: mockAppleNotificationMap['badge'],
          sound: mockAppleNotificationMap['sound'],
          imageUrl: mockAppleNotificationMap['imageUrl'],
          subtitle: mockAppleNotificationMap['subtitle'],
          subtitleLocArgs: mockAppleNotificationMap['subtitleLocArgs'],
          subtitleLocKey: mockAppleNotificationMap['subtitleLocKey']);

      expect(notification.sound, mockAppleNotificationMap['sound']);
      expect(notification.badge, mockAppleNotificationMap['badge']);
      expect(notification.imageUrl, mockAppleNotificationMap['imageUrl']);
      expect(notification.subtitle, mockAppleNotificationMap['subtitle']);
      expect(notification.subtitleLocArgs,
          mockAppleNotificationMap['subtitleLocArgs']);
      expect(notification.subtitleLocKey,
          mockAppleNotificationMap['subtitleLocKey']);
    });
  });

  group('AppleNotificationSound', () {
    test('new instance', () {
      const testCritical = false;
      const iosSound = AppleNotificationSound();
      expect(iosSound.critical, equals(testCritical));
    });
  });
}
