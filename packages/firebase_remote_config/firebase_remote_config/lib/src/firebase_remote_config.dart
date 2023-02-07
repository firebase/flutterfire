// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_remote_config;

/// The entry point for accessing Remote Config.
///
/// You can get an instance by calling [FirebaseRemoteConfig.instance]. Note
/// [FirebaseRemoteConfig.instance] is async.
// ignore: prefer_mixin
class FirebaseRemoteConfig extends FirebasePluginPlatform with ChangeNotifier {
  FirebaseRemoteConfig._({required this.app})
      : super(app.name, 'plugins.flutter.io/firebase_remote_config');

  // Cached instances of [FirebaseRemoteConfig].
  static final Map<String, FirebaseRemoteConfig>
      _firebaseRemoteConfigInstances = {};

  /// Returns the underlying delegate implementation.
  ///
  /// If called and no [_delegatePackingProperty] exists, it will first be
  /// created and assigned before returning the delegate.
  late final _delegate = FirebaseRemoteConfigPlatform.instanceFor(
    app: app,
    pluginConstants: pluginConstants,
  );

  /// The [FirebaseApp] this instance was initialized with.
  final FirebaseApp app;

  /// Returns an instance using the default [FirebaseApp].
  static FirebaseRemoteConfig get instance {
    return FirebaseRemoteConfig.instanceFor(app: Firebase.app());
  }

  /// Returns an instance using the specified [FirebaseApp].
  static FirebaseRemoteConfig instanceFor({required FirebaseApp app}) {
    return _firebaseRemoteConfigInstances.putIfAbsent(app.name, () {
      return FirebaseRemoteConfig._(app: app);
    });
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
  /// A [FirebaseException] maybe thrown with the following error code:
  /// - **forbidden**:
  ///  - Thrown if the Google Cloud Platform Firebase Remote Config API is disabled
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
    return _delegate.getBool(key);
  }

  /// Gets the value for a given key as an int.
  int getInt(String key) {
    return _delegate.getInt(key);
  }

  /// Gets the value for a given key as a double.
  double getDouble(String key) {
    return _delegate.getDouble(key);
  }

  /// Gets the value for a given key as a String.
  String getString(String key) {
    return _delegate.getString(key);
  }

  /// Gets the [RemoteConfigValue] for a given key.
  RemoteConfigValue getValue(String key) {
    return _delegate.getValue(key);
  }

  /// Sets the [RemoteConfigSettings] for the current instance.
  Future<void> setConfigSettings(RemoteConfigSettings remoteConfigSettings) {
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
  /// Only booleans, strings and numbers are supported as values of the map
  Future<void> setDefaults(Map<String, dynamic> defaultParameters) {
    defaultParameters.forEach(_checkIsSupportedType);
    return _delegate.setDefaults(defaultParameters);
  }

  void _checkIsSupportedType(String key, dynamic value) {
    if (value is! bool && value is! num && value is! String) {
      throw ArgumentError(
        'Invalid value type "${value.runtimeType}" for key "$key". '
        'Only booleans, numbers and strings are supported as config values. '
        "If you're trying to pass a json object – convert it to string beforehand",
      );
    }
  }
}

@Deprecated('Use FirebaseRemoteConfig instead.')
class RemoteConfig extends FirebaseRemoteConfig {
  @Deprecated('Use FirebaseRemoteConfig instead.')

  /// The [FirebaseApp] this instance was initialized with.
  RemoteConfig._({required FirebaseApp app}) : super._(app: app);

  // Cached instances of [RemoteConfig].
  static final Map<String, RemoteConfig> _firebaseRemoteConfigInstances = {};

  /// Returns an instance using the default [FirebaseApp].
  @Deprecated('Use FirebaseRemoteConfig.instance instead.')
  static RemoteConfig get instance {
    return RemoteConfig.instanceFor(app: Firebase.app());
  }

  /// Returns an instance using the specified [FirebaseApp].
  @Deprecated('Use FirebaseRemoteConfig.instanceFor instead.')
  static RemoteConfig instanceFor({required FirebaseApp app}) {
    return _firebaseRemoteConfigInstances.putIfAbsent(app.name, () {
      return RemoteConfig._(app: app);
    });
  }
}
