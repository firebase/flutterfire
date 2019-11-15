// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('$FirebaseCorePlatform', () {
    test('$MethodChannelFirebaseCore is the default instance', () {
      expect(FirebaseCorePlatform.instance, isA<MethodChannelFirebaseCore>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        FirebaseCorePlatform.instance = ImplementsFirebaseCorePlatform();
      }, throwsAssertionError);
    });

    test('Can be extended', () {
      FirebaseCorePlatform.instance = ExtendsFirebaseCorePlatform();
    });

    test('Can be mocked with `implements`', () {
      final ImplementsFirebaseCorePlatform mock =
          ImplementsFirebaseCorePlatform();
      when(mock.isMock).thenReturn(true);
      FirebaseCorePlatform.instance = mock;
    });
  });
}

class ImplementsFirebaseCorePlatform extends Mock
    implements FirebaseCorePlatform {}

class ExtendsFirebaseCorePlatform extends FirebaseCorePlatform {}
