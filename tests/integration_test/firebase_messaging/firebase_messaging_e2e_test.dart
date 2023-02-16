// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tests/firebase_options.dart';

// ignore: do_not_use_environment
const bool skipManualTests = bool.fromEnvironment('CI');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    'firebase_messaging',
    () {
      late FirebaseApp app;
      late FirebaseMessaging messaging;

      setUpAll(() async {
        app = await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        messaging = FirebaseMessaging.instance;
      });

      test('instance', () {
        expect(messaging, isA<FirebaseMessaging>());
        expect(messaging.app, isA<FirebaseApp>());
        expect(messaging.app.name, defaultFirebaseAppName);
      });

      test('.app accessible from messaging.app', () {
        expect(messaging.app, isA<FirebaseApp>());
        expect(messaging.app.name, app.name);
      });

      group('onMessage', () {
        test('can listen multiple times', () async {
          // regression test for https://github.com/firebase/flutterfire/issues/6009

          StreamSubscription<RemoteMessage> _onMessageSubscription;
          StreamSubscription<RemoteMessage> _onMessageOpenedAppSubscription;

          _onMessageSubscription = FirebaseMessaging.onMessage.listen((_) {});
          _onMessageOpenedAppSubscription =
              FirebaseMessaging.onMessageOpenedApp.listen((_) {});

          await _onMessageSubscription.cancel();
          await _onMessageOpenedAppSubscription.cancel();

          _onMessageSubscription = FirebaseMessaging.onMessage.listen((_) {});
          _onMessageOpenedAppSubscription =
              FirebaseMessaging.onMessageOpenedApp.listen((_) {});

          await _onMessageSubscription.cancel();
          await _onMessageOpenedAppSubscription.cancel();
        });
      });

      group('setAutoInitEnabled()', () {
        test(
          'sets the value',
          () async {
            expect(messaging.isAutoInitEnabled, isTrue);
            await messaging.setAutoInitEnabled(false);
            expect(messaging.isAutoInitEnabled, isFalse);
          },
          skip: kIsWeb,
        );
      });

      group('isSupported()', () {
        test('returns "true" value', () async {
          final result = await messaging.isSupported();

          expect(result, isA<bool>());
        });
      });

      group('requestPermission', () {
        test(
          'authorizationStatus returns AuthorizationStatus.authorized on Android',
          () async {
            final result = await messaging.requestPermission();
            expect(result, isA<NotificationSettings>());
            expect(result.authorizationStatus, AuthorizationStatus.authorized);
          },
          skip: defaultTargetPlatform != TargetPlatform.android || kIsWeb,
        );
      });

      group('requestPermission', () {
        test(
          'authorizationStatus returns AuthorizationStatus.notDetermined on Web',
          () async {
            final result = await messaging.requestPermission();

            expect(result, isA<NotificationSettings>());
            expect(
              result.authorizationStatus,
              AuthorizationStatus.notDetermined,
            );
          },
          skip: !kIsWeb,
        );
      });

      group('getAPNSToken', () {
        test(
          'resolves null on android',
          () async {
            expect(await messaging.getAPNSToken(), null);
          },
          skip: defaultTargetPlatform != TargetPlatform.android,
        );

        test(
          'resolves null on ios if using simulator',
          () async {
            expect(await messaging.getAPNSToken(), null);
          },
          skip: !(defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform != TargetPlatform.macOS),
        );
      });

      group('getInitialMessage', () {
        test('returns null when no initial message', () async {
          expect(await messaging.getInitialMessage(), null);
        });
      });

      group(
        'getToken()',
        () {
          test('returns a token', () async {
            final result = await messaging.requestPermission();

            if (result.authorizationStatus == AuthorizationStatus.authorized) {
              final result = await messaging.getToken();

              expect(result, isA<String>());
            } else {
              await expectLater(
                messaging.getToken(),
                throwsA(
                  isA<FirebaseException>()
                      .having((e) => e.code, 'code', 'permission-blocked'),
                ),
              );
            }
          });
        },
        skip: skipManualTests,
      ); // only run for manual testing

      group('deleteToken()', () {
        test(
          'generate a new token after deleting',
          () async {
            final result = await messaging.requestPermission();

            if (result.authorizationStatus == AuthorizationStatus.authorized) {
              final token1 = await messaging.getToken();
              await Future.delayed(const Duration(seconds: 3));
              await messaging.deleteToken();
              await Future.delayed(const Duration(seconds: 3));
              final token2 = await messaging.getToken();
              expect(token1, isA<String>());
              expect(token2, isA<String>());
              expect(token1, isNot(token2));
            } else {
              await expectLater(
                messaging.getToken(),
                throwsA(
                  isA<FirebaseException>()
                      .having((e) => e.code, 'code', 'permission-blocked'),
                ),
              );
            }
          },
          skip: skipManualTests,
        ); // only run for manual testing
      });

      group('subscribeToTopic()', () {
        test(
          'successfully subscribes from topic',
          () async {
            const topic = 'test-topic';
            await messaging.subscribeToTopic(topic);
          },
          // macOS skipped because it needs keychain sharing entitlement. See: https://github.com/firebase/flutterfire/issues/9538
          skip: kIsWeb || defaultTargetPlatform == TargetPlatform.macOS,
        );
      });

      group('unsubscribeFromTopic()', () {
        test(
          'successfully unsubscribes from topic',
          () async {
            const topic = 'test-topic';
            await messaging.unsubscribeFromTopic(topic);
          },
          // macOS skipped because it needs keychain sharing entitlement. See: https://github.com/firebase/flutterfire/issues/9538
          skip: kIsWeb || defaultTargetPlatform == TargetPlatform.macOS,
        );
      });

      group('setDeliveryMetricsExportToBigQuery()', () {
        test(
          'successfully set delivery metrics export to big query',
          () async {
            await messaging.setDeliveryMetricsExportToBigQuery(true);
          },
          // Web is skipped because it has to be setup in the service worker
          skip: kIsWeb,
        );
      });
    },
  );
}
