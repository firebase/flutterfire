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

  late TestHttpMetricPlatform httpMetricPlatform;

  group('$HttpMetricPlatform()', () {
    setUpAll(() async {
      await Firebase.initializeApp();

      httpMetricPlatform = TestHttpMetricPlatform();
    });
  });
  test('Constructor', () {
    expect(httpMetricPlatform, isA<HttpMetricPlatform>());
    expect(httpMetricPlatform, isA<PlatformInterface>());
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

  test('throws if get httpResponseCode', () {
    expect(() => httpMetricPlatform.httpResponseCode, throwsUnimplementedError);
  });

  test('throws if get requestPayloadSize', () {
    expect(
      () => httpMetricPlatform.requestPayloadSize,
      throwsUnimplementedError,
    );
  });

  test('throws if get responseContentType', () {
    expect(
      () => httpMetricPlatform.responseContentType,
      throwsUnimplementedError,
    );
  });

  test('throws if get responsePayloadSize', () {
    expect(
      () => httpMetricPlatform.responsePayloadSize,
      throwsUnimplementedError,
    );
  });

  test('throws if set httpResponseCode', () {
    expect(
      () => httpMetricPlatform.httpResponseCode = 4,
      throwsUnimplementedError,
    );
  });

  test('throws if set requestPayloadSize', () {
    expect(
      () => httpMetricPlatform.requestPayloadSize = 4,
      throwsUnimplementedError,
    );
  });

  test('throws if set responsePayloadSize', () {
    expect(
      () => httpMetricPlatform.responsePayloadSize = 4,
      throwsUnimplementedError,
    );
  });

  test('throws if set responseContentType', () {
    expect(
      () => httpMetricPlatform.responseContentType = 'foo',
      throwsUnimplementedError,
    );
  });

  test('throws if start()', () {
    expect(() => httpMetricPlatform.start(), throwsUnimplementedError);
  });

  test('throws if stop()', () {
    expect(() => httpMetricPlatform.stop(), throwsUnimplementedError);
  });

  test('throws if putAttribute()', () {
    expect(
      () => httpMetricPlatform.putAttribute('foo', 'baz'),
      throwsUnimplementedError,
    );
  });

  test('throws if removeAttribute()', () {
    expect(
      () => httpMetricPlatform.removeAttribute('bar'),
      throwsUnimplementedError,
    );
  });

  test('throws if getAttribute()', () {
    expect(
      () => httpMetricPlatform.getAttribute('bar'),
      throwsUnimplementedError,
    );
  });

  test('throws if getAttributes()', () {
    expect(() => httpMetricPlatform.getAttributes(), throwsUnimplementedError);
  });
}

class TestHttpMetricPlatform extends HttpMetricPlatform {
  TestHttpMetricPlatform() : super();
}
