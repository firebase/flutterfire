// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$FirebaseOptions', () {
    test('should return true if instances are the same', () {
      const options1 = FirebaseOptions(
        apiKey: 'apiKey',
        appId: 'appId',
        messagingSenderId: 'messagingSenderId',
        projectId: 'projectId',
      );

      const options2 = FirebaseOptions(
        apiKey: 'apiKey',
        appId: 'appId',
        messagingSenderId: 'messagingSenderId',
        projectId: 'projectId',
      );

      expect(options1 == options2, isTrue);
      expect(options1.hashCode, options2.hashCode);
    });

    test('should not return equal if instances are the different', () {
      const options1 = FirebaseOptions(
        apiKey: 'apiKey',
        appId: 'appId',
        messagingSenderId: 'messagingSenderId',
        projectId: 'projectId',
      );

      const options2 = FirebaseOptions(
        apiKey: 'apiKey2',
        appId: 'appId2',
        messagingSenderId: 'messagingSenderId2',
        projectId: 'projectId2',
      );

      expect(options1 == options2, isFalse);
    });

    test('should construct an instance from a Map', () {
      FirebaseOptions options1 = FirebaseOptions.fromPigeon(
        CoreFirebaseOptions(
          apiKey: 'apiKey',
          appId: 'appId',
          messagingSenderId: 'messagingSenderId',
          projectId: 'projectId',
        ),
      );

      FirebaseOptions options2 = const FirebaseOptions(
        apiKey: 'apiKey',
        appId: 'appId',
        messagingSenderId: 'messagingSenderId',
        projectId: 'projectId',
      );

      expect(options1 == options2, isTrue);
    });

    test('should copyWith new values', () {
      const options = FirebaseOptions(
        apiKey: 'apiKey',
        appId: 'appId',
        messagingSenderId: 'messagingSenderId',
        projectId: 'projectId',
      );

      final newOptions = options.copyWith(
        apiKey: 'newApiKey',
        appId: 'newAppId',
        messagingSenderId: 'newMessagingSenderId',
        projectId: 'newProjectId',
        authDomain: 'newAuthDomain',
        databaseURL: 'newDatabaseURL',
        storageBucket: 'newStorageBucket',
        measurementId: 'newMeasurementId',
        trackingId: 'newTrackingId',
        deepLinkURLScheme: 'newDeepLinkURLScheme',
        androidClientId: 'newAndroidClientId',
        iosClientId: 'newIosClientId',
        iosBundleId: 'newIosBundleId',
        appGroupId: 'newAppGroupId',
      );

      expect(
        newOptions,
        const FirebaseOptions(
          apiKey: 'newApiKey',
          appId: 'newAppId',
          messagingSenderId: 'newMessagingSenderId',
          projectId: 'newProjectId',
          authDomain: 'newAuthDomain',
          databaseURL: 'newDatabaseURL',
          storageBucket: 'newStorageBucket',
          measurementId: 'newMeasurementId',
          trackingId: 'newTrackingId',
          deepLinkURLScheme: 'newDeepLinkURLScheme',
          androidClientId: 'newAndroidClientId',
          iosClientId: 'newIosClientId',
          iosBundleId: 'newIosBundleId',
          appGroupId: 'newAppGroupId',
        ),
      );
    });

    test('should return a Map', () {
      const options = FirebaseOptions(
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
        iosBundleId: 'iosBundleId',
        iosClientId: 'iosClientId',
        appGroupId: 'appGroupId',
      );

      expect(options.asMap, {
        'apiKey': 'apiKey',
        'appId': 'appId',
        'messagingSenderId': 'messagingSenderId',
        'projectId': 'projectId',
        'authDomain': 'authDomain',
        'databaseURL': 'databaseURL',
        'storageBucket': 'storageBucket',
        'measurementId': 'measurementId',
        'trackingId': 'trackingId',
        'deepLinkURLScheme': 'deepLinkURLScheme',
        'androidClientId': 'androidClientId',
        'iosBundleId': 'iosBundleId',
        'iosClientId': 'iosClientId',
        'appGroupId': 'appGroupId',
      });
    });
  });
}
