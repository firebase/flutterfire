// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'package:e2e/e2e.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:pedantic/pedantic.dart';

Future<void> main() async {
  E2EWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('$FirebasePerformance', () {
    testWidgets('test instance is singleton', (WidgetTester tester) async {
      FirebasePerformance performance1 = FirebasePerformance.instance;
      FirebasePerformance performance2 = FirebasePerformance.instance;

      expect(identical(performance1, performance2), isTrue);
    });

    testWidgets('setPerformanceCollectionEnabled', (WidgetTester tester) async {
      FirebasePerformance performance = FirebasePerformance.instance;

      await performance.setPerformanceCollectionEnabled(true);
      expect(
        performance.isPerformanceCollectionEnabled(),
        completion(isTrue),
      );

      await performance.setPerformanceCollectionEnabled(false);
      expect(
        performance.isPerformanceCollectionEnabled(),
        completion(isFalse),
      );
    });

    testWidgets('test all Http method values', (WidgetTester tester) async {
      FirebasePerformance performance = FirebasePerformance.instance;
      for (final HttpMethod method in HttpMethod.values) {
        final HttpMetric testMetric = performance.newHttpMetric(
          'https://www.google.com/',
          method,
        );
        unawaited(testMetric.start());
        unawaited(testMetric.stop());
      }
    });

    testWidgets('startTrace', (WidgetTester tester) async {
      Trace testTrace = await FirebasePerformance.startTrace('testTrace');
      await testTrace.stop();
    });
  });

  // TODO(kroikie): Update flaky tests comment back in
  //                https://github.com/FirebaseExtended/flutterfire/issues/1454.
  group('$Trace', () {
    FirebasePerformance performance;
    Trace testTrace;
    const String metricName = 'test-metric';

    setUpAll(() async {
      performance = FirebasePerformance.instance;
      await performance.setPerformanceCollectionEnabled(true);
    });

    setUp(() {
      testTrace = performance.newTrace('test-trace');
    });

    tearDown(() {
      testTrace.stop();
      testTrace = null;
    });

    testWidgets('incrementMetric does nothing before the trace is started',
        (WidgetTester tester) async {
      await testTrace.incrementMetric(metricName, 100);
      await testTrace.start();

      expect(testTrace.getMetric(metricName), completion(0));
    });

    testWidgets(
        "incrementMetric works correctly after the trace is started and before it's stopped",
        (WidgetTester tester) async {
      await testTrace.start();

      await testTrace.incrementMetric(metricName, 14);
      expect(testTrace.getMetric(metricName), completion(14));

      await testTrace.incrementMetric(metricName, 45);
      expect(testTrace.getMetric(metricName), completion(59));
    });

    testWidgets('incrementMetric does nothing after the trace is stopped',
        (WidgetTester tester) async {
      await testTrace.start();
      await testTrace.stop();
      await testTrace.incrementMetric(metricName, 100);

      expect(testTrace.getMetric(metricName), completion(0));
    });

    testWidgets('setMetric does nothing before the trace is started',
        (WidgetTester tester) async {
      await testTrace.setMetric(metricName, 37);
      await testTrace.start();

      expect(testTrace.getMetric(metricName), completion(0));
    });

    testWidgets(
        "setMetric works correctly after the trace is started and before it's stopped",
        (WidgetTester tester) async {
      await testTrace.start();

      await testTrace.setMetric(metricName, 37);
      expect(testTrace.getMetric(metricName), completion(37));

      await testTrace.setMetric(metricName, 3);
      expect(testTrace.getMetric(metricName), completion(3));
    });

    testWidgets('setMetric does nothing after the trace is stopped',
        (WidgetTester tester) async {
      await testTrace.start();
      await testTrace.stop();
      await testTrace.setMetric(metricName, 100);

      expect(testTrace.getMetric(metricName), completion(0));
    });

    testWidgets('putAttribute works correctly before the trace is stopped',
        (WidgetTester tester) async {
      await testTrace.putAttribute('apple', 'sauce');
      await testTrace.putAttribute('banana', 'pie');

      expect(
        testTrace.getAttributes(),
        completion(<String, String>{'apple': 'sauce', 'banana': 'pie'}),
      );

      await testTrace.putAttribute('apple', 'sauce2');
      expect(
        testTrace.getAttributes(),
        completion(<String, String>{'apple': 'sauce2', 'banana': 'pie'}),
      );
    });

    testWidgets('putAttribute does nothing after the trace is stopped',
        (WidgetTester tester) async {
      await testTrace.start();
      await testTrace.stop();
      await testTrace.putAttribute('apple', 'sauce');

      expect(
        testTrace.getAttributes(),
        completion(<String, String>{}),
      );
    });

    testWidgets('removeAttribute works correctly before the trace is stopped',
        (WidgetTester tester) async {
      await testTrace.putAttribute('sponge', 'bob');
      await testTrace.putAttribute('patrick', 'star');
      await testTrace.removeAttribute('sponge');

      expect(
        testTrace.getAttributes(),
        completion(<String, String>{'patrick': 'star'}),
      );

      await testTrace.removeAttribute('sponge');
      expect(
        testTrace.getAttributes(),
        completion(<String, String>{'patrick': 'star'}),
      );
    });

    testWidgets('removeAttribute does nothing after the trace is stopped',
        (WidgetTester tester) async {
      await testTrace.start();
      await testTrace.putAttribute('sponge', 'bob');
      await testTrace.stop();
      await testTrace.removeAttribute('sponge');

      expect(
        testTrace.getAttributes(),
        completion(<String, String>{'sponge': 'bob'}),
      );
    });

    testWidgets('getAttribute', (WidgetTester tester) async {
      await testTrace.putAttribute('yugi', 'oh');

      expect(testTrace.getAttribute('yugi'), equals('oh'));

      await testTrace.start();
      await testTrace.stop();
      expect(testTrace.getAttribute('yugi'), equals('oh'));
    });
  });

  // TODO(kroikie): Update flaky tests and comment back in
  //                https://github.com/FirebaseExtended/flutterfire/issues/1454.
  group('$HttpMetric', () {
    FirebasePerformance performance;
    HttpMetric testHttpMetric;

    setUpAll(() async {
      performance = FirebasePerformance.instance;
      await performance.setPerformanceCollectionEnabled(true);
    });

    setUp(() {
      testHttpMetric = performance.newHttpMetric(
        'https://www.google.com/',
        HttpMethod.Delete,
      );
    });

    tearDown(() {
      testHttpMetric.stop();
      testHttpMetric = null;
    });

    testWidgets(
        'putAttribute works correctly before the HTTP metric is stopped',
        (WidgetTester tester) async {
      await testHttpMetric.putAttribute('apple', 'sauce');
      await testHttpMetric.putAttribute('banana', 'pie');

      expect(
        testHttpMetric.getAttributes(),
        completion(<String, String>{'apple': 'sauce', 'banana': 'pie'}),
      );

      await testHttpMetric.putAttribute('apple', 'sauce2');
      expect(
        testHttpMetric.getAttributes(),
        completion(<String, String>{'apple': 'sauce2', 'banana': 'pie'}),
      );
    });

    testWidgets('putAttribute does nothing after the HTTP metric is stopped',
        (WidgetTester tester) async {
      await testHttpMetric.start();
      await testHttpMetric.stop();
      await testHttpMetric.putAttribute('apple', 'sauce');

      expect(
        testHttpMetric.getAttributes(),
        completion(<String, String>{}),
      );
    });

    testWidgets(
        'removeAttribute works correctly before the HTTP metric is stopped',
        (WidgetTester tester) async {
      await testHttpMetric.putAttribute('sponge', 'bob');
      await testHttpMetric.putAttribute('patrick', 'star');
      await testHttpMetric.removeAttribute('sponge');

      expect(
        testHttpMetric.getAttributes(),
        completion(<String, String>{'patrick': 'star'}),
      );

      await testHttpMetric.removeAttribute('sponge');
      expect(
        testHttpMetric.getAttributes(),
        completion(<String, String>{'patrick': 'star'}),
      );
    });

    testWidgets('removeAttribute does nothing after the HTTP metric is stopped',
        (WidgetTester tester) async {
      await testHttpMetric.start();
      await testHttpMetric.putAttribute('sponge', 'bob');
      await testHttpMetric.stop();
      await testHttpMetric.removeAttribute('sponge');

      expect(
        testHttpMetric.getAttributes(),
        completion(<String, String>{'sponge': 'bob'}),
      );
    });

    testWidgets('getAttribute', (WidgetTester tester) async {
      await testHttpMetric.putAttribute('yugi', 'oh');

      expect(testHttpMetric.getAttribute('yugi'), equals('oh'));

      await testHttpMetric.start();
      await testHttpMetric.stop();
      expect(testHttpMetric.getAttribute('yugi'), equals('oh'));
    });

    testWidgets('set HTTP response code correctly',
        (WidgetTester tester) async {
      await testHttpMetric.start();
      testHttpMetric.httpResponseCode = 443;
      expect(testHttpMetric.httpResponseCode, equals(443));
    });

    testWidgets('set request payload size correctly',
        (WidgetTester tester) async {
      await testHttpMetric.start();
      testHttpMetric.requestPayloadSize = 56734;
      expect(testHttpMetric.requestPayloadSize, equals(56734));
    });

    testWidgets('set response payload size correctly',
        (WidgetTester tester) async {
      await testHttpMetric.start();
      testHttpMetric.responsePayloadSize = 4949;
      expect(testHttpMetric.responsePayloadSize, equals(4949));
    });

    testWidgets('set response content type correctly',
        (WidgetTester tester) async {
      await testHttpMetric.start();
      testHttpMetric.responseContentType = '1984';
      expect(testHttpMetric.responseContentType, equals('1984'));
    });
  });
}
