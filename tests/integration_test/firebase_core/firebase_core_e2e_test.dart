// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/firebase_auth.dart';
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
      expect(() => Firebase.app('NoApp'), throwsA(noAppExists('NoApp')));
    });

    test('FirebaseApp.delete()', () async {
      await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: DefaultFirebaseOptions.currentPlatform,
      );

      expect(Firebase.apps.length, 2);

      FirebaseApp app = Firebase.app('SecondaryApp');

      await app.delete();

      expect(Firebase.apps.length, 1);
      // TODO(russellwheatley): test randomly causes an auth sign-in failure due to duplicate accounts.
    }, skip: TargetPlatform.android == defaultTargetPlatform);

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

    test('Firebase.initializeApp() with demoProjectId', () async {
      const demoProjectId = 'demo-flutterfire-e2e';
      final app = await Firebase.initializeApp(demoProjectId: demoProjectId);
      addTearDown(app.delete);

      expect(app.name, demoProjectId);
      expect(app.options.projectId, demoProjectId);
    });

    // The tests app links the Auth, App Check and Messaging plugins, so the
    // native SDKs' interop components are in the container. Auth runs against
    // the emulator that CI starts around this suite.
    group(
      'interop tokens',
      () {
        late FirebaseAppPlatform defaultApp;

        setUpAll(() async {
          defaultApp = FirebasePlatform.instance.app();
          await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
        });

        tearDown(() => FirebaseAuth.instance.signOut());

        test('getAuthIdToken is null when nobody is signed in', () async {
          await FirebaseAuth.instance.signOut();

          expect(await defaultApp.getAuthIdToken(), isNull);
        });

        test(
          "getAuthIdToken is the signed-in user's ID token",
          () async {
            final credential = await FirebaseAuth.instance.signInAnonymously();
            final idToken = await credential.user!.getIdToken();

            expect(await defaultApp.getAuthIdToken(), idToken);
          },
          // Signing in persists the user to the keychain, which the unsigned
          // macOS test app cannot write to (errSecMissingEntitlement), as in
          // the firebase_auth suite.
          skip: defaultTargetPlatform == TargetPlatform.macOS,
        );

        test(
          'getAppCheckToken answers with a placeholder before activation',
          () async {
            // App Check is linked but never activated in this app, so the SDK
            // answers with its placeholder token and the reason.
            final answer = await defaultApp.getAppCheckToken();

            expect(answer, isNotNull);
            expect(answer!.token, isNotEmpty);
            expect(answer.error, isNotNull);
          },
        );

        test(
          'getMessagingToken is null for an app other than the default',
          () async {
            // Messaging only serves the default app.
            final secondary = await Firebase.initializeApp(
              name: 'InteropTokensApp',
              options: DefaultFirebaseOptions.currentPlatform,
            );
            addTearDown(secondary.delete);

            expect(
              await FirebasePlatform.instance
                  .app('InteropTokensApp')
                  .getMessagingToken(),
              isNull,
            );
          },
          // On Android the token comes from the Instance ID library, which
          // answers for any app and fetches over the network.
          skip: defaultTargetPlatform == TargetPlatform.android,
        );
      },
      // No implementation on Windows yet; web lands separately.
      skip: kIsWeb || defaultTargetPlatform == TargetPlatform.windows,
    );
  });
}
