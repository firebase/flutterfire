@TestOn('chrome') // Uses web-only Flutter SDK

import 'package:firebase/firebase.dart';
import 'package:firebase_performance_platform_interface/firebase_performance_platform_interface.dart';
import 'package:firebase_performance_web/firebase_performance_web.dart';
import 'package:firebase_performance_web/src/http_metric.dart';
import 'package:firebase_performance_web/src/trace.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockPerformance extends Mock implements Performance {}

class MockTrace extends Mock implements Trace {}

void main() {
  group('FirebasePerformanceWeb', () {
    late FirebasePerformancePlatform firebasePerformancePlatform;
    late MockPerformance mockPerformance;

    setUp(() {
      mockPerformance = MockPerformance();
      firebasePerformancePlatform =
          FirebasePerformanceWeb(performance: mockPerformance);
    });

    test('isPerformanceCollectionEnabled always returns true', () async {
      expect(await firebasePerformancePlatform.isPerformanceCollectionEnabled(),
          true);
      verifyNoMoreInteractions(mockPerformance);
    });

    test('setPerformanceCollectionEnabled does nothing', () async {
      await firebasePerformancePlatform.setPerformanceCollectionEnabled(true);
      verifyNoMoreInteractions(mockPerformance);
    });

    test('newTrace returns correct trace web platform object', () async {
      const testTraceName = 'test_trace';
      final MockTrace mockTrace = MockTrace();
      when(mockPerformance.trace(testTraceName)).thenReturn(mockTrace);

      TracePlatform trace = firebasePerformancePlatform.newTrace(testTraceName);

      expect(trace.runtimeType, TraceWeb);
      trace = trace as TraceWeb;
      expect(trace.traceDelegate, mockTrace);
      expect(trace.name, testTraceName);
      expect(trace.performance, firebasePerformancePlatform);
      verify(mockPerformance.trace(testTraceName)).called(1);
      verifyNoMoreInteractions(mockPerformance);
      verifyNoMoreInteractions(mockTrace);
    });

    test('newHttpMetric returns a dummy object', () async {
      HttpMetricPlatform httpMeric = firebasePerformancePlatform.newHttpMetric(
          'http://test_url', HttpMethod.Get);

      expect(httpMeric.runtimeType, HttpMetricWeb);
      expect(httpMeric.url, '');
      verifyNoMoreInteractions(mockPerformance);
    });

    test('startTrace starts a trace and returns the trace web platform object',
        () async {
      const testTraceName = 'test_trace';
      final MockTrace mockTrace = MockTrace();
      when(mockPerformance.trace(testTraceName)).thenReturn(mockTrace);

      TracePlatform trace =
          await firebasePerformancePlatform.startTrace(testTraceName);

      expect(trace.runtimeType, TraceWeb);
      trace = trace as TraceWeb;
      expect(trace.traceDelegate, mockTrace);
      expect(trace.name, testTraceName);
      expect(trace.performance, firebasePerformancePlatform);
      verify(mockPerformance.trace(testTraceName)).called(1);
      verify(mockTrace.start()).called(1);
      verifyNoMoreInteractions(mockPerformance);
      verifyNoMoreInteractions(mockTrace);
    });
  });

  group('TraceWeb', () {
    late FirebasePerformancePlatform firebasePerformancePlatform;
    late MockPerformance mockPerformance;
    late TracePlatform tracePlatform;
    late MockTrace mockTrace;
    late String testTraceName = 'test_trace';

    setUp(() {
      mockPerformance = MockPerformance();
      firebasePerformancePlatform =
          FirebasePerformanceWeb(performance: mockPerformance);
      mockTrace = MockTrace();
      tracePlatform =
          TraceWeb(firebasePerformancePlatform, mockTrace, 0, testTraceName);
    });

    test('start', () async {
      await tracePlatform.start();
      verify(mockTrace.start()).called(1);
      verifyNoMoreInteractions(mockPerformance);
      verifyNoMoreInteractions(mockTrace);
    });

    test('stop', () async {
      await tracePlatform.stop();
      verify(mockTrace.stop()).called(1);
      verifyNoMoreInteractions(mockPerformance);
      verifyNoMoreInteractions(mockTrace);
    });

    test('incrementMetric', () async {
      await tracePlatform.incrementMetric('counter_name', 33);
      verify(mockTrace.incrementMetric('counter_name', 33)).called(1);
      verifyNoMoreInteractions(mockPerformance);
      verifyNoMoreInteractions(mockTrace);
    });

    test('setMetric does nothing', () async {
      await tracePlatform.setMetric('counter_name', 33);
      verifyNoMoreInteractions(mockPerformance);
      verifyNoMoreInteractions(mockTrace);
    });

    test('getMetric', () async {
      await tracePlatform.getMetric('counter_name');
      verify(mockTrace.getMetric('counter_name')).called(1);
      verifyNoMoreInteractions(mockPerformance);
      verifyNoMoreInteractions(mockTrace);
    });

    test('putAttribute', () async {
      await tracePlatform.putAttribute('attribute', 'value');
      verify(mockTrace.putAttribute('attribute', 'value')).called(1);
      verifyNoMoreInteractions(mockPerformance);
      verifyNoMoreInteractions(mockTrace);
    });

    test('removeAttribute', () async {
      await tracePlatform.removeAttribute('attribute');
      verify(mockTrace.removeAttribute('attribute')).called(1);
      verifyNoMoreInteractions(mockPerformance);
      verifyNoMoreInteractions(mockTrace);
    });

    test('getAttribute', () async {
      tracePlatform.getAttribute('attribute');
      verify(mockTrace.getAttribute('attribute')).called(1);
      verifyNoMoreInteractions(mockPerformance);
      verifyNoMoreInteractions(mockTrace);
    });

    test('getAttributes', () async {
      when(mockTrace.getAttributes()).thenReturn(<String, String>{});
      await tracePlatform.getAttributes();
      verify(mockTrace.getAttributes()).called(1);
      verifyNoMoreInteractions(mockPerformance);
      verifyNoMoreInteractions(mockTrace);
    });
  });

  group('HttpMetricWeb', () {
    late FirebasePerformancePlatform firebasePerformancePlatform;
    late MockPerformance mockPerformance;
    late HttpMetricPlatform httpMetricPlatform;

    setUp(() {
      mockPerformance = MockPerformance();
      firebasePerformancePlatform =
          FirebasePerformanceWeb(performance: mockPerformance);
      httpMetricPlatform =
          HttpMetricWeb(firebasePerformancePlatform, 0, '', HttpMethod.Get);
    });

    test('httpResponseCode setter does nothing', () async {
      httpMetricPlatform.httpResponseCode = 404;
      expect(httpMetricPlatform.httpResponseCode, null);
      verifyNoMoreInteractions(mockPerformance);
    });

    test('requestPayloadSize setter does nothing', () async {
      httpMetricPlatform.requestPayloadSize = 100;
      expect(httpMetricPlatform.requestPayloadSize, null);
      verifyNoMoreInteractions(mockPerformance);
    });

    test('responsePayloadSize setter does nothing', () async {
      httpMetricPlatform.responsePayloadSize = 100;
      expect(httpMetricPlatform.responsePayloadSize, null);
      verifyNoMoreInteractions(mockPerformance);
    });

    test('start does nothing', () async {
      await httpMetricPlatform.start();
      verifyNoMoreInteractions(mockPerformance);
    });

    test('stop does nothing', () async {
      await httpMetricPlatform.stop();
      verifyNoMoreInteractions(mockPerformance);
    });

    test('putAttribute does nothing', () async {
      //await httpMetricPlatform.putAttribute();
      verifyNoMoreInteractions(mockPerformance);
    });
  });
}
