// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'package:e2e/e2e.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_performance/firebase_performance.dart';

void main() async {
  E2EWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('setPerformanceCollectionEnabled', (WidgetTester tester) async {
    FirebasePerformance performance = FirebasePerformance.instance;
    performance.setPerformanceCollectionEnabled(true);
    expect(
      performance.isPerformanceCollectionEnabled(),
      completion(isTrue),
    );

    performance.setPerformanceCollectionEnabled(false);
    expect(
      performance.isPerformanceCollectionEnabled(),
      completion(isFalse),
    );
  });

  testWidgets('test all values', (WidgetTester tester) async {
    FirebasePerformance performance = FirebasePerformance.instance;
    for (HttpMethod method in HttpMethod.values) {
      final HttpMetric testMetric = performance.newHttpMetric(
        'https://www.google.com/',
        method,
      );
      testMetric.start();
      testMetric.stop();
    }
  });

  // TODO(kroikie): Update flaky tests comment back in
  //                https://github.com/FirebaseExtended/flutterfire/issues/1454.
  // group('$Trace', () {
  //   Trace testTrace;

  //   setUpAll(() {
  //     FirebasePerformance performance = FirebasePerformance.instance;
  //     performance.setPerformanceCollectionEnabled(true);
  //   });

  //   setUp(() {
  //     FirebasePerformance performance = FirebasePerformance.instance;
  //     testTrace = performance.newTrace('test-trace');
  //   });

  //   tearDown(() {
  //     testTrace.stop();
  //     testTrace = null;
  //   });

  //   testWidgets('incrementMetric', (WidgetTester tester) async {
  //     testTrace.start();

  //     testTrace.incrementMetric('metric', 14);
  //     expectLater(testTrace.getMetric('metric'), completion(14));

  //     testTrace.incrementMetric('metric', 45);
  //     expect(testTrace.getMetric('metric'), completion(59));
  //   });

  //   testWidgets('setMetric', (WidgetTester tester) async {
  //     testTrace.start();

  //     testTrace.setMetric('metric2', 37);
  //     expect(testTrace.getMetric('metric2'), completion(37));
  //   });

  //   testWidgets('putAttribute', (WidgetTester tester) async {
  //     testTrace.putAttribute('apple', 'sauce');
  //     testTrace.putAttribute('banana', 'pie');

  //     expect(
  //       testTrace.getAttributes(),
  //       completion(<String, String>{'apple': 'sauce', 'banana': 'pie'}),
  //     );
  //   });

  //   testWidgets('removeAttribute', (WidgetTester tester) async {
  //     testTrace.putAttribute('sponge', 'bob');
  //     testTrace.putAttribute('patrick', 'star');
  //     testTrace.removeAttribute('sponge');

  //     expect(
  //       testTrace.getAttributes(),
  //       completion(<String, String>{'patrick': 'star'}),
  //     );
  //   });

  //   testWidgets('getAttributes', (WidgetTester tester) async {
  //     testTrace.putAttribute('yugi', 'oh');

  //     expect(
  //       testTrace.getAttributes(),
  //       completion(<String, String>{'yugi': 'oh'}),
  //     );

  //     testTrace.start();
  //     testTrace.stop();
  //     expect(
  //       testTrace.getAttributes(),
  //       completion(<String, String>{'yugi': 'oh'}),
  //     );
  //   });
  // }, skip: true);

  // TODO(kroikie): Update flaky tests and comment back in
  //                https://github.com/FirebaseExtended/flutterfire/issues/1454.
  // group('$HttpMetric', () {
  //   HttpMetric testMetric;

  //   setUpAll(() {
  //     FirebasePerformance performance = FirebasePerformance.instance;
  //     performance.setPerformanceCollectionEnabled(true);
  //   });

  //   setUp(() {
  //     FirebasePerformance performance = FirebasePerformance.instance;
  //     testMetric = performance.newHttpMetric(
  //       'https://www.google.com/',
  //       HttpMethod.Delete,
  //     );
  //   });

  //   testWidgets('putAttribute', (WidgetTester tester) async {
  //     testMetric.putAttribute('apple', 'sauce');
  //     testMetric.putAttribute('banana', 'pie');

  //     expect(
  //       testMetric.getAttributes(),
  //       completion(<String, String>{'apple': 'sauce', 'banana': 'pie'}),
  //     );
  //   });

  //   testWidgets('removeAttribute', (WidgetTester tester) async {
  //     testMetric.putAttribute('sponge', 'bob');
  //     testMetric.putAttribute('patrick', 'star');
  //     testMetric.removeAttribute('sponge');

  //     expect(
  //       testMetric.getAttributes(),
  //       completion(<String, String>{'patrick': 'star'}),
  //     );
  //   });

  //   testWidgets('getAttributes', (WidgetTester tester) async {
  //     testMetric.putAttribute('yugi', 'oh');

  //     expect(
  //       testMetric.getAttributes(),
  //       completion(<String, String>{'yugi': 'oh'}),
  //     );

  //     testMetric.start();
  //     testMetric.stop();
  //     expect(
  //       testMetric.getAttributes(),
  //       completion(<String, String>{'yugi': 'oh'}),
  //     );
  //   });

  //   testWidgets('http setters shouldn\'t cause a crash',
  //       (WidgetTester tester) async {
  //     testMetric.start();

  //     testMetric.httpResponseCode = 443;
  //     testMetric.requestPayloadSize = 56734;
  //     testMetric.responseContentType = '1984';
  //     testMetric.responsePayloadSize = 4949;

  //     await pumpEventQueue();
  //   });
  // }, skip: true);
}
