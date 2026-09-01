// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';

void main() {
  setupFirebaseAuthMocks();

  late MethodChannelFirebaseAuth auth;

  group('$MethodChannelFirebaseAuth()', () {
    setUpAll(() async {
      final app = await Firebase.initializeApp();
      auth = MethodChannelFirebaseAuth(app: app);
    });

    group('setSettings()', () {
      test('throws if migrateCurrentUser is set without a userAccessGroup',
          () async {
        await expectLater(
          () => auth.setSettings(migrateCurrentUser: true),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('userAccessGroup'),
            ),
          ),
        );
      });

      test('throws if only one of phoneNumber & smsCode is set', () async {
        await expectLater(
          () => auth.setSettings(phoneNumber: '5555555555'),
          throwsArgumentError,
        );
      });
    });
  });
}
