// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CoreFirebaseOptions.toFirebaseOptions', () {
    test('copies every field', () {
      final options = CoreFirebaseOptions(
        apiKey: 'apiKey',
        appId: 'appId',
        messagingSenderId: 'messagingSenderId',
        projectId: 'projectId',
        authDomain: 'authDomain',
        databaseURL: 'databaseURL',
        storageBucket: 'storageBucket',
        measurementId: 'measurementId',
        trackingId: 'trackingId',
        deepLinkURLScheme: 'deepLinkURLScheme',
        androidClientId: 'androidClientId',
        iosClientId: 'iosClientId',
        iosBundleId: 'iosBundleId',
        appGroupId: 'appGroupId',
      ).toFirebaseOptions();

      expect(
        options,
        const FirebaseOptions(
          apiKey: 'apiKey',
          appId: 'appId',
          messagingSenderId: 'messagingSenderId',
          projectId: 'projectId',
          authDomain: 'authDomain',
          databaseURL: 'databaseURL',
          storageBucket: 'storageBucket',
          measurementId: 'measurementId',
          trackingId: 'trackingId',
          deepLinkURLScheme: 'deepLinkURLScheme',
          androidClientId: 'androidClientId',
          iosClientId: 'iosClientId',
          iosBundleId: 'iosBundleId',
          appGroupId: 'appGroupId',
        ),
      );
      // Same placeholder as the removed `FirebaseOptions.fromPigeon`.
      expect(options.recaptchaSiteKey, '');
    });

    test('keeps optional fields null', () {
      final options = CoreFirebaseOptions(
        apiKey: 'apiKey',
        appId: 'appId',
        messagingSenderId: 'messagingSenderId',
        projectId: 'projectId',
      ).toFirebaseOptions();

      expect(
        options,
        const FirebaseOptions(
          apiKey: 'apiKey',
          appId: 'appId',
          messagingSenderId: 'messagingSenderId',
          projectId: 'projectId',
        ),
      );
      expect(options.authDomain, isNull);
    });
  });
}
