// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$FirebasePlatform', () {
    // should allow read of default app from native
    test('$MethodChannelFirebase is the default instance', () {
      expect(FirebasePlatform.instance, isA<MethodChannelFirebase>());
    });

    test('Can be extended', () {
      FirebasePlatform.instance = ExtendsFirebasePlatform();
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        FirebasePlatform.instance = ImplementsFirebasePlatform();
      }, throwsNoSuchMethodError);
    });

    test('Can be mocked with `implements`', () {
      final FirebaseCoreMockPlatform mock = FirebaseCoreMockPlatform();
      FirebasePlatform.instance = mock;
    });
  });
}

class ImplementsFirebasePlatform implements FirebasePlatform {
  @override
  Future<FirebaseAppPlatform> initializeApp(
          {String name, FirebaseOptions options}) =>
      null;

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return null;
  }

  @override
  List<FirebaseAppPlatform> get apps => null;
}

class ExtendsFirebasePlatform extends FirebasePlatform {}

class FirebaseCoreMockPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FirebasePlatform {}
