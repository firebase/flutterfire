// ignore_for_file: require_trailing_commas
// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
@TestOn('chrome')
import 'dart:js_interop';

import 'package:firebase_remote_config_platform_interface/firebase_remote_config_platform_interface.dart';
import 'package:firebase_remote_config_web/firebase_remote_config_web.dart';
import 'package:firebase_remote_config_web/src/interop/firebase_remote_config.dart'
    as remote_config_interop_wrapper;
import 'package:firebase_remote_config_web/src/interop/firebase_remote_config_interop.dart'
    as remote_config_interop;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<FirebaseRemoteConfigWeb>()])
import 'firebase_remote_config_web_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('$FirebaseRemoteConfigWeb', () {
    late MockFirebaseRemoteConfigWeb remoteConfig;

    setUp(() {
      remoteConfig = MockFirebaseRemoteConfigWeb();
    });

    test('setInitialValues', () {
      final remoteConfigValues = <dynamic, dynamic>{'a': 'b'};
      remoteConfig.setInitialValues(remoteConfigValues: remoteConfigValues);
      verify(
        remoteConfig.setInitialValues(remoteConfigValues: remoteConfigValues),
      );
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
      RemoteConfigSettings settings = RemoteConfigSettings(
        fetchTimeout: time,
        minimumFetchInterval: time,
      );
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

    test(
      'RemoteConfig.defaultConfig round-trips and returns unmodifiable Map',
      () {
        final jsRemoteConfig =
            JSObject() as remote_config_interop.RemoteConfigJsImpl;
        final wrapper = remote_config_interop_wrapper.RemoteConfig.getInstance(
          jsRemoteConfig,
        );

        wrapper.defaultConfig = <String, dynamic>{
          'title': 'Hello',
          'counter': 1,
        };
        final config = wrapper.defaultConfig;

        expect(config, isA<Map<String, dynamic>>());
        expect(
          config,
          equals(<String, dynamic>{'title': 'Hello', 'counter': 1}),
        );
        expect(() => config['x'] = 2, throwsUnsupportedError);
      },
    );
  });
}
