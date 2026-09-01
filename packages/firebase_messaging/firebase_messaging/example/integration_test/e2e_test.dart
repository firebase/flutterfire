// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_messaging_example/firebase_options.dart';

import 'report_test_results.dart';

/// Test helpers that use UiAutomation to mutate runtime permissions during
/// integration tests. Falls back gracefully on platforms that don't support it.
const _permissionsChannel = MethodChannel('tests/permissions');
const _postNotifications = 'android.permission.POST_NOTIFICATIONS';

Future<int?> androidSdkInt() async {
  try {
    return await _permissionsChannel.invokeMethod<int>('getSdkInt');
  } on MissingPluginException {
    return null;
  }
}

Future<bool> grantAndroidPermission(String permission) async {
  try {
    return await _permissionsChannel.invokeMethod<bool>('grant', {
          'permission': permission,
        }) ??
        false;
  } on MissingPluginException {
    return false;
  }
}

/// Revokes [permission], clears its user-set/user-fixed flags, and clears the
/// prompt state firebase_messaging records, so the permission is reported as
/// never asked again.
Future<bool> resetAndroidPermission(String permission) async {
  try {
    final reset = await _permissionsChannel.invokeMethod<bool>(
      'resetPermission',
      {'permission': permission},
    );
    return reset ?? false;
  } on MissingPluginException {
    return false;
  }
}

// ignore: do_not_use_environment
const bool skipTestsOnCI = bool.fromEnvironment('CI');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  reportTestResultsToDriver(binding);

  group('firebase_messaging', () {
    late FirebaseApp app;
    late FirebaseMessaging messaging;
    int? sdkInt;

    setUpAll(() async {
      app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      messaging = FirebaseMessaging.instance;
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        sdkInt = await androidSdkInt();
      }
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
        _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp
            .listen((_) {});

        await _onMessageSubscription.cancel();
        await _onMessageOpenedAppSubscription.cancel();

        _onMessageSubscription = FirebaseMessaging.onMessage.listen((_) {});
        _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp
            .listen((_) {});

        await _onMessageSubscription.cancel();
        await _onMessageOpenedAppSubscription.cancel();
      });
    });

    group('setAutoInitEnabled()', () {
      test('sets the value', () async {
        await messaging.setAutoInitEnabled(true);
        expect(messaging.isAutoInitEnabled, isTrue);
        await messaging.setAutoInitEnabled(false);
        expect(messaging.isAutoInitEnabled, isFalse);
      }, skip: kIsWeb);
    });

    group('isSupported()', () {
      test('returns "true" value', () async {
        final result = await messaging.isSupported();

        expect(result, isA<bool>());
      });
    });

    group('getNotificationSettings', () {
      bool android13Plus() =>
          !kIsWeb &&
          defaultTargetPlatform == TargetPlatform.android &&
          (sdkInt ?? 0) >= 33;

      setUp(() async {
        if (!android13Plus()) {
          return;
        }
        // Ensure a true "never asked" state between tests and runs.
        // revoke alone leaves USER_SET flags and would look like a denial.
        final reset = await resetAndroidPermission(_postNotifications);
        if (!reset) {
          fail('Could not reset POST_NOTIFICATIONS via UiAutomation');
        }
      });

      test(
        'returns notDetermined on Android 13+ before permission is granted',
        () async {
          if (!android13Plus()) {
            markTestSkipped('Requires Android API 33+');
            return;
          }
          // On Android 13+, getNotificationSettings() should return
          // notDetermined when POST_NOTIFICATIONS has never been granted,
          // allowing callers to decide whether to show the OS prompt or
          // direct the user to app settings.
          final settings = await messaging.getNotificationSettings();
          expect(settings, isA<NotificationSettings>());
          expect(
            settings.authorizationStatus,
            AuthorizationStatus.notDetermined,
          );
        },
        skip: kIsWeb || defaultTargetPlatform != TargetPlatform.android,
      );

      test(
        'returns authorized on Android 13+ after permission is granted',
        () async {
          if (!android13Plus()) {
            markTestSkipped('Requires Android API 33+');
            return;
          }
          final granted = await grantAndroidPermission(_postNotifications);
          if (!granted) {
            fail('Could not grant POST_NOTIFICATIONS via UiAutomation');
          }

          final settings = await messaging.getNotificationSettings();
          expect(settings, isA<NotificationSettings>());
          expect(settings.authorizationStatus, AuthorizationStatus.authorized);
        },
        skip: kIsWeb || defaultTargetPlatform != TargetPlatform.android,
      );
    });

    group('requestPermission', () {
      test(
        'authorizationStatus returns AuthorizationStatus.authorized on Android 13+',
        () async {
          final isAndroid13Plus =
              !kIsWeb &&
              defaultTargetPlatform == TargetPlatform.android &&
              (sdkInt ?? 0) >= 33;
          if (!isAndroid13Plus) {
            markTestSkipped('Requires Android API 33+');
            return;
          }
          // Pre-grant the permission so requestPermission() returns
          // authorized without showing a system dialog.
          final granted = await grantAndroidPermission(_postNotifications);
          if (!granted) {
            fail('Could not grant POST_NOTIFICATIONS via UiAutomation');
          }

          final result = await messaging.requestPermission();
          expect(result, isA<NotificationSettings>());
          expect(result.authorizationStatus, AuthorizationStatus.authorized);
        },
        skip: kIsWeb || defaultTargetPlatform != TargetPlatform.android,
      );

      test(
        'authorizationStatus returns AuthorizationStatus.notDetermined on Web',
        () async {
          final result = await messaging.requestPermission();

          expect(result, isA<NotificationSettings>());
          expect(result.authorizationStatus, AuthorizationStatus.notDetermined);
        },
        // This requires interaction with the browser's permission dialog, it no longer returns `notDetermined` on web
        skip: true,
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
    });

    group('getInitialMessage', () {
      test('returns null when no initial message', () async {
        expect(
          await messaging.getInitialMessage().timeout(
            const Duration(seconds: 5),
          ),
          null,
        );
      });
    });

    group(
      'getToken()',
      () {
        test('returns a token', () async {
          final result = await messaging.getToken();
          expect(result, isA<String>());
        });
      },
      // Skipping on Web since we cannot click on authorize notification dialog
      skip: skipTestsOnCI || kIsWeb,
    ); // only run for manual testing

    group('deleteToken()', () {
      test(
        'generate a new token after deleting',
        () async {
          final token1 = await messaging.getToken();
          await Future.delayed(const Duration(seconds: 3));
          await messaging.deleteToken();
          await Future.delayed(const Duration(seconds: 3));
          final token2 = await messaging.getToken();
          expect(token1, isA<String>());
          expect(token2, isA<String>());
          expect(token1, isNot(token2));
        },
        // Skipping on Web since we cannot click on authorize notification dialog
        skip: skipTestsOnCI || kIsWeb,
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
        // android skipped due to consistently failing, works locally: https://github.com/firebase/flutterfire/pull/11260
        // iOS fails because APNS token handler doesn't have a chance to receive token before calling this method
        skip: kIsWeb || skipTestsOnCI,
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
        // android skipped due to consistently failing, works locally: https://github.com/firebase/flutterfire/pull/11260
        // iOS fails because APNS token handler doesn't have a chance to receive token before calling this method
        skip: kIsWeb || skipTestsOnCI,
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
  });
}
