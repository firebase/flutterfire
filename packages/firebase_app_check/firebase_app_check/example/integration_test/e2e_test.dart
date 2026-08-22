// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: do_not_use_environment

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_app_check_example/firebase_options.dart';

import 'report_test_results.dart';

const androidDebugToken =
    String.fromEnvironment('APP_CHECK_ANDROID_DEBUG_TOKEN');

const appleDebugToken = String.fromEnvironment('APP_CHECK_APPLE_DEBUG_TOKEN');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  reportTestResultsToDriver(binding);

  group(
    'firebase_app_check',
    () {
      setUpAll(() async {
        // The native SDK may already have configured [DEFAULT] from a bundled
        // GoogleService-Info.plist (the plugin registrant does this before any
        // Dart runs). Dart's Firebase.apps cannot see that app until the first
        // platform-channel call, so the only reliable guard is catching the
        // duplicate-app error and keeping the natively configured instance.
        try {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        } on FirebaseException catch (e) {
          if (e.code != 'duplicate-app') {
            rethrow;
          }
        }
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
        'getTokenResult',
        () async {
          try {
            final result = await FirebaseAppCheck.instance.getTokenResult(true);
            if (result != null) {
              expect(result.token, isNotEmpty);
              if (!kIsWeb) {
                expect(result.expirationTime, isNotNull);
                expect(result.expirationTime!.isAfter(DateTime.now()), isTrue);
              }
            }
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
        'appAttestWithDeviceCheckFallback falls back rather than erroring',
        () async {
          await FirebaseAppCheck.instance.activate(
            providerApple:
                const AppleAppAttestWithDeviceCheckFallbackProvider(),
          );

          // On devices without App Attest support — most Macs, and every
          // simulator — the provider has to fall back to DeviceCheck. It used
          // to pick App Attest purely on OS version and fail with "The
          // attestation provider AppAttestProvider is not supported on current
          // platform and OS version", so App Attest must not be the provider
          // named in any error. Fetching a token can still fail beyond that
          // (simulators do not support DeviceCheck either, and there is no
          // debug token configured), which is fine here.
          try {
            await FirebaseAppCheck.instance.getToken(true);
          } on FirebaseException catch (e) {
            expect(
              '${e.message}',
              isNot(contains('AppAttestProvider')),
              reason: 'the DeviceCheck fallback did not engage',
            );
          }
        },
        skip: defaultTargetPlatform != TargetPlatform.macOS &&
                defaultTargetPlatform != TargetPlatform.iOS
            ? 'Apple platforms only.'
            : null,
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

      group(
        'WindowsCustomProvider',
        () {
          int farFutureExpireTimeMillis() {
            return DateTime.now()
                .add(const Duration(hours: 1))
                .millisecondsSinceEpoch;
          }

          test(
            'getToken invokes fetchToken and returns the synthetic token',
            () async {
              var fetchCount = 0;
              const token = 'windows-custom-e2e-token';
              final expireTimeMillis = farFutureExpireTimeMillis();

              await FirebaseAppCheck.instance.activate(
                providerWindows: WindowsCustomProvider(
                  fetchToken: () async {
                    fetchCount++;
                    return CustomAppCheckToken(
                      token: token,
                      expireTimeMillis: expireTimeMillis,
                    );
                  },
                ),
              );

              expect(
                await FirebaseAppCheck.instance.getToken(true),
                token,
              );
              expect(
                fetchCount,
                greaterThan(0),
                reason: 'native must call GetCustomToken so fetchToken runs; '
                    'a zero count means the debug provider path was used',
              );
            },
          );

          test(
            'isolates fetchToken by Firebase app name',
            () async {
              var defaultFetchCount = 0;
              var secondaryFetchCount = 0;
              const defaultToken = 'windows-custom-default-app-token';
              const secondaryToken = 'windows-custom-secondary-app-token';
              final expireTimeMillis = farFutureExpireTimeMillis();

              final secondaryApp = await Firebase.initializeApp(
                name: 'app-check-secondary',
                options: DefaultFirebaseOptions.currentPlatform,
              );
              addTearDown(secondaryApp.delete);

              final defaultAppCheck = FirebaseAppCheck.instance;
              final secondaryAppCheck = FirebaseAppCheck.instanceFor(
                app: secondaryApp,
              );

              await defaultAppCheck.activate(
                providerWindows: WindowsCustomProvider(
                  fetchToken: () async {
                    defaultFetchCount++;
                    return CustomAppCheckToken(
                      token: defaultToken,
                      expireTimeMillis: expireTimeMillis,
                    );
                  },
                ),
              );
              await secondaryAppCheck.activate(
                providerWindows: WindowsCustomProvider(
                  fetchToken: () async {
                    secondaryFetchCount++;
                    return CustomAppCheckToken(
                      token: secondaryToken,
                      expireTimeMillis: expireTimeMillis,
                    );
                  },
                ),
              );

              expect(await defaultAppCheck.getToken(true), defaultToken);
              expect(defaultFetchCount, greaterThan(0));
              expect(
                secondaryFetchCount,
                0,
                reason: 'fetching the default app must not invoke the '
                    'secondary app fetchToken',
              );

              final defaultCountAfterDefaultFetch = defaultFetchCount;
              expect(
                await secondaryAppCheck.getToken(true),
                secondaryToken,
              );
              expect(secondaryFetchCount, greaterThan(0));
              expect(
                defaultFetchCount,
                defaultCountAfterDefaultFetch,
                reason: 'fetching the secondary app must not invoke the '
                    'default app fetchToken',
              );

              final secondaryCountAfterSecondaryFetch = secondaryFetchCount;
              expect(await defaultAppCheck.getToken(true), defaultToken);
              expect(
                defaultFetchCount,
                greaterThan(defaultCountAfterDefaultFetch),
              );
              expect(
                secondaryFetchCount,
                secondaryCountAfterSecondaryFetch,
              );
            },
          );
        },
        skip: kIsWeb || defaultTargetPlatform != TargetPlatform.windows,
      );
    },
  );
}
