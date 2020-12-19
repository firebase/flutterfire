import 'dart:async';

import 'package:firebase_remote_config_platform_interface/firebase_remote_config_platform_interface.dart';
import 'package:firebase_remote_config_platform_interface/src/method_channel/method_channel_firebase_remote_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

///
abstract class FirebaseRemoteConfigPlatform extends PlatformInterface {
  static final Object _token = Object();

  @protected
  final FirebaseApp appInstance;

  ///
  FirebaseRemoteConfigPlatform({this.appInstance}) : super(token: _token);

  ///
  FirebaseApp get app {
    if (appInstance == null) {
      return Firebase.app();
    }
    return appInstance;
  }

  static FirebaseRemoteConfigPlatform _instance;

  ///
  static FirebaseRemoteConfigPlatform get instance {
    if (_instance == null) {
      _instance = MethodChannelFirebaseRemoteConfig.instance;
    }

    return _instance;
  }

  static set instance(FirebaseRemoteConfigPlatform instance) {
    assert(instance != null);
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  factory FirebaseRemoteConfigPlatform.instanceFor({FirebaseApp app, Map<dynamic, dynamic> pluginConstants}) {
    return FirebaseRemoteConfigPlatform.instance.delegateFor(app: app).setInitialValues(
        activeParameters: pluginConstants == null
            ? Map<String, RemoteConfigValue>()
            : parseParameters(pluginConstants)
    );
  }

  @protected
  static Map<String, RemoteConfigValue> parseParameters(Map<dynamic, dynamic> rawParameters) {
    Map<String, RemoteConfigValue> parameters = Map();
    for (String key in rawParameters.keys) {
      final rawValue = rawParameters[key];
      parameters[key] = RemoteConfigValue(rawValue['value'], _parseValueSource(rawValue['source']));
    }
    return parameters;
  }

  static ValueSource _parseValueSource(String sourceStr) {
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

  @protected
  FirebaseRemoteConfigPlatform delegateFor({FirebaseApp app}) {
    throw UnimplementedError('delegateFor() is not implemented');
  }

  @protected
  FirebaseRemoteConfigPlatform setInitialValues({Map<String, RemoteConfigValue> activeParameters}) {
    throw UnimplementedError('setInitialValues() is not implemented');
  }

  Future<bool> activate() {
    throw UnimplementedError('activate() is not implemented');
  }

  Future<void> ensureInitialized() {
    throw UnimplementedError('ensureInitialized() is not implemented');
  }

  Future<void> fetch() {
    throw UnimplementedError('fetch() is not implemented');
  }

  Future<bool> fetchAndActivate() {
    throw UnimplementedError('fetchAndActivate() is not implemented');
  }

  Map<String, RemoteConfigValue> getAll() {
    throw UnimplementedError('getAll() is not implemented');
  }

  bool getBool(String key) {
    throw UnimplementedError('getBool() is not implemented');
  }

  int getInt(String key) {
    throw UnimplementedError('getInt() is not implemented');
  }

  double getDouble(String key) {
    throw UnimplementedError('getDouble() is not implemented');
  }

  String getString(String key) {
    throw UnimplementedError('getString() is not implemented');
  }

  RemoteConfigValue getValue(String key) {
    throw UnimplementedError('getValue() is not implemented');
  }

  Future<void> setConfigSettings(RemoteConfigSettings remoteConfigSettings) {
    throw UnimplementedError('setConfigSettings() is not implemented');
  }

  Future<void> setDefaults(Map<String, dynamic> defaultParameters) {
    throw UnimplementedError('setDefaults() is not implemented');
  }

}
