// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_crashlytics/src/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './mock.dart';

void main() {
  setupFirebaseCrashlyticsMocks();

  FirebaseCrashlytics? crashlytics;

  group('$FirebaseCrashlytics', () {
    setUpAll(() async {
      await Firebase.initializeApp();
      crashlytics = FirebaseCrashlytics.instance;
    });

    setUp(() async {
      methodCallLog.clear();
    });

    tearDown(methodCallLog.clear);

    test('checkForUnsentReports', () async {
      await crashlytics!.setCrashlyticsCollectionEnabled(false);
      await crashlytics!.checkForUnsentReports();

      expect(methodCallLog, <Matcher>[
        isMethodCall('Crashlytics#setCrashlyticsCollectionEnabled',
            arguments: {'enabled': false}),
        isMethodCall('Crashlytics#checkForUnsentReports', arguments: null)
      ]);
    });

    test('crash', () async {
      crashlytics!.crash();

      expect(methodCallLog,
          <Matcher>[isMethodCall('Crashlytics#crash', arguments: null)]);
    });

    test('deleteUnsentReports', () async {
      await crashlytics!.deleteUnsentReports();

      expect(methodCallLog, <Matcher>[
        isMethodCall('Crashlytics#deleteUnsentReports', arguments: null)
      ]);
    });

    test('didCrashOnPreviousExecution', () async {
      await crashlytics!.didCrashOnPreviousExecution();

      expect(methodCallLog, <Matcher>[
        isMethodCall('Crashlytics#didCrashOnPreviousExecution', arguments: null)
      ]);
    });

    group('recordError', () {
      test('with stack', () async {
        final stack = StackTrace.current;
        const exception = 'foo exception';
        const exceptionReason = 'bar reason';

        await crashlytics!
            .recordError(exception, stack, reason: exceptionReason);
        expect(methodCallLog, <Matcher>[
          isMethodCall('Crashlytics#recordError', arguments: {
            'exception': exception,
            'reason': exceptionReason,
            'information': '',
            'fatal': false,
            'stackTraceElements': getStackTraceElements(stack),
            'buildId': '',
          })
        ]);
        // Confirm that the stack trace contains current stack.
        expect(
          methodCallLog[0].arguments['stackTraceElements'],
          contains(
              containsPair('file', contains('firebase_crashlytics_test.dart'))),
        );
      });

      test('without stack', () async {
        const exception = 'foo exception';
        const exceptionReason = 'bar reason';

        await crashlytics!
            .recordError(exception, null, reason: exceptionReason);
        expect(methodCallLog[0].method, 'Crashlytics#recordError');
        expect(methodCallLog[0].arguments['exception'], exception);
        expect(methodCallLog[0].arguments['reason'], exceptionReason);

        // Confirm that the stack trace contains current stack.
        expect(
          methodCallLog[0].arguments['stackTraceElements'],
          contains(
              containsPair('file', contains('firebase_crashlytics_test.dart'))),
        );
      });
    });

    test('recordFlutterError', () async {
      const exception = 'foo exception';
      const exceptionReason = 'bar reason';
      const exceptionLibrary = 'baz library';
      const exceptionFirstMessage = 'first message';
      const exceptionSecondMessage = 'second message';
      final stack = StackTrace.current;
      final FlutterErrorDetails details = FlutterErrorDetails(
        exception: exception,
        stack: stack,
        library: exceptionLibrary,
        informationCollector: () => <DiagnosticsNode>[
          DiagnosticsNode.message(exceptionFirstMessage),
          DiagnosticsNode.message(exceptionSecondMessage),
        ],
        context: ErrorDescription(exceptionReason),
      );
      final oldPresentError = FlutterError.presentError;
      var presentedError = false;
      FlutterError.presentError = (details) {
        presentedError = true;
      };
      try {
        await crashlytics!.recordFlutterError(details);
        expect(presentedError, true);
        expect(methodCallLog, <Matcher>[
          isMethodCall('Crashlytics#recordError', arguments: {
            'exception': exception,
            'reason': exceptionReason,
            'fatal': false,
            'information': '$exceptionFirstMessage\n$exceptionSecondMessage',
            'stackTraceElements': getStackTraceElements(stack),
            'buildId': '',
          })
        ]);
      } finally {
        FlutterError.presentError = oldPresentError;
      }
    });

    group('log', () {
      test('should call delegate method', () async {
        const msg = 'foo';
        await crashlytics!.log(msg);
        expect(methodCallLog, <Matcher>[
          isMethodCall('Crashlytics#log', arguments: {
            'message': msg,
          })
        ]);
      });
    });

    group('sendUnsentReports', () {
      test('should call delegate method', () async {
        await crashlytics!.sendUnsentReports();
        expect(methodCallLog, <Matcher>[
          isMethodCall('Crashlytics#sendUnsentReports', arguments: null)
        ]);
      });
    });

    group('setCrashlyticsCollectionEnabled', () {
      test('should call delegate method', () async {
        await crashlytics!.setCrashlyticsCollectionEnabled(false);
        expect(crashlytics!.isCrashlyticsCollectionEnabled, isFalse);
        await crashlytics!.setCrashlyticsCollectionEnabled(true);
        expect(crashlytics!.isCrashlyticsCollectionEnabled, isTrue);
        expect(methodCallLog, <Matcher>[
          isMethodCall('Crashlytics#setCrashlyticsCollectionEnabled',
              arguments: {
                'enabled': false,
              }),
          isMethodCall('Crashlytics#setCrashlyticsCollectionEnabled',
              arguments: {
                'enabled': true,
              })
        ]);
      });
    });

    group('setUserIdentifier', () {
      test('should call delegate method', () async {
        const id = 'foo';
        await crashlytics!.setUserIdentifier(id);
        expect(methodCallLog, <Matcher>[
          isMethodCall('Crashlytics#setUserIdentifier', arguments: {
            'identifier': id,
          })
        ]);
      });
    });

    group('setCustomKey', () {
      test('should throw if null', () async {
        expect(
            () => crashlytics!.setCustomKey('foo', []), throwsAssertionError);
        expect(
            () => crashlytics!.setCustomKey('foo', {}), throwsAssertionError);
      });

      test('should call delegate method', () async {
        const key = 'foo';
        const value = 'bar';
        await crashlytics!.setCustomKey(key, value);
        expect(methodCallLog, <Matcher>[
          isMethodCall('Crashlytics#setCustomKey', arguments: {
            'key': key,
            'value': value,
          })
        ]);
      });
    });

    group('getStackTraceElements', () {
      test('with symbolic stack trace', () async {
        final List<String> lines = <String>[
          '#0      StatefulElement.build (package:flutter/src/widgets/framework.dart:3825:27)'
        ];
        final StackTrace trace = StackTrace.fromString(lines.join('\n'));
        final List<Map<String, String>> elements = getStackTraceElements(trace);
        expect(elements.length, 1);
        expect(elements.first, <String, String>{
          'class': 'StatefulElement',
          'method': 'build',
          'file': 'package:flutter/src/widgets/framework.dart',
          'line': '3825',
        });
      });

      test('with symbolic stack trace and without class', () async {
        final List<String> lines = <String>[
          '#0      main (package:firebase_crashlytics/test/main.dart:12)'
        ];
        final StackTrace trace = StackTrace.fromString(lines.join('\n'));
        final List<Map<String, String>> elements = getStackTraceElements(trace);
        expect(elements.length, 1);
        expect(elements.first, <String, String>{
          'method': 'main',
          'file': 'package:firebase_crashlytics/test/main.dart',
          'line': '12',
        });
      });

      test('with android obfuscated stack trace', () async {
        final List<String> lines = <String>[
          'Warning: This VM has been configured to produce stack traces that violate the Dart standard.',
          '*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***',
          'pid: 1357, tid: 1415, name 1.ui',
          "build_id: '77d1b910140a2d66b93594aea59469cf'",
          'isolate_dso_base: 75f178181000, vm_dso_base: 75f178181000',
          'isolate_instructions: 75f17818f000, vm_instructions: 75f178183000',
          '    #00 abs 000075f17833027b virt 00000000001af27b _kDartIsolateSnapshotInstructions+0x1a127b',
        ];
        final StackTrace trace = StackTrace.fromString(lines.join('\n'));
        final List<Map<String, String>> elements = getStackTraceElements(trace);
        expect(elements.length, 1);
        expect(elements.first, <String, String>{
          'method':
              '    #00 abs 0 virt 00000000001af27b _kDartIsolateSnapshotInstructions+0x1a127b',
          'file': '',
          'line': '0',
        });
      });

      test('with ios obfuscated stack trace', () async {
        final List<String> lines = <String>[
          'Warning: This VM has been configured to produce stack traces that violate the Dart standard.',
          '*** *** *** *** *** *** *** *** *** *** *** *** *** *** *** ***',
          'pid: 1357, tid: 1415, name 1.ui',
          "build_id: '77d1b910140a2d66b93594aea59469cf'",
          'isolate_dso_base: 75f178181000, vm_dso_base: 75f178181000',
          'isolate_instructions: 75f17818f000, vm_instructions: 75f178183000',
          '    #00 abs 000075f17833027b _kDartIsolateSnapshotInstructions+0x1a127b',
        ];
        final StackTrace trace = StackTrace.fromString(lines.join('\n'));
        final List<Map<String, String>> elements = getStackTraceElements(trace);
        expect(elements.length, 1);
        expect(elements.first, <String, String>{
          'method': '    #00 abs 0 _kDartIsolateSnapshotInstructions+0x1a127b',
          'file': '',
          'line': '0',
        });
      });
    });
  });
}
