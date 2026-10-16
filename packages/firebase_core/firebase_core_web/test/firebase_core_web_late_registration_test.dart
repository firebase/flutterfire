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
  group('FirebaseCoreWeb late library version registration', () {
    setUp(() {
      FirebasePlatform.instance = FirebaseCoreWeb();
      web.window.sessionStorage.clear();
    });

    test(
      'registers library version with PlatformLogger when called after initializeApp',
      () async {
        const options = FirebaseOptions(
          apiKey: 'fake-api-key',
          appId: '1:1234567890:web:fake',
          messagingSenderId: '1234567890',
          projectId: 'fake-project',
          authDomain: 'fake-project.firebaseapp.com',
        );

        await FirebasePlatform.instance.initializeApp(options: options);

        final initialPlatformInfo = _getPlatformInfoString();
        expect(initialPlatformInfo, contains('flutter-fire-core/'));
        expect(
          initialPlatformInfo,
          isNot(contains('flutter-fire-late-test/1.2.3')),
        );

        FirebaseCoreWeb.registerLibraryVersion(
          'flutter-fire-late-test',
          '1.2.3',
        );

        expect(
          web.window.sessionStorage
              .getItem('flutterfire-flutter-fire-late-test-1.2.3'),
          '1.2.3',
        );
        expect(
          _getPlatformInfoString(),
          contains('flutter-fire-late-test/1.2.3'),
        );

        // Clearing sessionStorage allows re-registering a subsequent version.
        web.window.sessionStorage.clear();
        FirebaseCoreWeb.registerLibraryVersion(
          'flutter-fire-late-test-2',
          '2.0.0',
        );
        expect(
          web.window.sessionStorage
              .getItem('flutterfire-flutter-fire-late-test-2-2.0.0'),
          '2.0.0',
        );
        expect(
          _getPlatformInfoString(),
          contains('flutter-fire-late-test-2/2.0.0'),
        );
      },
    );
  });
}
