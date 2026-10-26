// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_auth_web/src/interop/auth.dart' as auth_interop;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'fetchSignInMethodsForEmail converts JSArray<JSString> to List<String>',
    () async {
      final jsAuth = JSObject();
      JSAny? receivedAuth;
      String? receivedEmail;

      final firebaseAuth = JSObject();
      firebaseAuth['fetchSignInMethodsForEmail'] =
          (JSAny auth, JSString email) {
        receivedAuth = auth;
        receivedEmail = email.toDart;
        return Future<JSArray<JSString>>.value(
          <JSString>['password'.toJS, 'emailLink'.toJS].toJS,
        ).toJS;
      }.toJS;
      globalContext['firebase_auth'] = firebaseAuth;

      final auth = auth_interop.Auth.getInstance(
        jsAuth as auth_interop.AuthJsImpl,
      );
      final methods = await auth.fetchSignInMethodsForEmail('user@example.com');

      expect(receivedAuth, equals(jsAuth));
      expect(receivedEmail, 'user@example.com');
      expect(methods, isA<List<String>>());
      expect(methods, <String>['password', 'emailLink']);
    },
  );

  test(
    'fetchSignInMethodsForEmail handles an empty JSArray<JSString>',
    () async {
      final jsAuth = JSObject();
      final firebaseAuth = JSObject();
      firebaseAuth['fetchSignInMethodsForEmail'] = (JSAny _, JSString __) {
        return Future<JSArray<JSString>>.value(<JSString>[].toJS).toJS;
      }.toJS;
      globalContext['firebase_auth'] = firebaseAuth;

      final auth = auth_interop.Auth.getInstance(
        jsAuth as auth_interop.AuthJsImpl,
      );
      final methods = await auth.fetchSignInMethodsForEmail('none@example.com');

      expect(methods, isEmpty);
    },
  );
}
