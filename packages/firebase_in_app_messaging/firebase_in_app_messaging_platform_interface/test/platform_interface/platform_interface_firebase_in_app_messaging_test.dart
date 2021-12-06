// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_in_app_messaging_platform_interface/firebase_in_app_messaging_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';

void main() {
  setupFirebaseInAppMessagingMocks();
  TestFirebaseInAppMessagingPlatform? platform;

  group('$FirebaseInAppMessagingPlatform()', () {
    setUpAll(() async {
      FirebaseApp app = await Firebase.initializeApp();
      platform = TestFirebaseInAppMessagingPlatform(app);
    });

    test('Constructor', () {
      expect(platform, isA<FirebaseInAppMessagingPlatform>());
    });

    test('triggerEvent throws if not implemented', () async {
      await expectLater(
        () => platform!.triggerEvent('foo'),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('setMessagesSuppressed throws if not implemented', () async {
      await expectLater(
        () => platform!.setMessagesSuppressed(true),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('setAutomaticDataCollectionEnabled throws if not implemented',
        () async {
      await expectLater(
        () => platform!.setAutomaticDataCollectionEnabled(true),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}

class TestFirebaseInAppMessagingPlatform
    extends FirebaseInAppMessagingPlatform {
  TestFirebaseInAppMessagingPlatform(FirebaseApp app) : super(app);
}
