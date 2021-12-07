// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_performance_platform_interface/firebase_performance_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../mock.dart';

void main() {
  setupFirebasePerformanceMocks();

  late TestFirebasePerformancePlatform firebasePerformancePlatform;

  late FirebaseApp app;
  group('$FirebasePerformancePlatform()', () {
    setUpAll(() async {
      app = await Firebase.initializeApp();

      firebasePerformancePlatform = TestFirebasePerformancePlatform(
        app,
      );
    });

    test('Constructor', () {
      expect(firebasePerformancePlatform, isA<FirebasePerformancePlatform>());
      expect(firebasePerformancePlatform, isA<PlatformInterface>());
    });

    test('FirebasePerformancePlatform.instanceFor', () {
      final result = FirebasePerformancePlatform.instanceFor(
        app: app,
      );
      expect(result, isA<FirebasePerformancePlatform>());
    });

    test('get.instance', () {
      expect(
        FirebasePerformancePlatform.instance,
        isA<FirebasePerformancePlatform>(),
      );
      expect(
        FirebasePerformancePlatform.instance.app.name,
        equals(defaultFirebaseAppName),
      );
    });

    group('set.instance', () {
      test('sets the current instance', () {
        FirebasePerformancePlatform.instance =
            TestFirebasePerformancePlatform(app);

        expect(
          FirebasePerformancePlatform.instance,
          isA<FirebasePerformancePlatform>(),
        );
        expect(
          FirebasePerformancePlatform.instance.app.name,
          equals('[DEFAULT]'),
        );
      });
    });

    test('throws if .delegateFor', () {
      expect(
        // ignore: invalid_use_of_protected_member
        () => firebasePerformancePlatform.delegateFor(app: app),
        throwsUnimplementedError,
      );
    });

    test('throws if .delegateFor', () {
      expect(
        // ignore: invalid_use_of_protected_member
        () => firebasePerformancePlatform.delegateFor(app: app),
        throwsUnimplementedError,
      );
    });

    test('throws if .isPerformanceCollectionEnabled', () {
      expect(
        firebasePerformancePlatform.isPerformanceCollectionEnabled,
        throwsUnimplementedError,
      );
    });

    test('throws if .setPerformanceCollectionEnabled', () {
      expect(
        () => firebasePerformancePlatform.setPerformanceCollectionEnabled(true),
        throwsUnimplementedError,
      );
    });

    test('throws if .newTrace', () {
      expect(
        () => firebasePerformancePlatform.newTrace('name'),
        throwsUnimplementedError,
      );
    });

    test('throws if .newHttpMetric', () {
      expect(
        () => firebasePerformancePlatform.newHttpMetric('url', HttpMethod.Get),
        throwsUnimplementedError,
      );
    });
  });
}

class TestFirebasePerformancePlatform extends FirebasePerformancePlatform {
  TestFirebasePerformancePlatform(FirebaseApp app) : super(appInstance: app);
}
