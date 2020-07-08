// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_remote_config_platform_interface;

/// The method channel implementation of [FirebaseRemoteConfigPlatform].
class MethodChannelFirebaseRemoteConfig extends FirebaseRemoteConfigPlatform {
  /// The [MethodChannel] to which calls will be delegated.
  @visibleForTesting
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_remote_config');

  Map<String, RemoteConfigValue> _parameters;

  @override
  Future<Map<String, dynamic>> getRemoteConfigInstance() async {
    final Map<String, dynamic> properties =
        await channel.invokeMapMethod<String, dynamic>('RemoteConfig#instance');
    _parameters =
        _parseRemoteConfigParameters(parameters: properties['parameters']);
    return properties;
  }

  @override
  Future<void> setConfigSettings(
      RemoteConfigSettings remoteConfigSettings) async {
    return channel
        .invokeMethod<void>('RemoteConfig#setConfigSettings', <String, dynamic>{
      'debugMode': remoteConfigSettings.debugMode,
    });
  }

  @override
  Future<Map<String, dynamic>> fetch(
      {Duration expiration = const Duration(hours: 12)}) async {
    return channel.invokeMapMethod<String, dynamic>('RemoteConfig#fetch',
        <dynamic, dynamic>{'expiration': expiration.inSeconds});
  }

  @override
  Future<bool> activateFetched() async {
    final Map<String, dynamic> properties =
        await channel.invokeMapMethod<String, dynamic>('RemoteConfig#activate');
    final Map<dynamic, dynamic> rawParameters = properties['parameters'];
    final bool newConfig = properties['newConfig'];
    final Map<String, RemoteConfigValue> fetchedParameters =
        _parseRemoteConfigParameters(parameters: rawParameters);
    _parameters = fetchedParameters;
    return newConfig;
  }

  @override
  Future<void> setDefaults(Map<String, dynamic> defaults) async {
    // Make defaults available even if fetch fails.
    defaults.forEach((String key, dynamic value) {
      if (!_parameters.containsKey(key)) {
        final RemoteConfigValue remoteConfigValue = RemoteConfigValue._(
          const Utf8Codec().encode(value.toString()),
          ValueSource.valueDefault,
        );
        _parameters[key] = remoteConfigValue;
      }
    });
    return channel.invokeMethod<void>(
        'RemoteConfig#setDefaults', <String, dynamic>{'defaults': defaults});
  }

  @override
  String getString(String key) {
    if (_parameters.containsKey(key)) {
      return _parameters[key].asString();
    } else {
      return defaultValueForString;
    }
  }

  @override
  int getInt(String key) {
    if (_parameters.containsKey(key)) {
      return _parameters[key].asInt();
    } else {
      return defaultValueForInt;
    }
  }

  @override
  double getDouble(String key) {
    if (_parameters.containsKey(key)) {
      return _parameters[key].asDouble();
    } else {
      return defaultValueForDouble;
    }
  }

  @override
  bool getBool(String key) {
    if (_parameters.containsKey(key)) {
      return _parameters[key].asBool();
    } else {
      return defaultValueForBool;
    }
  }

  @override
  RemoteConfigValue getValue(String key) {
    if (_parameters.containsKey(key)) {
      return _parameters[key];
    } else {
      return RemoteConfigValue._(null, ValueSource.valueStatic);
    }
  }

  @override
  Map<String, RemoteConfigValue> getAll() {
    return Map<String, RemoteConfigValue>.unmodifiable(_parameters);
  }
}
