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
import 'package:firebase_auth_web/src/utils/web_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Shaped like the object the JS SDK's getIdTokenResult() resolves to.
  JSObject buildJsIdTokenResult({String? signInSecondFactor}) {
    final firebaseClaim = JSObject()..['sign_in_provider'] = 'password'.toJS;
    if (signInSecondFactor != null) {
      firebaseClaim['sign_in_second_factor'] = signInSecondFactor.toJS;
    }
    return JSObject()
      ..['claims'] = (JSObject()..['firebase'] = firebaseClaim)
      ..['token'] = 'test-token'.toJS
      ..['authTime'] = 'Fri, 22 Sep 2017 01:49:58 GMT'.toJS
      ..['issuedAtTime'] = 'Fri, 22 Sep 2017 01:49:58 GMT'.toJS
      ..['expirationTime'] = 'Fri, 22 Sep 2017 02:49:58 GMT'.toJS
      ..['signInProvider'] = 'password'.toJS
      ..['signInSecondFactor'] = signInSecondFactor?.toJS;
  }

  Future<auth_interop.IdTokenResult> getIdTokenResult(JSObject jsResult) {
    JSPromise<JSObject> fakeGetIdTokenResult(JSBoolean? forceRefresh) =>
        Future<JSObject>.value(jsResult).toJS;
    final jsUser = JSObject()..['getIdTokenResult'] = fakeGetIdTokenResult.toJS;
    final user = auth_interop.User.getInstance(
      jsUser as auth_js_interop.UserJsImpl,
    )!;
    return user.getIdTokenResult(false);
  }

  group('convertWebIdTokenResult', () {
    test('passes signInSecondFactor through', () async {
      final result = convertWebIdTokenResult(
        await getIdTokenResult(
          buildJsIdTokenResult(signInSecondFactor: 'totp'),
        ),
      );

      expect(result.signInProvider, 'password');
      expect(result.signInSecondFactor, 'totp');
    });

    test('returns null signInSecondFactor without a second factor', () async {
      final result = convertWebIdTokenResult(
        await getIdTokenResult(buildJsIdTokenResult()),
      );

      expect(result.signInProvider, 'password');
      expect(result.signInSecondFactor, isNull);
    });
  });
}
