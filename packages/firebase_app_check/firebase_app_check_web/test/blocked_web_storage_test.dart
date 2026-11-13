// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:firebase_app_check_platform_interface/firebase_app_check_platform_interface.dart';
import 'package:firebase_app_check_web/firebase_app_check_web.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

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

void main() {
  group('FirebaseAppCheckWeb with web storage blocked', () {
    setUpAll(() {
      FirebasePlatform.instance = FirebaseCoreWeb();
      FirebaseAppCheckWeb.registerWith(webPluginRegistrar);
    });

    setUp(_blockWebStorage);

    tearDown(_restoreWebStorage);

    test('initializeApp with App Check succeeds', () async {
      const options = FirebaseOptions(
        apiKey: 'fake-api-key',
        appId: '1:1234567890:web:fake',
        messagingSenderId: '1234567890',
        projectId: 'fake-project',
      );

      await expectLater(
        FirebasePlatform.instance.initializeApp(options: options),
        completes,
      );
    });

    test('activate succeeds', () async {
      final appCheck = FirebaseAppCheckWeb(app: Firebase.app());

      await expectLater(
        appCheck.activate(
          providerWeb: WebDebugProvider(debugToken: 'fake-debug-token'),
        ),
        completes,
      );
    });
  });
}
