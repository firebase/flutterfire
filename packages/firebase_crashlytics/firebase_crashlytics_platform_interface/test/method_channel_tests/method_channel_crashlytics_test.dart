// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics_platform_interface/firebase_crashlytics_platform_interface.dart';
import 'package:firebase_crashlytics_platform_interface/src/method_channel/method_channel_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';

void main() {
  setupFirebaseCrashlyticsMocks();

  FirebaseCrashlyticsPlatform? crashlytics;
  final List<MethodCall> logger = <MethodCall>[];

  // mock props
  bool mockPlatformExceptionThrown = false;
  bool mockExceptionThrown = false;

  bool kUnsentReports = false;

  String kMockMessage = 'foo.bar.baz';
  String kMockUserIdentifier = 'user12345';

  Map<String, dynamic> kMockError = <String, dynamic>{
    'exception': 'Test exception',
    'reason': 'MethodChannelTest',
    'information': 'This is a test exception',
    'stackTraceElements': <Map<String, String>>[
      <String, String>{
        'declaringClass': 'MethodChannelCrashlyticsTest',
        'methodName': 'recordError',
        'fileName': 'method_channel_crashlytics_test.dart',
        'lineNumber': '99999',
      }
    ]
  };

  group('$MethodChannelFirebaseCrashlytics', () {
    setUpAll(() async {
      FirebaseApp app = await Firebase.initializeApp();

      handleMethodCall((call) async {
        logger.add(call);

        if (mockExceptionThrown) {
          throw Exception();
        } else if (mockPlatformExceptionThrown) {
          throw PlatformException(code: 'UNKNOWN');
        }

        switch (call.method) {
          case 'Crashlytics#recordError':
            return null;
          case 'Crashlytics#checkForUnsentReports':
            return <String, dynamic>{'unsentReports': kUnsentReports};
          case 'Crashlytics#crash':
            return null;
          case 'Crashlytics#deleteUnsentReports':
            kUnsentReports = false;
            return null;
          case 'Crashlytics#didCrashOnPreviousExecution':
            return <String, dynamic>{'didCrashOnPreviousExecution': true};
          case 'Crashlytics#log':
            return null;
          case 'Crashlytics#sendUnsentReports':
            return null;
          case 'Crashlytics#setCrashlyticsCollectionEnabled':
            return <String, dynamic>{'isCrashlyticsCollectionEnabled': true};
          default:
            return true;
        }
      });

      crashlytics = MethodChannelFirebaseCrashlytics(app: app);
    });

    setUp(() async {
      mockPlatformExceptionThrown = false;
      mockExceptionThrown = false;
      logger.clear();
    });

    tearDown(() async {
      mockPlatformExceptionThrown = false;
      mockExceptionThrown = false;
    });

    group('checkForUnsentReports', () {
      test('should call delegate method successfully', () async {
        kUnsentReports = true;
        var isUnsentReports = await crashlytics!.checkForUnsentReports();

        expect(isUnsentReports, isTrue);

        // check native method was called
        expect(logger, <Matcher>[
          isMethodCall(
            'Crashlytics#checkForUnsentReports',
            arguments: null,
          ),
        ]);

        kUnsentReports = false;
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseCrashlyticsException] error',
          () async {
        mockPlatformExceptionThrown = true;

        await testExceptionHandling(
            'PLATFORM', crashlytics!.checkForUnsentReports);
      });
    });

    group('crash', () {
      test('should call delegate method successfully', () {
        crashlytics!.crash();

        // check native method was called
        expect(logger, <Matcher>[
          isMethodCall(
            'Crashlytics#crash',
            arguments: null,
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseCrashlyticsException] error',
          () async {
        mockPlatformExceptionThrown = true;

        await testExceptionHandling('PLATFORM', crashlytics!.crash);
      });
    });

    group('deleteUnsentReports', () {
      test('should call delegate method successfully', () async {
        kUnsentReports = true;
        await crashlytics!.deleteUnsentReports();

        expect(kUnsentReports, isFalse);

        // check native method was called
        expect(logger, <Matcher>[
          isMethodCall(
            'Crashlytics#deleteUnsentReports',
            arguments: null,
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseCrashlyticsException] error',
          () async {
        mockPlatformExceptionThrown = true;

        await testExceptionHandling(
            'PLATFORM', crashlytics!.deleteUnsentReports);
      });
    });

    group('didCrashOnPreviousExecution', () {
      test('should call delegate method successfully', () async {
        var didCrash = await crashlytics!.didCrashOnPreviousExecution();

        expect(didCrash, isTrue);

        // check native method was called
        expect(logger, <Matcher>[
          isMethodCall(
            'Crashlytics#didCrashOnPreviousExecution',
            arguments: null,
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseCrashlyticsException] error',
          () async {
        mockPlatformExceptionThrown = true;

        await testExceptionHandling(
            'PLATFORM', crashlytics!.didCrashOnPreviousExecution);
      });
    });

    group('recordError', () {
      test('should call delegate method successfully', () async {
        await crashlytics!.recordError(
            exception: kMockError['exception'],
            reason: kMockError['reason'],
            information: kMockError['information'],
            stackTraceElements: kMockError['stackTraceElements']);

        // check native method was called
        expect(logger, <Matcher>[
          isMethodCall(
            'Crashlytics#recordError',
            arguments: <String, dynamic>{
              'exception': kMockError['exception'],
              'reason': kMockError['reason'],
              'information': kMockError['information'],
              'stackTraceElements': kMockError['stackTraceElements'],
            },
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseCrashlyticsException] error',
          () async {
        mockPlatformExceptionThrown = true;

        await testExceptionHandling(
            'PLATFORM',
            () => crashlytics!.recordError(
                exception: 'test exception',
                reason: 'test',
                information: 'test',
                stackTraceElements: []));
      });
    });

    test('log', () async {
      await crashlytics!.log(kMockMessage);

      // check native method was called
      expect(logger, <Matcher>[
        isMethodCall(
          'Crashlytics#log',
          arguments: <String, dynamic>{
            'message': kMockMessage,
          },
        ),
      ]);
    });

    group('sendUnsentReports', () {
      test('should call delegate method successfully', () async {
        await crashlytics!.sendUnsentReports();

        // check native method was called
        expect(logger, <Matcher>[
          isMethodCall(
            'Crashlytics#sendUnsentReports',
            arguments: null,
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseCrashlyticsException] error',
          () async {
        mockPlatformExceptionThrown = true;

        await testExceptionHandling('PLATFORM', crashlytics!.sendUnsentReports);
      });
    });

    group('setCrashlyticsCollectionEnabled', () {
      test('should call delegate method successfully', () async {
        await crashlytics!.setCrashlyticsCollectionEnabled(true);

        // check native method was called
        expect(logger, <Matcher>[
          isMethodCall(
            'Crashlytics#setCrashlyticsCollectionEnabled',
            arguments: <String, dynamic>{
              'enabled': true,
            },
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseCrashlyticsException] error',
          () async {
        mockPlatformExceptionThrown = true;

        await testExceptionHandling('PLATFORM',
            () => crashlytics!.setCrashlyticsCollectionEnabled(true));
      });
    });

    group('setUserIdentifier', () {
      test('should call delegate method successfully', () async {
        await crashlytics!.setUserIdentifier(kMockUserIdentifier);

        // check native method was called
        expect(logger, <Matcher>[
          isMethodCall(
            'Crashlytics#setUserIdentifier',
            arguments: <String, dynamic>{
              'identifier': kMockUserIdentifier,
            },
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseCrashlyticsException] error',
          () async {
        mockPlatformExceptionThrown = true;

        await testExceptionHandling('PLATFORM',
            () => crashlytics!.setUserIdentifier(kMockUserIdentifier));
      });
    });

    group('setCustomKey', () {
      test('setCustomKey', () async {
        await crashlytics!.setCustomKey('foo', 'bar');

        // check native method was called
        expect(logger, <Matcher>[
          isMethodCall(
            'Crashlytics#setCustomKey',
            arguments: <String, dynamic>{
              'key': 'foo',
              'value': 'bar',
            },
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseCrashlyticsException] error',
          () async {
        mockPlatformExceptionThrown = true;

        await testExceptionHandling(
            'PLATFORM', () => crashlytics!.setCustomKey('foo', 'bar'));
      });
    });
  });
}
