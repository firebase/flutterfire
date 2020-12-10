// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../mock.dart';

void main() {
  setupFirebaseFunctionsMocks();

  TestFirebaseFunctionsPlatform firebaseFunctionsPlatform;
  TestHttpsCallablePlatform httpsCallablePlatform;
  FirebaseApp app;

  group('$HttpsCallablePlatform()', () {
    setUpAll(() async {
      app = await Firebase.initializeApp();

      firebaseFunctionsPlatform = TestFirebaseFunctionsPlatform(app);
      httpsCallablePlatform =
          TestHttpsCallablePlatform(firebaseFunctionsPlatform);

      handleMethodCall((call) async {
        switch (call.method) {
          default:
            return null;
        }
      });
    });

    test('Constructor', () {
      expect(httpsCallablePlatform, isA<HttpsCallablePlatform>());
      expect(httpsCallablePlatform, isA<PlatformInterface>());
    });

    test('throws if call()', () {
      try {
        httpsCallablePlatform.call();
      } on UnimplementedError catch (e) {
        expect(e.message, equals('call() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });
  });
}

class TestHttpsCallablePlatform extends HttpsCallablePlatform {
  TestHttpsCallablePlatform(FirebaseFunctionsPlatform functions)
      : super(functions, 'test_region', '', HttpsCallableOptions());
}

class TestFirebaseFunctionsPlatform extends FirebaseFunctionsPlatform {
  TestFirebaseFunctionsPlatform(FirebaseApp app) : super(app, 'test_region');
  FirebaseFunctionsPlatform testDelegateFor({FirebaseApp app}) {
    return this.delegateFor();
  }
}
