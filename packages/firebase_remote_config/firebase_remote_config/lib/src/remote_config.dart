// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

part of firebase_remote_config;

/// The entry point for accessing Remote Config.
///
/// You can get an instance by calling [RemoteConfig.instance]. Note
/// [RemoteConfig.instance] is async.
// ignore: prefer_mixin
class RemoteConfig extends FirebasePluginPlatform with ChangeNotifier {
  RemoteConfig._({this.app})
      : super(app.name, 'plugins.flutter.io/firebase_remote_config');

  // Cached instances of [FirebaseRemoteConfig].
  static final Map<String, RemoteConfig> _firebaseRemoteConfigInstances = {};

  // Cached and lazily loaded instance of [FirebaseRemoteConfigPlatform]
  // to avoid creating a [MethodChannelFirebaseRemoteConfig] when not needed
  // or creating an instance with the default app before a user specifies an
  // app.
  FirebaseRemoteConfigPlatform _delegatePackingProperty;

  /// Returns the underlying delegate implementation.
  ///
  /// If called and no [_delegatePackingProperty] exists, it will first be
  /// created and assigned before returning the delegate.
  FirebaseRemoteConfigPlatform get _delegate {
    return _delegatePackingProperty ??=
        FirebaseRemoteConfigPlatform.instanceFor(
      app: app,
      pluginConstants: pluginConstants,
    );
  }

  /// The [FirebaseApp] this instance was initialized with.
  final FirebaseApp app;

  /// Returns an instance using the default [FirebaseApp].
  static RemoteConfig get instance {
    return RemoteConfig.instanceFor(app: Firebase.app());
  }

  /// Returns an instance using the specified [FirebaseApp].
  static RemoteConfig instanceFor({@required FirebaseApp app}) {
    assert(app != null);

    if (_firebaseRemoteConfigInstances.containsKey(app.name)) {
      return _firebaseRemoteConfigInstances[app.name];
    }

    RemoteConfig newInstance = RemoteConfig._(app: app);
    _firebaseRemoteConfigInstances[app.name] = newInstance;

    return newInstance;
  }

  /// Returns the [DateTime] of the last successful fetch.
  ///
  /// If no successful fetch has been made a [DateTime] representing
  /// the epoch (1970-01-01 UTC) is returned.
  DateTime get lastFetchTime {
    return _delegate.lastFetchTime;
  }

  /// Returns the status of the last fetch attempt.
  RemoteConfigFetchStatus get lastFetchStatus {
    return _delegate.lastFetchStatus;
  }

  /// Returns the [RemoteConfigSettings] of the current instance.
  RemoteConfigSettings get settings {
    return _delegate.settings;
  }

  /// Makes the last fetched config available to getters.
  ///
  /// Returns a [bool] that is true if the config parameters
  /// were activated. Returns a [bool] that is false if the
  /// config parameters were already activated.
  Future<bool> activate() async {
    bool configChanged = await _delegate.activate();
    notifyListeners();
    return configChanged;
  }

  /// Ensures the last activated config are available to getters.
  Future<void> ensureInitialized() {
    return _delegate.ensureInitialized();
  }

  /// Fetches and caches configuration from the Remote Config service.
  Future<void> fetch() {
    return _delegate.fetch();
  }

  /// Performs a fetch and activate operation, as a convenience.
  ///
  /// Returns [bool] in the same way that is done for [activate].
  Future<bool> fetchAndActivate() async {
    bool configChanged = await _delegate.fetchAndActivate();
    notifyListeners();
    return configChanged;
  }

  /// Returns a Map of all Remote Config parameters.
  Map<String, RemoteConfigValue> getAll() {
    return _delegate.getAll();
  }

  /// Gets the value for a given key as a bool.
  bool getBool(String key) {
    assert(key != null);
    return _delegate.getBool(key);
  }

  /// Gets the value for a given key as an int.
  int getInt(String key) {
    assert(key != null);
    return _delegate.getInt(key);
  }

  /// Gets the value for a given key as a double.
  double getDouble(String key) {
    assert(key != null);
    return _delegate.getDouble(key);
  }

  /// Gets the value for a given key as a String.
  String getString(String key) {
    assert(key != null);
    return _delegate.getString(key);
  }

  /// Gets the [RemoteConfigValue] for a given key.
  RemoteConfigValue getValue(String key) {
    assert(key != null);
    return _delegate.getValue(key);
  }

  /// Sets the [RemoteConfigSettings] for the current instance.
  Future<void> setConfigSettings(RemoteConfigSettings remoteConfigSettings) {
    assert(remoteConfigSettings != null);
    assert(remoteConfigSettings.fetchTimeout != null);
    assert(remoteConfigSettings.minimumFetchInterval != null);
    assert(!remoteConfigSettings.fetchTimeout.isNegative);
    assert(!remoteConfigSettings.minimumFetchInterval.isNegative);
    // To be consistent with iOS fetchTimeout is set to the default
    // 1 minute (60 seconds) if an attempt is made to set it to zero seconds.
    if (remoteConfigSettings.fetchTimeout.inSeconds == 0) {
      remoteConfigSettings.fetchTimeout = const Duration(seconds: 60);
    }
    return _delegate.setConfigSettings(remoteConfigSettings);
  }

  /// Sets the default parameter values for the current instance.
  Future<void> setDefaults(Map<String, dynamic> defaultParameters) {
    assert(defaultParameters != null);
    return _delegate.setDefaults(defaultParameters);
  }
}
