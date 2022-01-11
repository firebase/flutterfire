// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RemoteNotification', () {
    test('"RemoteNotification.fromMap" with every possible property expected',
        () {
      Map<String, dynamic> mockNotificationMap = {
        'title': 'title',
        'titleLocArgs': ['titleLocArgs'],
        'titleLocKey': 'titleLocKey',
        'body': 'body',
        'bodyLocArgs': ['bodyLocArgs'],
        'bodyLocKey': 'bodyLocKey',
        'android': {},
        'apple': {},
        'web': {},
      };

      RemoteNotification notification =
          RemoteNotification.fromMap(mockNotificationMap);

      expect(notification.title, mockNotificationMap['title']);
      expect(notification.titleLocArgs, mockNotificationMap['titleLocArgs']);
      expect(notification.titleLocKey, mockNotificationMap['titleLocKey']);
      expect(notification.body, mockNotificationMap['body']);
      expect(notification.bodyLocArgs, mockNotificationMap['bodyLocArgs']);
      expect(notification.bodyLocKey, mockNotificationMap['bodyLocKey']);
      expect(notification.android, isA<AndroidNotification>());
      expect(notification.apple, isA<AppleNotification>());
      expect(notification.web, isA<WebNotification>());
    });

    test(
        '"RemoteNotification.fromMap" with nullable properties mapped as null & default values invoked',
        () {
      Map<String, dynamic> mockNullNotificationMap = {
        'title': null,
        'titleLocKey': null,
        'body': null,
        'bodyLocKey': null,
        'android': null,
        'apple': null,
        'web': null,
      };
      RemoteNotification notification =
          RemoteNotification.fromMap(mockNullNotificationMap);

      expect(notification.title, mockNullNotificationMap['title']);
      expect(notification.titleLocArgs, []);
      expect(notification.titleLocKey, mockNullNotificationMap['titleLocKey']);
      expect(notification.body, mockNullNotificationMap['body']);
      expect(notification.bodyLocArgs, []);
      expect(notification.bodyLocKey, mockNullNotificationMap['bodyLocKey']);
      expect(notification.android, null);
      expect(notification.apple, null);
      expect(notification.web, null);
    });

    test(
        'Use RemoteMessage.fromMap constructor to create every available property',
        () {
      Map<String, dynamic> mockNotificationMap = {
        'title': 'title',
        'titleLocArgs': ['titleLocArgs'],
        'titleLocKey': 'titleLocKey',
        'body': 'body',
        'bodyLocArgs': ['bodyLocArgs'],
        'bodyLocKey': 'bodyLocKey',
        'android': {},
        'apple': {},
        'web': {},
      };

      RemoteNotification notification = RemoteNotification(
          android: const AndroidNotification(),
          apple: const AppleNotification(),
          web: const WebNotification(),
          title: mockNotificationMap['title'],
          titleLocArgs: mockNotificationMap['titleLocArgs'],
          titleLocKey: mockNotificationMap['titleLocKey'],
          body: mockNotificationMap['body'],
          bodyLocArgs: mockNotificationMap['bodyLocArgs'],
          bodyLocKey: mockNotificationMap['bodyLocKey']);

      expect(notification.title, mockNotificationMap['title']);
      expect(notification.titleLocArgs, mockNotificationMap['titleLocArgs']);
      expect(notification.titleLocKey, mockNotificationMap['titleLocKey']);
      expect(notification.body, mockNotificationMap['body']);
      expect(notification.bodyLocArgs, mockNotificationMap['bodyLocArgs']);
      expect(notification.bodyLocKey, mockNotificationMap['bodyLocKey']);
      expect(notification.android, isA<AndroidNotification>());
      expect(notification.apple, isA<AppleNotification>());
      expect(notification.web, isA<WebNotification>());
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
      expect(notification.web, null);
    });
  });

  group('AndroidNotification', () {
    test('Provide every type of argument', () {
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
        visibility: mockAndroidNotificationMap['visibility'],
      );

      expect(notification.channelId, mockAndroidNotificationMap['channelId']);
      expect(
        notification.clickAction,
        mockAndroidNotificationMap['clickAction'],
      );
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

    test('Provide no arguments', () {
      AndroidNotification notification = const AndroidNotification();
      expect(notification.channelId, null);
      expect(notification.clickAction, null);
      expect(notification.color, null);
      expect(notification.count, null);
      expect(notification.imageUrl, null);
      expect(notification.link, null);
      expect(
          notification.priority, AndroidNotificationPriority.defaultPriority);
      expect(notification.smallIcon, null);
      expect(notification.sound, null);
      expect(notification.ticker, null);
      expect(notification.visibility, AndroidNotificationVisibility.private);
    });
  });

  group('AppleNotification', () {
    test('Provide every type of argument', () {
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

    test('Provide no arguments', () {
      AppleNotification notification = const AppleNotification();

      expect(notification.sound, null);
      expect(notification.badge, null);
      expect(notification.imageUrl, null);
      expect(notification.subtitle, null);
      expect(notification.subtitleLocArgs, []);
      expect(notification.subtitleLocKey, null);
    });
  });

  group('AppleNotificationSound', () {
    test('Provide every type of argument', () {
      Map<String, dynamic> appleSoundMap = {
        'critical': true,
        'name': 'name',
        'volume': 0.5
      };

      AppleNotificationSound iosSound = AppleNotificationSound(
          critical: appleSoundMap['critical'],
          name: appleSoundMap['name'],
          volume: appleSoundMap['volume']);
      expect(iosSound.critical, appleSoundMap['critical']);
      expect(iosSound.name, appleSoundMap['name']);
      expect(iosSound.volume, appleSoundMap['volume']);
    });

    test('Provide no arguments', () {
      AppleNotificationSound iosSound = const AppleNotificationSound();

      expect(iosSound.critical, false);
      expect(iosSound.name, null);
      expect(iosSound.volume, 0);
    });
  });

  group('WebNotification', () {
    test('Provide every type of argument', () {
      Map<String, dynamic>? mockWebNotificationMap = {
        'analyticsLabel': 'analyticsLabel',
        'image': 'imageLink',
        'link': 'httpLink',
      };

      final WebNotification notification = WebNotification(
        analyticsLabel: mockWebNotificationMap['analyticsLabel'],
        image: mockWebNotificationMap['image'],
        link: mockWebNotificationMap['link'],
      );

      expect(notification.analyticsLabel,
          mockWebNotificationMap['analyticsLabel']);
      expect(notification.image, mockWebNotificationMap['image']);
      expect(notification.link, mockWebNotificationMap['link']);
    });

    test('Provide no argument', () {
      const WebNotification notification = WebNotification();

      expect(notification.analyticsLabel, null);
      expect(notification.image, null);
      expect(notification.link, null);
    });
  });
}
