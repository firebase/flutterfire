// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_auth_web/src/interop/auth.dart' as auth_interop;
import 'package:firebase_auth_web/src/interop/auth_interop.dart'
    as auth_js_interop;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User.toJson', () {
    test('converts JSObject from toJSON() to Map<String, dynamic>', () {
      final jsJson = JSObject()
        ..['uid'] = 'user-123'.toJS
        ..['email'] = 'user@example.com'.toJS
        ..['emailVerified'] = true.toJS;
      final jsUser = JSObject()..['toJSON'] = (() => jsJson).toJS;

      final user = auth_interop.User.getInstance(
        jsUser as auth_js_interop.UserJsImpl,
      )!;
      final json = user.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(
        json,
        equals(<String, dynamic>{
          'uid': 'user-123',
          'email': 'user@example.com',
          'emailVerified': true,
        }),
      );
    });

    test('handles an empty JSObject from toJSON()', () {
      final emptyJson = JSObject();
      final jsUser = JSObject()..['toJSON'] = (() => emptyJson).toJS;

      final user = auth_interop.User.getInstance(
        jsUser as auth_js_interop.UserJsImpl,
      )!;
      final json = user.toJson();

      expect(json, isA<Map<String, dynamic>>());
      expect(json, isEmpty);
    });
  });
}
