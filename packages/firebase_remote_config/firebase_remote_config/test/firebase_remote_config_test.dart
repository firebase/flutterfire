// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_remote_config_platform_interface/firebase_remote_config_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:mockito/mockito.dart';

import 'mock.dart';

MockFirebaseRemoteConfig mockRemoteConfigPlatform = MockFirebaseRemoteConfig();

void main() {
  setupFirebaseRemoteConfigMocks();

  RemoteConfig remoteConfig;

  DateTime mockLastFetchTime;
  RemoteConfigFetchStatus mockLastFetchStatus;
  RemoteConfigSettings mockRemoteConfigSettings;
  Map<String, RemoteConfigValue> mockParameters;
  Map<String, dynamic> mockDefaultParameters;
  RemoteConfigValue mockRemoteConfigValue;

  group('$RemoteConfig', () {
    FirebaseRemoteConfigPlatform.instance = mockRemoteConfigPlatform;

    setUpAll(() async {
      await Firebase.initializeApp();
      remoteConfig = RemoteConfig.instance;

      mockLastFetchTime = DateTime(2020);
      mockLastFetchStatus = RemoteConfigFetchStatus.noFetchYet;
      mockRemoteConfigSettings = RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      );
      mockParameters = <String, RemoteConfigValue>{};
      mockDefaultParameters = <String, dynamic>{};
      mockRemoteConfigValue = RemoteConfigValue(
        <int>[],
        ValueSource.valueStatic,
      );

      when(mockRemoteConfigPlatform.instanceFor(
              app: anyNamed('app'),
              pluginConstants: anyNamed('pluginConstants')))
          .thenAnswer((_) => mockRemoteConfigPlatform);

      when(mockRemoteConfigPlatform.delegateFor(
        app: anyNamed('app'),
      )).thenAnswer((_) => mockRemoteConfigPlatform);

      when(mockRemoteConfigPlatform.setInitialValues(
              remoteConfigValues: anyNamed('remoteConfigValues')))
          .thenAnswer((_) => mockRemoteConfigPlatform);

      when(mockRemoteConfigPlatform.lastFetchTime)
          .thenReturn(mockLastFetchTime);

      when(mockRemoteConfigPlatform.lastFetchStatus)
          .thenReturn(mockLastFetchStatus);

      when(mockRemoteConfigPlatform.settings)
          .thenReturn(mockRemoteConfigSettings);

      when(mockRemoteConfigPlatform.setConfigSettings(any))
          .thenAnswer((_) => null);

      when(mockRemoteConfigPlatform.activate())
          .thenAnswer((_) => Future.value(true));

      when(mockRemoteConfigPlatform.ensureInitialized())
          .thenAnswer((_) => Future.value());

      when(mockRemoteConfigPlatform.fetch()).thenAnswer((_) => Future.value());

      when(mockRemoteConfigPlatform.fetchAndActivate())
          .thenAnswer((_) => Future.value(true));

      when(mockRemoteConfigPlatform.getAll()).thenReturn(mockParameters);

      when(mockRemoteConfigPlatform.getBool('foo')).thenReturn(true);

      when(mockRemoteConfigPlatform.getInt('foo')).thenReturn(8);

      when(mockRemoteConfigPlatform.getDouble('foo')).thenReturn(8.8);

      when(mockRemoteConfigPlatform.getString('foo')).thenReturn('bar');

      when(mockRemoteConfigPlatform.getValue('foo'))
          .thenReturn(mockRemoteConfigValue);

      when(mockRemoteConfigPlatform.setDefaults(any))
          .thenAnswer((_) => Future.value());
    });

    test('doubleInstance', () async {
      final List<RemoteConfig> remoteConfigs = <RemoteConfig>[
        RemoteConfig.instance,
        RemoteConfig.instance,
      ];
      expect(remoteConfigs[0], remoteConfigs[1]);
    });

    group('lastFetchTime', () {
      test('get lastFetchTime', () {
        remoteConfig.lastFetchTime;
        verify(mockRemoteConfigPlatform.lastFetchTime);
      });
    });

    group('lastFetchStatus', () {
      test('get lastFetchStatus', () {
        remoteConfig.lastFetchStatus;
        verify(mockRemoteConfigPlatform.lastFetchStatus);
      });
    });

    group('settings', () {
      test('get settings', () {
        remoteConfig.settings;
        verify(mockRemoteConfigPlatform.settings);
      });

      test('set settings', () async {
        final remoteConfigSettings = RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 8),
          minimumFetchInterval: Duration.zero,
        );
        await remoteConfig.setConfigSettings(remoteConfigSettings);
        verify(
            mockRemoteConfigPlatform.setConfigSettings(remoteConfigSettings));
      });

      test('should throw if settings is null', () async {
        expect(
          () => remoteConfig.setConfigSettings(null),
          throwsAssertionError,
        );
      });
    });

    group('activate()', () {
      test('should call delegate method', () async {
        await remoteConfig.activate();
        verify(mockRemoteConfigPlatform.activate());
      });
    });

    group('ensureEnitialized()', () {
      test('should call delegate method', () async {
        await remoteConfig.ensureInitialized();
        verify(mockRemoteConfigPlatform.ensureInitialized());
      });
    });

    group('fetch()', () {
      test('should call delegate method', () async {
        await remoteConfig.fetch();
        verify(mockRemoteConfigPlatform.fetch());
      });
    });

    group('fetchAndActivate()', () {
      test('should call delegate method', () async {
        await remoteConfig.fetchAndActivate();
        verify(mockRemoteConfigPlatform.fetchAndActivate());
      });
    });

    group('getAll()', () {
      test('should call delegate method', () {
        remoteConfig.getAll();
        verify(mockRemoteConfigPlatform.getAll());
      });
    });

    group('getBool()', () {
      test('should call delegate method', () {
        remoteConfig.getBool('foo');
        verify(mockRemoteConfigPlatform.getBool('foo'));
      });

      test('should throw if key is null', () {
        expect(() => remoteConfig.getBool(null), throwsAssertionError);
      });
    });

    group('getInt()', () {
      test('should call delegate method', () {
        remoteConfig.getInt('foo');
        verify(mockRemoteConfigPlatform.getInt('foo'));
      });

      test('should throw if key is null', () {
        expect(() => remoteConfig.getInt(null), throwsAssertionError);
      });
    });

    group('getDouble()', () {
      test('should call delegate method', () {
        remoteConfig.getDouble('foo');
        verify(mockRemoteConfigPlatform.getDouble('foo'));
      });

      test('should throw if key is null', () {
        expect(() => remoteConfig.getDouble(null), throwsAssertionError);
      });
    });

    group('getString()', () {
      test('should call delegate method', () {
        remoteConfig.getString('foo');
        verify(mockRemoteConfigPlatform.getString('foo'));
      });

      test('should throw if key is null', () {
        expect(() => remoteConfig.getString(null), throwsAssertionError);
      });
    });

    group('getValue()', () {
      test('should call delegate method', () {
        remoteConfig.getValue('foo');
        verify(mockRemoteConfigPlatform.getValue('foo'));
      });

      test('should throw if key is null', () {
        expect(() => remoteConfig.getValue(null), throwsAssertionError);
      });
    });

    group('setDefaults()', () {
      test('should call delegate method', () {
        remoteConfig.setDefaults(mockParameters);
        verify(mockRemoteConfigPlatform.setDefaults(mockDefaultParameters));
      });

      test('should throw if parameters are null', () {
        expect(() => remoteConfig.setDefaults(null), throwsAssertionError);
      });
    });
  });
}

class MockFirebaseRemoteConfig extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        TestFirebaseRemoteConfigPlatform {
  MockFirebaseRemoteConfig();
}

class TestFirebaseRemoteConfigPlatform extends FirebaseRemoteConfigPlatform {
  TestFirebaseRemoteConfigPlatform() : super();

  void instanceFor({FirebaseApp app, Map<dynamic, dynamic> pluginConstants}) {}

  @override
  FirebaseRemoteConfigPlatform delegateFor({FirebaseApp app}) {
    return this;
  }

  @override
  FirebaseRemoteConfigPlatform setInitialValues(
      {Map<dynamic, dynamic> remoteConfigValues}) {
    return this;
  }
}
