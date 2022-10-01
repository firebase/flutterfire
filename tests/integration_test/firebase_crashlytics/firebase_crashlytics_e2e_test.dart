// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tests/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    'firebase_crashlytics',
    () {
      setUpAll(() async {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      });

      group('checkForUnsentReports', () {
        test('should throw if automatic crash report is enabled', () async {
          await FirebaseCrashlytics.instance
              .setCrashlyticsCollectionEnabled(true);

          await expectLater(
            FirebaseCrashlytics.instance.checkForUnsentReports,
            throwsA(isA<StateError>()),
          );
        });

        test('checks device cache for unsent crashlytics reports', () async {
          await FirebaseCrashlytics.instance
              .setCrashlyticsCollectionEnabled(false);
          var unsentReports =
              await FirebaseCrashlytics.instance.checkForUnsentReports();

          expect(unsentReports, isFalse);
        });
      });

      group('deleteUnsentReports', () {
        // This is currently only testing that we can delete reports without crashing.
        test('deletes unsent crashlytics reports', () async {
          await FirebaseCrashlytics.instance.deleteUnsentReports();
        });
      });

      group('didCrashOnPreviousExecution', () {
        test('checks if app crashed on previous execution', () async {
          var didCrash =
              await FirebaseCrashlytics.instance.didCrashOnPreviousExecution();
          expect(didCrash, isFalse);
        });
      });

      group('recordError', () {
        // This is currently only testing that we can log errors without crashing.
        test('should log error', () async {
          await FirebaseCrashlytics.instance.recordError(
            'foo exception',
            StackTrace.fromString('during testing'),
          );
        });

        // This is currently only testing that we can log flutter errors without crashing.
        test(
          'should record flutter error',
          () async {
            await FirebaseCrashlytics.instance.recordFlutterError(
              FlutterErrorDetails(
                exception: 'foo exception',
                stack: StackTrace.fromString(''),
                context: DiagnosticsNode.message('bar reason'),
                informationCollector: () => <DiagnosticsNode>[
                  DiagnosticsNode.message('first message'),
                  DiagnosticsNode.message('second message')
                ],
              ),
            );
          },
        );
      });

      group('log', () {
        // This is currently only testing that we can log without crashing.
        test('accepts any value', () async {
          await FirebaseCrashlytics.instance.log('flutter');
        });
      });

      group('sendUnsentReports', () {
        // This is currently only testing that we can send unsent reports without crashing.
        test('sends unsent reports to crashlytics server', () async {
          await FirebaseCrashlytics.instance.sendUnsentReports();
        });
      });

      group('setCrashlyticsCollectionEnabled', () {
        // This is currently only testing that we can send unsent reports without crashing.
        test('should update to true', () async {
          await FirebaseCrashlytics.instance
              .setCrashlyticsCollectionEnabled(true);
        });

        // This is currently only testing that we can send unsent reports without crashing.
        test('should update to false', () async {
          await FirebaseCrashlytics.instance
              .setCrashlyticsCollectionEnabled(false);
        });
      });

      group('setUserIdentifier', () {
        // This is currently only testing that we can log errors without crashing.
        test('should update', () async {
          await FirebaseCrashlytics.instance.setUserIdentifier('foo');
        });
      });

      group('setCustomKey', () {
        test('should throw if null', () async {
          // expect(
          //   () => FirebaseCrashlytics.instance.setCustomKey(null, null),
          //   throwsAssertionError,
          // );
          // expect(
          //   () => FirebaseCrashlytics.instance.setCustomKey('foo', null),
          //   throwsAssertionError,
          // );
          expect(
            () => FirebaseCrashlytics.instance.setCustomKey('foo', []),
            throwsAssertionError,
          );
          expect(
            () => FirebaseCrashlytics.instance.setCustomKey('foo', {}),
            throwsAssertionError,
          );
        });

        // This is currently only testing that we can log errors without crashing.
        test('should update', () async {
          await FirebaseCrashlytics.instance.setCustomKey('fooString', 'bar');
          await FirebaseCrashlytics.instance.setCustomKey('fooBool', true);
          await FirebaseCrashlytics.instance.setCustomKey('fooInt', 42);
          await FirebaseCrashlytics.instance.setCustomKey('fooDouble', 42.0);
        });
      });
    },
    // Only supported on Android & iOS/macOS.
    skip: kIsWeb,
  );
}
