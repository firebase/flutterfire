// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: require_trailing_commas
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:firebase_remote_config_platform_interface/src/pigeon/messages.pigeon.dart';

import '../../firebase_remote_config_platform_interface.dart';
import 'utils/exception.dart';

/// Method Channel delegate for [FirebaseRemoteConfigPlatform].
class MethodChannelFirebaseRemoteConfig extends FirebaseRemoteConfigPlatform {
  /// Creates a new instance for a given [FirebaseApp].
  MethodChannelFirebaseRemoteConfig({required FirebaseApp app})
      : super(appInstance: app);

  /// Internal stub class initializer.
  ///
  /// When the user code calls a Remote Config method, the real instance
  /// is initialized via the [delegateFor] method.
  MethodChannelFirebaseRemoteConfig._() : super(appInstance: null);

  final _api = FirebaseRemoteConfigHostApi();

  /// Keeps an internal handle ID for the channel.
  static int _methodChannelHandleId = 0;

  /// Increments and returns the next channel ID handler for RemoteConfig.
  static int get nextMethodChannelHandleId => _methodChannelHandleId++;

  /// The [MethodChannelRemoteConfig] method channel.
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_remote_config');

  static Map<String, MethodChannelFirebaseRemoteConfig>
      _methodChannelFirebaseRemoteConfigInstances =
      <String, MethodChannelFirebaseRemoteConfig>{};

  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebaseRemoteConfig get instance {
    return MethodChannelFirebaseRemoteConfig._();
  }

  late Map<String, PigeonRemoteConfigValue> _activeParameters;
  late PigeonRemoteConfigSettings _settings;
  late DateTime _lastFetchTime;
  late PigeonRemoteConfigFetchStatus _lastFetchStatus;

  PigeonFirebaseApp get pigeonDefault {
    return PigeonFirebaseApp(
      appName: app.name,
      tenantId: tenantId,
    );
  }

  @override
  RemoteConfigSettings getSettings() {
    return RemoteConfigSettings(
        fetchTimeout: Duration(seconds: _settings.fetchTimeout),
        minimumFetchInterval:
            Duration(seconds: _settings.minimumFetchInterval));
  }

  @override
  RemoteConfigFetchStatus getFetchStatus() {
    switch (_lastFetchStatus) {
      case PigeonRemoteConfigFetchStatus.noFetchYet:
        return RemoteConfigFetchStatus.noFetchYet;
      case PigeonRemoteConfigFetchStatus.success:
        return RemoteConfigFetchStatus.success;
      case PigeonRemoteConfigFetchStatus.failure:
        return RemoteConfigFetchStatus.failure;
      case PigeonRemoteConfigFetchStatus.throttle:
        return RemoteConfigFetchStatus.throttle;
      default:
        return RemoteConfigFetchStatus.noFetchYet;
    }
  }

  /// Gets a [FirebaseRemoteConfigPlatform] instance for a specific
  /// [FirebaseApp].
  ///
  /// Instances are cached and reused for incoming event handlers.
  @override
  FirebaseRemoteConfigPlatform delegateFor({required FirebaseApp app}) {
    return _methodChannelFirebaseRemoteConfigInstances.putIfAbsent(
      app.name,
      () => MethodChannelFirebaseRemoteConfig(app: app),
    );
  }

  @override
  FirebaseRemoteConfigPlatform setInitialValues({
    required Map<dynamic, dynamic> remoteConfigValues,
  }) {
    final fetchTimeout = remoteConfigValues.isEmpty
        ? const Duration(seconds: 60)
        : Duration(seconds: remoteConfigValues['fetchTimeout']);
    final minimumFetchInterval = remoteConfigValues.isEmpty
        ? const Duration(hours: 12)
        : Duration(seconds: remoteConfigValues['minimumFetchInterval']);
    final lastFetchMillis =
        remoteConfigValues.isEmpty ? 0 : remoteConfigValues['lastFetchTime'];
    final lastFetchStatus = remoteConfigValues.isEmpty
        ? 'noFetchYet'
        : remoteConfigValues['lastFetchStatus'];

    _settings = PigeonRemoteConfigSettings(
      fetchTimeout: fetchTimeout.inSeconds,
      minimumFetchInterval: minimumFetchInterval.inSeconds,
    );
    _lastFetchTime = DateTime.fromMillisecondsSinceEpoch(lastFetchMillis);
    _lastFetchStatus = _parseFetchStatus(lastFetchStatus);
    if (remoteConfigValues.isNotEmpty) {
      _activeParameters =
          _parsePigeonParameters(remoteConfigValues['parameters']);
    }

    return this;
  }

  PigeonRemoteConfigFetchStatus _parseFetchStatus(String? status) {
    switch (status) {
      case 'noFetchYet':
        return PigeonRemoteConfigFetchStatus.noFetchYet;
      case 'success':
        return PigeonRemoteConfigFetchStatus.success;
      case 'failure':
        return PigeonRemoteConfigFetchStatus.failure;
      case 'throttle':
        return PigeonRemoteConfigFetchStatus.throttle;
      default:
        return PigeonRemoteConfigFetchStatus.noFetchYet;
    }
  }

  @override
  DateTime get lastFetchTime => _lastFetchTime;

  @override
  PigeonRemoteConfigFetchStatus get lastFetchStatus => _lastFetchStatus;

  @override
  PigeonRemoteConfigSettings get settings => _settings;

  @override
  Future<void> ensureInitialized() async {
    try {
      await _api.ensureInitialized(pigeonDefault);
    } catch (exception, stackTrace) {
      convertPlatformException(exception, stackTrace);
    }
  }

  @override
  Future<bool> activate() async {
    try {
      bool configChanged = await _api.activate(pigeonDefault);
      await _updateConfigParameters();
      return configChanged;
    } catch (exception, stackTrace) {
      convertPlatformException(exception, stackTrace);
    }
  }

  @override
  Future<void> fetch() async {
    try {
      await _api.fetch(pigeonDefault);
      // await _updateConfigProperties();
    } catch (exception, stackTrace) {
      // Ensure that fetch status is updated.
      // await _updateConfigProperties();
      convertPlatformException(exception, stackTrace);
    }
  }

  @override
  Future<bool> fetchAndActivate() async {
    try {
      log('method_remote_config fetchAndActivate');
      bool configChanged = await _api.fetchAndActivate(pigeonDefault);
      await _updateConfigParameters();
      //await _updateConfigProperties();
      return configChanged;
    } catch (exception, stackTrace) {
      // Ensure that fetch status is updated.
      // await _updateConfigProperties();
      convertPlatformException(exception, stackTrace);
    }
  }

  @override
  Map<String, PigeonRemoteConfigValue> getAll() {
    return _activeParameters;
  }

  @override
  Map<String, RemoteConfigValue> getAllConverted() {
    var parameters = <String, RemoteConfigValue>{};
    for (final key in _activeParameters.keys) {
      final rawValue = _activeParameters[key]!.value;

      parameters[key] = RemoteConfigValue(_pigoenListIntToListInt(rawValue!),
          _pigeonToValueSource(_activeParameters[key]!.source));
    }
    return parameters;
  }

  @override
  bool getBool(String key) {
    if (!_activeParameters.containsKey(key)) {
      return RemoteConfigValue.defaultValueForBool;
    }
    return _pigeonValueToBool(_activeParameters[key]!);
  }

  @override
  int getInt(String key) {
    if (!_activeParameters.containsKey(key)) {
      return RemoteConfigValue.defaultValueForInt;
    }
    return _pigeonValueToInt(_activeParameters[key]!);
  }

  @override
  double getDouble(String key) {
    if (!_activeParameters.containsKey(key)) {
      return RemoteConfigValue.defaultValueForDouble;
    }
    return _pigeonValueToDouble(_activeParameters[key]!);
  }

  @override
  String getString(String key) {
    if (!_activeParameters.containsKey(key)) {
      return RemoteConfigValue.defaultValueForString;
    }
    return _pigeonValueToString(_activeParameters[key]!);
  }

  @override
  PigeonRemoteConfigValue getValue(String key) {
    if (!_activeParameters.containsKey(key)) {
      return PigeonRemoteConfigValue(source: PigeonValueSource.valueStatic);
    }
    return _activeParameters[key]!;
  }

  @override
  RemoteConfigValue getValueConverted(String key) {
    var pigeonValue = getValue(key);
    return RemoteConfigValue(_pigoenListIntToListInt(pigeonValue.value!),
        _pigeonToValueSource(pigeonValue.source));
  }

  @override
  Future<void> setConfigSettingsConverted(
      RemoteConfigSettings remoteConfigSettings) {
    log('method remote config setConfigSettingsConverted');
    var pigeonSettings = PigeonRemoteConfigSettings(
        fetchTimeout: remoteConfigSettings.fetchTimeout.inSeconds,
        minimumFetchInterval:
            remoteConfigSettings.minimumFetchInterval.inSeconds);
    return setConfigSettings(pigeonSettings);
  }

  @override
  Future<void> setConfigSettings(
    PigeonRemoteConfigSettings pigeonRemoteConfigSettings,
  ) async {
    try {
      await _api.setConfigSettings(pigeonDefault, pigeonRemoteConfigSettings);
      //await _updateConfigProperties();
    } catch (exception, stackTrace) {
      convertPlatformException(exception, stackTrace);
    }
  }

  @override
  Future<void> setDefaults(Map<String, dynamic> defaultParameters) async {
    try {
      await _api.setDefaults(pigeonDefault, defaultParameters);
      await _updateConfigParameters();
    } catch (exception, stackTrace) {
      convertPlatformException(exception, stackTrace);
    }
  }

  Future<void> _updateConfigParameters() async {
    Map<dynamic, dynamic>? parameters = await _api.getAll(pigeonDefault);
    _activeParameters = _parsePigeonParameters(parameters!);
  }

  Future<void> _updateConfigProperties() async {
    Map<dynamic, dynamic>? properties = await channel
        .invokeMapMethod<dynamic, dynamic>(
            'RemoteConfig#getProperties', <String, dynamic>{
      'appName': app.name,
    });
    final fetchTimeout = Duration(seconds: properties!['fetchTimeout']);
    final minimumFetchInterval =
        Duration(seconds: properties['minimumFetchInterval']);
    final lastFetchMillis = properties['lastFetchTime'];
    final lastFetchStatus = properties['lastFetchStatus'];

    _settings = PigeonRemoteConfigSettings(
      fetchTimeout: fetchTimeout.inSeconds,
      minimumFetchInterval: minimumFetchInterval.inSeconds,
    );
    _lastFetchTime = DateTime.fromMillisecondsSinceEpoch(lastFetchMillis);
    _lastFetchStatus = _parseFetchStatus(lastFetchStatus);
  }

  Map<String, RemoteConfigValue> _parseParameters(
      Map<dynamic, dynamic> rawParameters) {
    var parameters = <String, RemoteConfigValue>{};
    for (final key in rawParameters.keys) {
      final rawValue = rawParameters[key];
      parameters[key] = RemoteConfigValue(
          rawValue['value'], _parseValueSource(rawValue['source']));
    }
    return parameters;
  }

  Map<String, PigeonRemoteConfigValue> _parsePigeonParameters(
      Map<dynamic, dynamic> rawParameters) {
    var parameters = <String, PigeonRemoteConfigValue>{};
    for (final key in rawParameters.keys) {
      final rawValue = rawParameters[key];
      parameters[key] = PigeonRemoteConfigValue(
          value: rawValue['value'],
          source: _valueSourceToPigeon(_parseValueSource(rawValue['source'])));
    }
    return parameters;
  }

  ValueSource _parseValueSource(String? sourceStr) {
    switch (sourceStr) {
      case 'static':
        return ValueSource.valueStatic;
      case 'default':
        return ValueSource.valueDefault;
      case 'remote':
        return ValueSource.valueRemote;
      default:
        return ValueSource.valueStatic;
    }
  }

  static const EventChannel _eventChannelConfigUpdated =
      EventChannel('plugins.flutter.io/firebase_remote_config_updated');

  @override
  Stream<RemoteConfigUpdate> get onConfigUpdated {
    return _eventChannelConfigUpdated.receiveBroadcastStream(<String, dynamic>{
      'appName': app.name,
    }).map((event) {
      final updatedKeys = Set<String>.from(event);
      return RemoteConfigUpdate(updatedKeys);
    });
  }

  PigeonValueSource _valueSourceToPigeon(ValueSource source) {
    switch (source) {
      case ValueSource.valueDefault:
        return PigeonValueSource.valueDefault;
      case ValueSource.valueRemote:
        return PigeonValueSource.valueRemote;
      case ValueSource.valueStatic:
      default:
        return PigeonValueSource.valueStatic;
    }
  }

  ValueSource _pigeonToValueSource(PigeonValueSource source) {
    switch (source) {
      case PigeonValueSource.valueDefault:
        return ValueSource.valueDefault;
      case PigeonValueSource.valueRemote:
        return ValueSource.valueRemote;
      case PigeonValueSource.valueStatic:
      default:
        return ValueSource.valueStatic;
    }
  }

  static int _pigeonValueToInt(PigeonRemoteConfigValue pigeonValue) {
    final value = pigeonValue.value;
    if (value != null) {
      final String strValue =
          const Utf8Codec().decode(_pigoenListIntToListInt(value));
      final int intValue =
          int.tryParse(strValue) ?? RemoteConfigValue.defaultValueForInt;
      return intValue;
    } else {
      return RemoteConfigValue.defaultValueForInt;
    }
  }

  static String _pigeonValueToString(PigeonRemoteConfigValue pigeonValue) {
    final value = pigeonValue.value;
    return value != null
        ? const Utf8Codec().decode(_pigoenListIntToListInt(value))
        : RemoteConfigValue.defaultValueForString;
  }

  /// Decode value to double.
  static double _pigeonValueToDouble(PigeonRemoteConfigValue pigeonValue) {
    final value = pigeonValue.value;
    if (value != null) {
      final String strValue =
          const Utf8Codec().decode(_pigoenListIntToListInt(value));
      final double doubleValue =
          double.tryParse(strValue) ?? RemoteConfigValue.defaultValueForDouble;
      return doubleValue;
    } else {
      return RemoteConfigValue.defaultValueForDouble;
    }
  }

  /// Decode value to bool.
  static bool _pigeonValueToBool(PigeonRemoteConfigValue pigeonValue) {
    final value = pigeonValue.value;
    if (value != null) {
      final String strValue =
          const Utf8Codec().decode(_pigoenListIntToListInt(value));
      final lowerCase = strValue.toLowerCase();
      return lowerCase == 'true' || lowerCase == '1';
    } else {
      return RemoteConfigValue.defaultValueForBool;
    }
  }

  static List<int> _pigoenListIntToListInt(List<int?> list) {
    List<int> newList = [];
    for (final int? element in list) {
      if (element != null) {
        newList.add(element);
      }
    }
    return newList;
  }
}
