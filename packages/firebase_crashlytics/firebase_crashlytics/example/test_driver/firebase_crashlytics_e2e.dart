// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

import 'package:drive/drive.dart' as drive;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void testsMain() {
  group('$FirebaseCrashlytics', () {
    /*late*/ FirebaseCrashlytics crashlytics;

    setUpAll(() async {
      await Firebase.initializeApp();
      crashlytics = FirebaseCrashlytics.instance;
    });

    group('checkForUnsentReports', () {
      //TODO(russellwheatley) debug test. The fail() function doesn't fail test and an error isn't thrown on android platform
      // test('should throw if automatic crash report is enabled', () async {

      //previous implementation
      // try {
      //   await crashlytics.checkForUnsentReports();
      //   fail('Error did not throw');
      // } catch (e) {
      //   // Do nothing. test will fail.
      // }

      // current implementation
      //   await crashlytics.setCrashlyticsCollectionEnabled(true);

      //   await expectLater(
      //     crashlytics.checkForUnsentReports,
      //     throwsA(isA<FirebaseException>()),
      //   );
      // });

      test('checks device cache for unsent crashlytics reports', () async {
        await crashlytics.setCrashlyticsCollectionEnabled(false);
        var unsentReports = await crashlytics.checkForUnsentReports();

        expect(unsentReports, isFalse);
      });
    });

    group('deleteUnsentReports', () {
      // This is currently only testing that we can delete reports without crashing.
      test('deletes unsent crashlytics reports', () async {
        await crashlytics.deleteUnsentReports();
      });
    });

    group('didCrashOnPreviousExecution', () {
      test('checks if app crashed on previous execution', () async {
        var didCrash = await crashlytics.didCrashOnPreviousExecution();
        expect(didCrash, isFalse);
      });
    });

    group('recordError', () {
      // This is currently only testing that we can log errors without crashing.
      test('should log error', () async {
        await crashlytics.recordError(
            'foo exception', StackTrace.fromString('during testing'));
      });

      // This is currently only testing that we can log flutter errors without crashing.
      test('should record flutter error', () async {
        await crashlytics.recordFlutterError(FlutterErrorDetails(
            exception: 'foo exception',
            stack: StackTrace.fromString(''),
            context: DiagnosticsNode.message('bar reason'),
            informationCollector: () => <DiagnosticsNode>[
                  DiagnosticsNode.message('first message'),
                  DiagnosticsNode.message('second message')
                ]));
      });
    });

    group('log', () {
      // This is currently only testing that we can log without crashing.
      test('accepts any value', () async {
        await crashlytics.log('flutter');
      });
    });

    group('sendUnsentReports', () {
      // This is currently only testing that we can send unsent reports without crashing.
      test('sends unsent reports to crashlytics server', () async {
        await crashlytics.sendUnsentReports();
      });
    });

    group('setCrashlyticsCollectionEnabled', () {
      // This is currently only testing that we can send unsent reports without crashing.
      test('should update to true', () async {
        await crashlytics.setCrashlyticsCollectionEnabled(true);
      });

      // This is currently only testing that we can send unsent reports without crashing.
      test('should update to false', () async {
        await crashlytics.setCrashlyticsCollectionEnabled(false);
      });
    });

    group('setUserIdentifier', () {
      // This is currently only testing that we can log errors without crashing.
      test('should update', () async {
        await crashlytics.setUserIdentifier('foo');
      });
    });

    group('setCustomKey', () {
      test('should throw if null', () async {
        expect(
            () => crashlytics.setCustomKey(null, null), throwsAssertionError);
        expect(
            () => crashlytics.setCustomKey('foo', null), throwsAssertionError);
        expect(() => crashlytics.setCustomKey('foo', []), throwsAssertionError);
        expect(() => crashlytics.setCustomKey('foo', {}), throwsAssertionError);
      });

      // This is currently only testing that we can log errors without crashing.
      test('should update', () async {
        await crashlytics.setCustomKey('fooString', 'bar');
        await crashlytics.setCustomKey('fooBool', true);
        await crashlytics.setCustomKey('fooInt', 42);
        await crashlytics.setCustomKey('fooDouble', 42.0);
      });
    });
  });
}

void main() => drive.main(testsMain);
