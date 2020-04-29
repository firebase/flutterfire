// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$FirebaseMessagingPlatform()', () {
    test('$MethodChannelFirebaseMessaging is the default instance', () {
      expect(FirebaseMessagingPlatform.instance, isA<MethodChannelFirebaseMessaging>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        FirebaseMessagingPlatform.instance = ImplementsFirebaseMessagingPlatform();
      }, throwsAssertionError);
    });

    test('Can be extended', () {
      FirebaseMessagingPlatform.instance = ExtendsFirebaseMessagingPlatform();
    });

    test('Can be mocked with `implements`', () {
      final FirebaseMessagingPlatform mock = MocksFirebaseMessagingPlatform();
      FirebaseMessagingPlatform.instance = mock;
    });
  });
}

class ImplementsFirebaseMessagingPlatform extends Mock implements FirebaseMessagingPlatform {}

class MocksFirebaseMessagingPlatform extends Mock with MockPlatformInterfaceMixin implements FirebaseMessagingPlatform {
}

class ExtendsFirebaseMessagingPlatform extends FirebaseMessagingPlatform {}
