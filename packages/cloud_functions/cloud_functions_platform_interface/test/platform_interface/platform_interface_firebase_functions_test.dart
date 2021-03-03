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

  TestFirebaseFunctionsPlatform? firebaseFunctionsPlatform;
  FirebaseApp? app;
  FirebaseApp? secondaryApp;

  group('$FirebaseFunctionsPlatform()', () {
    setUpAll(() async {
      app = await Firebase.initializeApp();
      secondaryApp = await Firebase.initializeApp(
        name: 'testApp2',
        options: const FirebaseOptions(
          appId: '1:1234567890:ios:42424242424242',
          apiKey: '123',
          projectId: '123',
          messagingSenderId: '1234567890',
        ),
      );

      firebaseFunctionsPlatform = TestFirebaseFunctionsPlatform(app);

      handleMethodCall((call) async {
        switch (call.method) {
          default:
            return null;
        }
      });
    });

    test('Constructor', () {
      expect(firebaseFunctionsPlatform, isA<FirebaseFunctionsPlatform>());
      expect(firebaseFunctionsPlatform, isA<PlatformInterface>());
    });

    test('FirebaseFunctionsPlatform.instanceFor', () {
      final result = FirebaseFunctionsPlatform.instanceFor(
          app: app, region: 'us-central1');
      expect(result, isA<FirebaseFunctionsPlatform>());
      expect(result.app, isA<FirebaseApp>());
      expect(result.app!.name, defaultFirebaseAppName);
    });

    test('get.instance', () {
      expect(
          FirebaseFunctionsPlatform.instance, isA<FirebaseFunctionsPlatform>());
      expect(FirebaseFunctionsPlatform.instance.app, isNull);
    });

    group('set.instance', () {
      test('sets the current instance', () {
        FirebaseFunctionsPlatform.instance =
            TestFirebaseFunctionsPlatform(secondaryApp);

        expect(FirebaseFunctionsPlatform.instance,
            isA<FirebaseFunctionsPlatform>());
        expect(
            FirebaseFunctionsPlatform.instance.app!.name, equals('testApp2'));
      });
    });

    test('throws if .delegateFor is not implemented', () {
      try {
        firebaseFunctionsPlatform!.testDelegateFor(app!);
        // ignore: avoid_catching_errors, acceptable as UnimplementedError usage is correct
      } on UnimplementedError catch (e) {
        expect(e.message, equals('delegateFor() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });

    test('throws if httpsCallable()', () {
      try {
        firebaseFunctionsPlatform!
            .httpsCallable('', '', HttpsCallableOptions());
        // ignore: avoid_catching_errors, acceptable as UnimplementedError usage is correct
      } on UnimplementedError catch (e) {
        expect(e.message, equals('httpsCallable() is not implemented'));
        return;
      }
      fail('Should have thrown an [UnimplementedError]');
    });
  });
}

class TestFirebaseFunctionsPlatform extends FirebaseFunctionsPlatform {
  TestFirebaseFunctionsPlatform(FirebaseApp? app) : super(app, 'test_region');
  FirebaseFunctionsPlatform testDelegateFor(FirebaseApp app) {
    return delegateFor(app: app, region: 'test_region');
  }
}
