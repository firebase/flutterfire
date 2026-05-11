// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import './mock.dart';

void main() {
  setupFirebaseAppCheckMocks();
  late FirebaseApp secondaryApp;

  group('$FirebaseAppCheck', () {
    setUpAll(() async {
      await Firebase.initializeApp();
      secondaryApp = await Firebase.initializeApp(
        name: 'secondaryApp',
        options: const FirebaseOptions(
          appId: '1:1234567890:ios:42424242424242',
          apiKey: '123',
          projectId: '123',
          messagingSenderId: '1234567890',
        ),
      );
    });

    group('instance', () {
      test('successful call', () async {
        final appCheck = FirebaseAppCheck.instance;

        expect(appCheck, isA<FirebaseAppCheck>());
        expect(appCheck.app.name, defaultFirebaseAppName);
      });
    });

    group('instanceFor', () {
      test('successful call', () async {
        final appCheck = FirebaseAppCheck.instanceFor(app: secondaryApp);

        expect(appCheck, isA<FirebaseAppCheck>());
        expect(appCheck.app.name, 'secondaryApp');
      });

      test('creates a fresh instance after app delete and reinitialize',
          () async {
        const appName = 'delete-reinit-app-check';
        const options = FirebaseOptions(
          appId: '1:1234567890:ios:42424242424242',
          apiKey: '123',
          projectId: '123',
          messagingSenderId: '1234567890',
        );
        final app = await Firebase.initializeApp(
          name: appName,
          options: options,
        );
        final appCheck1 = FirebaseAppCheck.instanceFor(app: app);

        expect(app.getService<FirebaseAppCheck>(), same(appCheck1));

        await app.delete();

        final app2 = await Firebase.initializeApp(
          name: appName,
          options: options,
        );
        addTearDown(app2.delete);

        final appCheck2 = FirebaseAppCheck.instanceFor(app: app2);

        expect(appCheck2, isNot(same(appCheck1)));
        expect(appCheck2.app, app2);
        expect(app2.getService<FirebaseAppCheck>(), same(appCheck2));
      });
    });
  });
}
