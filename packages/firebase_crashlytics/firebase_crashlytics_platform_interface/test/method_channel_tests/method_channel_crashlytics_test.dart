// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics_platform_interface/firebase_crashlytics_platform_interface.dart';
import 'package:firebase_crashlytics_platform_interface/src/pigeon/messages.pigeon.dart';
import 'package:firebase_crashlytics_platform_interface/src/pigeon/test_api.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';

void main() {
  setupFirebaseCrashlyticsMocks();

  late FirebaseCrashlyticsPlatform crashlytics;
  late TestMethodChannelFirebaseCrashlytics mockCrashlytics;
  late _TestFirebaseCrashlyticsHostApi hostApi;

  const kMockMessage = 'foo.bar.baz';
  const kMockUserIdentifier = 'user12345';

  final kMockStackTraceElements = <Map<String, String>>[
    <String, String>{
      'class': 'MethodChannelCrashlyticsTest',
      'method': 'recordError',
      'file': 'method_channel_crashlytics_test.dart',
      'line': '99999',
    }
  ];

  group('$MethodChannelFirebaseCrashlytics', () {
    setUpAll(() async {
      final FirebaseApp app = await Firebase.initializeApp();
      hostApi = _TestFirebaseCrashlyticsHostApi();
      TestFirebaseCrashlyticsHostApi.setUp(hostApi);
      crashlytics = MethodChannelFirebaseCrashlytics(app: app);
      mockCrashlytics = TestMethodChannelFirebaseCrashlytics(app);
    });

    tearDownAll(() {
      TestFirebaseCrashlyticsHostApi.setUp(null);
    });

    setUp(() {
      hostApi.reset();
    });

    group('checkForUnsentReports', () {
      test('should call delegate method successfully', () async {
        hostApi.unsentReports = true;
        final isUnsentReports = await mockCrashlytics.checkForUnsentReports();

        expect(isUnsentReports, isTrue);
        expect(hostApi.checkForUnsentReportsCalled, isTrue);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseCrashlyticsException] error',
          () async {
        hostApi.throwPlatformException = true;

        await testExceptionHandling(
          'PLATFORM',
          mockCrashlytics.checkForUnsentReports,
        );
      });
    });

    group('crash', () {
      test('should call delegate method successfully', () async {
        await mockCrashlytics.crash();

        expect(hostApi.crashCalled, isTrue);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseCrashlyticsException] error',
          () async {
        hostApi.throwPlatformException = true;

        await testExceptionHandling('PLATFORM', crashlytics.crash);
      });
    });

    group('deleteUnsentReports', () {
      test('should call delegate method successfully', () async {
        hostApi.unsentReports = true;
        await crashlytics.deleteUnsentReports();

        expect(hostApi.unsentReports, isFalse);
        expect(hostApi.deleteUnsentReportsCalled, isTrue);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseCrashlyticsException] error',
          () async {
        hostApi.throwPlatformException = true;

        await testExceptionHandling(
          'PLATFORM',
          crashlytics.deleteUnsentReports,
        );
      });
    });

    group('didCrashOnPreviousExecution', () {
      test('should call delegate method successfully', () async {
        final didCrash = await crashlytics.didCrashOnPreviousExecution();

        expect(didCrash, isTrue);
        expect(hostApi.didCrashOnPreviousExecutionCalled, isTrue);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseCrashlyticsException] error',
          () async {
        hostApi.throwPlatformException = true;

        await testExceptionHandling(
          'PLATFORM',
          crashlytics.didCrashOnPreviousExecution,
        );
      });
    });

    group('recordError', () {
      test('should call delegate method successfully', () async {
        await crashlytics.recordError(
          exception: 'Test exception',
          reason: 'MethodChannelTest',
          information: 'This is a test exception',
          stackTraceElements: kMockStackTraceElements,
        );

        expect(hostApi.lastRecordError, isNotNull);
        expect(hostApi.lastRecordError!.exception, 'Test exception');
        expect(hostApi.lastRecordError!.reason, 'MethodChannelTest');
        expect(hostApi.lastRecordError!.fatal, isFalse);
        expect(
          hostApi.lastRecordError!.information,
          'This is a test exception',
        );
        expect(hostApi.lastRecordError!.buildId, '');
        expect(hostApi.lastRecordError!.loadingUnits, isEmpty);
        expect(hostApi.lastRecordError!.stackTraceElements, [
          CrashlyticsStackFrame(
            className: 'MethodChannelCrashlyticsTest',
            method: 'recordError',
            file: 'method_channel_crashlytics_test.dart',
            line: '99999',
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseCrashlyticsException] error',
          () async {
        hostApi.throwPlatformException = true;

        await testExceptionHandling(
          'PLATFORM',
          () => crashlytics.recordError(
            exception: 'test exception',
            reason: 'test',
            information: 'test',
            stackTraceElements: [],
          ),
        );
      });
    });

    test('log', () async {
      await crashlytics.log(kMockMessage);

      expect(hostApi.lastLogMessage, kMockMessage);
    });

    group('sendUnsentReports', () {
      test('should call delegate method successfully', () async {
        await crashlytics.sendUnsentReports();

        expect(hostApi.sendUnsentReportsCalled, isTrue);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseCrashlyticsException] error',
          () async {
        hostApi.throwPlatformException = true;

        await testExceptionHandling('PLATFORM', crashlytics.sendUnsentReports);
      });
    });

    group('setCrashlyticsCollectionEnabled', () {
      test('should call delegate method successfully', () async {
        await crashlytics.setCrashlyticsCollectionEnabled(true);

        expect(hostApi.lastCollectionEnabled, isTrue);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseCrashlyticsException] error',
          () async {
        hostApi.throwPlatformException = true;

        await testExceptionHandling(
          'PLATFORM',
          () => crashlytics.setCrashlyticsCollectionEnabled(true),
        );
      });
    });

    group('setUserIdentifier', () {
      test('should call delegate method successfully', () async {
        await crashlytics.setUserIdentifier(kMockUserIdentifier);

        expect(hostApi.lastUserIdentifier, kMockUserIdentifier);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseCrashlyticsException] error',
          () async {
        hostApi.throwPlatformException = true;

        await testExceptionHandling(
          'PLATFORM',
          () => crashlytics.setUserIdentifier(kMockUserIdentifier),
        );
      });
    });

    group('setCustomKey', () {
      test('setCustomKey', () async {
        await crashlytics.setCustomKey('foo', 'bar');

        expect(hostApi.lastCustomKey, 'foo');
        expect(hostApi.lastCustomValue, 'bar');
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseCrashlyticsException] error',
          () async {
        hostApi.throwPlatformException = true;

        await testExceptionHandling(
          'PLATFORM',
          () => crashlytics.setCustomKey('foo', 'bar'),
        );
      });
    });
  });
}

class TestMethodChannelFirebaseCrashlytics
    extends MethodChannelFirebaseCrashlytics {
  TestMethodChannelFirebaseCrashlytics(FirebaseApp app) : super(app: app);
  @override
  bool get isCrashlyticsCollectionEnabled => false;
}

class _TestFirebaseCrashlyticsHostApi
    implements TestFirebaseCrashlyticsHostApi {
  bool throwPlatformException = false;
  bool unsentReports = false;
  bool checkForUnsentReportsCalled = false;
  bool crashCalled = false;
  bool deleteUnsentReportsCalled = false;
  bool didCrashOnPreviousExecutionCalled = false;
  bool sendUnsentReportsCalled = false;
  RecordErrorRequest? lastRecordError;
  String? lastLogMessage;
  bool? lastCollectionEnabled;
  String? lastUserIdentifier;
  String? lastCustomKey;
  String? lastCustomValue;

  void reset() {
    throwPlatformException = false;
    checkForUnsentReportsCalled = false;
    crashCalled = false;
    deleteUnsentReportsCalled = false;
    didCrashOnPreviousExecutionCalled = false;
    sendUnsentReportsCalled = false;
    lastRecordError = null;
    lastLogMessage = null;
    lastCollectionEnabled = null;
    lastUserIdentifier = null;
    lastCustomKey = null;
    lastCustomValue = null;
  }

  void _maybeThrow() {
    if (throwPlatformException) {
      throw PlatformException(code: 'UNKNOWN');
    }
  }

  @override
  Future<bool> checkForUnsentReports() async {
    _maybeThrow();
    checkForUnsentReportsCalled = true;
    return unsentReports;
  }

  @override
  Future<void> crash() async {
    _maybeThrow();
    crashCalled = true;
  }

  @override
  Future<void> deleteUnsentReports() async {
    _maybeThrow();
    deleteUnsentReportsCalled = true;
    unsentReports = false;
  }

  @override
  Future<bool> didCrashOnPreviousExecution() async {
    _maybeThrow();
    didCrashOnPreviousExecutionCalled = true;
    return true;
  }

  @override
  Future<void> recordError(RecordErrorRequest request) async {
    _maybeThrow();
    lastRecordError = request;
  }

  @override
  Future<void> log(String message) async {
    _maybeThrow();
    lastLogMessage = message;
  }

  @override
  Future<void> sendUnsentReports() async {
    _maybeThrow();
    sendUnsentReportsCalled = true;
  }

  @override
  Future<bool> setCrashlyticsCollectionEnabled(bool enabled) async {
    _maybeThrow();
    lastCollectionEnabled = enabled;
    return enabled;
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    _maybeThrow();
    lastUserIdentifier = identifier;
  }

  @override
  Future<void> setCustomKey(String key, String value) async {
    _maybeThrow();
    lastCustomKey = key;
    lastCustomValue = value;
  }
}
