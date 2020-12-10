// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock.dart';

import 'package:mockito/mockito.dart';

void main() {
  setupFirebaseFunctionsMocks();
  FirebaseFunctions functions;
  FirebaseFunctions functionsSecondary;
  FirebaseApp app;
  FirebaseApp secondaryApp;

  group('$FirebaseFunctions', () {
    setUpAll(() async {
      app = await Firebase.initializeApp();
      kMockFirebaseFunctionsPlatform =
          MockFirebaseFunctionsPlatform(app, 'test_region');
      FirebaseFunctionsPlatform.instance = kMockFirebaseFunctionsPlatform;

      secondaryApp = await Firebase.initializeApp(
          name: 'foo',
          options: FirebaseOptions(
            apiKey: '123',
            appId: '123',
            messagingSenderId: '123',
            projectId: '123',
          ));
      functions = FirebaseFunctions.instance;

      when(kMockFirebaseFunctionsPlatform.delegateFor(
              app: anyNamed('app'), region: anyNamed('region')))
          .thenAnswer((_) {
        return kMockFirebaseFunctionsPlatform;
      });

      when(kMockFirebaseFunctionsPlatform.httpsCallable(any, any, any))
          .thenAnswer((_) {
        return kMockHttpsCallablePlatform;
      });
    });

    test('instance', () {
      expect(functions, isA<FirebaseFunctions>());
      expect(functions, equals(FirebaseFunctions.instance));
    });

    test('returns the correct $FirebaseApp', () {
      expect(functions.app, isA<FirebaseApp>());
    });

    group('instanceFor()', () {
      test('returns the correct $FirebaseApp', () {
        functionsSecondary = FirebaseFunctions.instanceFor(app: secondaryApp);

        expect(functionsSecondary.app, isA<FirebaseApp>());
        expect(functionsSecondary.app.name, 'foo');
      });
    });
  });

  test('httpsCallable()', () {
    functions.httpsCallable('testName');
    verify(kMockFirebaseFunctionsPlatform.httpsCallable(any, 'testName', any));
  });

//
  test('getHttpsCallable()', () {
    // ignore: deprecated_member_use_from_same_package
    functions.getHttpsCallable(functionName: 'testName');
    verify(kMockFirebaseFunctionsPlatform.httpsCallable(any, 'testName', any));
  });
}
