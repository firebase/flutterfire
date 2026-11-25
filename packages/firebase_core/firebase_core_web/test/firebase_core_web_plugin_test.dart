// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('browser')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:flutter_test/flutter_test.dart';
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

void main() {
  // The version is only registered once per session storage key.
  setUp(() => web.window.sessionStorage.clear());

  test(
    'registerWith registers FirebaseCoreWeb and the flutter-fire-core version',
    () async {
      FirebaseCoreWebPlugin.registerWith(null);
      expect(FirebasePlatform.instance, isA<FirebaseCoreWeb>());

      await FirebasePlatform.instance.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'fake-api-key',
          appId: '1:1234567890:web:fake',
          messagingSenderId: '1234567890',
          projectId: 'fake-project',
        ),
      );

      expect(
        _getPlatformInfoString(),
        // The version itself is checked in `firebase_core_js`.
        contains('flutter-fire-core/'),
      );
    },
  );
}
