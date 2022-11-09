// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tests/firebase_options.dart';

void main() {
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
      bool enabled = app.isAutomaticDataCollectionEnabled;

      await app.setAutomaticDataCollectionEnabled(!enabled);

      expect(app.isAutomaticDataCollectionEnabled, !enabled);
    });

    test('FirebaseApp.setAutomaticResourceManagementEnabled()', () async {
      FirebaseApp app = Firebase.app(testAppName);

      await app.setAutomaticResourceManagementEnabled(true);
    });
  });
}
