// ignore_for_file: require_trailing_commas
// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
@TestOn('chrome')
import 'package:firebase_remote_config_platform_interface/firebase_remote_config_platform_interface.dart';
import 'package:firebase_remote_config_web/firebase_remote_config_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockRemoteConfig extends Mock implements FirebaseRemoteConfigWeb {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('$FirebaseRemoteConfigWeb', () {
    late MockRemoteConfig remoteConfig;

    setUp(() {
      remoteConfig = MockRemoteConfig();
    });

    test('setInitialValues', () {
      final remoteConfigValues = <dynamic, dynamic>{'a': 'b'};
      remoteConfig.setInitialValues(remoteConfigValues: remoteConfigValues);
      verify(remoteConfig.setInitialValues(
          remoteConfigValues: remoteConfigValues));
      verifyNoMoreInteractions(remoteConfig);
    });

    test('activate', () {
      remoteConfig.activate();
      verify(remoteConfig.activate());
      verifyNoMoreInteractions(remoteConfig);
    });

    test('ensureInitialized', () {
      remoteConfig.ensureInitialized();
      verify(remoteConfig.ensureInitialized());
      verifyNoMoreInteractions(remoteConfig);
    });

    test('fetch', () {
      remoteConfig.fetch();
      verify(remoteConfig.fetch());
      verifyNoMoreInteractions(remoteConfig);
    });

    test('fetchAndActivate', () {
      remoteConfig.fetchAndActivate();
      verify(remoteConfig.fetchAndActivate());
      verifyNoMoreInteractions(remoteConfig);
    });

    test('getAll', () {
      remoteConfig.getAll();
      verify(remoteConfig.getAll());
      verifyNoMoreInteractions(remoteConfig);
    });

    test('getBool', () {
      String key = 'key';
      remoteConfig.getBool(key);
      verify(remoteConfig.getBool(key));
      verifyNoMoreInteractions(remoteConfig);
    });

    test('getInt', () {
      String key = 'key';
      remoteConfig.getInt(key);
      verify(remoteConfig.getInt(key));
      verifyNoMoreInteractions(remoteConfig);
    });

    test('getDouble', () {
      String key = 'key';
      remoteConfig.getDouble(key);
      verify(remoteConfig.getDouble(key));
      verifyNoMoreInteractions(remoteConfig);
    });

    test('getString', () {
      String key = 'key';
      remoteConfig.getString(key);
      verify(remoteConfig.getString(key));
      verifyNoMoreInteractions(remoteConfig);
    });

    test('getValue', () {
      String key = 'key';
      remoteConfig.getValue(key);
      verify(remoteConfig.getValue(key));
      verifyNoMoreInteractions(remoteConfig);
    });

    test('setConfigSettings', () {
      const time = Duration(milliseconds: 1000);
      RemoteConfigSettings settings =
          RemoteConfigSettings(fetchTimeout: time, minimumFetchInterval: time);
      remoteConfig.setConfigSettings(settings);
      verify(remoteConfig.setConfigSettings(settings));
      verifyNoMoreInteractions(remoteConfig);
    });

    test('setDefaults', () {
      final parameters = <String, dynamic>{'a': 'b'};
      remoteConfig.setDefaults(parameters);
      verify(remoteConfig.setDefaults(parameters));
      verifyNoMoreInteractions(remoteConfig);
    });
  });
}
