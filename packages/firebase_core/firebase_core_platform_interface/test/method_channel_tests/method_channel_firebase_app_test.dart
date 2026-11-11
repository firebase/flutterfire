// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const options = FirebaseOptions(
    apiKey: 'apiKey',
    appId: 'appId',
    messagingSenderId: 'messagingSenderId',
    projectId: 'projectId',
  );

  group('$MethodChannelFirebaseApp interop tokens', () {
    late FakeFirebaseTokenHostApi native;
    late MethodChannelFirebaseApp app;

    setUp(() {
      native = FakeFirebaseTokenHostApi();
      TestFirebaseTokenHostApi.setUp(native);
      app = MethodChannelFirebaseApp('testApp', options);
    });

    tearDown(() {
      TestFirebaseTokenHostApi.setUp(null);
    });

    group('getAuthIdToken', () {
      test('asks native for this app and returns its token', () async {
        native.authIdToken = 'id-token';

        expect(await app.getAuthIdToken(), 'id-token');
        expect(native.calls, ['getAuthIdToken(testApp)']);
      });

      test('returns null when native has nothing to give', () async {
        expect(await app.getAuthIdToken(), isNull);
      });

      test('surfaces a native failure as a core FirebaseException', () async {
        native.failure = PlatformException(
          code: 'auth-token-failed',
          message: 'A network error has occurred.',
        );

        await expectLater(
          app.getAuthIdToken(),
          throwsA(
            isA<FirebaseException>()
                .having((e) => e.plugin, 'plugin', 'core')
                .having((e) => e.code, 'code', 'auth-token-failed')
                .having(
                  (e) => e.message,
                  'message',
                  'A network error has occurred.',
                ),
          ),
        );
      });
    });

    group('getAppCheckToken', () {
      test('maps the native answer and defaults to a regular token', () async {
        native.appCheckToken = CoreAppCheckInteropToken(
          token: 'app-check-token',
        );

        expect(
          await app.getAppCheckToken(),
          const AppCheckInteropToken(token: 'app-check-token'),
        );
        expect(native.calls, ['getAppCheckToken(testApp, limitedUse: false)']);
      });

      test('passes limitedUse through', () async {
        native.appCheckToken = CoreAppCheckInteropToken(
          token: 'limited-use-token',
        );

        await app.getAppCheckToken(limitedUse: true);

        expect(native.calls, ['getAppCheckToken(testApp, limitedUse: true)']);
      });

      test('keeps the placeholder and the error together', () async {
        native.appCheckToken = CoreAppCheckInteropToken(
          token: 'placeholder',
          error: 'App Check is not activated.',
        );

        expect(
          await app.getAppCheckToken(),
          const AppCheckInteropToken(
            token: 'placeholder',
            error: 'App Check is not activated.',
          ),
        );
      });

      test('returns null when App Check is not linked', () async {
        expect(await app.getAppCheckToken(), isNull);
      });
    });

    group('getMessagingToken', () {
      test('asks native for this app and returns its token', () async {
        native.messagingToken = 'fcm-token';

        expect(await app.getMessagingToken(), 'fcm-token');
        expect(native.calls, ['getMessagingToken(testApp)']);
      });

      test('returns null when Messaging has nothing to give', () async {
        expect(await app.getMessagingToken(), isNull);
      });
    });
  });
}

/// Stands in for the native side of [FirebaseTokenHostApi].
class FakeFirebaseTokenHostApi implements TestFirebaseTokenHostApi {
  String? authIdToken;
  CoreAppCheckInteropToken? appCheckToken;
  String? messagingToken;

  /// Thrown by every call when set, the way native reports a failure.
  PlatformException? failure;

  final List<String> calls = [];

  @override
  Future<String?> getAuthIdToken(String appName) async {
    calls.add('getAuthIdToken($appName)');
    _failIfRequested();
    return authIdToken;
  }

  @override
  Future<CoreAppCheckInteropToken?> getAppCheckToken(
    String appName,
    bool limitedUse,
  ) async {
    calls.add('getAppCheckToken($appName, limitedUse: $limitedUse)');
    _failIfRequested();
    return appCheckToken;
  }

  @override
  Future<String?> getMessagingToken(String appName) async {
    calls.add('getMessagingToken($appName)');
    _failIfRequested();
    return messagingToken;
  }

  void _failIfRequested() {
    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }
  }
}
