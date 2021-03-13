// @dart=2.9

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../firebase_remote_config_platform_interface.dart';
import '../method_channel/method_channel_firebase_remote_config.dart';

/// The interface that implementations of `firebase_remote_config` must
/// extend.
///
/// Platform implementations should extend this class rather than implement it
/// as `firebase_remote_config` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [FirebaseRemoteConfigPlatform] methods.
abstract class FirebaseRemoteConfigPlatform extends PlatformInterface {
  /// Create an instance using [app].
  FirebaseRemoteConfigPlatform({this.appInstance}) : super(token: _token);

  /// Create instance using [app] using the existing implementation.
  factory FirebaseRemoteConfigPlatform.instanceFor({
    FirebaseApp app,
    Map<dynamic, dynamic> pluginConstants,
  }) {
    return FirebaseRemoteConfigPlatform.instance
        .delegateFor(app: app)
        .setInitialValues(
          remoteConfigValues: pluginConstants ?? <dynamic, dynamic>{},
        );
  }

  static final Object _token = Object();

  /// The [FirebaseApp] this instance was initialized with.
  @protected
  final FirebaseApp appInstance;

  /// Returns the [FirebaseApp] for the current instance.
  FirebaseApp get app {
    if (appInstance == null) {
      return Firebase.app();
    }
    return appInstance;
  }

  static FirebaseRemoteConfigPlatform _instance;

  /// The current default [FirebaseRemoteConfigPlatform] instance.
  ///
  /// It will always default to [MethodChannelFirebaseRemoteConfig]
  /// if no other implementation was provided.
  static FirebaseRemoteConfigPlatform get instance {
    return _instance ??= MethodChannelFirebaseRemoteConfig.instance;
  }

  /// Sets the [FirebaseRemoteConfigPlatform] instance.
  static set instance(FirebaseRemoteConfigPlatform instance) {
    assert(instance != null);
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Enables delegates to create new instances of themselves if a none
  /// default [FirebaseApp] instance is required by the user.
  @protected
  FirebaseRemoteConfigPlatform delegateFor({FirebaseApp app}) {
    throw UnimplementedError('delegateFor() is not implemented');
  }

  /// Sets any initial values on the instance.
  ///
  /// Platforms with Method Channels can provide constant values to be
  /// available before the instance has initialized to prevent unnecessary
  /// async calls.
  @protected
  FirebaseRemoteConfigPlatform setInitialValues(
      {Map<dynamic, dynamic> remoteConfigValues}) {
    throw UnimplementedError('setInitialValues() is not implemented');
  }

  /// Returns the [DateTime] of the last successful fetch.
  ///
  /// If no successful fetch has been made a [DateTime] representing
  /// the epoch (1970-01-01 UTC) is returned.
  DateTime get lastFetchTime {
    throw UnimplementedError('lastFetchTime getter not implemented');
  }

  /// Returns the status of the last fetch attempt.
  RemoteConfigFetchStatus get lastFetchStatus {
    throw UnimplementedError('lastFetchStatus getter not implemented');
  }

  /// Returns the [RemoteConfigSettings] of the current instance.
  RemoteConfigSettings get settings {
    throw UnimplementedError('settings getter not implemented');
  }

  /// Makes the last fetched config available to getters.
  ///
  /// Returns a [bool] that is true if the config parameters
  /// were activated. Returns a [bool] that is false if the
  /// config parameters were already activated.
  Future<bool> activate() {
    throw UnimplementedError('activate() is not implemented');
  }

  /// Ensures the last activated config are available to getters.
  Future<void> ensureInitialized() {
    throw UnimplementedError('ensureInitialized() is not implemented');
  }

  /// Fetches and caches configuration from the Remote Config service.
  Future<void> fetch() {
    throw UnimplementedError('fetch() is not implemented');
  }

  /// Performs a fetch and activate operation, as a convenience.
  ///
  /// Returns [bool] in the same way that is done for [activate].
  Future<bool> fetchAndActivate() {
    throw UnimplementedError('fetchAndActivate() is not implemented');
  }

  /// Returns a Map of all Remote Config parameters.
  Map<String, RemoteConfigValue> getAll() {
    throw UnimplementedError('getAll() is not implemented');
  }

  /// Gets the value for a given key as a bool.
  bool getBool(String key) {
    throw UnimplementedError('getBool() is not implemented');
  }

  /// Gets the value for a given key as an int.
  int getInt(String key) {
    throw UnimplementedError('getInt() is not implemented');
  }

  /// Gets the value for a given key as a double.
  double getDouble(String key) {
    throw UnimplementedError('getDouble() is not implemented');
  }

  /// Gets the value for a given key as a String.
  String getString(String key) {
    throw UnimplementedError('getString() is not implemented');
  }

  /// Gets the [RemoteConfigValue] for a given key.
  RemoteConfigValue getValue(String key) {
    throw UnimplementedError('getValue() is not implemented');
  }

  /// Sets the [RemoteConfigSettings] for the current instance.
  Future<void> setConfigSettings(RemoteConfigSettings remoteConfigSettings) {
    throw UnimplementedError('setConfigSettings() is not implemented');
  }

  /// Sets the default parameter values for the current instance.
  Future<void> setDefaults(Map<String, dynamic> defaultParameters) {
    throw UnimplementedError('setDefaults() is not implemented');
  }
}
