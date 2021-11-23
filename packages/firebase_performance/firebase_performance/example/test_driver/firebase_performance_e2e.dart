// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:drive/drive.dart' as drive;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void testsMain() {
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('$FirebasePerformance.instance', () {
    test('isPerformanceCollectionEnabled', () async {
      FirebasePerformance performance = FirebasePerformance.instance;

      expect(
        performance.isPerformanceCollectionEnabled(),
        completion(isTrue),
      );
    });
    test('setPerformanceCollectionEnabled', () async {
      FirebasePerformance performance = FirebasePerformance.instance;

      await performance.setPerformanceCollectionEnabled(false);

      if (kIsWeb) {
        // Todo update API to match web & iOS
        expect(
          performance.isPerformanceCollectionEnabled(),
          completion(isTrue),
        );
      } else {
        expect(
          performance.isPerformanceCollectionEnabled(),
          completion(isFalse),
        );
      }
    });
  });

  group('$Trace', () {
    late FirebasePerformance performance;
    late Trace testTrace;
    const String metricName = 'test-metric';

    setUpAll(() async {
      performance = FirebasePerformance.instance;
      await performance.setPerformanceCollectionEnabled(true);
    });

    setUp(() async {
      testTrace = await performance.newTrace('test-trace');
    });

    tearDown(() async {
      await testTrace.stop();
    });

    test('startTrace()', () async {
      Trace testTrace = await FirebasePerformance.startTrace('testTrace');
      expect(testTrace, isA<Trace>());
    });

    test('incrementMetric does nothing before the trace is started', () async {
      await testTrace.incrementMetric(metricName, 100);
      await testTrace.start();

      await expectLater(testTrace.getMetric(metricName), 0);
    });

    test(
        "incrementMetric works correctly after the trace is started and before it's stopped",
        () async {
      await testTrace.start();

      await testTrace.incrementMetric(metricName, 14);
      await expectLater(testTrace.getMetric(metricName), 14);

      await testTrace.incrementMetric(metricName, 45);
      await expectLater(testTrace.getMetric(metricName), 59);
    });

    test('incrementMetric does nothing after the trace has stopped', () async {
      await testTrace.start();
      await testTrace.stop();
      await testTrace.incrementMetric(metricName, 100);

      await expectLater(testTrace.getMetric(metricName), 0);
    });
    test('setMetric does nothing before the trace has started', () async {
      await testTrace.setMetric(metricName, 37);
      await testTrace.start();

      await expectLater(testTrace.getMetric(metricName), 0);
    });

    test(
        "setMetric works correctly after the trace is started and before it's stopped",
        () async {
      await testTrace.start();

      await testTrace.setMetric(metricName, 37);

      if (kIsWeb) {
        await expectLater(testTrace.getMetric(metricName), 0);
      } else {
        await expectLater(testTrace.getMetric(metricName), 37);
      }

      await testTrace.setMetric(metricName, 3);
      if (kIsWeb) {
        await expectLater(testTrace.getMetric(metricName), 0);
      } else {
        await expectLater(testTrace.getMetric(metricName), 3);
      }
    });

    test('setMetric does nothing after the trace is stopped', () async {
      await testTrace.start();
      await testTrace.stop();
      await testTrace.setMetric(metricName, 100);

      await expectLater(testTrace.getMetric(metricName), 0);
    });

    test('putAttribute works correctly before the trace is stopped', () async {
      await testTrace.putAttribute('apple', 'sauce');
      await testTrace.putAttribute('banana', 'pie');

      expect(
        testTrace.getAttributes(),
        <String, String>{'apple': 'sauce', 'banana': 'pie'},
      );

      await testTrace.putAttribute('apple', 'sauce2');
      expect(
        testTrace.getAttributes(),
        <String, String>{'apple': 'sauce2', 'banana': 'pie'},
      );
    });

    test('putAttribute does nothing after the trace is stopped', () async {
      await testTrace.start();
      await testTrace.stop();
      await testTrace.putAttribute('apple', 'sauce');

      expect(
        testTrace.getAttributes(),
        <String, String>{},
      );
    });

    test('removeAttribute works correctly before the trace is stopped',
        () async {
      await testTrace.putAttribute('sponge', 'bob');
      await testTrace.putAttribute('patrick', 'star');
      await testTrace.removeAttribute('sponge');

      expect(
        testTrace.getAttributes(),
        <String, String>{'patrick': 'star'},
      );

      await testTrace.removeAttribute('sponge');

      expect(
        testTrace.getAttributes(),
        <String, String>{'patrick': 'star'},
      );
    });
    test('removeAttribute does nothing after the trace is stopped', () async {
      await testTrace.start();
      await testTrace.putAttribute('sponge', 'bob');
      await testTrace.stop();
      await testTrace.removeAttribute('sponge');

      expect(
        testTrace.getAttributes(),
        <String, String>{'sponge': 'bob'},
      );
    });

    test('getAttribute', () async {
      await testTrace.putAttribute('yugi', 'oh');

      expect(testTrace.getAttribute('yugi'), equals('oh'));

      await testTrace.start();
      await testTrace.stop();
      expect(testTrace.getAttribute('yugi'), equals('oh'));
    });
  });

  test('test all Http method values', () async {
    FirebasePerformance performance = FirebasePerformance.instance;

    await Future.forEach(HttpMethod.values, (HttpMethod method) async {
      final HttpMetric testMetric = await performance.newHttpMetric(
        'https://www.google.com/',
        method,
      );
      await testMetric.start();
      await testMetric.stop();
    });
  });
  //
  group('$HttpMetric', () {
    late FirebasePerformance performance;
    late HttpMetric testHttpMetric;

    setUpAll(() async {
      performance = FirebasePerformance.instance;
      await performance.setPerformanceCollectionEnabled(true);
    });

    setUp(() async {
      testHttpMetric = await performance.newHttpMetric(
        'https://www.google.com/',
        HttpMethod.Delete,
      );
    });

    tearDown(() {
      testHttpMetric.stop();
    });

    test('putAttribute works correctly before the HTTP metric is started',
        () async {
      await testHttpMetric.putAttribute('apple', 'sauce');
      await testHttpMetric.putAttribute('banana', 'pie');

      expect(
        testHttpMetric.getAttributes(),
        <String, String>{'apple': 'sauce', 'banana': 'pie'},
      );
    });

    test('putAttribute works correctly after the HTTP metric is started',
        () async {
      await testHttpMetric.start();

      await testHttpMetric.putAttribute('apple', 'sauce2');
      expect(
        testHttpMetric.getAttributes(),
        <String, String>{'apple': 'sauce2'},
      );
    });

    test('putAttribute does nothing after the HTTP metric is stopped',
        () async {
      await testHttpMetric.start();
      await testHttpMetric.stop();
      await testHttpMetric.putAttribute('apple', 'sauce');

      expect(
        testHttpMetric.getAttributes(),
        <String, String>{},
      );
    });

    test('removeAttribute works correctly before the HTTP metric is started',
        () async {
      await testHttpMetric.putAttribute('sponge', 'bob');
      await testHttpMetric.putAttribute('patrick', 'star');
      await testHttpMetric.removeAttribute('sponge');

      expect(
        testHttpMetric.getAttributes(),
        <String, String>{'patrick': 'star'},
      );

      await testHttpMetric.removeAttribute('sponge');
      expect(
        testHttpMetric.getAttributes(),
        <String, String>{'patrick': 'star'},
      );
    });

    test('removeAttribute works correctly after the HTTP metric is started',
        () async {
      await testHttpMetric.start();
      await testHttpMetric.putAttribute('sponge', 'bob');
      await testHttpMetric.putAttribute('patrick', 'star');
      await testHttpMetric.removeAttribute('sponge');

      expect(
        testHttpMetric.getAttributes(),
        <String, String>{'patrick': 'star'},
      );

      await testHttpMetric.removeAttribute('sponge');
      expect(
        testHttpMetric.getAttributes(),
        <String, String>{'patrick': 'star'},
      );
    });

    test('removeAttribute does nothing after the HTTP metric is stopped',
        () async {
      await testHttpMetric.start();
      await testHttpMetric.putAttribute('sponge', 'bob');
      await testHttpMetric.stop();
      await testHttpMetric.removeAttribute('sponge');

      expect(
        testHttpMetric.getAttributes(),
        <String, String>{'sponge': 'bob'},
      );
    });

    test('getAttribute', () async {
      await testHttpMetric.putAttribute('yugi', 'oh');

      expect(testHttpMetric.getAttribute('yugi'), equals('oh'));

      await testHttpMetric.start();
      await testHttpMetric.stop();
      expect(testHttpMetric.getAttribute('yugi'), equals('oh'));
    });

    test('set HTTP response code correctly before started', () async {
      await testHttpMetric.setHttpResponseCode(443);
      expect(testHttpMetric.httpResponseCode, equals(443));
    });

    test('set HTTP response code correctly after started', () async {
      await testHttpMetric.start();
      await testHttpMetric.setHttpResponseCode(443);
      expect(testHttpMetric.httpResponseCode, equals(443));
    });

    test('cannot set HTTP response code correctly after stopped', () async {
      await testHttpMetric.start();
      await testHttpMetric.stop();
      await testHttpMetric.setHttpResponseCode(443);
      expect(testHttpMetric.httpResponseCode, equals(null));
    });

    test('set request payload size correctly before started', () async {
      await testHttpMetric.setRequestPayloadSize(56734);
      expect(testHttpMetric.requestPayloadSize, equals(56734));
    });

    test('set request payload size correctly after started', () async {
      await testHttpMetric.start();
      await testHttpMetric.setRequestPayloadSize(56734);
      expect(testHttpMetric.requestPayloadSize, equals(56734));
    });

    test('Cannot set request payload size correctly after stopped', () async {
      await testHttpMetric.start();
      await testHttpMetric.stop();
      await testHttpMetric.setRequestPayloadSize(56734);
      expect(testHttpMetric.requestPayloadSize, equals(null));
    });

    test('set response payload size correctly before started', () async {
      await testHttpMetric.setResponsePayloadSize(4949);
      expect(testHttpMetric.responsePayloadSize, equals(4949));
    });

    test('set response payload size correctly after started', () async {
      await testHttpMetric.start();
      await testHttpMetric.setResponsePayloadSize(4949);
      expect(testHttpMetric.responsePayloadSize, equals(4949));
    });

    test('Cannot set response payload size correctly after stopped', () async {
      await testHttpMetric.start();
      await testHttpMetric.stop();
      await testHttpMetric.setResponsePayloadSize(4949);
      expect(testHttpMetric.responsePayloadSize, equals(null));
    });

    test('set response content type correctly before started', () async {
      await testHttpMetric.setResponseContentType('1984');
      expect(testHttpMetric.responseContentType, equals('1984'));
    });

    test('set response content type correctly after started', () async {
      await testHttpMetric.start();
      await testHttpMetric.setResponseContentType('1984');
      expect(testHttpMetric.responseContentType, equals('1984'));
    });

    test('Cannot set response content type correctly after stopped', () async {
      await testHttpMetric.start();
      await testHttpMetric.stop();
      await testHttpMetric.setResponseContentType('1984');
      expect(testHttpMetric.responseContentType, equals(null));
    });
  });
}

void main() => drive.main(testsMain);
