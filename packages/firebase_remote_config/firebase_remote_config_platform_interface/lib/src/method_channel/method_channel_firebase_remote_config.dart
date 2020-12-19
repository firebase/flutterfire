import 'dart:convert';

import 'package:firebase_remote_config_platform_interface/firebase_remote_config_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

class MethodChannelFirebaseRemoteConfig extends FirebaseRemoteConfigPlatform {

  static int _methodChannelHandleId = 0;

  static int get nextMethodChannelHandleId => _methodChannelHandleId++;

  static const MethodChannel channel = MethodChannel(
      'plugins.flutter.io/firebase_remote_config'
  );

  static Map<String, MethodChannelFirebaseRemoteConfig>
      _methodChannelFirebaseRemoteConfigInstances =
      <String, MethodChannelFirebaseRemoteConfig>{};

  static MethodChannelFirebaseRemoteConfig get instance {
    return MethodChannelFirebaseRemoteConfig._();
  }

  MethodChannelFirebaseRemoteConfig._() : super(appInstance: null);

  MethodChannelFirebaseRemoteConfig({FirebaseApp app}) : super(appInstance: app);

  Map<String, RemoteConfigValue> _activeParameters;

  @override
  FirebaseRemoteConfigPlatform delegateFor({FirebaseApp app}) {
    if (_methodChannelFirebaseRemoteConfigInstances.containsKey(app.name)) {
      return _methodChannelFirebaseRemoteConfigInstances[app.name];
    }

    _methodChannelFirebaseRemoteConfigInstances[app.name] =
        MethodChannelFirebaseRemoteConfig(app: app);
    return _methodChannelFirebaseRemoteConfigInstances[app.name];
  }

  @override
  FirebaseRemoteConfigPlatform setInitialValues(
      {Map<String, RemoteConfigValue> activeParameters}) {
    this._activeParameters = activeParameters;
    return this;
  }

  @override
  Future<void> ensureInitialized() async {
    await channel.invokeMethod<void>('RemoteConfig#ensureInitialized', <String, dynamic>{
      'appName': app.name,
    });
  }

  @override
  Future<bool> activate() async {
    bool configChanged = await channel.invokeMethod<bool>('RemoteConfig#activate', <String, dynamic>{
      'appName': app.name,
    });
    if (configChanged) {
      await _updateActiveParameters();
    }
    return configChanged;
  }

  Future<void> _updateActiveParameters() async {
    Map<dynamic, dynamic> parameters = await channel.invokeMapMethod<String, dynamic>('RemoteConfig#getAll', <String, dynamic>{
      'appName': app.name,
    });
    _activeParameters = FirebaseRemoteConfigPlatform.parseParameters(parameters);
  }

  @override
  Future<void> fetch() async {
    await channel.invokeMethod<void>('RemoteConfig#fetch', <String, dynamic>{
      'appName': app.name,
    });
  }

  @override
  Future<bool> fetchAndActivate() async {
    bool configChanged = await channel.invokeMethod<bool>('RemoteConfig#fetchAndActivate', <String, dynamic>{
      'appName': app.name,
    });
    if (configChanged) {
      await _updateActiveParameters();
    }
    return configChanged;
  }

  @override
  Map<String, RemoteConfigValue> getAll() {
    return _activeParameters;
  }

  @override
  bool getBool(String key) {
    if (!_activeParameters.containsKey(key)) {
      return RemoteConfigValue.defaultValueForBool;
    }
    return _activeParameters[key].asBool();
  }

  @override
  int getInt(String key) {
    if (!_activeParameters.containsKey(key)) {
      return RemoteConfigValue.defaultValueForInt;
    }
    return _activeParameters[key].asInt();
  }

  @override
  double getDouble(String key) {
    if (!_activeParameters.containsKey(key)) {
      return RemoteConfigValue.defaultValueForDouble;
    }
    return _activeParameters[key].asDouble();
  }

  @override
  String getString(String key) {
    if (!_activeParameters.containsKey(key)) {
      return RemoteConfigValue.defaultValueForString;
    }
    return _activeParameters[key].asString();
  }

  @override
  RemoteConfigValue getValue(String key) {
    if (!_activeParameters.containsKey(key)) {
      return RemoteConfigValue(null, ValueSource.valueStatic);
    }
    return _activeParameters[key];
  }

  @override
  Future<void> setConfigSettings(RemoteConfigSettings remoteConfigSettings) async {
    await channel.invokeMethod('RemoteConfig#setConfigSettings', <String, dynamic>{
      'appName': app.name,
      'fetchTimeout': remoteConfigSettings.fetchTimeout.inSeconds,
      'minimumFetchInterval': remoteConfigSettings.minimumFetchInterval.inSeconds,
    });
  }

  @override
  Future<void> setDefaults(Map<String, dynamic> defaultParameters) async {
    await channel.invokeMethod('RemoteConfig#setDefaults', <String, dynamic>{
      'appName': app.name,
      'defaults': defaultParameters
    });
    await _updateActiveParameters();
  }
}
