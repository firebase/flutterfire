// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_crashlytics_platform_interface/firebase_crashlytics_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../mock.dart';

void main() {
  setupFirebaseCrashlyticsMocks();

  TestFirebaseCrashlyticsPlatform firebaseCrashlyticsPlatform;

  FirebaseApp app;
  FirebaseApp secondaryApp;

  group('$FirebaseCrashlyticsPlatform()', () {
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

      firebaseCrashlyticsPlatform = TestFirebaseCrashlyticsPlatform(
        app,
      );
    });

    test('Constructor', () {
      expect(firebaseCrashlyticsPlatform, isA<FirebaseCrashlyticsPlatform>());
      expect(firebaseCrashlyticsPlatform, isA<PlatformInterface>());
    });

    test('get.instance', () {
      expect(FirebaseCrashlyticsPlatform.instance,
          isA<FirebaseCrashlyticsPlatform>());
      expect(FirebaseCrashlyticsPlatform.instance.app.name,
          equals(defaultFirebaseAppName));
    });

    group('set.instance', () {
      test('sets the current instance', () {
        FirebaseCrashlyticsPlatform.instance =
            TestFirebaseCrashlyticsPlatform(secondaryApp);

        expect(FirebaseCrashlyticsPlatform.instance,
            isA<FirebaseCrashlyticsPlatform>());
        expect(
            FirebaseCrashlyticsPlatform.instance.app.name, equals('testApp2'));
      });

      test('throws an [AssertionError] if instance is null', () {
        expect(() => FirebaseCrashlyticsPlatform.instance = null,
            throwsAssertionError);
      });
    });

    test('throws if .checkForUnsentReports', () {
      try {
        firebaseCrashlyticsPlatform.checkForUnsentReports();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('checkForUnsentReports() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if .crash', () {
      try {
        firebaseCrashlyticsPlatform.crash();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('crash() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if .deleteUnsentReports', () {
      try {
        firebaseCrashlyticsPlatform.deleteUnsentReports();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('deleteUnsentReports() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if .didCrashOnPreviousExecution', () {
      try {
        firebaseCrashlyticsPlatform.didCrashOnPreviousExecution();
      } on UnimplementedError catch (e) {
        expect(e.message,
            equals('didCrashOnPreviousExecution() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if .recordError', () {
      try {
        firebaseCrashlyticsPlatform.recordError();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('recordError() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if .log', () {
      try {
        firebaseCrashlyticsPlatform.log('foo');
      } on UnimplementedError catch (e) {
        expect(e.message, equals('log() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if .sendUnsentReports', () {
      try {
        firebaseCrashlyticsPlatform.sendUnsentReports();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('sendUnsentReports() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if .setCrashlyticsCollectionEnabled', () {
      try {
        firebaseCrashlyticsPlatform.setCrashlyticsCollectionEnabled(true);
      } on UnimplementedError catch (e) {
        expect(e.message,
            equals('setCrashlyticsCollectionEnabled() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if .setUserIdentifier', () {
      try {
        firebaseCrashlyticsPlatform.setUserIdentifier('foo');
      } on UnimplementedError catch (e) {
        expect(e.message, equals('setUserIdentifier() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if .setCustomKey', () {
      try {
        firebaseCrashlyticsPlatform.setCustomKey('foo', 'bar');
      } on UnimplementedError catch (e) {
        expect(e.message, equals('setCustomKey() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });
  });
}

class TestFirebaseCrashlyticsPlatform extends FirebaseCrashlyticsPlatform {
  TestFirebaseCrashlyticsPlatform(FirebaseApp app) : super(appInstance: app);
}
