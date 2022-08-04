// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics_platform_interface/src/platform_interface/platform_interface_firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../mock.dart';

void main() {
  setupFirebaseAnalyticsMocks();

  late TestFirebaseAnalyticsPlatform firebaseAnalyticsPlatform;

  FirebaseApp? app;
  FirebaseApp? secondaryApp;

  group('$FirebaseAnalyticsPlatform', () {
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

      firebaseAnalyticsPlatform = TestFirebaseAnalyticsPlatform(
        app!,
      );
    });

    test('Constructor', () {
      expect(firebaseAnalyticsPlatform, isA<FirebaseAnalyticsPlatform>());
      expect(firebaseAnalyticsPlatform, isA<PlatformInterface>());
    });

    test('get.instance', () {
      expect(
        FirebaseAnalyticsPlatform.instance,
        isA<FirebaseAnalyticsPlatform>(),
      );
      expect(
        FirebaseAnalyticsPlatform.instance.app.name,
        equals(defaultFirebaseAppName),
      );
    });

    test('set.instance', () {
      FirebaseAnalyticsPlatform.instance =
          TestFirebaseAnalyticsPlatform(secondaryApp!);

      expect(
        FirebaseAnalyticsPlatform.instance,
        isA<FirebaseAnalyticsPlatform>(),
      );
      expect(FirebaseAnalyticsPlatform.instance.app.name, equals('testApp2'));
    });

    test('throws if .delegateFor() not implemented', () async {
      await expectLater(
        () => firebaseAnalyticsPlatform.delegateFor(app: app!),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'delegateFor() is not implemented',
          ),
        ),
      );
    });

    test('throws if .logEvent() not implemented', () async {
      await expectLater(
        () => firebaseAnalyticsPlatform.logEvent(name: 'test name'),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'logEvent() is not implemented',
          ),
        ),
      );
    });

    test('throws if .setAnalyticsCollectionEnabled() not implemented',
        () async {
      await expectLater(
        () => firebaseAnalyticsPlatform.setAnalyticsCollectionEnabled(true),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'setAnalyticsCollectionEnabled() is not implemented',
          ),
        ),
      );
    });

    test('throws if .setUserId() not implemented', () async {
      await expectLater(
        () => firebaseAnalyticsPlatform.setUserId(id: 'test user id'),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'setUserId() is not implemented',
          ),
        ),
      );
    });

    test('throws if .setCurrentScreen() not implemented', () async {
      await expectLater(
        () => firebaseAnalyticsPlatform.setCurrentScreen(
          screenName: 'test screen',
        ),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'setCurrentScreen() is not implemented',
          ),
        ),
      );
    });

    test('throws if .setUserProperty() not implemented', () async {
      await expectLater(
        () => firebaseAnalyticsPlatform.setUserProperty(
          value: 'test value',
          name: 'test name',
        ),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'setUserProperty() is not implemented',
          ),
        ),
      );
    });

    test('throws if .resetAnalyticsData() not implemented', () async {
      await expectLater(
        () => firebaseAnalyticsPlatform.resetAnalyticsData(),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'resetAnalyticsData() is not implemented',
          ),
        ),
      );
    });

    test('throws if .setSessionTimeoutDuration() not implemented', () async {
      await expectLater(
        () => firebaseAnalyticsPlatform
            .setSessionTimeoutDuration(const Duration(milliseconds: 1000)),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'setSessionTimeoutDuration() is not implemented',
          ),
        ),
      );
    });

    test('throws if .setConsent() not implemented', () async {
      await expectLater(
        () => firebaseAnalyticsPlatform.setConsent(),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'setConsent() is not implemented',
          ),
        ),
      );
    });

    test('throws if .setDefaultEventParameters() not implemented', () async {
      await expectLater(
        () => firebaseAnalyticsPlatform.setDefaultEventParameters({}),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'setDefaultEventParameters() is not implemented',
          ),
        ),
      );
    });

    test('throws if .getAppInstanceId() not implemented', () async {
      await expectLater(
        () => firebaseAnalyticsPlatform.getAppInstanceId(),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'getAppInstanceId() is not implemented',
          ),
        ),
      );
    });
  });
}

class TestFirebaseAnalyticsPlatform extends FirebaseAnalyticsPlatform {
  TestFirebaseAnalyticsPlatform(FirebaseApp app) : super(appInstance: app);
}
