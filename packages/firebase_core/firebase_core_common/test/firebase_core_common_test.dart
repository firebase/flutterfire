// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core_common/firebase_core_common.dart';
import 'package:test/test.dart';

const FirebaseOptions _options = FirebaseOptions(
  apiKey: 'api-key',
  appId: 'app-id',
  messagingSenderId: 'sender-id',
  projectId: 'project-id',
);

void main() {
  group('$FirebasePlatform', () {
    test('is not registered by default', () {
      expect(FirebasePlatform.isRegistered, isFalse);
    });

    test('throws until an implementation is registered', () {
      expect(
        () => FirebasePlatform.instance,
        throwsA(
          isA<FirebaseException>().having(
            (error) => error.code,
            'code',
            'no-platform-implementation',
          ),
        ),
      );
    });

    test('can be set to a platform implementation', () {
      FirebasePlatform.instance = _TestFirebasePlatform();

      expect(FirebasePlatform.isRegistered, isTrue);
      expect(FirebasePlatform.instance, isA<_TestFirebasePlatform>());
    });
  });

  group('$FirebaseApp', () {
    test('can be created from a platform delegate', () {
      final FirebaseApp app = FirebaseApp.fromPlatform(_TestFirebaseApp());

      expect(app.name, defaultFirebaseAppName);
      expect(app.options, _options);
      expect(app.toString(), contains(defaultFirebaseAppName));

      // The delegate is verified when the app is created, so a platform
      // implementation which does not extend `FirebaseAppPlatform` is rejected.
      expect(
        () => FirebaseApp.fromPlatform(_FakeFirebaseApp()),
        throwsA(anything),
      );
    });
  });

  group('$FirebaseException', () {
    test('exposes its plugin, code and message', () {
      final FirebaseException exception = FirebaseException(
        plugin: 'core',
        code: 'no-app',
        message: 'no app',
      );

      expect(exception.code, 'no-app');
      expect(exception.toString(), contains('no app'));
    });
  });
}

class _TestFirebasePlatform extends FirebasePlatform {}

class _TestFirebaseApp extends FirebaseAppPlatform {
  _TestFirebaseApp() : super(defaultFirebaseAppName, _options);
}

// `FirebaseAppPlatform` overrides `==`, which is exactly why implementing it
// (instead of extending it) is rejected when a [FirebaseApp] is created.
// ignore: avoid_implementing_value_types
class _FakeFirebaseApp implements FirebaseAppPlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
