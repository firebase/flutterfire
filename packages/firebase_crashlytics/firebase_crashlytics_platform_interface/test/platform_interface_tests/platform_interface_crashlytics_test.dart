// ignore_for_file: require_trailing_commas
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

  TestFirebaseCrashlyticsPlatform? firebaseCrashlyticsPlatform;

  FirebaseApp? app;
  FirebaseApp? secondaryApp;

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
        app!,
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
            TestFirebaseCrashlyticsPlatform(secondaryApp!);

        expect(FirebaseCrashlyticsPlatform.instance,
            isA<FirebaseCrashlyticsPlatform>());
        expect(
            FirebaseCrashlyticsPlatform.instance.app.name, equals('testApp2'));
      });
    });

    test('throws if .checkForUnsentReports', () {
      expect(
        () => firebaseCrashlyticsPlatform!.checkForUnsentReports(),
        throwsA(isA<UnimplementedError>().having((e) => e.message, 'message',
            'checkForUnsentReports() is not implemented')),
      );
    });

    test('throws if .crash', () {
      expect(
        () => firebaseCrashlyticsPlatform!.crash(),
        throwsA(isA<UnimplementedError>()
            .having((e) => e.message, 'message', 'crash() is not implemented')),
      );
    });

    test('throws if .deleteUnsentReports', () {
      expect(
        () => firebaseCrashlyticsPlatform!.deleteUnsentReports(),
        throwsA(isA<UnimplementedError>().having((e) => e.message, 'message',
            'deleteUnsentReports() is not implemented')),
      );
    });

    test('throws if .didCrashOnPreviousExecution', () {
      expect(
        () => firebaseCrashlyticsPlatform!.didCrashOnPreviousExecution(),
        throwsA(isA<UnimplementedError>().having((e) => e.message, 'message',
            'didCrashOnPreviousExecution() is not implemented')),
      );
    });

    test('throws if .log', () {
      expect(
        () => firebaseCrashlyticsPlatform!.log('foo'),
        throwsA(isA<UnimplementedError>()
            .having((e) => e.message, 'message', 'log() is not implemented')),
      );
    });

    test('throws if .sendUnsentReports', () {
      expect(
        () => firebaseCrashlyticsPlatform!.sendUnsentReports(),
        throwsA(isA<UnimplementedError>().having((e) => e.message, 'message',
            'sendUnsentReports() is not implemented')),
      );
    });

    test('throws if .setCrashlyticsCollectionEnabled', () {
      expect(
        () =>
            firebaseCrashlyticsPlatform!.setCrashlyticsCollectionEnabled(true),
        throwsA(isA<UnimplementedError>().having((e) => e.message, 'message',
            'setCrashlyticsCollectionEnabled() is not implemented')),
      );
    });

    test('throws if .setUserIdentifier', () {
      try {
        firebaseCrashlyticsPlatform!.setUserIdentifier('foo');
        // ignore: avoid_catching_errors, acceptable as UnimplementedError usage is correct
      } on UnimplementedError catch (e) {
        expect(e.message, equals('setUserIdentifier() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if .setCustomKey', () {
      try {
        firebaseCrashlyticsPlatform!.setCustomKey('foo', 'bar');
        // ignore: avoid_catching_errors, acceptable as UnimplementedError usage is correct
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
