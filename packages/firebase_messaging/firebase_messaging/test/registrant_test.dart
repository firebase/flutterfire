// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show MessagingTokenProvider;
import 'package:firebase_messaging/src/registrant.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import './mock.dart';

void main() {
  setupFirebaseMessagingMocks();

  late _FakeFirebaseMessagingPlatform platform;
  late FirebaseApp defaultApp;
  var appCount = 0;

  setUpAll(() async {
    defaultApp = await Firebase.initializeApp();
    FirebaseMessagingRegistrant.registerWith();
  });

  setUp(
    () => FirebaseMessagingPlatform.instance = platform =
        _FakeFirebaseMessagingPlatform(),
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

  group('$FirebaseMessagingRegistrant', () {
    test(
      'registers a MessagingTokenProvider before the app uses Messaging',
      () async {
        final provider = defaultApp.getService<MessagingTokenProvider>();

        expect(provider, isA<FirebaseMessagingTokenProvider>());
        expect(defaultApp.getService<MessagingTokenProvider>(), same(provider));
        expect(platform.reads, 0);
      },
    );
  });

  group('$FirebaseMessagingTokenProvider', () {
    test('is null when nothing is cached', () async {
      expect(
        await FirebaseMessagingTokenProvider(defaultApp).getFcmToken(),
        isNull,
      );
      expect(platform.reads, 1);
    });

    test('is the cached token', () async {
      platform.token = 'fcm-token';

      expect(
        await FirebaseMessagingTokenProvider(defaultApp).getFcmToken(),
        'fcm-token',
      );
    });

    test('is null for an app other than the default, without asking', () async {
      final app = await newApp();
      platform.token = 'fcm-token';

      expect(await FirebaseMessagingTokenProvider(app).getFcmToken(), isNull);
      expect(platform.reads, 0);
    });

    test("is null when the token can't be read", () async {
      platform.error = FirebaseException(
        plugin: 'firebase_messaging',
        code: 'unknown',
        message: 'SERVICE_NOT_AVAILABLE',
      );

      expect(
        await FirebaseMessagingTokenProvider(defaultApp).getFcmToken(),
        isNull,
      );
    });
  });
}

class _FakeFirebaseMessagingPlatform extends FirebaseMessagingPlatform {
  _FakeFirebaseMessagingPlatform() : super();

  String? token;
  Object? error;
  int reads = 0;

  @override
  FirebaseMessagingPlatform delegateFor({required FirebaseApp app}) => this;

  @override
  FirebaseMessagingPlatform setInitialValues({bool? isAutoInitEnabled}) => this;

  @override
  Future<String?> getCachedToken() async {
    reads++;
    if (error case final error?) {
      throw error;
    }
    return token;
  }
}
