// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

  late FirebaseRemoteConfig remoteConfig;
  late DateTime mockLastFetchTime;
  late RemoteConfigFetchStatus mockLastFetchStatus;
  late RemoteConfigSettings mockRemoteConfigSettings;
  late Map<String, RemoteConfigValue> mockParameters;
  late Map<String, dynamic> mockDefaultParameters;
  late RemoteConfigValue mockRemoteConfigValue;

  group('FirebaseRemoteConfig', () {
    FirebaseRemoteConfigPlatform.instance = mockRemoteConfigPlatform;

    setUpAll(() async {
      await Firebase.initializeApp();
      remoteConfig = FirebaseRemoteConfig.instance;

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

      when(
        mockRemoteConfigPlatform.instanceFor(
          app: anyNamed('app'),
          pluginConstants: anyNamed('pluginConstants'),
        ),
      ).thenAnswer((_) => mockRemoteConfigPlatform);

      when(
        mockRemoteConfigPlatform.delegateFor(
          app: anyNamed('app'),
        ),
      ).thenAnswer((_) => mockRemoteConfigPlatform);

      when(
        mockRemoteConfigPlatform.setInitialValues(
          remoteConfigValues: anyNamed('remoteConfigValues'),
        ),
      ).thenAnswer((_) => mockRemoteConfigPlatform);

      when(mockRemoteConfigPlatform.lastFetchTime)
          .thenReturn(mockLastFetchTime);

      when(mockRemoteConfigPlatform.lastFetchStatus)
          .thenReturn(mockLastFetchStatus);

      when(mockRemoteConfigPlatform.settings)
          .thenReturn(mockRemoteConfigSettings);

      when(mockRemoteConfigPlatform.setConfigSettings(any))
          .thenAnswer((_) => Future.value());

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
      final List<FirebaseRemoteConfig> remoteConfigs = <FirebaseRemoteConfig>[
        FirebaseRemoteConfig.instance,
        FirebaseRemoteConfig.instance,
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
          mockRemoteConfigPlatform.setConfigSettings(remoteConfigSettings),
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
    });

    group('getInt()', () {
      test('should call delegate method', () {
        remoteConfig.getInt('foo');
        verify(mockRemoteConfigPlatform.getInt('foo'));
      });
    });

    group('getDouble()', () {
      test('should call delegate method', () {
        remoteConfig.getDouble('foo');
        verify(mockRemoteConfigPlatform.getDouble('foo'));
      });
    });

    group('getString()', () {
      test('should call delegate method', () {
        remoteConfig.getString('foo');
        verify(mockRemoteConfigPlatform.getString('foo'));
      });
    });

    group('getValue()', () {
      test('should call delegate method', () {
        remoteConfig.getValue('foo');
        verify(mockRemoteConfigPlatform.getValue('foo'));
      });
    });

    group('setDefaults()', () {
      test('should call delegate method', () {
        remoteConfig.setDefaults(mockParameters);
        verify(mockRemoteConfigPlatform.setDefaults(mockDefaultParameters));
      });

      test('should throw when non-primitive value is passed', () {
        expect(
          () => remoteConfig.setDefaults({
            'key': {'nested': 'object'}
          }),
          throwsArgumentError,
        );
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
  MockFirebaseRemoteConfig() {
    TestFirebaseRemoteConfigPlatform();
  }

  @override
  FirebaseRemoteConfigPlatform delegateFor({FirebaseApp? app}) {
    return super.noSuchMethod(
      Invocation.method(#delegateFor, [], {#app: app}),
      returnValue: TestFirebaseRemoteConfigPlatform(),
      returnValueForMissingStub: TestFirebaseRemoteConfigPlatform(),
    );
  }

  @override
  FirebaseRemoteConfigPlatform setInitialValues({Map? remoteConfigValues}) {
    return super.noSuchMethod(
      Invocation.method(
        #setInitialValues,
        [],
        {#remoteConfigValues: remoteConfigValues},
      ),
      returnValue: TestFirebaseRemoteConfigPlatform(),
      returnValueForMissingStub: TestFirebaseRemoteConfigPlatform(),
    );
  }

  @override
  Future<bool> activate() {
    return super.noSuchMethod(
      Invocation.method(#activate, []),
      returnValue: Future<bool>.value(true),
      returnValueForMissingStub: Future<bool>.value(true),
    );
  }

  @override
  Future<void> ensureInitialized() {
    return super.noSuchMethod(
      Invocation.method(#ensureInitialized, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    );
  }

  @override
  Future<void> fetch() {
    return super.noSuchMethod(
      Invocation.method(#fetch, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    );
  }

  @override
  Future<bool> fetchAndActivate() {
    return super.noSuchMethod(
      Invocation.method(#fetchAndActivate, []),
      returnValue: Future<bool>.value(true),
      returnValueForMissingStub: Future<bool>.value(true),
    );
  }

  @override
  Future<void> setConfigSettings(RemoteConfigSettings? remoteConfigSettings) {
    return super.noSuchMethod(
      Invocation.method(#setConfigSettings, [remoteConfigSettings]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    );
  }

  @override
  Future<void> setDefaults(Map<String, dynamic>? defaultParameters) {
    return super.noSuchMethod(
      Invocation.method(#setDefaults, [defaultParameters]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    );
  }

  @override
  Map<String, RemoteConfigValue> getAll() {
    return super.noSuchMethod(
      Invocation.method(#getAll, []),
      returnValue: <String, RemoteConfigValue>{},
      returnValueForMissingStub: <String, RemoteConfigValue>{},
    );
  }

  @override
  bool getBool(String key) {
    return super.noSuchMethod(
      Invocation.method(#getBool, [key]),
      returnValue: true,
      returnValueForMissingStub: true,
    );
  }

  @override
  int getInt(String key) {
    return super.noSuchMethod(
      Invocation.method(#getInt, [key]),
      returnValue: 8,
      returnValueForMissingStub: 8,
    );
  }

  @override
  String getString(String key) {
    return super.noSuchMethod(
      Invocation.method(#getString, [key]),
      returnValue: 'foo',
      returnValueForMissingStub: 'foo',
    );
  }

  @override
  double getDouble(String key) {
    return super.noSuchMethod(
      Invocation.method(#getDouble, [key]),
      returnValue: 8.8,
      returnValueForMissingStub: 8.8,
    );
  }

  @override
  RemoteConfigValue getValue(String key) {
    return super.noSuchMethod(
      Invocation.method(#getValue, [key]),
      returnValue: RemoteConfigValue(
        <int>[],
        ValueSource.valueStatic,
      ),
      returnValueForMissingStub: RemoteConfigValue(
        <int>[],
        ValueSource.valueStatic,
      ),
    );
  }

  @override
  RemoteConfigFetchStatus get lastFetchStatus {
    return super.noSuchMethod(
      Invocation.getter(#lastFetchStatus),
      returnValue: RemoteConfigFetchStatus.success,
      returnValueForMissingStub: RemoteConfigFetchStatus.success,
    );
  }

  @override
  DateTime get lastFetchTime {
    return super.noSuchMethod(
      Invocation.getter(#lastFetchTime),
      returnValue: DateTime(2020),
      returnValueForMissingStub: DateTime(2020),
    );
  }

  @override
  RemoteConfigSettings get settings {
    return super.noSuchMethod(
      Invocation.getter(#settings),
      returnValue: RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
      returnValueForMissingStub: RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
  }
}

class TestFirebaseRemoteConfigPlatform extends FirebaseRemoteConfigPlatform {
  TestFirebaseRemoteConfigPlatform() : super();

  void instanceFor({
    FirebaseApp? app,
    Map<dynamic, dynamic>? pluginConstants,
  }) {}

  @override
  FirebaseRemoteConfigPlatform delegateFor({FirebaseApp? app}) {
    return this;
  }

  @override
  FirebaseRemoteConfigPlatform setInitialValues({
    Map<dynamic, dynamic>? remoteConfigValues,
  }) {
    return this;
  }
}
