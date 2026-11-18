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
  /// Minimal stand-in for the JS `Auth` object: `onAuthStateChanged` invokes
  /// either the next or the error callback once, and records unsubscribe.
  ({auth_interop.Auth auth, bool Function() unsubscribed}) fakeAuth({
    JSObject? error,
  }) {
    var unsubscribed = false;
    final jsAuth = JSObject();
    jsAuth['onAuthStateChanged'] = (JSFunction next, JSFunction? onError) {
      if (error != null) {
        onError!.callAsFunction(null, error);
      } else {
        // ignore: avoid_redundant_argument_values
        next.callAsFunction(null, null);
      }
      return (() {
        unsubscribed = true;
      }).toJS;
    }.toJS;
    return (
      auth: auth_interop.Auth.getInstance(jsAuth as auth_interop.AuthJsImpl),
      unsubscribed: () => unsubscribed,
    );
  }

  test('onWaitInitState completes when the first auth state arrives', () async {
    final fake = fakeAuth();

    await fake.auth.onWaitInitState();

    expect(fake.unsubscribed(), isTrue);
  });

  test(
    'onWaitInitState fails instead of hanging when the first auth state is an error',
    () async {
      final error = JSObject();
      error['code'] = 'auth/internal-error'.toJS;
      final fake = fakeAuth(error: error);

      await expectLater(
        fake.auth.onWaitInitState().timeout(const Duration(seconds: 2)),
        throwsA(
          predicate<Object>(
            (e) => (e as JSObject)['code'].dartify() == 'auth/internal-error',
          ),
        ),
      );
      expect(fake.unsubscribed(), isTrue);
    },
  );
}
