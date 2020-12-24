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
        remoteConfigValues: pluginConstants == null
            ? Map<dynamic, dynamic>()
            : pluginConstants
    );
  }

  @protected
  FirebaseRemoteConfigPlatform delegateFor({FirebaseApp app}) {
    throw UnimplementedError('delegateFor() is not implemented');
  }

  @protected
  FirebaseRemoteConfigPlatform setInitialValues({Map<dynamic, dynamic> remoteConfigValues}) {
    throw UnimplementedError('setInitialValues() is not implemented');
  }

  DateTime get lastFetchTime {
    throw UnimplementedError('lastFetchTime getter not implemented');
  }

  RemoteConfigFetchStatus get lastFetchStatus {
    throw UnimplementedError('lastFetchStatus getter not implemented');
  }

  RemoteConfigSettings get settings {
    throw UnimplementedError('settings getter not implemented');
  }

  set settings(RemoteConfigSettings remoteConfigSettings) {
    throw UnimplementedError('settings setter not implemented');
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
