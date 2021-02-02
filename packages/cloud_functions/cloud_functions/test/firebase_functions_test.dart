// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock.dart';

void main() {
  setUp(() async {
    resetFirebaseCoreMocks();
    await Firebase.initializeApp();
    FirebaseFunctionsPlatform.instance =
        MockFirebaseFunctionsPlatform(region: 'us-central1');
  });

  group('FirebaseFunctions', () {
    group('.instance', () {
      test('uses the default FirebaseApp instance', () {
        expect(FirebaseFunctions.instance.app, isA<FirebaseApp>());
        expect(FirebaseFunctions.instance.app.name,
            equals(defaultFirebaseAppName));
      });

      test('uses the default Functions region', () {
        expect(
            FirebaseFunctions.instance.delegate.region, equals('us-central1'));
      });
    });

    group('.instanceFor()', () {
      FirebaseApp? secondaryApp;

      setUp(() async {
        resetFirebaseCoreMocks();
        await Firebase.initializeApp();
        secondaryApp = await Firebase.initializeApp(
          name: 'foo',
          options: const FirebaseOptions(
            apiKey: '123',
            appId: '123',
            messagingSenderId: '123',
            projectId: '123',
          ),
        );
      });

      test('accepts a secondary FirebaseApp instance', () async {
        FirebaseFunctions functionsSecondary =
            FirebaseFunctions.instanceFor(app: secondaryApp);
        expect(functionsSecondary.app, isA<FirebaseApp>());
        expect(functionsSecondary.app.name, secondaryApp!.name);
      });

      test('accepts a secondary FirebaseApp instance and custom region',
          () async {
        FirebaseFunctions functionsSecondary = FirebaseFunctions.instanceFor(
            app: secondaryApp, region: 'europe-west1');
        expect(functionsSecondary.app, isA<FirebaseApp>());
        expect(functionsSecondary.app.name, secondaryApp!.name);
        expect(functionsSecondary.delegate.region, equals('europe-west1'));
      });

      test('accepts a custom region for the default app', () async {
        FirebaseFunctions functions =
            FirebaseFunctions.instanceFor(region: 'europe-west1');
        expect(functions.app, isA<FirebaseApp>());
        expect(functions.app.name, defaultFirebaseAppName);
        expect(functions.delegate.region, equals('europe-west1'));
      });

      test('caches instances by FirebaseApp and region', () async {
        // Instances using the same region and FirebaseApp should be identical.
        FirebaseFunctions functions1 =
            FirebaseFunctions.instanceFor(region: 'europe-west1');
        FirebaseFunctions functions2 =
            FirebaseFunctions.instanceFor(region: 'europe-west1');
        expect(functions1, same(functions2));

        // Instances using the same region but a different FirebaseApp should not be identical.
        FirebaseFunctions functions3 = FirebaseFunctions.instanceFor(
            app: secondaryApp, region: 'europe-west1');
        expect(functions1, isNot(same(functions3)));

        // Instances using the same FirebaseApp but a different region should not be identical.
        FirebaseFunctions functions4 =
            FirebaseFunctions.instanceFor(region: 'europe-west2');
        expect(functions1, isNot(same(functions4)));
      });
    });

    group('.useEmulator()', () {
      test('passes emulator "origin" through to the delegate', () {
        // Check null by default.
        expect(FirebaseFunctions.instance.httpsCallable('test').delegate.origin,
            isNull);
        // Set the origin for the default FirebaseFunctions instance.
        FirebaseFunctions.instance
            .useFunctionsEmulator(origin: 'http://0.0.0.0:5000');
        expect(FirebaseFunctions.instance.httpsCallable('test').delegate.origin,
            equals('http://0.0.0.0:5000'));
      });

      test('"origin" is only set for the specific FirebaseFunctions instance',
          () {
        FirebaseFunctions.instance
            .useFunctionsEmulator(origin: 'http://0.0.0.0:5000');
        // Origin on the default FirebaseFunctions instance should be set.
        expect(FirebaseFunctions.instance.httpsCallable('test').delegate.origin,
            equals('http://0.0.0.0:5000'));
        // Origin on a secondary FirebaseFunctions instance should remain unset/null.
        expect(
            FirebaseFunctions.instanceFor(region: 'europe-west1')
                .httpsCallable('test')
                .delegate
                .origin,
            isNull);
      });

      test('throws if "origin" is an empty string', () {
        expect(() {
          FirebaseFunctions.instance.useFunctionsEmulator(origin: '');
        }, throwsA(isA<AssertionError>()));
      });
    });

    group('.httpsCallable()', () {
      test('throws if "name" is an empty string', () {
        expect(() {
          FirebaseFunctions.instance.httpsCallable('');
        }, throwsA(isA<AssertionError>()));
      });

      test('passes "name" through to delegate', () {
        expect(FirebaseFunctions.instance.httpsCallable('foo').delegate.name,
            equals('foo'));
      });

      test('provides default "options" if none provided', () {
        expect(FirebaseFunctions.instance.httpsCallable('foo').delegate.options,
            isNotNull);
      });

      test('passes custom "options" through to the delegate', () {
        HttpsCallablePlatform delegate = FirebaseFunctions.instance
            .httpsCallable('foo',
                options: HttpsCallableOptions(
                    timeout: const Duration(seconds: 1337)))
            .delegate;
        expect(delegate.options, isNotNull);
        expect(delegate.options.timeout, isA<Duration>());
        expect(delegate.options.timeout.inSeconds, equals(1337));
      });
    });
  });
}
