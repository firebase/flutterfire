// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_crashlytics/src/utils.dart';
import 'package:stack_trace/stack_trace.dart';
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
      await crashlytics!.checkForUnsentReports();

      expect(methodCallLog, <Matcher>[
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
            'stackTraceElements': getStackTraceElements(
                Trace.format(stack).trimRight().split('\n'))
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
      await crashlytics!.recordFlutterError(details);
      expect(methodCallLog, <Matcher>[
        isMethodCall('Crashlytics#recordError', arguments: {
          'exception': exception,
          'reason': exceptionReason,
          'information': '$exceptionFirstMessage\n$exceptionSecondMessage',
          'stackTraceElements':
              getStackTraceElements(Trace.format(stack).trimRight().split('\n'))
        })
      ]);
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
      test('with character index', () async {
        final List<String> lines = <String>[
          'package:flutter/src/widgets/framework.dart 3825:27  StatefulElement.build'
        ];
        final List<Map<String, String>> elements = getStackTraceElements(lines);
        expect(elements.length, 1);
        expect(elements.first, <String, String>{
          'class': 'StatefulElement',
          'method': 'build',
          'file': 'package:flutter/src/widgets/framework.dart',
          'line': '3825',
        });
      });

      test('without character index', () async {
        final List<String> lines = <String>[
          'package:flutter/src/widgets/framework.dart 3825  StatefulElement.build'
        ];
        final List<Map<String, String>> elements = getStackTraceElements(lines);
        expect(elements.length, 1);
        expect(elements.first, <String, String>{
          'class': 'StatefulElement',
          'method': 'build',
          'file': 'package:flutter/src/widgets/framework.dart',
          'line': '3825',
        });
      });

      test('without class', () async {
        final List<String> lines = <String>[
          'package:firebase_crashlytics/test/main.dart 12  main'
        ];
        final List<Map<String, String>> elements = getStackTraceElements(lines);
        expect(elements.length, 1);
        expect(elements.first, <String, String>{
          'method': 'main',
          'file': 'package:firebase_crashlytics/test/main.dart',
          'line': '12',
        });
      });
    });
  });
}
