// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_performance_platform_interface/firebase_performance_platform_interface.dart';
import 'package:firebase_performance_platform_interface/src/method_channel/method_channel_trace.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';

void main() {
  setupFirebasePerformanceMocks();

  late TestMethodChannelTrace trace;
  const int kHandle = 21;
  const String kName = 'test-trace-name';
  const HttpMethod kMethod = HttpMethod.Get;
  final List<MethodCall> log = <MethodCall>[];
  // mock props
  bool mockPlatformExceptionThrown = false;
  bool mockExceptionThrown = false;

  late FirebaseApp app;
  group('$FirebasePerformancePlatform()', () {
    setUpAll(() async {
      app = await Firebase.initializeApp();

      handleMethodCall((call) async {
        log.add(call);

        if (mockExceptionThrown) {
          throw Exception();
        } else if (mockPlatformExceptionThrown) {
          throw PlatformException(code: 'UNKNOWN');
        }

        switch (call.method) {
          case 'FirebasePerformance#newTrace':
          case 'Trace#start':
          case 'Trace#stop':
          case 'Trace#incrementMetric':
          case 'Trace#setMetric':
            return null;
          default:
            return true;
        }
      });
    });
    setUp(() async {
      trace = TestMethodChannelTrace(kHandle, kName);
      mockPlatformExceptionThrown = false;
      mockExceptionThrown = false;
      log.clear();
    });

    tearDown(() async {
      mockPlatformExceptionThrown = false;
      mockExceptionThrown = false;
    });

    test('instance', () {
      expect(trace, isA<MethodChannelTrace>());
      expect(trace, isA<TracePlatform>());
    });

    group('start', () {
      test('should call delegate method successfully', () async {
        const int traceHandle = kHandle + 1;
        await trace.start();

        expect(log, <Matcher>[
          isMethodCall('FirebasePerformance#newTrace', arguments: {
            'handle': kHandle,
            'traceHandle': traceHandle,
            'name': kName
          }),
          isMethodCall('Trace#start', arguments: {
            'handle': traceHandle,
          })
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        mockPlatformExceptionThrown = true;

        await testExceptionHandling('PLATFORM', trace.start);
      });
    });

    group('stop', () {
      test('should call delegate method successfully', () async {
        const int traceHandle = kHandle + 1;
        await trace.start();

        await trace.stop();

        expect(log, <Matcher>[
          isMethodCall('FirebasePerformance#newTrace', arguments: {
            'handle': kHandle,
            'traceHandle': traceHandle,
            'name': kName
          }),
          isMethodCall('Trace#start', arguments: {
            'handle': traceHandle,
          }),
          isMethodCall('Trace#stop', arguments: {
            'handle': traceHandle,
          })
        ]);
      });

      test("will immediately return if start() hasn't been called first",
          () async {
        await trace.stop();
        expect(log, <Matcher>[]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        await trace.start();
        mockPlatformExceptionThrown = true;

        await testExceptionHandling('PLATFORM', trace.stop);
      });
    });

    group('incrementMetric', () {
      const String metricName = 'test-metric-name';
      const int metricValue = 300;
      test('should call delegate method successfully', () async {
        const int traceHandle = kHandle + 1;
        await trace.start();
        await trace.incrementMetric(metricName, metricValue);

        expect(log, <Matcher>[
          isMethodCall('FirebasePerformance#newTrace', arguments: {
            'handle': kHandle,
            'traceHandle': traceHandle,
            'name': kName
          }),
          isMethodCall('Trace#start', arguments: {
            'handle': traceHandle,
          }),
          isMethodCall('Trace#incrementMetric', arguments: {
            'handle': traceHandle,
            'name': metricName,
            'value': metricValue,
          })
        ]);
      });

      test("will immediately return if start() hasn't been called first",
          () async {
        await trace.stop();
        expect(log, <Matcher>[]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        await trace.start();
        mockPlatformExceptionThrown = true;

        await testExceptionHandling(
            'PLATFORM', () => trace.incrementMetric(metricName, metricValue));
      });
    });

    group('setMetric', () {
      const String metricName = 'test-metric-name';
      const int metricValue = 300;
      test('should call delegate method successfully', () async {
        const int traceHandle = kHandle + 1;
        await trace.start();
        await trace.setMetric(metricName, metricValue);

        expect(log, <Matcher>[
          isMethodCall('FirebasePerformance#newTrace', arguments: {
            'handle': kHandle,
            'traceHandle': traceHandle,
            'name': kName
          }),
          isMethodCall('Trace#start', arguments: {
            'handle': traceHandle,
          }),
          isMethodCall('Trace#setMetric', arguments: {
            'handle': traceHandle,
            'name': metricName,
            'value': metricValue,
          })
        ]);
      });

      test("will immediately return if start() hasn't been called first",
          () async {
        await trace.setMetric(metricName, metricValue);
        expect(log, <Matcher>[]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        await trace.start();
        mockPlatformExceptionThrown = true;

        await testExceptionHandling(
            'PLATFORM', () => trace.setMetric(metricName, metricValue));
      });
    });

    group('getMetric', () {
      const String metricName = 'test-metric-name';
      const int metricValue = 300;
      test('should call delegate method successfully', () async {
        const int traceHandle = kHandle + 1;
        await trace.start();
        await trace.setMetric(metricName, metricValue);

        expect(log, <Matcher>[
          isMethodCall('FirebasePerformance#newTrace', arguments: {
            'handle': kHandle,
            'traceHandle': traceHandle,
            'name': kName
          }),
          isMethodCall('Trace#start', arguments: {
            'handle': traceHandle,
          }),
          isMethodCall('Trace#setMetric', arguments: {
            'handle': traceHandle,
            'name': metricName,
            'value': metricValue,
          })
        ]);
      });

      test("will immediately return if start() hasn't been called first",
          () async {
        await trace.setMetric(metricName, metricValue);
        expect(log, <Matcher>[]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        await trace.start();
        mockPlatformExceptionThrown = true;

        await testExceptionHandling(
            'PLATFORM', () => trace.setMetric(metricName, metricValue));
      });
    });
  });
}

class TestFirebasePerformancePlatform extends FirebasePerformancePlatform {
  TestFirebasePerformancePlatform(FirebaseApp app) : super(appInstance: app);
}

class TestMethodChannelTrace extends MethodChannelTrace {
  TestMethodChannelTrace(handle, name) : super(handle, name);
}
