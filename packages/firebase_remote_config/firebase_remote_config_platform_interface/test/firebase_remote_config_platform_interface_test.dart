// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_remote_config_platform_interface/firebase_remote_config_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$FirebaseRemoteConfigPlatform', () {
    test('$MethodChannelFirebaseRemoteConfig is the default instance', () {
      expect(FirebaseRemoteConfigPlatform.instance,
          isA<MethodChannelFirebaseRemoteConfig>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        FirebaseRemoteConfigPlatform.instance =
            ImplementsFirebaseRemoteConfigPlatform();
      }, throwsNoSuchMethodError);
    });

    test('Can be extended', () {
      FirebaseRemoteConfigPlatform.instance =
          ExtendsFirebaseRemoteConfigPlatform();
    });

    test('Can be mocked with `implements`', () {
      final MockFirebaseRemoteConfigPlatform mock =
          MockFirebaseRemoteConfigPlatform();
      FirebaseRemoteConfigPlatform.instance = mock;
    });
  });
}

class ImplementsFirebaseRemoteConfigPlatform
    implements FirebaseRemoteConfigPlatform {
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockFirebaseRemoteConfigPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FirebaseRemoteConfigPlatform {}

class ExtendsFirebaseRemoteConfigPlatform extends FirebaseRemoteConfigPlatform {
}
