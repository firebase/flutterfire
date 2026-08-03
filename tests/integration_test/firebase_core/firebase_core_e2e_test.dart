// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tests/firebase_options.dart';

void main({bool includeRecaptchaTests = true}) {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('firebase_core', () {
    String testAppName = '[DEFAULT]';

    setUpAll(() async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    });

    test('Firebase.apps', () async {
      List<FirebaseApp> apps = Firebase.apps;
      expect(apps.length, 1);
      expect(apps[0].name, testAppName);
      expect(apps[0].options, DefaultFirebaseOptions.currentPlatform);
    });

    test('Firebase.app()', () async {
      FirebaseApp app = Firebase.app(testAppName);

      expect(app.name, testAppName);
      expect(app.options, DefaultFirebaseOptions.currentPlatform);
    });

    test('Firebase.app() Exception', () async {
      expect(
        () => Firebase.app('NoApp'),
        throwsA(noAppExists('NoApp')),
      );
    });

    test(
      'FirebaseApp.delete()',
      () async {
        await Firebase.initializeApp(
          name: 'SecondaryApp',
          options: DefaultFirebaseOptions.currentPlatform,
        );

        expect(Firebase.apps.length, 2);

        FirebaseApp app = Firebase.app('SecondaryApp');

        await app.delete();

        expect(Firebase.apps.length, 1);
        // TODO(russellwheatley): test randomly causes an auth sign-in failure due to duplicate accounts.
      },
      skip: TargetPlatform.android == defaultTargetPlatform,
    );

    test('FirebaseApp.setAutomaticDataCollectionEnabled()', () async {
      FirebaseApp app = Firebase.app(testAppName);
      await app.setAutomaticDataCollectionEnabled(false);

      expect(app.isAutomaticDataCollectionEnabled, false);

      await app.setAutomaticDataCollectionEnabled(true);

      expect(app.isAutomaticDataCollectionEnabled, true);
    });

    test('FirebaseApp.setAutomaticResourceManagementEnabled()', () async {
      FirebaseApp app = Firebase.app(testAppName);

      try {
        await app.setAutomaticResourceManagementEnabled(true);
      } finally {
        await app.setAutomaticResourceManagementEnabled(false);
      }
    });
  });

  if (includeRecaptchaTests) {
    recaptchaMain();
  }
}

void recaptchaMain() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('firebase_core recaptcha', () {
    setUpAll(() async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    });

    test('Firebase.initializeApp with recaptchaSiteKey', () async {
      String appName = 'recaptcha-test-app';
      FirebaseOptions options = (defaultTargetPlatform == TargetPlatform.android
              ? DefaultFirebaseOptions.currentPlatform.copyWith(
                  appId: '1:1234567890:android:fedcba0987654321fedcba',
                )
              : DefaultFirebaseOptions.currentPlatform)
          .copyWith(
        recaptchaSiteKey: 'test-recaptcha-site-key',
      );

      await Firebase.initializeApp(
        name: appName,
        options: options,
      );

      FirebaseApp app = Firebase.app(appName);
      expect(app.options.recaptchaSiteKey, 'test-recaptcha-site-key');

      await app.delete();
    });

    test('Default app recaptchaSiteKey precedence test', () async {
      // Natively initialized default app has no recaptchaSiteKey.
      // Trying to initialize it again with different recaptchaSiteKey in Dart.
      FirebaseApp app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform.copyWith(
          recaptchaSiteKey: 'dart-recaptcha-key',
        ),
      );

      // It should NOT update the key, because native initializeApp was skipped.
      // (It returns the natively initialized app which has null key).
      expect(app.options.recaptchaSiteKey, isNull);
    });
  });
}
