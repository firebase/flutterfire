// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:e2e/e2e.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  group('$FirebaseCrashlytics', () {
    FirebaseCrashlytics crashlytics;

    setUpAll(() async {
      await Firebase.initializeApp();
      crashlytics = FirebaseCrashlytics.instance;
    });

    group('checkForUnsentReports', () {
      test('should throw if automatic crash report is enabled', () async {
        await crashlytics.setCrashlyticsCollectionEnabled(true);
        try {
          await crashlytics.checkForUnsentReports();
          fail("Error did not throw");
        } catch (e) {
          print(e);
        }
      });

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
            context: DiagnosticsNode.message('bar context'),
            informationCollector: () => <DiagnosticsNode>[
                  DiagnosticsNode.message('first message'),
                  DiagnosticsNode.message('second message')
                ]));
      });
    });

    group('log', () {
      test('should throw if message is null', () async {
        expect(() => crashlytics.log(null), throwsAssertionError);
      });

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
      test('should throw if null', () async {
        expect(() => crashlytics.setCrashlyticsCollectionEnabled(null),
            throwsAssertionError);
      });

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
      test('should throw if null', () async {
        expect(() => crashlytics.setUserIdentifier(null), throwsAssertionError);
      });

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
