// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_app_check/src/registrant.dart';
import 'package:firebase_app_check_platform_interface/firebase_app_check_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show AppCheckInteropToken, AppCheckTokenProvider;
import 'package:flutter_test/flutter_test.dart';

import './mock.dart';

void main() {
  setupFirebaseAppCheckMocks();

  late _FakeFirebaseAppCheckPlatform platform;
  var appCount = 0;

  setUpAll(() async {
    await Firebase.initializeApp();
    FirebaseAppCheckRegistrant.registerWith();
  });

  setUp(
    () => FirebaseAppCheckPlatform.instance = platform =
        _FakeFirebaseAppCheckPlatform(),
  );

  Future<FirebaseApp> newApp() => Firebase.initializeApp(
    name: 'token-provider-${appCount++}',
    options: const FirebaseOptions(
      appId: '1:1234567890:ios:42424242424242',
      apiKey: '123',
      projectId: '123',
      messagingSenderId: '1234567890',
    ),
  );

  group('$FirebaseAppCheckRegistrant', () {
    test(
      'registers an AppCheckTokenProvider before the app uses App Check',
      () async {
        final app = await newApp();

        final provider = app.getService<AppCheckTokenProvider>();

        expect(provider, isA<FirebaseAppCheckTokenProvider>());
        expect(app.getService<AppCheckTokenProvider>(), same(provider));
        expect(platform.requests, isEmpty);
      },
    );
  });

  group('$FirebaseAppCheckTokenProvider', () {
    test('is the App Check token', () async {
      final app = await newApp();
      platform.token = 'app-check-token';

      final answer = await FirebaseAppCheckTokenProvider(app).getToken();

      expect(answer, const AppCheckInteropToken(token: 'app-check-token'));
      expect(platform.requests, ['getToken(false)']);
    });

    test('is null when App Check has no token', () async {
      final app = await newApp();

      expect(await FirebaseAppCheckTokenProvider(app).getToken(), isNull);
    });

    test('asks for a limited-use token with limitedUse', () async {
      final app = await newApp();
      platform.limitedUseToken = 'limited-use-token';

      final answer = await FirebaseAppCheckTokenProvider(
        app,
      ).getToken(limitedUse: true);

      expect(answer, const AppCheckInteropToken(token: 'limited-use-token'));
      expect(platform.requests, ['getLimitedUseToken()']);
    });

    test(
      'answers with the placeholder and the reason before activate()',
      () async {
        final app = await newApp();
        platform.error = FirebaseException(
          plugin: 'firebase_app_check',
          code: 'no-provider',
          message: 'No AppCheckProvider installed.',
        );

        final answer = await FirebaseAppCheckTokenProvider(app).getToken();

        expect(
          answer,
          const AppCheckInteropToken.failure('No AppCheckProvider installed.'),
        );
        expect(answer!.token, AppCheckInteropToken.placeholderToken);
      },
    );

    test('describes a failure without a message by its code', () async {
      final app = await newApp();
      platform.error = FirebaseException(
        plugin: 'firebase_app_check',
        code: 'unknown',
      );

      final answer = await FirebaseAppCheckTokenProvider(
        app,
      ).getToken(limitedUse: true);

      expect(answer, const AppCheckInteropToken.failure('unknown'));
    });

    test('describes any other error by its string', () async {
      final app = await newApp();
      platform.error = StateError('not activated');

      final answer = await FirebaseAppCheckTokenProvider(app).getToken();

      expect(
        answer,
        const AppCheckInteropToken.failure('Bad state: not activated'),
      );
    });
  });
}

class _FakeFirebaseAppCheckPlatform extends FirebaseAppCheckPlatform {
  _FakeFirebaseAppCheckPlatform() : super();

  String? token;
  String limitedUseToken = '';
  Object? error;
  final List<String> requests = [];

  @override
  FirebaseAppCheckPlatform delegateFor({required FirebaseApp app}) => this;

  @override
  FirebaseAppCheckPlatform setInitialValues() => this;

  @override
  Future<String?> getToken(bool forceRefresh) async {
    requests.add('getToken($forceRefresh)');
    if (error case final error?) {
      throw error;
    }
    return token;
  }

  @override
  Future<String> getLimitedUseToken() async {
    requests.add('getLimitedUseToken()');
    if (error case final error?) {
      throw error;
    }
    return limitedUseToken;
  }
}
