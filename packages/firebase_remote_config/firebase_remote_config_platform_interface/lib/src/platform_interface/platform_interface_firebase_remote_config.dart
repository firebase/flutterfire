import 'dart:async';

import 'package:firebase_remote_config_platform_interface/firebase_remote_config_platform_interface.dart';
import 'package:firebase_remote_config_platform_interface/src/method_channel/method_channel_firebase_remote_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class FirebaseRemoteConfigPlatform extends PlatformInterface {
  static final Object _token = Object();

  FirebaseRemoteConfigPlatform(this.app) : super(token: _token);

  static FirebaseRemoteConfigPlatform _instance;

  final FirebaseApp app;

  static FirebaseRemoteConfigPlatform get instance {
    if (_instance == null) {
      _instance = MethodChannelFirebaseRemoteConfig.instance;
    }

    return _instance;
  }

  Future<void> activate() {
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

  RemoteConfigValue getValue() {
    throw UnimplementedError('getValue() is not implemented');
  }

  Future<void> setLogLevel() {
    throw UnimplementedError('setLogLevel() is not implemented');
  }

}
