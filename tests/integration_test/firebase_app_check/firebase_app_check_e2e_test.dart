// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: do_not_use_environment

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tests/firebase_options.dart';

const androidDebugToken =
    String.fromEnvironment('APP_CHECK_ANDROID_DEBUG_TOKEN');

const appleDebugToken = String.fromEnvironment('APP_CHECK_APPLE_DEBUG_TOKEN');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(
    'firebase_app_check',
    () {
      setUpAll(() async {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      });

      test(
        'activate',
        () async {
          await expectLater(
            FirebaseAppCheck.instance.activate(
              providerWeb: ReCaptchaV3Provider(
                '6Lemcn0dAAAAABLkf6aiiHvpGD6x-zF3nOSDU2M8',
              ),
            ),
            completes,
          );
        },
      );

      test(
        'getToken',
        () async {
          try {
            await FirebaseAppCheck.instance.getToken(true);
          } catch (exception) {
            // Needs a debug token pasted in the Firebase console to work so we catch the exception.
            expect(exception, isA<FirebaseException>());
          }
        },
      );

      test(
        'setTokenAutoRefreshEnabled',
        () async {
          await expectLater(
            FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true),
            completes,
          );
        },
      );

      test('onTokenChange', () async {
        final stream = FirebaseAppCheck.instance.onTokenChange;
        expect(stream, isA<Stream<String?>>());
      });

      test(
        'getLimitedUseToken',
        () async {
          try {
            await FirebaseAppCheck.instance.getLimitedUseToken();
          } catch (exception) {
            // Needs a debug token pasted in the Firebase console to work so we catch the exception.
            expect(exception, isA<FirebaseException>());
          }
        },
      );

      test(
        'debugToken on Android',
        () async {
          await expectLater(
            FirebaseAppCheck.instance.activate(
              providerAndroid: const AndroidDebugProvider(),
            ),
            completes,
          );
        },
        skip: defaultTargetPlatform != TargetPlatform.android,
      );

      test(
        'debugToken on iOS',
        () async {
          await expectLater(
            FirebaseAppCheck.instance.activate(
              providerApple: const AppleDebugProvider(),
            ),
            completes,
          );
        },
        skip: defaultTargetPlatform != TargetPlatform.iOS,
      );

      test(
        'uses Apple debug token when both Android and Apple debug tokens are configured',
        () async {
          await FirebaseAppCheck.instance.activate(
            providerAndroid: const AndroidDebugProvider(
              debugToken: androidDebugToken,
            ),
            providerApple: const AppleDebugProvider(
              debugToken: appleDebugToken,
            ),
          );

          await expectLater(
            FirebaseAppCheck.instance.getToken(true),
            completes,
          );
        },
        skip: defaultTargetPlatform != TargetPlatform.iOS ||
                androidDebugToken.isEmpty ||
                appleDebugToken.isEmpty
            ? 'Requires iOS plus APP_CHECK_ANDROID_DEBUG_TOKEN and '
                'APP_CHECK_APPLE_DEBUG_TOKEN dart-defines.'
            : null,
      );

      test(
        'uses Android debug token when both Android and Apple debug tokens are configured',
        () async {
          await FirebaseAppCheck.instance.activate(
            providerAndroid: const AndroidDebugProvider(
              debugToken: androidDebugToken,
            ),
            providerApple: const AppleDebugProvider(
              debugToken: appleDebugToken,
            ),
          );

          await expectLater(
            FirebaseAppCheck.instance.getToken(true),
            completes,
          );
        },
        skip: defaultTargetPlatform != TargetPlatform.android ||
                androidDebugToken.isEmpty ||
                appleDebugToken.isEmpty
            ? 'Requires Android plus APP_CHECK_ANDROID_DEBUG_TOKEN and '
                'APP_CHECK_APPLE_DEBUG_TOKEN dart-defines.'
            : null,
      );
    },
  );
}
