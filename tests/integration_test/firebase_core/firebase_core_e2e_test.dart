// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_app_check/firebase_app_check.dart';
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

    // The tests app links the Auth, App Check and Messaging plugins, so their
    // token providers are available to any package that asks the app for
    // them. Auth runs against the emulator that CI starts around this suite.
    group('token providers', () {
      late FirebaseApp defaultApp;

      setUpAll(() => defaultApp = Firebase.app());

      // Declared before anything in this suite touches FirebaseAuth,
      // FirebaseAppCheck or FirebaseMessaging: the plugins register their
      // providers before main (dartPluginClass on Android, Apple and Windows;
      // registerWith on web), so a user restored from a previous launch, or a
      // token the SDK holds, is reachable before the app uses the plugin.
      test('AuthTokenProvider is registered before the app uses Auth', () {
        expect(defaultApp.getService<AuthTokenProvider>(), isNotNull);
      });

      test(
        'AppCheckTokenProvider is registered before the app uses App Check',
        () {
          expect(defaultApp.getService<AppCheckTokenProvider>(), isNotNull);
        },
      );

      test(
        'MessagingTokenProvider is registered before the app uses Messaging',
        () {
          expect(defaultApp.getService<MessagingTokenProvider>(), isNotNull);
        },
        // There is no Messaging plugin on Windows.
        skip: !kIsWeb && defaultTargetPlatform == TargetPlatform.windows,
      );

      group('AuthTokenProvider', () {
        late AuthTokenProvider provider;

        setUpAll(() async {
          provider = defaultApp.getService<AuthTokenProvider>()!;
          await FirebaseAuth.instance.useAuthEmulator(
            defaultTargetPlatform == TargetPlatform.android && !kIsWeb
                ? '10.0.2.2'
                : 'localhost',
            9099,
          );
        });

        tearDown(() => FirebaseAuth.instance.signOut());

        test('getIdToken is null when nobody is signed in', () async {
          await FirebaseAuth.instance.signOut();

          expect(await provider.getIdToken(), isNull);
        });

        test(
          "getIdToken is the signed-in user's ID token",
          () async {
            final credential = await FirebaseAuth.instance.signInAnonymously();
            final idToken = await credential.user!.getIdToken();

            expect(await provider.getIdToken(), idToken);
          },
          // Signing in persists the user to the keychain, which the unsigned
          // macOS test app cannot write to (errSecMissingEntitlement), as in
          // the firebase_auth suite.
          skip: !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS,
        );
      });

      group('AppCheckTokenProvider', () {
        test(
          'getToken answers with the placeholder before activation',
          () async {
            // App Check is linked but never activated in this app, so the
            // plugin can't produce a token; the provider answers the way the
            // SDKs answer each other, with the placeholder and the reason.
            final answer = await defaultApp
                .getService<AppCheckTokenProvider>()!
                .getToken();

            expect(answer, isNotNull);
            expect(answer!.token, AppCheckInteropToken.placeholderToken);
            expect(answer.error, isNotNull);
          },
        );

        test('stays the same provider once the app uses FirebaseAppCheck', () {
          // Using App Check after the provider exists must not replace it.
          final provider = defaultApp.getService<AppCheckTokenProvider>();
          FirebaseAppCheck.instanceFor(app: defaultApp);

          expect(
            defaultApp.getService<AppCheckTokenProvider>(),
            same(provider),
          );
        });
      });

      group('MessagingTokenProvider', () {
        test('getFcmToken answers null or the token the SDK holds', () async {
          // Nothing in this suite requests notification permission, so on
          // web and on fresh simulators there is no token; the call must
          // answer without prompting or throwing either way.
          final token = await defaultApp
              .getService<MessagingTokenProvider>()!
              .getFcmToken();

          expect(token, anyOf(isNull, isA<String>()));
          if (kIsWeb) {
            // CI's browser never grants notification permission.
            expect(token, isNull);
          }
          if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
            // The tests app enables the installation ID in its manifest, so
            // no legacy token may be fetched for it.
            expect(token, isNull);
          }
        }, skip: !kIsWeb && defaultTargetPlatform == TargetPlatform.windows);
      });
    });
  });
}
