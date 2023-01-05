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
  const int kHttpMetricHandle = 2;
  const String kUrl = 'https://test-url.com';
  const HttpMethod kMethod = HttpMethod.Get;
  final List<MethodCall> log = <MethodCall>[];
  // mock props
  bool mockPlatformExceptionThrown = false;
  bool mockExceptionThrown = false;

  group('$FirebasePerformancePlatform()', () {
    setUpAll(() async {
      await Firebase.initializeApp();

      handleMethodCall((call) async {
        log.add(call);

        if (mockExceptionThrown) {
          throw Exception();
        } else if (mockPlatformExceptionThrown) {
          throw PlatformException(code: 'UNKNOWN');
        }
        switch (call.method) {
          case 'FirebasePerformance#httpMetricStart':
            return kHttpMetricHandle;
          case 'FirebasePerformance#httpMetricStop':
            return null;
          default:
            return true;
        }
      });
    });

    setUp(() async {
      httpMetric = TestMethodChannelHttpMetric(
        kUrl,
        kMethod,
      );
      mockPlatformExceptionThrown = false;
      mockExceptionThrown = false;
      log.clear();
    });

    tearDown(() async {
      mockPlatformExceptionThrown = false;
      mockExceptionThrown = false;
    });

    test('instance', () {
      expect(httpMetric, isA<MethodChannelHttpMetric>());
      expect(httpMetric, isA<HttpMetricPlatform>());
    });

    group('start', () {
      test('should call delegate method successfully', () async {
        await httpMetric.start();

        expect(log, <Matcher>[
          isMethodCall(
            'FirebasePerformance#httpMetricStart',
            arguments: {
              'url': kUrl,
              'httpMethod': kMethod.toString(),
            },
          ),
        ]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        mockPlatformExceptionThrown = true;

        await testExceptionHandling('PLATFORM', httpMetric.start);
      });
    });

    group('stop', () {
      test('should call delegate method successfully', () async {
        await httpMetric.start();

        httpMetric.putAttribute('foo', 'bar');
        httpMetric.httpResponseCode = 2;
        httpMetric.requestPayloadSize = 28;
        httpMetric.responseContentType = 'baz';
        httpMetric.responsePayloadSize = 23;
        await httpMetric.stop();

        expect(log, <Matcher>[
          isMethodCall(
            'FirebasePerformance#httpMetricStart',
            arguments: {'url': kUrl, 'httpMethod': kMethod.toString()},
          ),
          isMethodCall(
            'FirebasePerformance#httpMetricStop',
            arguments: {
              'handle': kHttpMetricHandle,
              'attributes': {
                'foo': 'bar',
              },
              'httpResponseCode': 2,
              'requestPayloadSize': 28,
              'responseContentType': 'baz',
              'responsePayloadSize': 23,
            },
          )
        ]);
      });

      test("will immediately return if start() hasn't been called first",
          () async {
        await httpMetric.stop();
        expect(log, <Matcher>[]);
      });

      test(
          'catch a [PlatformException] error and throws a [FirebaseException] error',
          () async {
        await httpMetric.start();
        mockPlatformExceptionThrown = true;

        await testExceptionHandling('PLATFORM', httpMetric.stop);
      });
    });

    group('httpResponseCode', () {
      test('httpResponseCode', () async {
        httpMetric.httpResponseCode = 3;
        expect(httpMetric.httpResponseCode, 3);
      });
    });

    group('requestPayloadSize', () {
      test('requestPayloadSize', () async {
        httpMetric.requestPayloadSize = 23;
        expect(httpMetric.requestPayloadSize, 23);
      });
    });

    group('responseContentType', () {
      test('responseContentType', () async {
        httpMetric.responseContentType = 'content';
        expect(httpMetric.responseContentType, 'content');
      });
    });

    group('responsePayloadSize', () {
      test('responsePayloadSize', () async {
        httpMetric.responsePayloadSize = 45;
        expect(httpMetric.responsePayloadSize, 45);
      });
    });

    group('putAttribute', () {
      test('should call delegate method successfully', () async {
        const String attributeName = 'test-attribute-name';
        const String attributeValue = 'foo';
        httpMetric.putAttribute(attributeName, attributeValue);
        expect(log, <Matcher>[]);
        expect(httpMetric.getAttribute(attributeName), attributeValue);
      });

      test(
          "will immediately return if name length is longer than 'HttpMetricPlatform.maxAttributeKeyLength' ",
          () async {
        String longName =
            'thisisaverylongnamethatislongerthanthe40charactersallowedbyHttpMetricPlatformmaxAttributeKeyLengthwaywaylongertogetover100charlimit';
        const String attributeValue = 'foo';
        httpMetric.putAttribute(longName, attributeValue);
        expect(log, <Matcher>[]);
        expect(httpMetric.getAttribute(longName), isNull);
      });

      test(
          "will immediately return if value length is longer than 'HttpMetricPlatform.maxAttributeValueLength' ",
          () async {
        String attributeName = 'foo';
        String longValue =
            'thisisaverylongnamethatislongerthanthe40charactersallowedbyHttpMetricPlatformmaxAttributeKeyLengthwaywaylongertogetover100charlimit';
        httpMetric.putAttribute(attributeName, longValue);
        expect(log, <Matcher>[]);
        expect(httpMetric.getAttribute(attributeName), isNull);
      });

      test(
          "will immediately return if attribute map has more properties than 'HttpMetricPlatform.maxCustomAttributes' allows",
          () async {
        String attributeName1 = 'foo';
        String attributeName2 = 'bar';
        String attributeName3 = 'baz';
        String attributeName4 = 'too';
        String attributeName5 = 'yoo';
        String attributeName6 = 'who';
        String attributeValue = 'bar';
        httpMetric.putAttribute(attributeName1, attributeValue);
        httpMetric.putAttribute(attributeName2, attributeValue);
        httpMetric.putAttribute(attributeName3, attributeValue);
        httpMetric.putAttribute(attributeName4, attributeValue);
        httpMetric.putAttribute(attributeName5, attributeValue);
        httpMetric.putAttribute(attributeName6, attributeValue);

        expect(log, <Matcher>[]);

        expect(httpMetric.getAttribute(attributeName5), attributeValue);
        expect(httpMetric.getAttribute(attributeName6), isNull);
      });
    });

    group('removeAttribute', () {
      test('should call delegate method successfully', () async {
        const String attributeName = 'test-attribute-name';
        const String attributeValue = 'barr';
        httpMetric.putAttribute(attributeName, attributeValue);
        httpMetric.removeAttribute(attributeName);
        expect(log, <Matcher>[]);
        expect(httpMetric.getAttribute(attributeName), isNull);
      });
    });

    group('getAttribute', () {
      test('should call delegate method successfully', () async {
        const String attributeName = 'test-attribute-name';
        const String attributeValue = 'mario';
        httpMetric.putAttribute(attributeName, attributeValue);
        httpMetric.getAttribute(attributeName);
        expect(log, <Matcher>[]);
      });
    });

    group('getAttributes', () {
      test('should call delegate method successfully', () async {
        String attributeName1 = 'foo';
        String attributeName2 = 'bar';
        String attributeName3 = 'baz';
        String attributeName4 = 'too';
        String attributeName5 = 'yoo';
        String attributeValue = 'bar';
        httpMetric.putAttribute(attributeName1, attributeValue);
        httpMetric.putAttribute(attributeName2, attributeValue);
        httpMetric.putAttribute(attributeName3, attributeValue);
        httpMetric.putAttribute(attributeName4, attributeValue);
        httpMetric.putAttribute(attributeName5, attributeValue);

        Map<String, String> attributes = {
          attributeName1: attributeValue,
          attributeName2: attributeValue,
          attributeName3: attributeValue,
          attributeName4: attributeValue,
          attributeName5: attributeValue,
        };

        expect(log, <Matcher>[]);
        expect(httpMetric.getAttributes(), attributes);
      });
    });
  });
}

class TestFirebasePerformancePlatform extends FirebasePerformancePlatform {
  TestFirebasePerformancePlatform(FirebaseApp app) : super(appInstance: app);
}

class TestMethodChannelHttpMetric extends MethodChannelHttpMetric {
  TestMethodChannelHttpMetric(
    url,
    method,
  ) : super(url, method);
}
