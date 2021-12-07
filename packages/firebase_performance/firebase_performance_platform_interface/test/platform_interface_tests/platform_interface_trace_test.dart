// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_performance_platform_interface/firebase_performance_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../mock.dart';

void main() {
  setupFirebasePerformanceMocks();

  late TestHttpTracePlatform tracePlatform;

  group('$HttpMetricPlatform()', () {
    setUpAll(() async {
      await Firebase.initializeApp();

      tracePlatform = TestHttpTracePlatform();
    });
  });
  test('Constructor', () {
    expect(tracePlatform, isA<TracePlatform>());
    expect(tracePlatform, isA<PlatformInterface>());
  });

  test('static maxAttributeKeyLength', () {
    expect(HttpMetricPlatform.maxAttributeKeyLength, 40);
  });

  test('static maxCustomAttributes', () {
    expect(HttpMetricPlatform.maxCustomAttributes, 5);
  });

  test('static maxAttributeValueLength', () {
    expect(HttpMetricPlatform.maxAttributeValueLength, 100);
  });

  test('throws if start()', () {
    expect(() => tracePlatform.start(), throwsUnimplementedError);
  });

  test('throws if stop()', () {
    expect(() => tracePlatform.stop(), throwsUnimplementedError);
  });

  test('throws if incrementMetric()', () {
    expect(
      () => tracePlatform.incrementMetric('foo', 99),
      throwsUnimplementedError,
    );
  });

  test('throws if setMetric()', () {
    expect(() => tracePlatform.setMetric('foo', 99), throwsUnimplementedError);
  });

  test('throws if getMetric()', () {
    expect(() => tracePlatform.getMetric('foo'), throwsUnimplementedError);
  });

  test('throws if putAttribute()', () {
    expect(
      () => tracePlatform.putAttribute('foo', 'baz'),
      throwsUnimplementedError,
    );
  });

  test('throws if removeAttribute()', () {
    expect(
      () => tracePlatform.removeAttribute('bar'),
      throwsUnimplementedError,
    );
  });

  test('throws if getAttribute()', () {
    expect(() => tracePlatform.getAttribute('bar'), throwsUnimplementedError);
  });

  test('throws if getAttributes()', () {
    expect(() => tracePlatform.getAttributes(), throwsUnimplementedError);
  });
}

class TestHttpTracePlatform extends TracePlatform {
  TestHttpTracePlatform() : super();
}
