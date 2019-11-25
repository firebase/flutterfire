// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$FirebaseAuthPlatform', () {
    test('$MethodChannelFirebaseAuth is the default instance', () {
      expect(FirebaseAuthPlatform.instance, isA<MethodChannelFirebaseAuth>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        FirebaseAuthPlatform.instance = ImplementsFirebaseAuthPlatform();
      }, throwsAssertionError);
    });

    test('Can be extended', () {
      FirebaseAuthPlatform.instance = ExtendsFirebaseAuthPlatform();
    });

    test('Can be mocked with `implements`', () {
      final ImplementsFirebaseAuthPlatform mock =
          ImplementsFirebaseAuthPlatform();
      when(mock.isMock).thenReturn(true);
      FirebaseAuthPlatform.instance = mock;
    });
  });
}

class ImplementsFirebaseAuthPlatform extends Mock
    implements FirebaseAuthPlatform {}

class ExtendsFirebaseAuthPlatform extends FirebaseAuthPlatform {}
