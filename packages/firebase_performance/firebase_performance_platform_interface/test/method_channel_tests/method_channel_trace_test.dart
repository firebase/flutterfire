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
  const int kTraceHandle = 1;
  const String kName = 'test-trace-name';
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
          case 'FirebasePerformance#traceStart':
            return 1;
          case 'FirebasePerformance#traceStop':
            return null;
          default:
            return true;
        }
      });
    });
    setUp(() async {
      trace = TestMethodChannelTrace(kName);
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
        await trace.start();

        expect(log, <Matcher>[
          isMethodCall(
            'FirebasePerformance#traceStart',
            arguments: {'name': kName},
          ),
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
        await trace.start();
        trace.putAttribute('bar', 'baz');
        trace.setMetric('yoo', 33);

        await trace.stop();

        expect(log, <Matcher>[
          isMethodCall(
            'FirebasePerformance#traceStart',
            arguments: {'name': kName},
          ),
          isMethodCall(
            'FirebasePerformance#traceStop',
            arguments: {
              'handle': kTraceHandle,
              'metrics': {
                'yoo': 33,
              },
              'attributes': {
                'bar': 'baz',
              },
            },
          ),
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
      const int metricValue = 453;
      test('should call delegate method successfully', () async {
        await trace.start();
        trace.incrementMetric(metricName, metricValue);

        expect(log, <Matcher>[
          isMethodCall(
            'FirebasePerformance#traceStart',
            arguments: {'name': kName},
          ),
        ]);

        expect(trace.getMetric(metricName), metricValue);
      });
    });

    group('setMetric', () {
      const String metricName = 'test-metric-name';
      const int metricValue = 4;
      test('should call delegate method successfully', () async {
        await trace.start();
        trace.setMetric(metricName, metricValue);

        expect(log, <Matcher>[
          isMethodCall(
            'FirebasePerformance#traceStart',
            arguments: {'name': kName},
          ),
        ]);

        expect(trace.getMetric(metricName), metricValue);
      });
    });

    group('getMetric', () {
      const String metricName = 'test-metric-name';
      const int metricValue = 546;
      test('should call delegate method successfully', () async {
        await trace.start();
        trace.setMetric(metricName, metricValue);

        expect(log, <Matcher>[
          isMethodCall(
            'FirebasePerformance#traceStart',
            arguments: {'name': kName},
          ),
        ]);

        expect(trace.getMetric(metricName), metricValue);
      });
    });

    group('putAttribute', () {
      test('should call delegate method successfully', () async {
        const String attributeName = 'test-attribute-name';
        const String attributeValue = 'foo';
        trace.putAttribute(attributeName, attributeValue);
        expect(log, <Matcher>[]);
        expect(trace.getAttribute(attributeName), attributeValue);
      });

      test(
          "will immediately return if name length is longer than 'TracePlatform.maxAttributeKeyLength' ",
          () async {
        String longName =
            'thisisaverylongnamethatislongerthanthe40charactersallowedbyTracePlatformmaxAttributeKeyLengthwaywaylongertogetover100charlimit';
        const String attributeValue = 'foo';
        trace.putAttribute(longName, attributeValue);
        expect(log, <Matcher>[]);
        expect(trace.getAttribute(longName), isNull);
      });

      test(
          "will immediately return if value length is longer than 'TracePlatform.maxAttributeValueLength' ",
          () async {
        String attributeName = 'foo';
        String longValue =
            'thisisaverylongnamethatislongerthanthe40charactersallowedbyTracePlatformmaxAttributeKeyLengthwaywaylongertogetover100charlimit';
        trace.putAttribute(attributeName, longValue);
        expect(log, <Matcher>[]);
        expect(trace.getAttribute(attributeName), isNull);
      });

      test(
          "will immediately return if attribute map has more properties than 'TracePlatform.maxCustomAttributes' allows",
          () async {
        String attributeName1 = 'foo';
        String attributeName2 = 'bar';
        String attributeName3 = 'baz';
        String attributeName4 = 'too';
        String attributeName5 = 'yoo';
        String attributeName6 = 'who';
        String attributeValue = 'bar';
        trace.putAttribute(attributeName1, attributeValue);
        trace.putAttribute(attributeName2, attributeValue);
        trace.putAttribute(attributeName3, attributeValue);
        trace.putAttribute(attributeName4, attributeValue);
        trace.putAttribute(attributeName5, attributeValue);
        trace.putAttribute(attributeName6, attributeValue);

        expect(log, <Matcher>[]);

        expect(trace.getAttribute(attributeName5), attributeValue);
        expect(trace.getAttribute(attributeName6), isNull);
      });
    });

    group('removeAttribute', () {
      test('should call delegate method successfully', () async {
        const String attributeName = 'test-attribute-name';
        const String attributeValue = 'barr';
        trace.putAttribute(attributeName, attributeValue);
        trace.removeAttribute(attributeName);
        expect(log, <Matcher>[]);
        expect(trace.getAttribute(attributeName), isNull);
      });
    });

    group('getAttribute', () {
      test('should call delegate method successfully', () async {
        const String attributeName = 'test-attribute-name';
        const String attributeValue = 'mario';
        trace.putAttribute(attributeName, attributeValue);
        trace.getAttribute(attributeName);
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
        trace.putAttribute(attributeName1, attributeValue);
        trace.putAttribute(attributeName2, attributeValue);
        trace.putAttribute(attributeName3, attributeValue);
        trace.putAttribute(attributeName4, attributeValue);
        trace.putAttribute(attributeName5, attributeValue);

        Map<String, String> attributes = {
          attributeName1: attributeValue,
          attributeName2: attributeValue,
          attributeName3: attributeValue,
          attributeName4: attributeValue,
          attributeName5: attributeValue,
        };

        expect(log, <Matcher>[]);
        expect(trace.getAttributes(), attributes);
      });
    });
  });
}

class TestMethodChannelTrace extends MethodChannelTrace {
  TestMethodChannelTrace(name) : super(name);
}
