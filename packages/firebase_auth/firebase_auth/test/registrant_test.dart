// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_auth/src/registrant.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show AuthTokenProvider;
import 'package:flutter_test/flutter_test.dart';

import './mock.dart';

void main() {
  setupFirebaseAuthMocks();

  late _FakeFirebaseAuthPlatform platform;
  var appCount = 0;

  setUpAll(() async {
    await Firebase.initializeApp();
    FirebaseAuthRegistrant.registerWith();
  });

  setUp(
    () =>
        FirebaseAuthPlatform.instance = platform = _FakeFirebaseAuthPlatform(),
  );

  Future<FirebaseApp> newApp() => Firebase.initializeApp(
    name: 'token-provider-${appCount++}',
    options: const FirebaseOptions(
      apiKey: '',
      appId: '',
      messagingSenderId: '',
      projectId: '',
    ),
  );

  group('$FirebaseAuthRegistrant', () {
    test(
      'registers an AuthTokenProvider before the app uses FirebaseAuth',
      () async {
        final app = await newApp();

        final provider = app.getService<AuthTokenProvider>();

        expect(provider, isA<FirebaseAuthTokenProvider>());
        expect(app.getService<AuthTokenProvider>(), same(provider));
      },
    );
  });

  group('$FirebaseAuthTokenProvider', () {
    test('is null when nobody is signed in', () async {
      final app = await newApp();

      expect(await FirebaseAuthTokenProvider(app).getIdToken(), isNull);
    });

    test("is the signed-in user's ID token", () async {
      final app = await newApp();
      platform.user = _FakeUserPlatform(platform, token: 'id-token');

      expect(await FirebaseAuthTokenProvider(app).getIdToken(), 'id-token');
      expect(platform.user!.forceRefreshRequests, [false]);
    });

    test('passes forceRefresh through', () async {
      final app = await newApp();
      platform.user = _FakeUserPlatform(platform, token: 'fresh-token');

      final token = await FirebaseAuthTokenProvider(
        app,
      ).getIdToken(forceRefresh: true);

      expect(token, 'fresh-token');
      expect(platform.user!.forceRefreshRequests, [true]);
    });

    test("propagates Auth's exception", () async {
      final app = await newApp();
      platform.user = _FakeUserPlatform(
        platform,
        error: FirebaseAuthException(code: 'network-request-failed'),
      );

      await expectLater(
        FirebaseAuthTokenProvider(app).getIdToken(),
        throwsA(
          isA<FirebaseAuthException>().having(
            (e) => e.code,
            'code',
            'network-request-failed',
          ),
        ),
      );
    });
  });
}

class _FakeFirebaseAuthPlatform extends FirebaseAuthPlatform {
  _FakeFirebaseAuthPlatform() : super();

  _FakeUserPlatform? user;

  @override
  FirebaseAuthPlatform delegateFor({
    FirebaseApp? app,
    Persistence? persistence,
  }) => this;

  @override
  FirebaseAuthPlatform setInitialValues({
    InternalUserDetails? currentUser,
    String? languageCode,
  }) => this;

  @override
  UserPlatform? get currentUser => user;
}

class _FakeUserPlatform extends UserPlatform {
  _FakeUserPlatform(FirebaseAuthPlatform auth, {this.token, this.error})
    : super(auth, _FakeMultiFactorPlatform(auth), _details);

  final String? token;
  final Object? error;
  final List<bool> forceRefreshRequests = [];

  @override
  Future<String?> getIdToken(bool forceRefresh) async {
    forceRefreshRequests.add(forceRefresh);
    if (error case final error?) {
      throw error;
    }
    return token;
  }
}

class _FakeMultiFactorPlatform extends MultiFactorPlatform {
  _FakeMultiFactorPlatform(super.auth);
}

final _details = InternalUserDetails(
  userInfo: InternalUserInfo(
    uid: 'uid',
    isAnonymous: true,
    isEmailVerified: false,
  ),
  providerData: const [],
);
