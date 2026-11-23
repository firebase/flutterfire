// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core_interface/firebase_core_interface.dart';
import 'package:test/test.dart';

class _FakeFirebasePlatform extends FirebasePlatform {
  final Map<String, FirebaseAppPlatform> _apps = {};

  @override
  List<FirebaseAppPlatform> get apps => _apps.values.toList();

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    final appName = name ?? defaultFirebaseAppName;
    return _apps[appName] = _FakeFirebaseAppPlatform(appName, options!);
  }

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return _apps[name] ?? (throw noAppExists(name));
  }
}

class _FakeFirebaseAppPlatform extends FirebaseAppPlatform {
  _FakeFirebaseAppPlatform(super.name, super.options);

  @override
  Future<void> delete() async {}
}

// Each test registers its own service type: the factories are static.
class _Registered implements FirebaseService {}

class _Created implements FirebaseService {
  _Created(this.app);

  final FirebaseApp app;
}

class _Overridden implements FirebaseService {}

class _Disposable implements FirebaseService {}

class _PerApp implements FirebaseService {}

class _Unknown implements FirebaseService {}

class _AuthTokens implements AuthTokenProvider {
  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async => 'id-token';
}

const _options = FirebaseOptions(
  apiKey: 'apiKey',
  appId: '1:1:web:1',
  messagingSenderId: '1',
  projectId: 'project',
);

void main() {
  setUpAll(() => FirebasePlatform.instance = _FakeFirebasePlatform());

  group('FirebaseApp services', () {
    late FirebaseApp app;

    setUpAll(() async {
      app = await Firebase.initializeApp(name: 'services', options: _options);
    });

    test('getService returns a registered service', () {
      final service = _Registered();
      app.registerService(service);

      expect(app.getService<_Registered>(), same(service));
    });

    test('getService is null without a service or a factory', () {
      expect(app.getService<_Unknown>(), isNull);
    });

    test('getService creates from a factory once per app', () {
      var created = 0;
      registerFirebaseServiceFactory<_Created>((app) {
        created++;
        return _Created(app);
      });

      final service = app.getService<_Created>();

      expect(service, isNotNull);
      expect(service!.app, app);
      expect(app.getService<_Created>(), same(service));
      expect(created, 1);
    });

    test('a registered service takes precedence over a factory', () {
      final registered = _Overridden();
      registerFirebaseServiceFactory<_Overridden>((_) => _Overridden());
      app.registerService(registered);

      expect(app.getService<_Overridden>(), same(registered));
    });

    test('each app gets its own instance from a factory', () async {
      final other = await Firebase.initializeApp(
        name: 'services-other',
        options: _options,
      );
      registerFirebaseServiceFactory<_PerApp>((_) => _PerApp());

      expect(
        app.getService<_PerApp>(),
        isNot(same(other.getService<_PerApp>())),
      );
    });

    test('delete disposes a service created from a factory', () async {
      final deleted = await Firebase.initializeApp(
        name: 'services-deleted',
        options: _options,
      );
      _Disposable? disposed;
      registerFirebaseServiceFactory<_Disposable>(
        (_) => _Disposable(),
        dispose: (service) async => disposed = service,
      );
      final service = deleted.getService<_Disposable>();

      await deleted.delete();

      expect(disposed, same(service));
    });

    test('token providers are services', () {
      final tokens = _AuthTokens();
      app.registerService<AuthTokenProvider>(tokens);

      expect(app.getService<AuthTokenProvider>(), same(tokens));
    });
  });

  group('AppCheckInteropToken', () {
    test('failure carries the placeholder and the reason', () {
      const answer = AppCheckInteropToken.failure('not activated');

      expect(answer.token, AppCheckInteropToken.placeholderToken);
      expect(answer.error, 'not activated');
    });

    test('is a value', () {
      expect(
        const AppCheckInteropToken(token: 'token'),
        const AppCheckInteropToken(token: 'token'),
      );
      expect(
        const AppCheckInteropToken(token: 'token'),
        isNot(const AppCheckInteropToken.failure('error')),
      );
    });

    test('does not print the token', () {
      expect(
        const AppCheckInteropToken(token: 'secret').toString(),
        isNot(contains('secret')),
      );
    });
  });
}
