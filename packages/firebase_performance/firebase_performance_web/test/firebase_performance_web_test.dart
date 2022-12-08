// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('chrome') // Uses web-only Flutter SDK

import 'package:firebase_performance_platform_interface/firebase_performance_platform_interface.dart';
import 'package:firebase_performance_web/firebase_performance_web.dart';
import 'package:firebase_performance_web/src/interop/performance.dart';
import 'package:firebase_performance_web/src/trace.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockPerformance extends Mock implements Performance {}

class MockTrace extends Mock implements Trace {}

void main() {
  group('FirebasePerformanceWeb', () {
    late FirebasePerformanceWeb firebasePerformancePlatform;
    late MockPerformance mockPerformance;

    setUp(() {
      mockPerformance = MockPerformance();
      firebasePerformancePlatform = FirebasePerformanceWeb();
      firebasePerformancePlatform.mockDelegate = mockPerformance;
    });

    test('isPerformanceCollectionEnabled', () async {
      await expectLater(
        firebasePerformancePlatform.setPerformanceCollectionEnabled(true),
        completes,
      );
    });

    test('newTrace returns correct trace web platform object', () async {
      const testTraceName = 'test_trace';
      final MockTrace mockTrace = MockTrace();
      when(mockPerformance.trace(testTraceName)).thenReturn(mockTrace);

      TracePlatform trace = firebasePerformancePlatform.newTrace(testTraceName);

      expect(trace.runtimeType, TraceWeb);
      trace = trace as TraceWeb;
      expect(trace.traceDelegate, mockTrace);
      verify(mockPerformance.trace(testTraceName)).called(1);
      verifyNoMoreInteractions(mockPerformance);
      verifyNoMoreInteractions(mockTrace);
    });
  });
  group('TraceWeb', () {
    late TracePlatform tracePlatform;
    late MockTrace mockTrace;

    setUp(() {
      mockTrace = MockTrace();
      tracePlatform = TraceWeb(mockTrace);
    });

    test('start', () async {
      await tracePlatform.start();
      verify(mockTrace.start()).called(1);
      verifyNoMoreInteractions(mockTrace);
    });

    test('stop', () async {
      await tracePlatform.stop();
      verify(mockTrace.stop()).called(1);
      verifyNoMoreInteractions(mockTrace);
    });

    test('incrementMetric', () {
      tracePlatform.incrementMetric('counter_name', 33);
      verify(mockTrace.incrementMetric('counter_name', 33)).called(1);
      verifyNoMoreInteractions(mockTrace);
    });

    test('setMetric', () {
      tracePlatform.setMetric('set_name', 50);
      verify(mockTrace.putMetric('set_name', 50)).called(1);
      verifyNoMoreInteractions(mockTrace);
    });

    test('getMetric', () async {
      tracePlatform.getMetric('counter_name');
      verify(mockTrace.getMetric('counter_name')).called(1);
      verifyNoMoreInteractions(mockTrace);
    });

    test('putAttribute', () {
      tracePlatform.putAttribute('attribute', 'value');
      verify(mockTrace.putAttribute('attribute', 'value')).called(1);
      verifyNoMoreInteractions(mockTrace);
    });

    test('removeAttribute', () {
      tracePlatform.removeAttribute('attribute');
      verify(mockTrace.removeAttribute('attribute')).called(1);
      verifyNoMoreInteractions(mockTrace);
    });

    test('getAttribute', () async {
      tracePlatform.getAttribute('attribute');
      verify(mockTrace.getAttribute('attribute')).called(1);
      verifyNoMoreInteractions(mockTrace);
    });

    test('getAttributes', () async {
      when(mockTrace.getAttributes()).thenReturn(<String, String>{});
      tracePlatform.getAttributes();
      verify(mockTrace.getAttributes()).called(1);
      verifyNoMoreInteractions(mockTrace);
    });
  });
}
