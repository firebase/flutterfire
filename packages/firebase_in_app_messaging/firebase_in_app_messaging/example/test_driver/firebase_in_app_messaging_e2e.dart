// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive/drive.dart' as drive;

void main() => drive.main(testsMain);

void testsMain() {
  group('$FirebaseInAppMessaging', () {
    setUpAll(() async {
      await Firebase.initializeApp();
    });

    test('triggerEvent', () async {
      expect(
        FirebaseInAppMessaging.instance.triggerEvent('someEvent'),
        completes,
      );
    });

    test('logging', () async {
      expect(
        FirebaseInAppMessaging.instance.setMessagesSuppressed(true),
        completes,
      );
      expect(
        FirebaseInAppMessaging.instance.setAutomaticDataCollectionEnabled(true),
        completes,
      );
    });
  });
}
