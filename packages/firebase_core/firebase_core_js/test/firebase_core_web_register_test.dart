// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_core_interface/firebase_core_interface.dart'
    as core
    show Firebase;
import 'package:firebase_core_interface/firebase_core_interface.dart'
    show FirebaseAppPlatform, FirebasePlatform;
import 'package:firebase_core_js/firebase_core_js.dart';
import 'package:firebase_core_js/src/firebase_core_version.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

String _getPlatformInfoString() {
  final core = globalContext.getProperty<JSObject>('firebase_core'.toJS);
  final jsApp = core.callMethod<JSObject>('getApp'.toJS);
  final container = jsApp.getProperty<JSObject>('container'.toJS);
  final provider = container.callMethod<JSObject>(
    'getProvider'.toJS,
    'platform-logger'.toJS,
  );
  final logger = provider.callMethod<JSObject>('getImmediate'.toJS);
  return logger.callMethod<JSString>('getPlatformInfoString'.toJS).toDart;
}

class _FakeFirebase extends FirebasePlatform {
  @override
  List<FirebaseAppPlatform> get apps => [];
}

const _options = FirebaseOptions(
  apiKey: 'fake-api-key',
  appId: '1:1234567890:web:fake',
  messagingSenderId: '1234567890',
  projectId: 'fake-project',
);

void main() {
  // The version is only registered once per session storage key.
  setUp(() => web.window.sessionStorage.clear());

  // First, before anything registers an implementation.
  test(
    'Firebase.initializeApp uses FirebaseCoreWeb without registerWith',
    () async {
      final app = await Firebase.initializeApp(options: _options);

      expect(app.name, defaultFirebaseAppName);
      expect(FirebasePlatform.instance, isA<FirebaseCoreWeb>());
    },
  );

  test('registerWith registers FirebaseCoreWeb without a registrar', () {
    FirebaseCoreWeb.registerWith();

    expect(FirebasePlatform.instance, isA<FirebaseCoreWeb>());
  });

  test(
    'initializeApp reports the flutter-fire-core version after registerWith',
    () async {
      FirebaseCoreWeb.registerWith();

      await FirebasePlatform.instance.initializeApp(options: _options);

      expect(
        _getPlatformInfoString(),
        contains('flutter-fire-core/$packageVersion'),
      );
    },
  );

  test('initializeApp reports the flutter-fire-core version when the JS SDK is '
      'already loaded and FirebaseCoreWeb was set directly', () async {
    // Loaded by the previous test.
    expect(globalContext.getProperty('firebase_core'.toJS), isNotNull);
    FirebasePlatform.instance = FirebaseCoreWeb();

    await FirebasePlatform.instance.initializeApp(
      name: 'preloaded',
      options: _options,
    );

    expect(
      web.window.sessionStorage.getItem(
        'flutterfire-flutter-fire-core-$packageVersion',
      ),
      packageVersion,
    );
  });

  test('Firebase uses a FirebasePlatform that was set directly', () {
    final fake = _FakeFirebase();
    FirebasePlatform.instance = fake;
    // `Firebase` caches the platform it used in the first test.
    core.Firebase.delegatePackingProperty = null;

    expect(Firebase.apps, isEmpty);
    expect(core.Firebase.delegatePackingProperty, same(fake));
  });
}
