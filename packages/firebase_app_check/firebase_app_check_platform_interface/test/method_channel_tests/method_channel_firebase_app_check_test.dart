// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_app_check_platform_interface/firebase_app_check_platform_interface.dart';
import 'package:firebase_app_check_platform_interface/src/pigeon/messages.pigeon.dart'
    as pigeon;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';

void main() {
  setupFirebaseAppCheckMocks();
  late FirebaseApp secondaryApp;

  const activateChannelName =
      'dev.flutter.pigeon.firebase_app_check_platform_interface.FirebaseAppCheckHostApi.activate';

  group('$MethodChannelFirebaseAppCheck', () {
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
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
        activateChannelName,
        null,
      );
    });

    group('delegateFor()', () {
      test('returns a [FirebaseAppCheckPlatform]', () {
        final appCheck = FirebaseAppCheckPlatform.instance;
        expect(
          // ignore: invalid_use_of_protected_member
          appCheck.delegateFor(app: secondaryApp),
          FirebaseAppCheckPlatform.instanceFor(app: secondaryApp),
        );
      });
    });

    group('setInitialValues()', () {
      test('returns a [MethodChannelFirebaseAppCheck]', () {
        final appCheck = MethodChannelFirebaseAppCheck.instance;
        // ignore: invalid_use_of_protected_member
        expect(appCheck.setInitialValues(), appCheck);
      });
    });

    group('activate()', () {
      test('passes the Apple debug token on Apple platforms', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        final calls = <List<Object?>>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler(
          activateChannelName,
          (ByteData? message) async {
            calls.add(
              pigeon.FirebaseAppCheckHostApi.pigeonChannelCodec
                  .decodeMessage(message)! as List<Object?>,
            );
            return pigeon.FirebaseAppCheckHostApi.pigeonChannelCodec
                .encodeMessage(
              <Object?>[],
            );
          },
        );

        final appCheck = MethodChannelFirebaseAppCheck(app: secondaryApp);

        await appCheck.activate(
          providerAndroid: const AndroidDebugProvider(
            debugToken: 'android-debug-token',
          ),
          providerApple: const AppleDebugProvider(
            debugToken: 'apple-debug-token',
          ),
        );

        expect(calls, hasLength(1));
        expect(calls.single[3], 'apple-debug-token');
      });

      test('passes the Android debug token on Android', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        final calls = <List<Object?>>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler(
          activateChannelName,
          (ByteData? message) async {
            calls.add(
              pigeon.FirebaseAppCheckHostApi.pigeonChannelCodec
                  .decodeMessage(message)! as List<Object?>,
            );
            return pigeon.FirebaseAppCheckHostApi.pigeonChannelCodec
                .encodeMessage(
              <Object?>[],
            );
          },
        );

        final appCheck = MethodChannelFirebaseAppCheck(app: secondaryApp);

        await appCheck.activate(
          providerAndroid: const AndroidDebugProvider(
            debugToken: 'android-debug-token',
          ),
          providerApple: const AppleDebugProvider(
            debugToken: 'apple-debug-token',
          ),
        );

        expect(calls, hasLength(1));
        expect(calls.single[3], 'android-debug-token');
      });

      group('on Windows', () {
        late BasicMessageChannel<Object?> activateChannel;
        late List<Object?> activateMessages;

        setUp(() {
          debugDefaultTargetPlatformOverride = TargetPlatform.windows;
          activateChannel = const BasicMessageChannel<Object?>(
            activateChannelName,
            pigeon.FirebaseAppCheckHostApi.pigeonChannelCodec,
          );
          activateMessages = <Object?>[];
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockDecodedMessageHandler<Object?>(activateChannel,
                  (Object? message) async {
            activateMessages.add(message);
            return <Object?>[];
          });
        });

        tearDown(() {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockDecodedMessageHandler<Object?>(activateChannel, null);
        });

        test('forwards WindowsCustomProvider over Pigeon', () async {
          final appCheck = MethodChannelFirebaseAppCheck(app: secondaryApp);

          await appCheck.activate(
            providerWindows: WindowsCustomProvider(
              fetchToken: () async => const CustomAppCheckToken(
                token: 'app-check-token',
                expireTimeMillis: 1735689600000,
              ),
            ),
          );

          // Android/Apple slots carry method-channel defaults even on Windows.
          expect(activateMessages, hasLength(1));
          expect(activateMessages.single, <Object?>[
            'secondaryApp',
            'playIntegrity',
            'deviceCheck',
            null,
            'custom',
          ]);
        });

        test(
            'forwards WindowsDebugProvider with an explicit debug token over Pigeon',
            () async {
          final appCheck = MethodChannelFirebaseAppCheck(app: secondaryApp);

          await appCheck.activate(
            providerWindows: const WindowsDebugProvider(
              debugToken: 'debug-token',
            ),
          );

          expect(activateMessages, hasLength(1));
          expect(activateMessages.single, <Object?>[
            'secondaryApp',
            'playIntegrity',
            'deviceCheck',
            'debug-token',
            'debug',
          ]);
        });

        test(
            'forwards WindowsDebugProvider with no explicit token as null '
            '(env-var fallback path)', () async {
          final appCheck = MethodChannelFirebaseAppCheck(app: secondaryApp);

          // Null debugToken triggers the native APP_CHECK_DEBUG_TOKEN fallback.
          await appCheck.activate(
            providerWindows: const WindowsDebugProvider(),
          );

          expect(activateMessages, hasLength(1));
          expect(activateMessages.single, <Object?>[
            'secondaryApp',
            'playIntegrity',
            'deviceCheck',
            null,
            'debug',
          ]);
        });
      });
    });
  });

  group('Windows custom token callback', () {
    BasicMessageChannel<Object?> flutterApiChannelFor(String appName) {
      return BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.firebase_app_check_platform_interface.FirebaseAppCheckFlutterApi.getCustomToken.$appName',
        pigeon.FirebaseAppCheckFlutterApi.pigeonChannelCodec,
      );
    }

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
        activateChannelName,
        (ByteData? message) async {
          return pigeon.FirebaseAppCheckHostApi.pigeonChannelCodec
              .encodeMessage(
            <Object?>[],
          );
        },
      );
    });

    tearDown(() {
      pigeon.FirebaseAppCheckFlutterApi.setUp(
        null,
        messageChannelSuffix: Firebase.app().name,
      );
      pigeon.FirebaseAppCheckFlutterApi.setUp(
        null,
        messageChannelSuffix: secondaryApp.name,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
        activateChannelName,
        null,
      );
    });

    test('returns tokens from the active WindowsCustomProvider fetchToken',
        () async {
      const token = CustomAppCheckToken(
        token: 'app-check-token',
        expireTimeMillis: 1735689600000,
      );
      final appCheck = MethodChannelFirebaseAppCheck(app: secondaryApp);

      await appCheck.activate(
        providerWindows: WindowsCustomProvider(
          fetchToken: () async => token,
        ),
      );

      final flutterApiChannel = flutterApiChannelFor(secondaryApp.name);
      final replyData = await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .handlePlatformMessage(
        flutterApiChannel.name,
        flutterApiChannel.codec.encodeMessage(null),
        null,
      );
      final reply =
          flutterApiChannel.codec.decodeMessage(replyData) as List<Object?>?;

      final customToken = reply!.single! as pigeon.CustomAppCheckToken;
      expect(customToken.token, 'app-check-token');
      expect(customToken.expireTimeMillis, 1735689600000);
    });

    test('uses the provider registered for the requested app', () async {
      final defaultAppCheck =
          MethodChannelFirebaseAppCheck(app: Firebase.app());
      final secondaryAppCheck =
          MethodChannelFirebaseAppCheck(app: secondaryApp);

      await defaultAppCheck.activate(
        providerWindows: WindowsCustomProvider(
          fetchToken: () async => const CustomAppCheckToken(
            token: 'default-app-token',
            expireTimeMillis: 1735689600000,
          ),
        ),
      );
      await secondaryAppCheck.activate(
        providerWindows: WindowsCustomProvider(
          fetchToken: () async => const CustomAppCheckToken(
            token: 'secondary-app-token',
            expireTimeMillis: 1735689700000,
          ),
        ),
      );

      final defaultChannel = flutterApiChannelFor(Firebase.app().name);
      final secondaryChannel = flutterApiChannelFor(secondaryApp.name);

      final defaultReplyData = await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .handlePlatformMessage(
        defaultChannel.name,
        defaultChannel.codec.encodeMessage(null),
        null,
      );
      final secondaryReplyData = await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .handlePlatformMessage(
        secondaryChannel.name,
        secondaryChannel.codec.encodeMessage(null),
        null,
      );

      final defaultReply = defaultChannel.codec.decodeMessage(defaultReplyData)
          as List<Object?>?;
      final secondaryReply = secondaryChannel.codec
          .decodeMessage(secondaryReplyData) as List<Object?>?;

      final defaultToken = defaultReply!.single! as pigeon.CustomAppCheckToken;
      final secondaryToken =
          secondaryReply!.single! as pigeon.CustomAppCheckToken;

      expect(defaultToken.token, 'default-app-token');
      expect(defaultToken.expireTimeMillis, 1735689600000);
      expect(secondaryToken.token, 'secondary-app-token');
      expect(secondaryToken.expireTimeMillis, 1735689700000);
    });

    test('returns a PlatformException envelope when fetchToken throws',
        () async {
      final appCheck = MethodChannelFirebaseAppCheck(app: secondaryApp);

      await appCheck.activate(
        providerWindows: WindowsCustomProvider(
          fetchToken: () async {
            throw PlatformException(
              code: 'token-error',
              message: 'Failed to mint App Check token',
              details: <String, String>{'source': 'test'},
            );
          },
        ),
      );

      final flutterApiChannel = flutterApiChannelFor(secondaryApp.name);
      final replyData = await TestDefaultBinaryMessengerBinding
          .instance.defaultBinaryMessenger
          .handlePlatformMessage(
        flutterApiChannel.name,
        flutterApiChannel.codec.encodeMessage(null),
        null,
      );
      final reply =
          flutterApiChannel.codec.decodeMessage(replyData) as List<Object?>?;

      expect(reply, <Object?>[
        'token-error',
        'Failed to mint App Check token',
        <String, String>{'source': 'test'},
      ]);
    });

    group('activate() with Recaptcha', () {
      test('passes recaptcha on Android', () async {
        final appCheck = MethodChannelFirebaseAppCheck(app: Firebase.app());

        final List<dynamic> log = <dynamic>[];

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler(
          'dev.flutter.pigeon.firebase_app_check_platform_interface.FirebaseAppCheckHostApi.activate',
          (message) async {
            final list = const StandardMessageCodec().decodeMessage(message)
                as List<dynamic>;
            log.add(list);
            return const StandardMessageCodec()
                .encodeMessage([null]); // Return success
          },
        );

        await appCheck.activate(
          providerAndroid: const AndroidReCaptchaProvider(),
        );

        expect(log.length, 1);
        expect(log[0][0], '[DEFAULT]'); // appName
        expect(log[0][1], 'recaptcha'); // androidProvider
      });

      test('passes recaptcha on iOS', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        final appCheck = MethodChannelFirebaseAppCheck(app: Firebase.app());

        final List<dynamic> log = <dynamic>[];

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler(
          'dev.flutter.pigeon.firebase_app_check_platform_interface.FirebaseAppCheckHostApi.activate',
          (message) async {
            final list = const StandardMessageCodec().decodeMessage(message)
                as List<dynamic>;
            log.add(list);
            return const StandardMessageCodec()
                .encodeMessage([null]); // Return success
          },
        );

        await appCheck.activate(
          providerApple: const AppleReCaptchaProvider(),
        );

        expect(log.length, 1);
        expect(log[0][0], '[DEFAULT]'); // appName
        expect(log[0][2], 'recaptcha'); // appleProvider
      });
    });
  });
}
