// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../mock.dart';

void main() {
  setupFirebaseMessagingMocks();

  late TestFirebaseMessagingPlatform firebaseMessagingPlatform;
  late FirebaseApp app;
  late FirebaseApp secondaryApp;

  group('$FirebaseMessagingPlatform()', () {
    setUpAll(() async {
      app = await Firebase.initializeApp();

      secondaryApp = await Firebase.initializeApp(
        name: 'testApp2',
        options: const FirebaseOptions(
          appId: '1:1234567890:ios:42424242424242',
          apiKey: '123',
          projectId: '123',
          messagingSenderId: '1234567890',
        ),
      );

      firebaseMessagingPlatform = TestFirebaseMessagingPlatform(
        app,
      );

      handleMethodCall((call) async {
        switch (call.method) {
          default:
            return null;
        }
      });
    });

    test('Constructor', () {
      expect(firebaseMessagingPlatform, isA<FirebaseMessagingPlatform>());
      expect(firebaseMessagingPlatform, isA<PlatformInterface>());
    });

    test('instanceFor', () {
      final result = FirebaseMessagingPlatform.instanceFor(
          app: app,
          pluginConstants: <dynamic, dynamic>{
            'AUTO_INIT_ENABLED': true,
          });
      expect(result, isA<FirebaseMessagingPlatform>());
      expect(result.isAutoInitEnabled, isA<bool>());
    });

    test('get.instance', () {
      expect(
          FirebaseMessagingPlatform.instance, isA<FirebaseMessagingPlatform>());
      expect(FirebaseMessagingPlatform.instance.app.name,
          equals(defaultFirebaseAppName));
    });

    group('set.instance', () {
      test('sets the current instance', () {
        FirebaseMessagingPlatform.instance =
            TestFirebaseMessagingPlatform(secondaryApp);

        expect(FirebaseMessagingPlatform.instance,
            isA<FirebaseMessagingPlatform>());
        expect(FirebaseMessagingPlatform.instance.app.name, equals('testApp2'));
      });
    });

    test('throws if delegateFor', () {
      try {
        firebaseMessagingPlatform.testDelegateFor();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('delegateFor() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if setInitialValues', () {
      try {
        firebaseMessagingPlatform.testSetInitialValues();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('setInitialValues() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if isAutoInitEnabled', () {
      try {
        firebaseMessagingPlatform.isAutoInitEnabled;
      } on UnimplementedError catch (e) {
        expect(e.message, equals('isAutoInitEnabled is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if getInitialMessage', () {
      try {
        firebaseMessagingPlatform.getInitialMessage();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('getInitialMessage() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if deleteToken()', () async {
      try {
        await firebaseMessagingPlatform.deleteToken();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('deleteToken() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if getAPNSToken()', () async {
      try {
        await firebaseMessagingPlatform.getAPNSToken();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('getAPNSToken() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if getToken()', () async {
      try {
        await firebaseMessagingPlatform.getToken();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('getToken() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if onTokenRefresh', () {
      try {
        firebaseMessagingPlatform.onTokenRefresh;
      } on UnimplementedError catch (e) {
        expect(e.message, equals('onTokenRefresh is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if requestPermission()', () async {
      try {
        await firebaseMessagingPlatform.requestPermission();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('requestPermission() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if setAutoInitEnabled()', () async {
      try {
        await firebaseMessagingPlatform.setAutoInitEnabled(true);
      } on UnimplementedError catch (e) {
        expect(e.message, equals('setAutoInitEnabled() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if subscribeToTopic()', () async {
      try {
        await firebaseMessagingPlatform.subscribeToTopic('foo');
      } on UnimplementedError catch (e) {
        expect(e.message, equals('subscribeToTopic() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if unsubscribeFromTopic()', () async {
      try {
        await firebaseMessagingPlatform.unsubscribeFromTopic('foo');
      } on UnimplementedError catch (e) {
        expect(e.message, equals('unsubscribeFromTopic() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });
  });
}

class TestFirebaseMessagingPlatform extends FirebaseMessagingPlatform {
  TestFirebaseMessagingPlatform(FirebaseApp? app) : super(appInstance: app);

  FirebaseMessagingPlatform testDelegateFor({FirebaseApp? app}) {
    return delegateFor(app: app ?? Firebase.app());
  }

  FirebaseMessagingPlatform testSetInitialValues() {
    return setInitialValues(isAutoInitEnabled: true);
  }
}
