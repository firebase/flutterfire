// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$FirebaseAuthPlatform', () {
    test('$MethodChannelFirebaseAuth is the default instance', () {
      expect(FirebaseAuthPlatform.instance, isA<MethodChannelFirebaseAuth>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        FirebaseAuthPlatform.instance = ImplementsFirebaseAuthPlatform();
      }, throwsNoSuchMethodError);
    });

    test('Can be extended', () {
      FirebaseAuthPlatform.instance = ExtendsFirebaseAuthPlatform();
    });

    test('Can be mocked with `implements`', () {
      final MockFirebaseAuthPlatform mock = MockFirebaseAuthPlatform();
      FirebaseAuthPlatform.instance = mock;
    });
  });
}

class ImplementsFirebaseAuthPlatform implements FirebaseAuthPlatform {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockFirebaseAuthPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FirebaseAuthPlatform {}

class ExtendsFirebaseAuthPlatform extends FirebaseAuthPlatform {}
