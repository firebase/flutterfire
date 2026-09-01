// Copyright 2026, the Chromium project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Generated for CI builds and emulator tests. These are not real credentials.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => ios,
      TargetPlatform.macOS => macos,
      TargetPlatform.windows => windows,
      _ => throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        ),
    };
  }

  static const web = FirebaseOptions(
    apiKey: 'dummy-api-key',
    appId: '1:123456789012:web:0000000000000000000000',
    messagingSenderId: '123456789012',
    projectId: 'flutterfire-e2e-tests',
    authDomain: 'flutterfire-e2e-tests.firebaseapp.com',
    storageBucket: 'flutterfire-e2e-tests.appspot.com',
  );

  static const android = FirebaseOptions(
    apiKey: 'dummy-api-key',
    appId: '1:123456789012:android:0000000000000000000000',
    messagingSenderId: '123456789012',
    projectId: 'flutterfire-e2e-tests',
    storageBucket: 'flutterfire-e2e-tests.appspot.com',
  );

  static const ios = FirebaseOptions(
    apiKey: 'dummy-api-key',
    appId: '1:123456789012:ios:0000000000000000000000',
    messagingSenderId: '123456789012',
    projectId: 'flutterfire-e2e-tests',
    storageBucket: 'flutterfire-e2e-tests.appspot.com',
  );

  static const macos = ios;

  static const windows = FirebaseOptions(
    apiKey: 'dummy-api-key',
    appId: '1:123456789012:web:0000000000000000000000',
    messagingSenderId: '123456789012',
    projectId: 'flutterfire-e2e-tests',
    authDomain: 'flutterfire-e2e-tests.firebaseapp.com',
    storageBucket: 'flutterfire-e2e-tests.appspot.com',
  );
}
