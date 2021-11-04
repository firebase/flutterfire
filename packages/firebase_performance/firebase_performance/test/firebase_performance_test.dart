// ignore_for_file: require_trailing_commas
// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_performance_platform_interface/firebase_performance_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import './mock.dart';

MockFirebasePerformance mockPerformancePlatform = MockFirebasePerformance();
MockTracePlatform mockTracePlatform = MockTracePlatform('foo');
String mockUrl = 'https://example.com';
MockHttpMetricPlatform mockHttpMetricPlatform =
    MockHttpMetricPlatform(mockUrl, HttpMethod.Get);

void main() {
  setupFirebasePerformanceMocks();

  late FirebasePerformance performance;

  group('$FirebasePerformance', () {
    FirebasePerformancePlatform.instance = mockPerformancePlatform;

    setUpAll(() async {
      await Firebase.initializeApp();
      performance = FirebasePerformance.instance;
    });

    group('performanceCollectionEnabled', () {
      when(mockPerformancePlatform.isPerformanceCollectionEnabled())
          .thenAnswer((_) => Future.value(true));
      when(mockPerformancePlatform.setPerformanceCollectionEnabled(true))
          .thenAnswer((_) => Future.value());

      test('getter should call delegate method', () async {
        await performance.isPerformanceCollectionEnabled();
        verify(mockPerformancePlatform.isPerformanceCollectionEnabled());
      });
      test('setter should call delegate method', () async {
        await performance.setPerformanceCollectionEnabled(true);
        verify(mockPerformancePlatform.setPerformanceCollectionEnabled(true));
      });
    });

    group('trace', () {
      when(mockPerformancePlatform.newTrace('foo'))
          .thenReturn(mockTracePlatform);
      when(FirebasePerformancePlatform.startTrace('foo')).thenAnswer(
          (realInvocation) => Future.value(MockTracePlatform('foo')));
      when(mockTracePlatform.start())
          .thenAnswer((realInvocation) => Future.value());
      when(mockTracePlatform.incrementMetric('bar', 8))
          .thenAnswer((realInvocation) => Future.value());

      test('newTrace should call delegate method', () async {
        performance.newTrace('foo');
        verify(mockPerformancePlatform.newTrace('foo'));
      });

      test('startTrace should call delegate methods', () async {
        final trace = await FirebasePerformancePlatform.startTrace('foo');
        verify(mockPerformancePlatform.newTrace('foo'));
        verify(trace.start());
      });

      test('start and stop should call delegate methods', () async {
        final trace = performance.newTrace('foo');
        await trace.start();
        verify(mockTracePlatform.start());
        await trace.stop();
        verify(mockTracePlatform.stop());
      });

      test('incrementMetric should call delegate method', () async {
        final trace = performance.newTrace('foo');
        await trace.incrementMetric('bar', 8);
        verify(mockTracePlatform.incrementMetric('bar', 8));
      });

      test('setMetric should call delegate method', () async {
        final trace = performance.newTrace('foo');
        await trace.setMetric('bar', 8);
        verify(mockTracePlatform.setMetric('bar', 8));
      });

      test('getMetric should call delegate method', () async {
        final trace = performance.newTrace('foo');
        await trace.getMetric('bar');
        verify(mockTracePlatform.getMetric('bar'));
      });
    });

    group('http metric', () {
      when(mockPerformancePlatform.newHttpMetric(mockUrl, HttpMethod.Get))
          .thenReturn(mockHttpMetricPlatform);

      test('newHttpMetric should call delegate method', () async {
        performance.newHttpMetric(mockUrl, HttpMethod.Get);
        verify(mockPerformancePlatform.newHttpMetric(mockUrl, HttpMethod.Get));
      });

      test('httpResponseCode getter should call delegate getter', () async {
        final httpMetric = performance.newHttpMetric(mockUrl, HttpMethod.Get);
        httpMetric.httpResponseCode;
        verify(mockHttpMetricPlatform.httpResponseCode);
      });

      test('requestPayloadSize getter should call delegate getter', () async {
        final httpMetric = performance.newHttpMetric(mockUrl, HttpMethod.Get);
        httpMetric.requestPayloadSize;
        verify(mockHttpMetricPlatform.requestPayloadSize);
      });

      test('responseContentType getter should call delegate getter', () async {
        final httpMetric = performance.newHttpMetric(mockUrl, HttpMethod.Get);
        httpMetric.responseContentType;
        verify(mockHttpMetricPlatform.responseContentType);
      });

      test('responsePayloadSize getter should call delegate getter', () async {
        final httpMetric = performance.newHttpMetric(mockUrl, HttpMethod.Get);
        httpMetric.responsePayloadSize;
        verify(mockHttpMetricPlatform.responsePayloadSize);
      });

      test('httpResponseCode setter should call delegate setter', () async {
        final httpMetric = performance.newHttpMetric(mockUrl, HttpMethod.Get);
        httpMetric.responsePayloadSize = 8080;
        verify(mockHttpMetricPlatform.responsePayloadSize = 8080);
      });

      test('requestPayloadSize setter should call delegate setter', () async {
        final httpMetric = performance.newHttpMetric(mockUrl, HttpMethod.Get);
        httpMetric.requestPayloadSize = 8;
        verify(mockHttpMetricPlatform.requestPayloadSize = 8);
      });

      test('responsePayloadSize setter should call delegate setter', () async {
        final httpMetric = performance.newHttpMetric(mockUrl, HttpMethod.Get);
        httpMetric.responsePayloadSize = 8;
        verify(mockHttpMetricPlatform.responsePayloadSize = 8);
      });

      test('responseContentType setter should call delegate setter', () async {
        final httpMetric = performance.newHttpMetric(mockUrl, HttpMethod.Get);
        httpMetric.responseContentType = 'foo';
        verify(mockHttpMetricPlatform.responseContentType = 'foo');
      });

      test('start should call delegate', () async {
        final httpMetric = performance.newHttpMetric(mockUrl, HttpMethod.Get);
        await httpMetric.start();
        verify(mockHttpMetricPlatform.start());
      });

      test('stop should call delegate', () async {
        final httpMetric = performance.newHttpMetric(mockUrl, HttpMethod.Get);
        await httpMetric.stop();
        verify(mockHttpMetricPlatform.stop());
      });
    });
  });
}

class MockFirebasePerformance extends Mock
    with MockPlatformInterfaceMixin
    implements TestFirebasePerformancePlatform {
  MockFirebasePerformance() {
    TestFirebasePerformancePlatform();
  }

  @override
  Future<bool> isPerformanceCollectionEnabled() {
    return super.noSuchMethod(
      Invocation.method(#isPerformanceCollectionEnabled, []),
      returnValue: Future<bool>.value(true),
      returnValueForMissingStub: Future<bool>.value(true),
    );
  }

  @override
  HttpMetricPlatform newHttpMetric(String url, HttpMethod httpMethod) {
    return super.noSuchMethod(
      Invocation.method(#newHttpMetric, [url, httpMethod]),
      returnValue: MockHttpMetricPlatform(url, httpMethod),
      returnValueForMissingStub: MockHttpMetricPlatform(url, httpMethod),
    );
  }

  @override
  TracePlatform newTrace(String name) {
    return super.noSuchMethod(
      Invocation.method(#newTrace, [name]),
      returnValue: MockTracePlatform(name),
      returnValueForMissingStub: MockTracePlatform(name),
    );
  }

  @override
  Future<void> setPerformanceCollectionEnabled(bool enabled) {
    return super.noSuchMethod(
      Invocation.method(#setPerformanceCollectionEnabled, [enabled]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    );
  }
}

class TestFirebasePerformancePlatform extends FirebasePerformancePlatform {
  TestFirebasePerformancePlatform() : super();
}

class TestTracePlatform extends TracePlatform {
  TestTracePlatform(String name) : super(name);
}

class MockTracePlatform extends Mock
    with MockPlatformInterfaceMixin
    implements TestTracePlatform {
  MockTracePlatform(String name) {
    TestTracePlatform(name);
  }

  @override
  Future<void> start() {
    return super.noSuchMethod(
      Invocation.method(#start, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    );
  }

  @override
  Future<void> stop() {
    return super.noSuchMethod(
      Invocation.method(#stop, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    );
  }

  @override
  Future<void> incrementMetric(String name, int value) {
    return super.noSuchMethod(
      Invocation.method(#incrementMetric, [name, value]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    );
  }

  @override
  Future<void> setMetric(String name, int value) {
    return super.noSuchMethod(
      Invocation.method(#setMetric, [name, value]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    );
  }

  @override
  Future<int> getMetric(String name) {
    return super.noSuchMethod(
      Invocation.method(#getMetric, [name]),
      returnValue: Future<int>.value(8),
      returnValueForMissingStub: Future<int>.value(8),
    );
  }
}

class TestHttpMetricPlatform extends HttpMetricPlatform {
  TestHttpMetricPlatform(String url, HttpMethod httpMethod)
      : super(url, httpMethod);
}

class MockHttpMetricPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements TestHttpMetricPlatform {
  MockHttpMetricPlatform(String url, HttpMethod httpMethod) {
    TestHttpMetricPlatform(url, httpMethod);
  }

  @override
  Future<void> start() {
    return super.noSuchMethod(
      Invocation.method(#start, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    );
  }

  @override
  Future<void> stop() {
    return super.noSuchMethod(
      Invocation.method(#stop, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    );
  }
}
