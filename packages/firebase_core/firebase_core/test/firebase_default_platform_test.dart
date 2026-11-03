// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Firebase uses MethodChannelFirebase when nothing registered', () async {
    // A custom host API instead of setupFirebaseCoreMocks(), which would set
    // the fallback itself.
    TestFirebaseCoreHostApi.setUp(MockFirebaseApp());

    final app = await Firebase.initializeApp();

    expect(app.name, defaultFirebaseAppName);
    expect(FirebasePlatform.instance, isA<MethodChannelFirebase>());
  });
}
