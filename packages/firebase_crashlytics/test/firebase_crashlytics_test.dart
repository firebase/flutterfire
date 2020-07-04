// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Crashlytics', () {
    final List<MethodCall> log = <MethodCall>[];

    final Crashlytics crashlytics = Crashlytics.instance;

    setUp(() async {
      Crashlytics.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'Crashlytics#onError':
            return 'Error reported to Crashlytics.';
          case 'Crashlytics#setUserIdentifier':
            return true;
          default:
            return false;
        }
      });
      log.clear();
    });

    test('recordFlutterError', () async {
      final FlutterErrorDetails details = FlutterErrorDetails(
        exception: 'foo exception',
        stack: StackTrace.current,
        library: 'foo library',
        informationCollector: () => <DiagnosticsNode>[
          DiagnosticsNode.message('test message'),
          DiagnosticsNode.message('second message'),
        ],
        context: ErrorDescription('foo context'),
      );
      crashlytics
        ..enableInDevMode = true
        ..log('foo')
        ..setCustomKey('testBool', true)
        ..setCustomKey('testInt', 42)
        ..setCustomKey('testDouble', 42.0)
        ..setCustomKey('testString', 'bar');
      await crashlytics.recordFlutterError(details);
      expect(log[0].method, 'Crashlytics#onError');
      expect(log[0].arguments['exception'], 'foo exception');
      expect(log[0].arguments['context'], 'foo context');
      expect(log[0].arguments['information'], 'test message\nsecond message');
      expect(log[0].arguments['logs'], isNotEmpty);
      expect(log[0].arguments['logs'], contains('foo'));
      expect(log[0].arguments['keys']['testBool'], 'true');
      expect(log[0].arguments['keys']['testInt'], '42');
      expect(log[0].arguments['keys']['testDouble'], '42.0');
      expect(log[0].arguments['keys']['testString'], 'bar');
    });

    test('recordError', () async {
      crashlytics.enableInDevMode = true;
      crashlytics.log('foo');
      await crashlytics.recordError('foo exception', null, context: "context");
      expect(log[0].method, 'Crashlytics#onError');
      expect(log[0].arguments['exception'], 'foo exception');
      expect(log[0].arguments['context'], "context");
      // Confirm that the stack trace contains current stack.
      expect(
        log[0].arguments['stackTraceElements'],
        contains(containsPair('file', 'firebase_crashlytics_test.dart')),
      );
      expect(log[0].arguments['logs'], isNotEmpty);
      expect(log[0].arguments['logs'], contains('foo'));
      expect(log[0].arguments['keys']['testBool'], 'true');
      expect(log[0].arguments['keys']['testInt'], '42');
      expect(log[0].arguments['keys']['testDouble'], '42.0');
      expect(log[0].arguments['keys']['testString'], 'bar');
    });

    test('crash', () {
      expect(() => crashlytics.crash(), throwsStateError);
    });

    test('setUserIdentifier', () async {
      await crashlytics.setUserIdentifier('foo');
      expect(log, <Matcher>[
        isMethodCall('Crashlytics#setUserIdentifier',
            arguments: <String, dynamic>{'identifier': 'foo'})
      ]);
    });

    test('getStackTraceElements with character index', () async {
      final List<String> lines = <String>[
        'package:flutter/src/widgets/framework.dart 3825:27  StatefulElement.build'
      ];
      final List<Map<String, String>> elements =
          crashlytics.getStackTraceElements(lines);
      expect(elements.length, 1);
      expect(elements.first, <String, String>{
        'class': 'StatefulElement',
        'method': 'build',
        'file': 'package:flutter/src/widgets/framework.dart',
        'line': '3825',
      });
    });

    test('getStackTraceElements without character index', () async {
      final List<String> lines = <String>[
        'package:flutter/src/widgets/framework.dart 3825  StatefulElement.build'
      ];
      final List<Map<String, String>> elements =
          crashlytics.getStackTraceElements(lines);
      expect(elements.length, 1);
      expect(elements.first, <String, String>{
        'class': 'StatefulElement',
        'method': 'build',
        'file': 'package:flutter/src/widgets/framework.dart',
        'line': '3825',
      });
    });

    test('getStackTraceElements without class', () async {
      final List<String> lines = <String>[
        'package:firebase_crashlytics/test/main.dart 12  main'
      ];
      final List<Map<String, String>> elements =
          crashlytics.getStackTraceElements(lines);
      expect(elements.length, 1);
      expect(elements.first, <String, String>{
        'method': 'main',
        'file': 'package:firebase_crashlytics/test/main.dart',
        'line': '12',
      });
    });
  });
}
