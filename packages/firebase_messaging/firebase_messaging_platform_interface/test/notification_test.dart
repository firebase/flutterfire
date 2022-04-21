// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RemoteNotification', () {
    test('Provide every type of argument', () {
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

    test('Provide no arguments', () {
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

      RemoteNotification defaultNotification = const RemoteNotification();

      expect(notification.title, defaultNotification.title);
      expect(notification.titleLocArgs, defaultNotification.titleLocArgs);
      expect(notification.titleLocKey, defaultNotification.titleLocKey);
      expect(notification.body, defaultNotification.body);
      expect(notification.bodyLocArgs, defaultNotification.bodyLocArgs);
      expect(notification.bodyLocKey, defaultNotification.bodyLocKey);
      expect(notification.android, defaultNotification.android);
      expect(notification.apple, defaultNotification.apple);
      expect(notification.web, defaultNotification.web);
    });

    test(
        '"RemoteNotification.fromMap" with no properties & default values invoked',
        () {
      RemoteNotification notification = RemoteNotification.fromMap({});

      RemoteNotification defaultNotification = const RemoteNotification();

      expect(notification.title, defaultNotification.title);
      expect(notification.titleLocArgs, defaultNotification.titleLocArgs);
      expect(notification.titleLocKey, defaultNotification.titleLocKey);
      expect(notification.body, defaultNotification.body);
      expect(notification.bodyLocArgs, defaultNotification.bodyLocArgs);
      expect(notification.bodyLocKey, defaultNotification.bodyLocKey);
      expect(notification.android, defaultNotification.android);
      expect(notification.apple, defaultNotification.apple);
      expect(notification.web, defaultNotification.web);
    });

    test('RemoteNotification.toMap returns "RemoteNotification" as Map', () {
      RemoteNotification notification = const RemoteNotification(
        android: AndroidNotification(),
        apple: AppleNotification(),
        web: WebNotification(),
        title: 'title',
        titleLocArgs: ['arg1'],
        titleLocKey: 'titleLocKey',
        body: 'body',
        bodyLocArgs: ['arg1'],
        bodyLocKey: 'bodyLocKey',
      );

      final Map<String, dynamic> notificationMap = notification.toMap();

      expect(notificationMap['android'], const AndroidNotification().toMap());
      expect(notificationMap['apple'], const AppleNotification().toMap());
      expect(notificationMap['web'], const WebNotification().toMap());
      expect(notificationMap['title'], notification.title);
      expect(notificationMap['titleLocArgs'], notification.titleLocArgs);
      expect(notificationMap['titleLocKey'], notification.titleLocKey);
      expect(notificationMap['body'], notification.body);
      expect(notificationMap['bodyLocArgs'], notification.bodyLocArgs);
      expect(notificationMap['bodyLocKey'], notification.bodyLocKey);
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

    test('"AndroidNotification.fromMap" with every possible property expected',
        () {
      Map<String, dynamic>? androidNotificationMap = {
        'channelId': 'channelId',
        'clickAction': 'clickAction',
        'color': 'color',
        'count': 5,
        'imageUrl': 'imageUrl',
        'link': 'link',
        'priority': 2,
        'smallIcon': 'smallIcon',
        'sound': 'sound',
        'ticker': 'ticker',
        'tag': 'tag',
        'visibility': -1,
      };

      final AndroidNotification notification =
          AndroidNotification.fromMap(androidNotificationMap);

      expect(notification.channelId, androidNotificationMap['channelId']);
      expect(notification.clickAction, androidNotificationMap['clickAction']);
      expect(notification.color, androidNotificationMap['color']);
      expect(notification.count, androidNotificationMap['count']);
      expect(notification.imageUrl, androidNotificationMap['imageUrl']);
      expect(notification.link, androidNotificationMap['link']);
      expect(
          notification.priority, AndroidNotificationPriority.maximumPriority);
      expect(notification.smallIcon, androidNotificationMap['smallIcon']);
      expect(notification.sound, androidNotificationMap['sound']);
      expect(notification.ticker, androidNotificationMap['ticker']);
      expect(notification.tag, androidNotificationMap['tag']);
      expect(notification.visibility, AndroidNotificationVisibility.secret);
    });

    test(
        '"AndroidNotification.fromMap" with nullable properties mapped as null & default values invoked',
        () {
      Map<String, dynamic>? androidNotificationMap = {
        'channelId': null,
        'clickAction': null,
        'color': null,
        'count': null,
        'imageUrl': null,
        'link': null,
        'priority': null,
        'smallIcon': null,
        'sound': null,
        'ticker': null,
        'tag': null,
        'visibility': null,
      };

      final AndroidNotification notification =
          AndroidNotification.fromMap(androidNotificationMap);

      const AndroidNotification defaultNotification = AndroidNotification();

      expect(notification.channelId, defaultNotification.channelId);
      expect(notification.clickAction, defaultNotification.clickAction);
      expect(notification.color, defaultNotification.color);
      expect(notification.count, defaultNotification.count);
      expect(notification.imageUrl, defaultNotification.imageUrl);
      expect(notification.link, defaultNotification.link);
      expect(notification.priority, defaultNotification.priority);
      expect(notification.smallIcon, defaultNotification.smallIcon);
      expect(notification.sound, defaultNotification.sound);
      expect(notification.ticker, defaultNotification.ticker);
      expect(notification.tag, defaultNotification.tag);
      expect(notification.visibility, defaultNotification.visibility);
    });

    test(
        '"AndroidNotification.fromMap" with no properties & default values invoked',
        () {
      final AndroidNotification notification = AndroidNotification.fromMap({});

      const AndroidNotification defaultNotification = AndroidNotification();

      expect(notification.channelId, defaultNotification.channelId);
      expect(notification.clickAction, defaultNotification.clickAction);
      expect(notification.color, defaultNotification.color);
      expect(notification.count, defaultNotification.count);
      expect(notification.imageUrl, defaultNotification.imageUrl);
      expect(notification.link, defaultNotification.link);
      expect(notification.priority, defaultNotification.priority);
      expect(notification.smallIcon, defaultNotification.smallIcon);
      expect(notification.sound, defaultNotification.sound);
      expect(notification.ticker, defaultNotification.ticker);
      expect(notification.tag, defaultNotification.tag);
      expect(notification.visibility, defaultNotification.visibility);
    });

    test('AndroidNotification.toMap returns "AndroidNotification" as Map', () {
      const AndroidNotification notification = AndroidNotification(
        channelId: 'channelId',
        clickAction: 'clickAction',
        color: 'color',
        count: 5,
        imageUrl: 'imageUrl',
        link: 'link',
        priority: AndroidNotificationPriority.lowPriority,
        smallIcon: 'smallIcon',
        sound: 'sound',
        ticker: 'ticker',
        tag: 'tag',
        visibility: AndroidNotificationVisibility.public,
      );

      final Map<String, dynamic> androidNotificationMap = notification.toMap();

      expect(androidNotificationMap['channelId'], notification.channelId);
      expect(androidNotificationMap['clickAction'], notification.clickAction);
      expect(androidNotificationMap['color'], notification.color);
      expect(androidNotificationMap['count'], notification.count);
      expect(androidNotificationMap['imageUrl'], notification.imageUrl);
      expect(androidNotificationMap['link'], notification.link);
      expect(androidNotificationMap['priority'], -1);
      expect(androidNotificationMap['smallIcon'], notification.smallIcon);
      expect(androidNotificationMap['sound'], notification.sound);
      expect(androidNotificationMap['ticker'], notification.ticker);
      expect(androidNotificationMap['tag'], notification.tag);
      expect(androidNotificationMap['visibility'], 1);
    });
  });

  group('AppleNotification', () {
    test('Provide every type of argument', () {
      Map<String, dynamic>? appleNotificationMap = {
        'badge': 'badge',
        'sound': const AppleNotificationSound(),
        'imageUrl': 'imageUrl',
        'subtitle': 'subtitle',
        'subtitleLocArgs': ['subtitleLocArgs'],
        'subtitleLocKey': 'subtitleLocKey'
      };

      AppleNotification notification = AppleNotification(
          badge: appleNotificationMap['badge'],
          sound: appleNotificationMap['sound'],
          imageUrl: appleNotificationMap['imageUrl'],
          subtitle: appleNotificationMap['subtitle'],
          subtitleLocArgs: appleNotificationMap['subtitleLocArgs'],
          subtitleLocKey: appleNotificationMap['subtitleLocKey']);

      expect(notification.sound, appleNotificationMap['sound']);
      expect(notification.badge, appleNotificationMap['badge']);
      expect(notification.imageUrl, appleNotificationMap['imageUrl']);
      expect(notification.subtitle, appleNotificationMap['subtitle']);
      expect(notification.subtitleLocArgs,
          appleNotificationMap['subtitleLocArgs']);
      expect(
          notification.subtitleLocKey, appleNotificationMap['subtitleLocKey']);
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

    test('"AppleNotification.fromMap" with every possible property expected',
        () {
      Map<String, dynamic> appleNotificationMap = {
        'badge': 'badge',
        'sound': {},
        'imageUrl': 'imageUrl',
        'subtitle': 'subtitle',
        'subtitleLocArgs': ['subtitleLocArgs'],
        'subtitleLocKey': 'subtitleLocKey'
      };

      AppleNotification notification =
          AppleNotification.fromMap(appleNotificationMap);

      expect(notification.badge, 'badge');
      expect(notification.sound, isA<AppleNotificationSound>());
      expect(notification.imageUrl, 'imageUrl');
      expect(notification.subtitle, 'subtitle');
      expect(notification.subtitleLocArgs, ['subtitleLocArgs']);
      expect(notification.subtitleLocKey, 'subtitleLocKey');
    });

    test(
        '"AppleNotification.fromMap" with nullable properties mapped as null & default values invoked',
        () {
      Map<String, dynamic> appleNotificationMap = {
        'badge': null,
        'sound': null,
        'imageUrl': null,
        'subtitle': null,
        'subtitleLocArgs': null,
        'subtitleLocKey': null
      };

      AppleNotification notification =
          AppleNotification.fromMap(appleNotificationMap);

      const AppleNotification defaultNotification = AppleNotification();

      expect(notification.badge, defaultNotification.badge);
      expect(notification.sound, defaultNotification.sound);
      expect(notification.imageUrl, defaultNotification.imageUrl);
      expect(notification.subtitle, defaultNotification.subtitle);
      expect(notification.subtitleLocArgs, defaultNotification.subtitleLocArgs);
      expect(notification.subtitleLocKey, defaultNotification.subtitleLocKey);
    });

    test(
        '"AppleNotification.fromMap" with no properties & default values invoked',
        () {
      AppleNotification notification = AppleNotification.fromMap({});

      const AppleNotification defaultNotification = AppleNotification();

      expect(notification.badge, defaultNotification.badge);
      expect(notification.sound, defaultNotification.sound);
      expect(notification.imageUrl, defaultNotification.imageUrl);
      expect(notification.subtitle, defaultNotification.subtitle);
      expect(notification.subtitleLocArgs, defaultNotification.subtitleLocArgs);
      expect(notification.subtitleLocKey, defaultNotification.subtitleLocKey);
    });

    test('AppleNotification.toMap returns "AppleNotification" as Map', () {
      const AppleNotificationSound appleSound = AppleNotificationSound(
        critical: true,
        name: 'name',
        volume: 0.5,
      );

      const AppleNotification notification = AppleNotification(
        badge: 'badge',
        sound: appleSound,
        imageUrl: 'imageUrl',
        subtitle: 'subtitle',
        subtitleLocArgs: ['subtitleLocArgs'],
        subtitleLocKey: 'subtitleLocKey',
      );

      final Map<String, dynamic> appleNotificationMap = notification.toMap();

      expect(appleNotificationMap['badge'], 'badge');
      expect(appleNotificationMap['sound'], appleSound.toMap());
      expect(appleNotificationMap['imageUrl'], 'imageUrl');
      expect(appleNotificationMap['subtitle'], 'subtitle');
      expect(appleNotificationMap['subtitleLocArgs'], ['subtitleLocArgs']);
      expect(appleNotificationMap['subtitleLocKey'], 'subtitleLocKey');
    });
  });

  group('AppleNotificationSound', () {
    test('Provide every type of argument', () {
      Map<String, dynamic> appleSoundMap = {
        'critical': true,
        'name': 'name',
        'volume': 0.5
      };

      AppleNotificationSound appleSound = AppleNotificationSound(
          critical: appleSoundMap['critical'],
          name: appleSoundMap['name'],
          volume: appleSoundMap['volume']);
      expect(appleSound.critical, appleSoundMap['critical']);
      expect(appleSound.name, appleSoundMap['name']);
      expect(appleSound.volume, appleSoundMap['volume']);
    });

    test('Provide no arguments', () {
      AppleNotificationSound appleSound = const AppleNotificationSound();

      expect(appleSound.critical, false);
      expect(appleSound.name, null);
      expect(appleSound.volume, 0);
    });

    test(
        '"AppleNotificationSound.fromMap" with every possible property expected',
        () {
      Map<String, dynamic> appleSoundMap = {
        'critical': true,
        'name': 'name',
        'volume': 0.57,
      };

      final AppleNotificationSound appleSound =
          AppleNotificationSound.fromMap(appleSoundMap);

      expect(appleSound.critical, appleSoundMap['critical']);
      expect(appleSound.name, appleSoundMap['name']);
      expect(appleSound.volume, appleSoundMap['volume']);
    });

    test(
        '"AppleNotificationSound.fromMap" with nullable properties mapped as null & default values invoked',
        () {
      Map<String, dynamic> webNotificationMap = {
        'critical': null,
        'name': null,
        'volume': null,
      };

      final AppleNotificationSound appleSound =
          AppleNotificationSound.fromMap(webNotificationMap);

      const AppleNotificationSound defaultAppleSound = AppleNotificationSound();

      expect(appleSound.critical, defaultAppleSound.critical);
      expect(appleSound.name, defaultAppleSound.name);
      expect(appleSound.volume, defaultAppleSound.volume);
    });

    test(
        '"AppleNotificationSound.fromMap" with no properties & default values invoked',
        () {
      final AppleNotificationSound appleSound =
          AppleNotificationSound.fromMap({});

      const AppleNotificationSound defaultAppleSound = AppleNotificationSound();

      expect(appleSound.critical, defaultAppleSound.critical);
      expect(appleSound.name, defaultAppleSound.name);
      expect(appleSound.volume, defaultAppleSound.volume);
    });

    test('AppleNotificationSound.toMap returns "AppleNotificationSound" as Map',
        () {
      const appleSound = AppleNotificationSound(
        critical: true,
        name: 'name',
        volume: 0.9,
      );

      final Map<String, dynamic> appleSoundMap = appleSound.toMap();

      expect(appleSoundMap['critical'], appleSound.critical);
      expect(appleSoundMap['name'], appleSound.name);
      expect(appleSoundMap['volume'], appleSound.volume);
    });
  });

  group('WebNotification', () {
    test('Provide every type of argument', () {
      Map<String, dynamic>? webNotificationMap = {
        'analyticsLabel': 'analyticsLabel',
        'image': 'imageLink',
        'link': 'httpLink',
      };

      final WebNotification notification = WebNotification(
        analyticsLabel: webNotificationMap['analyticsLabel'],
        image: webNotificationMap['image'],
        link: webNotificationMap['link'],
      );

      expect(notification.analyticsLabel, webNotificationMap['analyticsLabel']);
      expect(notification.image, webNotificationMap['image']);
      expect(notification.link, webNotificationMap['link']);
    });

    test('Provide no argument', () {
      const WebNotification notification = WebNotification();

      expect(notification.analyticsLabel, null);
      expect(notification.image, null);
      expect(notification.link, null);
    });

    test('"WebNotification.fromMap" with every possible property expected', () {
      Map<String, dynamic>? webNotificationMap = {
        'analyticsLabel': 'analyticsLabel',
        'image': 'imageLink',
        'link': 'httpLink',
      };

      final WebNotification notification =
          WebNotification.fromMap(webNotificationMap);

      expect(notification.analyticsLabel, webNotificationMap['analyticsLabel']);
      expect(notification.image, webNotificationMap['image']);
      expect(notification.link, webNotificationMap['link']);
    });

    test(
        '"WebNotification.fromMap" with nullable properties mapped as null & default values invoked',
        () {
      Map<String, dynamic>? webNotificationMap = {
        'analyticsLabel': null,
        'image': null,
        'link': null,
      };

      final WebNotification notification =
          WebNotification.fromMap(webNotificationMap);

      const WebNotification defaultWebNotification = WebNotification();

      expect(
          notification.analyticsLabel, defaultWebNotification.analyticsLabel);
      expect(notification.image, defaultWebNotification.image);
      expect(notification.link, defaultWebNotification.link);
    });

    test(
        '"WebNotification.fromMap" with no properties & default values invoked',
        () {
      final WebNotification notification = WebNotification.fromMap({});
      const WebNotification defaultWebNotification = WebNotification();

      expect(
          notification.analyticsLabel, defaultWebNotification.analyticsLabel);
      expect(notification.image, defaultWebNotification.image);
      expect(notification.link, defaultWebNotification.link);
    });

    test('WebNotification.toMap returns "WebNotification" as Map', () {
      const WebNotification notification = WebNotification(
        analyticsLabel: 'analyticsLabel',
        image: 'imageLink',
        link: 'httpLink',
      );

      Map<String, dynamic> webNotificationMap = notification.toMap();

      expect(webNotificationMap['analyticsLabel'], notification.analyticsLabel);
      expect(webNotificationMap['image'], notification.image);
      expect(webNotificationMap['link'], notification.link);
    });
  });
}
