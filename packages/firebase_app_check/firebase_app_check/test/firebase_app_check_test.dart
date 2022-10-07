// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import './mock.dart';

void main() {
  setupFirebaseAppCheckMocks();
  late FirebaseApp secondaryApp;
  late FirebaseAppCheck appCheck;

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
      appCheck = FirebaseAppCheck.instance;
    });

    setUp(() async {
      methodCallLog.clear();
    });

    tearDown(methodCallLog.clear);

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

    group('activate', () {
      test('successful call', () async {
        await appCheck.activate(
          webRecaptchaSiteKey: 'key',
        );

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'FirebaseAppCheck#activate',
              arguments: <String, dynamic>{
                'appName': defaultFirebaseAppName,
                'androidProvider': 'playIntegrity',
              },
            )
          ],
        );
      });
    });
    group('getToken', () {
      test('successful call', () async {
        await appCheck.getToken(true);

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'FirebaseAppCheck#getToken',
              arguments: <String, dynamic>{
                'appName': defaultFirebaseAppName,
                'forceRefresh': true
              },
            )
          ],
        );
      });
    });

    group('setTokenAutoRefreshEnabled', () {
      test('successful call', () async {
        await appCheck.setTokenAutoRefreshEnabled(false);

        expect(
          methodCallLog,
          <Matcher>[
            isMethodCall(
              'FirebaseAppCheck#setTokenAutoRefreshEnabled',
              arguments: <String, dynamic>{
                'appName': defaultFirebaseAppName,
                'isTokenAutoRefreshEnabled': false
              },
            )
          ],
        );
      });
    });

    group('tokenChanges', () {
      test('successful call', () async {
        final stream = appCheck.onTokenChange;

        expect(stream, isA<Stream<String?>>());
      });
    });
  });
}
