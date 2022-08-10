// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance_platform_interface/firebase_performance_platform_interface.dart';
import 'package:firebase_performance_platform_interface/src/method_channel/method_channel_firebase_performance.dart';
import 'package:firebase_performance_platform_interface/src/method_channel/method_channel_trace.dart';
import 'package:firebase_performance_platform_interface/src/method_channel/method_channel_http_metric.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';

void main() {
  setupFirebasePerformanceMocks();

  late FirebasePerformancePlatform performance;
  late FirebaseApp app;
  final List<MethodCall> log = <MethodCall>[];

  // mock props
  bool mockPlatformExceptionThrown = false;
  bool mockExceptionThrown = false;

  group('$MethodChannelFirebasePerformance', () {
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
          case 'FirebasePerformance#isPerformanceCollectionEnabled':
            return true;
          case 'FirebasePerformance#setPerformanceCollectionEnabled':
            return call.arguments['enable'];
          default:
            return true;
        }
      });

      performance = MethodChannelFirebasePerformance(app: app);
    });
  });

  setUp(() async {
    mockPlatformExceptionThrown = false;
    mockExceptionThrown = false;
    log.clear();
  });

  tearDown(() async {
    mockPlatformExceptionThrown = false;
    mockExceptionThrown = false;
  });

  test('instance', () {
    final testPerf = MethodChannelFirebasePerformance.instance;

    expect(testPerf, isA<FirebasePerformancePlatform>());
  });

  test('delegateFor', () {
    final testPerf = TestMethodChannelFirebasePerformance(Firebase.app());
    final result = testPerf.delegateFor(app: Firebase.app());

    expect(result, isA<FirebasePerformancePlatform>());
    expect(result.app, isA<FirebaseApp>());
  });

  group('isPerformanceCollectionEnabled', () {
    test('should call delegate method successfully', () async {
      await performance.isPerformanceCollectionEnabled();

      expect(log, <Matcher>[
        isMethodCall(
          'FirebasePerformance#isPerformanceCollectionEnabled',
          arguments: null,
        )
      ]);
    });

    test(
        'catch a [PlatformException] error and throws a [FirebaseException] error',
        () async {
      mockPlatformExceptionThrown = true;

      await testExceptionHandling(
        'PLATFORM',
        performance.isPerformanceCollectionEnabled,
      );
    });
  });

  group('setPerformanceCollectionEnabled', () {
    test('should call delegate method successfully', () async {
      await performance.setPerformanceCollectionEnabled(true);

      expect(log, <Matcher>[
        isMethodCall(
          'FirebasePerformance#setPerformanceCollectionEnabled',
          arguments: {'enable': true},
        )
      ]);
    });

    test(
        'catch a [PlatformException] error and throws a [FirebaseException] error',
        () async {
      mockPlatformExceptionThrown = true;

      await testExceptionHandling(
        'PLATFORM',
        () => performance.setPerformanceCollectionEnabled(true),
      );
    });
  });

  group('newTrace', () {
    test('should call delegate method successfully', () {
      final trace = performance.newTrace('trace-name');

      expect(trace, isA<MethodChannelTrace>());
    });
  });

  group('newHttpMetric', () {
    test('should call delegate method successfully', () {
      final httpMetric =
          performance.newHttpMetric('http-metric-url', HttpMethod.Get);

      expect(httpMetric, isA<MethodChannelHttpMetric>());
    });
  });
}

class TestMethodChannelFirebasePerformance
    extends MethodChannelFirebasePerformance {
  TestMethodChannelFirebasePerformance(FirebaseApp app) : super(app: app);
}
