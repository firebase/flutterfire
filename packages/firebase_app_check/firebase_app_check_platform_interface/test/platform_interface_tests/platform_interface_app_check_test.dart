// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check_platform_interface/firebase_app_check_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../mock.dart';

void main() {
  setupFirebaseAppCheckMocks();

  late TestFirebaseAppCheckPlatform firebaseAppCheckPlatform;

  FirebaseApp? app;
  FirebaseApp? secondaryApp;

  group('$FirebaseAppCheckPlatform', () {
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

      firebaseAppCheckPlatform = TestFirebaseAppCheckPlatform(
        app!,
      );
    });

    test('Constructor', () {
      expect(firebaseAppCheckPlatform, isA<FirebaseAppCheckPlatform>());
      expect(firebaseAppCheckPlatform, isA<PlatformInterface>());
    });

    test('get.instance', () {
      expect(
        FirebaseAppCheckPlatform.instance,
        isA<FirebaseAppCheckPlatform>(),
      );
      expect(
        FirebaseAppCheckPlatform.instance.app.name,
        equals(defaultFirebaseAppName),
      );
    });

    test('set.instance', () {
      FirebaseAppCheckPlatform.instance =
          TestFirebaseAppCheckPlatform(secondaryApp!);

      expect(
        FirebaseAppCheckPlatform.instance,
        isA<FirebaseAppCheckPlatform>(),
      );
      expect(FirebaseAppCheckPlatform.instance.app.name, equals('testApp2'));
    });

    test('throws if .delegateFor() not implemented', () async {
      await expectLater(
        // ignore: invalid_use_of_protected_member
        () => firebaseAppCheckPlatform.delegateFor(app: app!),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'delegateFor() is not implemented',
          ),
        ),
      );
    });

    test('throws if .activate() not implemented', () async {
      await expectLater(
        () =>
            firebaseAppCheckPlatform.activate(webRecaptchaSiteKey: 'test key'),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'activate() is not implemented',
          ),
        ),
      );
    });

    test('throws if .getToken() not implemented', () async {
      await expectLater(
        () => firebaseAppCheckPlatform.getToken(true),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'getToken() is not implemented',
          ),
        ),
      );
    });

    test('throws if .tokenChanges() not implemented', () async {
      await expectLater(
        () => firebaseAppCheckPlatform.onTokenChange,
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'tokenChanges() is not implemented',
          ),
        ),
      );
    });

    test('throws if .setInitialValues() not implemented', () async {
      await expectLater(
        // ignore: invalid_use_of_protected_member
        () => firebaseAppCheckPlatform.setInitialValues(),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'setInitialValues() is not implemented',
          ),
        ),
      );
    });

    test('throws if .setTokenAutoRefreshEnabled() not implemented', () async {
      await expectLater(
        () => firebaseAppCheckPlatform.setTokenAutoRefreshEnabled(false),
        throwsA(
          isA<UnimplementedError>().having(
            (e) => e.message,
            'message',
            'setTokenAutoRefreshEnabled() is not implemented',
          ),
        ),
      );
    });
  });
}

class TestFirebaseAppCheckPlatform extends FirebaseAppCheckPlatform {
  TestFirebaseAppCheckPlatform(FirebaseApp app) : super(appInstance: app);
}
