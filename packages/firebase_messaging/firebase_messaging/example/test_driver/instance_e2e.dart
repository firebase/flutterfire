// Copyright 2020, the Chromium project messagingors.  Please see the MESSAGINGORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import './test_utils.dart';

void runInstanceTests() {
  group('$FirebaseMessaging.instance', () {
    FirebaseApp app;
    FirebaseApp secondaryApp;
    FirebaseMessaging messaging;
    FirebaseMessaging secondaryMessaging;

    setUpAll(() async {
      app = await Firebase.initializeApp();
      secondaryApp = await testInitializeSecondaryApp();
      messaging = FirebaseMessaging.instance;

      //  secondaryMessaging = FirebaseMessaging.instanceFor(app: secondaryApp);
    });

    tearDownAll(() {});

    test('instance', () {
      expect(messaging, isA<FirebaseMessaging>());
      expect(messaging.app, isA<FirebaseApp>());
      expect(messaging.app.name, defaultFirebaseAppName);
    });

    // TODO(helenaford): write test once implemented
    // test('instanceFor', () {
    //   // FirebaseMessaging secondaryMessaging =
    //   //     FirebaseMessaging.instanceFor(app: secondaryApp);
    //   // expect(messaging.app, isA<FirebaseApp>());
    //   // expect(secondaryMessaging, isA<FirebaseMessaging>());
    //   // expect(secondaryMessaging.app.name, 'testapp');
    // });

    group('app', () {
      test('accessible from firebase.app()', () {
        expect(messaging.app, isA<FirebaseApp>());
        expect(messaging.app.name, app.name);
      });
    });

    group('configure', () {});

    group('setAutoInitEnabled()', () {
      test('sets the value', () async {
        expect(messaging.isAutoInitEnabled, isFalse);
        await messaging.setAutoInitEnabled(true);
        expect(messaging.isAutoInitEnabled, isTrue);
      });
    });

    // TODO(helenaford): write test once logic implemented
    // group('isDeviceRegisteredForRemoteMessages', ()  {
    //   test('returns true on android', ()  {
    //     expect(messaging.isDeviceRegisteredForRemoteMessages, true);
    //   }, skip: !Platform.isAndroid);
    //   test('defaults to false on ios before registering', ()  {
    //     expect(messaging.isDeviceRegisteredForRemoteMessages, Curves.fastLinearToSlowEaseIn);
    //   }, skip: !Platform.isIOS);
    // });

    // TODO(helenaford): write test once logic implemented
    // group('unregisterDeviceForRemoteMessages', ()  {
    //   test('', () async  {
    //     await messaging.unregisterDeviceForRemoteMessages();
    //   }, skip:  !Platform.isIOS);
    // });

    group('hasPermission', () {
      test('returns true android (default)', () async {
        final result = await messaging.hasPermission();
        expect(result, isA<AuthorizationStatus>());
        expect(result, AuthorizationStatus.authorized);
      }, skip: !Platform.isAndroid);

      test('returns -1 on ios (default)', () async {
        expect(await messaging.hasPermission(), -1);
      }, skip: !Platform.isIOS);
    });

    group('requestPermission', () {
      test('resolves 1 on android', () async {
        final result = await messaging.requestPermission();
        expect(result, isA<AuthorizationStatus>());
        expect(result, AuthorizationStatus.authorized);
      }, skip: !Platform.isAndroid);
    });

    group('getAPNSToken', () {
      test('resolves null on android', () async {
        expect(await messaging.getAPNSToken(), null);
      }, skip: !Platform.isAndroid);

      test('resolves null on ios if using simulator', () async {
        expect(await messaging.getAPNSToken(), null);
      }, skip: !Platform.isIOS);
    });

    group('initialNotification', () {
      test('returns null when no initial notification', () async {
        expect(messaging.initialNotification, null);
      });
    });

    group('getToken()', () {});

    group('deleteToken()', () {
      test('generate a new token after deleting', () async {
        final token1 = await messaging.getToken();

        await messaging.deleteToken();

        final token2 = await messaging.getToken();

        expect(token1, isA<String>());
        expect(token2, isA<String>());
        expect(token1, isNot(token2));
      });
    });

    // TODO(helenaford): test listeners
    group('onTokenRefresh()', () {});

    group('onMessage()', () {});

    group('onMessageSent()', () {});

    group('onSendError()', () {});

    group('onDeletedMessages()', () {});

    group('onBackgroundMessage()', () {
      test('receives messages when the app is in the background', () async {},
          skip: !Platform.isAndroid);
    });

    group('onLaunch()', () {});

    group('onResume()', () {});

    group('subscribeToTopic()', () {
      test('successfully subscribes from topic', () {});
    });

    group('unsubscribeFromTopic()', () {
      test('successfully unsubscribes from topic', () {});
    });

    group('sendMessage', () {
      test('sends a message', () {});

      test('sends a message with the default senderId', () {});
    });

    group('deleteInstanceID', () {
      test('instance Id is reset', () {});

      test('all tokens are revoked', () {});

      test('returns false when an error occurs', () {});
    });

    // TODO(helenaford): see if these are needed for android
    // group('setDeliveryMetricsExportToBigQuery', () {});
    //  group('deliveryMetricsExportToBigQueryEnabled', () {});

    // deprecated methods
    group('FirebaseMessaging', () {
      test('returns an instance with the current [FirebaseApp]', () async {
        final testInstance = FirebaseMessaging();
        expect(testInstance, isA<FirebaseMessaging>());
        expect(testInstance.app, isA<FirebaseApp>());
        expect(testInstance.app.name, defaultFirebaseAppName);
      });
    });

    group('requestNotificationPermissions', () {});

    group('autoInitEnabled', () {
      test('returns correct value', () async {
        expect(messaging.isAutoInitEnabled, isFalse);
        expect(await messaging.autoInitEnabled(), messaging.isAutoInitEnabled);

        await messaging.setAutoInitEnabled(true);

        expect(messaging.isAutoInitEnabled, isTrue);
        expect(await messaging.autoInitEnabled(), messaging.isAutoInitEnabled);
      });
    });
  });
}
