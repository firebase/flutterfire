// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_performance_web/src/interop/performance.dart';
import 'package:firebase_performance_web/src/interop/performance_interop.dart'
    as performance_interop;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Trace', () {
    test('getAttributes returns a Map<String, String>', () {
      final jsAttributes = JSObject()
        ..['a'] = 'b'.toJS
        ..['c'] = 'd'.toJS;
      final jsTrace = JSObject()..['getAttributes'] = (() => jsAttributes).toJS;

      final trace = Trace.fromJsObject(
        jsTrace as performance_interop.TraceJsImpl,
      );
      final attrs = trace.getAttributes();

      expect(attrs, isA<Map<String, String>>());
      expect(attrs, equals(<String, String>{'a': 'b', 'c': 'd'}));
    });

    test('getAttributes handles empty maps safely', () {
      final emptyAttributes = JSObject();
      final jsTrace = JSObject()
        ..['getAttributes'] = (() => emptyAttributes).toJS;

      final trace = Trace.fromJsObject(
        jsTrace as performance_interop.TraceJsImpl,
      );
      final attrs = trace.getAttributes();

      expect(attrs, isA<Map<String, String>>());
      expect(attrs, isEmpty);
    });
  });
}
