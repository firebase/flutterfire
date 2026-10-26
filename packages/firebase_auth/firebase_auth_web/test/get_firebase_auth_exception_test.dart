// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_web/src/utils/web_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    // getFirebaseAuthException always calls OAuthProvider.credentialFromError.
    // Stub it so this test does not need the full Auth JS SDK.
    final oauthProvider = JSObject();
    oauthProvider['credentialFromError'] = ((JSAny _) => null).toJS;
    final firebaseAuth = JSObject();
    firebaseAuth['OAuthProvider'] = oauthProvider;
    globalContext['firebase_auth'] = firebaseAuth;
  });

  JSObject authError({required bool includeCustomData}) {
    final error = JSObject();
    error['name'] = 'FirebaseError'.toJS;
    error['code'] = 'auth/invalid-credential'.toJS;
    error['message'] =
        'Firebase: INVALID_LOGIN_CREDENTIALS (auth/invalid-credential).'.toJS;
    if (includeCustomData) {
      final customData = JSObject();
      customData['appName'] = '[DEFAULT]'.toJS;
      customData['email'] = 'user@example.com'.toJS;
      error['customData'] = customData;
    }
    return error;
  }

  test(
    'converts an Auth error that omits customData without throwing',
    () {
      final exception = getFirebaseAuthException(
        authError(includeCustomData: false),
      );

      expect(exception, isA<FirebaseAuthException>());
      expect(exception.code, 'invalid-credential');
      expect(exception.email, isNull);
      expect(exception.phoneNumber, isNull);
      expect(exception.tenantId, isNull);
    },
  );

  test('still reads email from customData when it is present', () {
    final exception = getFirebaseAuthException(
      authError(includeCustomData: true),
    );

    expect(exception.code, 'invalid-credential');
    expect(exception.email, 'user@example.com');
  });
}
