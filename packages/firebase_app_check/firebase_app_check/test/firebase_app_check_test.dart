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
    });
  });
}
