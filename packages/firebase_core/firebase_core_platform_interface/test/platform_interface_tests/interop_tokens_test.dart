// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const options = FirebaseOptions(
    apiKey: 'apiKey',
    appId: 'appId',
    messagingSenderId: 'messagingSenderId',
    projectId: 'projectId',
  );

  group('$FirebaseAppPlatform interop token defaults', () {
    final app = FirebaseAppPlatform('testApp', options);

    test('getAuthIdToken is unimplemented', () {
      expect(app.getAuthIdToken, throwsUnimplementedError);
    });

    test('getAppCheckToken is unimplemented', () {
      expect(app.getAppCheckToken, throwsUnimplementedError);
    });

    test('getMessagingToken is unimplemented', () {
      expect(app.getMessagingToken, throwsUnimplementedError);
    });
  });

  group('$AppCheckInteropToken', () {
    test('compares by value', () {
      expect(
        const AppCheckInteropToken(token: 'a', error: 'e'),
        const AppCheckInteropToken(token: 'a', error: 'e'),
      );
      expect(
        const AppCheckInteropToken(token: 'a'),
        isNot(const AppCheckInteropToken(token: 'a', error: 'e')),
      );
      expect(
        const AppCheckInteropToken(token: 'a').hashCode,
        const AppCheckInteropToken(token: 'a').hashCode,
      );
    });

    test('toString does not print the token', () {
      const token = AppCheckInteropToken(token: 'secret', error: 'reason');

      expect(token.toString(), isNot(contains('secret')));
      expect(token.toString(), contains('reason'));
    });
  });
}
