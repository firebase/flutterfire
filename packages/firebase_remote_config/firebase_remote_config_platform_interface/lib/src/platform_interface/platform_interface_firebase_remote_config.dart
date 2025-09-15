// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: require_trailing_commas
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
    required FirebaseApp app,
    Map<dynamic, dynamic>? pluginConstants,
  }) {
    return FirebaseRemoteConfigPlatform.instance
        .delegateFor(app: app)
        .setInitialValues(
          remoteConfigValues: pluginConstants ?? <dynamic, dynamic>{},
        );
  }

  static final Object _token = Object();

  static FirebaseRemoteConfigPlatform? _instance;

  /// The current default [FirebaseRemoteConfigPlatform] instance.
  ///
  /// It will always default to [MethodChannelFirebaseRemoteConfig]
  /// if no other implementation was provided.
  static FirebaseRemoteConfigPlatform get instance {
    return _instance ??= MethodChannelFirebaseRemoteConfig.instance;
  }

  /// Sets the [FirebaseRemoteConfigPlatform] instance.
  static set instance(FirebaseRemoteConfigPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// The [FirebaseApp] this instance was initialized with.
  @protected
  final FirebaseApp? appInstance;

  /// Returns the [FirebaseApp] for the current instance.
  late final FirebaseApp app = appInstance ?? Firebase.app();

  /// Enables delegates to create new instances of themselves if a none
  /// default [FirebaseApp] instance is required by the user.
  @protected
  FirebaseRemoteConfigPlatform delegateFor({required FirebaseApp app}) {
    throw UnimplementedError('delegateFor() is not implemented');
  }

  /// Sets any initial values on the instance.
  ///
  /// Platforms with Method Channels can provide constant values to be
  /// available before the instance has initialized to prevent unnecessary
  /// async calls.
  @protected
  FirebaseRemoteConfigPlatform setInitialValues({
    required Map<dynamic, dynamic> remoteConfigValues,
  }) {
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
  /// A [FirebaseException] maybe thrown with the following error code:
  /// - **forbidden**:
  ///  - Thrown if the Google Cloud Platform Firebase Remote Config API is disabled
  Future<bool> fetchAndActivate() {
    throw UnimplementedError('fetchAndActivate() is not implemented');
  }

  /// Returns a Map of all Remote Config parameters.
  Map<String, RemoteConfigValue> getAll() {
    throw UnimplementedError('getAll() is not implemented');
  }

  /// Gets the value for a given key as a bool.
  ///
  /// Returns `false` if the key does not exist.
  bool getBool(String key) {
    throw UnimplementedError('getBool() is not implemented');
  }

  /// Gets the value for a given key as an int.
  ///
  /// Returns `0` if the key does not exist.
  int getInt(String key) {
    throw UnimplementedError('getInt() is not implemented');
  }

  /// Gets the value for a given key as a double.
  ///
  /// Returns `0.0` if the key does not exist.
  double getDouble(String key) {
    throw UnimplementedError('getDouble() is not implemented');
  }

  /// Gets the value for a given key as a String.
  ///
  /// Returns an empty String if the key does not exist.
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

  /// Get a [Stream] of [RemoteConfigUpdate]s.
  Stream<RemoteConfigUpdate> get onConfigUpdated {
    throw UnimplementedError('onConfigUpdated getter not implemented');
  }

  /// Changes the custom signals for this FirebaseRemoteConfig instance
  /// Custom signals are subject to limits on the size of key/value pairs and the total number of signals.
  /// Any calls that exceed these limits will be discarded.
  /// If a key already exists, the value is overwritten. Setting the value of a custom signal to null un-sets the signal.
  /// The signals will be persisted locally on the client.
  Future<void> setCustomSignals(Map<String, Object?> customSignals) {
    throw UnimplementedError('setCustomSignals() is not implemented');
  }
}
