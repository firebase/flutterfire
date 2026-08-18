// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'package:firebase_remote_config_web/src/internals.dart';
import 'package:firebase_remote_config_platform_interface/firebase_remote_config_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/interop/firebase_remote_config.dart' as remote_config_interop;

import 'src/firebase_remote_config_version.dart';

/// Web implementation of [FirebaseRemoteConfigPlatform].
class FirebaseRemoteConfigWeb extends FirebaseRemoteConfigPlatform {
  static const String _libraryName = 'flutter-fire-rc';

  /// The entry point for the [FirebaseRemoteConfigWeb] class.
  FirebaseRemoteConfigWeb({FirebaseApp? app}) : super(appInstance: app);

  /// Stub initializer to allow the [registerWith] to create an instance without
  /// registering the web delegates or listeners.
  FirebaseRemoteConfigWeb._()
      : _webRemoteConfig = null,
        super(appInstance: null);

  /// Instance of functions from the web plugin
  remote_config_interop.RemoteConfig? _webRemoteConfig;

  /// Lazily initialize [_webRemoteConfig] on first method call
  remote_config_interop.RemoteConfig get _delegate {
    return _webRemoteConfig ??= remote_config_interop.getRemoteConfigInstance(
      core_interop.app(app.name),
    );
  }

  /// Create the default instance of the [FirebaseRemoteConfigPlatform] as a [FirebaseRemoteConfigWeb]
  static void registerWith(Registrar registrar) {
    FirebaseCoreWeb.registerLibraryVersion(_libraryName, packageVersion);

    FirebaseCoreWeb.registerService(
      'remote-config',
      productNameOverride: 'remote_config',
    );
    FirebaseRemoteConfigPlatform.instance = FirebaseRemoteConfigWeb.instance;
  }

  /// Returns an instance of [FirebaseRemoteConfigWeb].
  static FirebaseRemoteConfigWeb get instance {
    return FirebaseRemoteConfigWeb._();
  }

  @override
  FirebaseRemoteConfigPlatform delegateFor({FirebaseApp? app}) {
    return FirebaseRemoteConfigWeb(app: app);
  }

  @override
  FirebaseRemoteConfigPlatform setInitialValues({
    required Map<dynamic, dynamic> remoteConfigValues,
  }) {
    return this;
  }

  /// Returns the [DateTime] of the last successful fetch.
  ///
  /// If no successful fetch has been made a [DateTime] representing
  /// the epoch (1970-01-01 UTC) is returned.
  @override
  DateTime get lastFetchTime {
    return _delegate.fetchTime;
  }

  /// Returns the status of the last fetch attempt.
  @override
  RemoteConfigFetchStatus get lastFetchStatus {
    switch (_delegate.lastFetchStatus) {
      case remote_config_interop.RemoteConfigFetchStatus.failure:
        return RemoteConfigFetchStatus.failure;
      case remote_config_interop.RemoteConfigFetchStatus.success:
        return RemoteConfigFetchStatus.success;
      case remote_config_interop.RemoteConfigFetchStatus.notFetchedYet:
        return RemoteConfigFetchStatus.noFetchYet;
      case remote_config_interop.RemoteConfigFetchStatus.throttle:
        return RemoteConfigFetchStatus.throttle;
    }
  }

  /// Returns the [RemoteConfigSettings] of the current instance.
  @override
  RemoteConfigSettings get settings {
    return RemoteConfigSettings(
      fetchTimeout: _delegate.settings.fetchTimeoutMillis,
      minimumFetchInterval: _delegate.settings.minimumFetchInterval,
    );
  }

  /// Makes the last fetched config available to getters.
  ///
  /// Returns a [bool] that is true if the config parameters
  /// were activated. Returns a [bool] that is false if the
  /// config parameters were already activated.
  @override
  Future<bool> activate() {
    return _delegate.activate();
  }

  /// Ensures the last activated config are available to getters.
  @override
  Future<void> ensureInitialized() {
    return _delegate.ensureInitialized();
  }

  /// Fetches and caches configuration from the Remote Config service.
  @override
  Future<void> fetch() {
    return _delegate.fetch();
  }

  /// Performs a fetch and activate operation, as a convenience.
  ///
  /// Returns [bool] in the same way that is done for [activate].
  @override
  Future<bool> fetchAndActivate() {
    return _delegate.fetchAndActivate();
  }

  /// Returns a Map of all Remote Config parameters.
  @override
  Map<String, RemoteConfigValue> getAll() {
    return _delegate.getAll();
  }

  /// Gets the value for a given key as a bool.
  ///
  /// Returns `false` if the key does not exist.
  @override
  bool getBool(String key) {
    return _delegate.getBoolean(key);
  }

  /// Gets the value for a given key as an int.
  ///
  /// Returns `0` if the key does not exist.
  @override
  int getInt(String key) {
    return _delegate.getNumber(key).toInt();
  }

  /// Gets the value for a given key as a double.
  ///
  /// Returns `0.0` if the key does not exist.
  @override
  double getDouble(String key) {
    return _delegate.getNumber(key).toDouble();
  }

  /// Gets the value for a given key as a String.
  ///
  /// Returns an empty String if the key does not exist.
  @override
  String getString(String key) {
    return _delegate.getString(key);
  }

  /// Gets the [RemoteConfigValue] for a given key.
  @override
  RemoteConfigValue getValue(String key) {
    return _delegate.getValue(key);
  }

  /// Sets the [RemoteConfigSettings] for the current instance.
  @override
  Future<void> setConfigSettings(RemoteConfigSettings remoteConfigSettings) {
    _delegate.settings.minimumFetchInterval =
        remoteConfigSettings.minimumFetchInterval;
    _delegate.settings.fetchTimeoutMillis = remoteConfigSettings.fetchTimeout;
    return Future<void>.value();
  }

  /// Sets the default parameter values for the current instance.
  @override
  Future<void> setDefaults(Map<String, dynamic> defaultParameters) {
    _delegate.defaultConfig = defaultParameters;
    return Future<void>.value();
  }

  @override
  Stream<RemoteConfigUpdate> get onConfigUpdated {
    return _delegate.onConfigUpdated
        .map((event) => RemoteConfigUpdate(event.updatedKeys));
  }

  @override
  Future<void> setCustomSignals(Map<String, Object?> customSignals) {
    return convertWebExceptions(
      () => _delegate.setCustomSignals(customSignals),
    );
  }
}
