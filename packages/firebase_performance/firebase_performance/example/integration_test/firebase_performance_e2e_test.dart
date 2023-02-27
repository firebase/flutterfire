// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
      expect(
        performance.isPerformanceCollectionEnabled(),
        completion(isFalse),
      );
    });
  });

  group('$Trace', () {
    late FirebasePerformance performance;
    late Trace testTrace;
    const String metricName = 'test-metric';

    setUpAll(() async {
      performance = FirebasePerformance.instance;
    });

    setUp(() async {
      await performance.setPerformanceCollectionEnabled(true);
      testTrace = performance.newTrace('test-trace');
    });

    test('start & stop trace', () async {
      await testTrace.start();
      await testTrace.stop();
    });

    test('starting trace with performance collection disabled', () async {
      await performance.setPerformanceCollectionEnabled(false);
      await testTrace.start();
      await testTrace.stop();
    });

    test("starting Trace twice shouldn't throw an error", () async {
      await testTrace.start();
      await testTrace.start();
    });

    test("stopping Trace twice shouldn't throw an error", () async {
      await testTrace.start();
      await testTrace.stop();
      await testTrace.stop();
    });

    test('incrementMetric works correctly', () {
      testTrace.incrementMetric(metricName, 14);
      expect(testTrace.getMetric(metricName), 14);

      testTrace.incrementMetric(metricName, 45);
      expect(testTrace.getMetric(metricName), 59);
    });

    test('setMetric works correctly', () async {
      testTrace.setMetric(metricName, 37);
      expect(testTrace.getMetric(metricName), 37);
      testTrace.setMetric(metricName, 3);
      expect(testTrace.getMetric(metricName), 3);
    });

    test('putAttribute works correctly', () {
      testTrace.putAttribute('apple', 'sauce');
      testTrace.putAttribute('banana', 'pie');

      expect(
        testTrace.getAttributes(),
        <String, String>{'apple': 'sauce', 'banana': 'pie'},
      );

      testTrace.putAttribute('apple', 'sauce2');
      expect(
        testTrace.getAttributes(),
        <String, String>{'apple': 'sauce2', 'banana': 'pie'},
      );
    });

    test('removeAttribute works correctly', () {
      testTrace.putAttribute('sponge', 'bob');
      testTrace.putAttribute('patrick', 'star');
      testTrace.removeAttribute('sponge');

      expect(
        testTrace.getAttributes(),
        <String, String>{'patrick': 'star'},
      );

      testTrace.removeAttribute('sponge');

      expect(
        testTrace.getAttributes(),
        <String, String>{'patrick': 'star'},
      );
    });

    test('getAttribute', () async {
      testTrace.putAttribute('yugi', 'oh');

      expect(testTrace.getAttribute('yugi'), equals('oh'));
      expect(testTrace.getAttribute('yugi'), equals('oh'));
    });
  });

  group(
    '$HttpMetric',
    () {
      late FirebasePerformance performance;
      late HttpMetric testHttpMetric;

      setUpAll(() async {
        performance = FirebasePerformance.instance;
        await performance.setPerformanceCollectionEnabled(true);
      });

      setUp(() async {
        testHttpMetric = performance.newHttpMetric(
          'https://www.google.com/',
          HttpMethod.Delete,
        );
      });

      tearDown(() {
        testHttpMetric.stop();
      });

      test('test all Http method values', () async {
        FirebasePerformance performance = FirebasePerformance.instance;

        await Future.forEach(HttpMethod.values, (HttpMethod method) async {
          final HttpMetric testMetric = performance.newHttpMetric(
            'https://www.google.com/',
            method,
          );
          await testMetric.start();
          await testMetric.stop();
        });
      });

      test('test all Http method values with collection disabled', () async {
        FirebasePerformance performance = FirebasePerformance.instance;
        await performance.setPerformanceCollectionEnabled(false);

        await Future.forEach(HttpMethod.values, (HttpMethod method) async {
          final HttpMetric testMetric = performance.newHttpMetric(
            'https://www.google.com/',
            method,
          );
          await testMetric.start();
          await testMetric.stop();
        });
      });

      test('putAttribute works correctly', () {
        testHttpMetric.putAttribute('apple', 'sauce');
        testHttpMetric.putAttribute('banana', 'pie');

        expect(
          testHttpMetric.getAttributes(),
          <String, String>{'apple': 'sauce', 'banana': 'pie'},
        );
      });

      test('removeAttribute works correctly', () {
        testHttpMetric.putAttribute('sponge', 'bob');
        testHttpMetric.putAttribute('patrick', 'star');
        testHttpMetric.removeAttribute('sponge');

        expect(
          testHttpMetric.getAttributes(),
          <String, String>{'patrick': 'star'},
        );

        testHttpMetric.removeAttribute('sponge');
        expect(
          testHttpMetric.getAttributes(),
          <String, String>{'patrick': 'star'},
        );
      });

      test('getAttribute works correctly', () {
        testHttpMetric.putAttribute('yugi', 'oh');

        expect(testHttpMetric.getAttribute('yugi'), equals('oh'));
      });

      test('set HTTP response code correctly', () {
        testHttpMetric.httpResponseCode = 443;
        expect(testHttpMetric.httpResponseCode, equals(443));
      });

      test('set request payload size correctly', () {
        testHttpMetric.requestPayloadSize = 56734;
        expect(testHttpMetric.requestPayloadSize, equals(56734));
      });

      test('set response payload size correctly', () {
        testHttpMetric.responsePayloadSize = 4949;
        expect(testHttpMetric.responsePayloadSize, equals(4949));
      });

      test('set response content type correctly', () {
        testHttpMetric.responseContentType = 'content';
        expect(testHttpMetric.responseContentType, equals('content'));
      });

      test("starting HttpMetric twice shouldn't throw an error", () async {
        await testHttpMetric.start();
        await testHttpMetric.start();
      });

      test("stopping HttpMetric twice shouldn't throw an error", () async {
        await testHttpMetric.start();
        await testHttpMetric.stop();
        await testHttpMetric.stop();
      });
    },
    skip: kIsWeb,
  );
}
