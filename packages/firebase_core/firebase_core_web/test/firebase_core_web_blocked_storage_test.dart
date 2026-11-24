// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:flutter_test/flutter_test.dart';

@JS('eval')
external JSAny? _eval(String code);

/// Makes `window.sessionStorage` and `window.localStorage` throw like they do
/// when the user has blocked site data for the origin.
void _blockWebStorage() {
  _eval(r'''
    window.__savedWebStorage = {};
    for (const name of ['sessionStorage', 'localStorage']) {
      window.__savedWebStorage[name] =
        Object.getOwnPropertyDescriptor(window, name);
      Object.defineProperty(window, name, {
        configurable: true,
        get() {
          throw new DOMException(
            `Failed to read the '${name}' property from 'Window': ` +
              'Access is denied for this document.',
            'SecurityError',
          );
        },
      });
    }
  ''');
}

void _restoreWebStorage() {
  _eval('''
    for (const [name, descriptor] of Object.entries(window.__savedWebStorage)) {
      Object.defineProperty(window, name, descriptor);
    }
    delete window.__savedWebStorage;
  ''');
}

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

void main() {
  group('FirebaseCoreWeb with web storage blocked', () {
    setUp(() {
      FirebasePlatform.instance = FirebaseCoreWeb();
      _blockWebStorage();
    });

    tearDown(_restoreWebStorage);

    test(
      'initializeApp succeeds and still registers library versions',
      () async {
        const options = FirebaseOptions(
          apiKey: 'fake-api-key',
          appId: '1:1234567890:web:fake',
          messagingSenderId: '1234567890',
          projectId: 'fake-project',
        );

        await FirebasePlatform.instance.initializeApp(options: options);
        expect(_getPlatformInfoString(), contains('flutter-fire-core/'));

        FirebaseCoreWeb.registerLibraryVersion('flutter-fire-blocked', '1.0.0');
        expect(
          _getPlatformInfoString(),
          contains('flutter-fire-blocked/1.0.0'),
        );
      },
    );
  });
}
