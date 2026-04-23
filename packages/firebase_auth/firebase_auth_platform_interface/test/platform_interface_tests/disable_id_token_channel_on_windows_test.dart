// Copyright 2025, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the Windows-only opt-in
/// [FirebaseAuthPlatform.disableIdTokenChannelOnWindows] flag that works
/// around the upstream engine threading bug
/// (https://github.com/firebase/flutterfire/issues/18210 /
/// https://github.com/flutter/flutter/issues/134346).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    FirebaseAuthPlatform.disableIdTokenChannelOnWindows = false;
  });

  group('FirebaseAuthPlatform.disableIdTokenChannelOnWindows', () {
    test('defaults to false so existing apps see no behavior change', () {
      expect(FirebaseAuthPlatform.disableIdTokenChannelOnWindows, isFalse);
    });

    test('is a plain mutable static bool toggle', () {
      FirebaseAuthPlatform.disableIdTokenChannelOnWindows = true;
      expect(FirebaseAuthPlatform.disableIdTokenChannelOnWindows, isTrue);

      FirebaseAuthPlatform.disableIdTokenChannelOnWindows = false;
      expect(FirebaseAuthPlatform.disableIdTokenChannelOnWindows, isFalse);
    });
  });
}
