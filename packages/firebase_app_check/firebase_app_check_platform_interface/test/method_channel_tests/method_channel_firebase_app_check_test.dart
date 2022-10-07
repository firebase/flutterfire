// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_app_check_platform_interface/firebase_app_check_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

import '../mock.dart';

void main() {
  setupFirebaseAppCheckMocks();
  late FirebaseAppCheckPlatform appCheck;
  late FirebaseApp secondaryApp;
  final List<MethodCall> methodCallLogger = <MethodCall>[];

  group('$MethodChannelFirebaseAppCheck', () {
    setUpAll(() async {
      FirebaseApp app = await Firebase.initializeApp();
      secondaryApp = await Firebase.initializeApp(
        name: 'secondaryApp',
        options: const FirebaseOptions(
          appId: '1:1234567890:ios:42424242424242',
          apiKey: '123',
          projectId: '123',
          messagingSenderId: '1234567890',
        ),
      );
      handleMethodCall((call) async {
        methodCallLogger.add(call);

        switch (call.method) {
          case 'FirebaseAppCheck#registerTokenListener':
            return 'channelName';
          case 'FirebaseAppCheck#getToken':
            return {'token': 'test-token'};
          default:
            return true;
        }
      });

      appCheck = MethodChannelFirebaseAppCheck(app: app);
    });

    setUp(() async {
      methodCallLogger.clear();
    });

    group('delegateFor()', () {
      test('returns a [FirebaseAppCheckPlatform]', () {
        expect(
          // ignore: invalid_use_of_protected_member
          appCheck.delegateFor(app: secondaryApp),
          FirebaseAppCheckPlatform.instanceFor(app: secondaryApp),
        );
      });
    });

    group('setInitialValues()', () {
      test('returns a [MethodChannelFirebaseAppCheck]', () {
        // ignore: invalid_use_of_protected_member
        expect(appCheck.setInitialValues(), appCheck);
      });
    });

    test('activate', () async {
      await appCheck.activate(
        webRecaptchaSiteKey: 'test-key',
      );
      expect(
        methodCallLogger,
        <Matcher>[
          isMethodCall(
            'FirebaseAppCheck#activate',
            arguments: {
              'appName': defaultFirebaseAppName,
              'androidProvider': 'playIntegrity'
            },
          ),
        ],
      );
    });

    test('getToken', () async {
      final tokenResult = await appCheck.getToken(true);
      expect(
        methodCallLogger,
        <Matcher>[
          isMethodCall(
            'FirebaseAppCheck#getToken',
            arguments: {
              'appName': defaultFirebaseAppName,
              'forceRefresh': true
            },
          ),
        ],
      );

      expect(tokenResult, isA<String>());
    });

    test('setTokenAutoRefreshEnabled', () async {
      await appCheck.setTokenAutoRefreshEnabled(false);
      expect(
        methodCallLogger,
        <Matcher>[
          isMethodCall(
            'FirebaseAppCheck#setTokenAutoRefreshEnabled',
            arguments: {
              'appName': defaultFirebaseAppName,
              'isTokenAutoRefreshEnabled': false,
            },
          ),
        ],
      );
    });

    test('tokenChanges', () async {
      final stream = appCheck.onTokenChange;
      expect(stream, isA<Stream<String?>>());
    });
  });
}

class TestMethodChannelFirebaseAppCheck extends MethodChannelFirebaseAppCheck {
  TestMethodChannelFirebaseAppCheck(FirebaseApp app) : super(app: app);
}
