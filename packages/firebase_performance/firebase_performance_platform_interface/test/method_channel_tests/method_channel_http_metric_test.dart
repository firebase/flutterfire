// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_performance_platform_interface/firebase_performance_platform_interface.dart';
import 'package:firebase_performance_platform_interface/src/method_channel/method_channel_http_metric.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';

void main() {
  setupFirebasePerformanceMocks();

  late TestMethodChannelHttpMetric httpMetric;
  const int kHandle = 23;
  const String kUrl = 'https://test-url.com';
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
          case 'FirebasePerformance#isPerformanceCollectionEnabled':
            return true;
          case 'FirebasePerformance#setPerformanceCollectionEnabled':
            return call.arguments['enable'];
          case 'FirebasePerformance#newTrace':
            return null;
          case 'FirebasePerformance#newHttpMetric':
            return null;
          default:
            return true;
        }
      });

      httpMetric = TestMethodChannelHttpMetric(kHandle, kUrl, kMethod);
    });

    test('instance', () {
      expect(httpMetric, isA<MethodChannelHttpMetric>());
      expect(httpMetric, isA<HttpMetricPlatform>());
    });

    group('httpResponseCode', () {
      // test('get httpResponseCode', () {
      //   expect(httpMetric.httpResponseCode, isNull);
      // });
      //
      // test('setHttpResponseCode', () async {
      //   expect(httpMetric.setHttpResponseCode(3), isNull);
      // });
    });
  });
}

//todo add this to the start() method channel call
// expect(log, <Matcher>[
// isMethodCall(
// 'FirebasePerformance#newHttpMetric',
// arguments: {
// 'handle': 0,
// 'httpMetricHandle': 1,
// 'url': 'http-metric-url',
// 'httpMethod': HttpMethod.Get.toString(),
// },
// )
// ]);

class TestFirebasePerformancePlatform extends FirebasePerformancePlatform {
  TestFirebasePerformancePlatform(FirebaseApp app) : super(appInstance: app);
}

class TestMethodChannelHttpMetric extends MethodChannelHttpMetric {
  TestMethodChannelHttpMetric(handle, url, method) : super(handle, url, method);
}
