// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_app_check_platform_interface/firebase_app_check_platform_interface.dart';
import 'package:firebase_app_check_platform_interface/src/pigeon/messages.pigeon.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mock.dart';

void main() {
  setupFirebaseAppCheckMocks();
  late FirebaseApp secondaryApp;

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
        'dev.flutter.pigeon.firebase_app_check_platform_interface.FirebaseAppCheckHostApi.activate',
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
          'dev.flutter.pigeon.firebase_app_check_platform_interface.FirebaseAppCheckHostApi.activate',
          (ByteData? message) async {
            calls.add(
              FirebaseAppCheckHostApi.pigeonChannelCodec.decodeMessage(message)!
                  as List<Object?>,
            );
            return FirebaseAppCheckHostApi.pigeonChannelCodec.encodeMessage(
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
          'dev.flutter.pigeon.firebase_app_check_platform_interface.FirebaseAppCheckHostApi.activate',
          (ByteData? message) async {
            calls.add(
              FirebaseAppCheckHostApi.pigeonChannelCodec.decodeMessage(message)!
                  as List<Object?>,
            );
            return FirebaseAppCheckHostApi.pigeonChannelCodec.encodeMessage(
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
    });
  });
}
