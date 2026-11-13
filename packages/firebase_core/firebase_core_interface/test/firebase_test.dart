// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core_interface/firebase_core_interface.dart';
import 'package:test/test.dart';

/// A pure-Dart implementation, as `firebase_core_js` provides on the web.
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
    return _apps[appName] = FirebaseAppPlatform(appName, options!);
  }

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return _apps[name] ?? (throw noAppExists(name));
  }
}

class _Service implements FirebaseService {}

const _options = FirebaseOptions(
  apiKey: 'apiKey',
  appId: '1:1:web:1',
  messagingSenderId: '1',
  projectId: 'project',
);

void main() {
  setUpAll(() => FirebasePlatform.instance = _FakeFirebasePlatform());

  test('Firebase works without Flutter', () async {
    final app = await Firebase.initializeApp(options: _options);

    expect(app.name, defaultFirebaseAppName);
    expect(app.options, _options);
    expect(Firebase.app(), app);
    expect(Firebase.apps, [app]);

    final service = _Service();
    app.registerService(service);
    expect(app.getService<_Service>(), same(service));
  });

  test('demoProjectId names the platform in the app ID', () async {
    final app = await Firebase.initializeApp(demoProjectId: 'demo-test');

    expect(app.name, 'demo-test');
    expect(app.options.projectId, 'demo-test');
    expect(app.options.appId, matches(RegExp(r'^1:1:(android|ios|web):1$')));
  });

  test('demoProjectId uses web in the browser', () async {
    final app = await Firebase.initializeApp(demoProjectId: 'demo-web');

    expect(app.options.appId, '1:1:web:1');
  }, testOn: 'browser');
}
