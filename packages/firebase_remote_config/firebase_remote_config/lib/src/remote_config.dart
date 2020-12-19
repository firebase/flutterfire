// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_remote_config;

/// The entry point for accessing Remote Config.
///
/// You can get an instance by calling [RemoteConfig.instance]. Note
/// [RemoteConfig.instance] is async.
class RemoteConfig extends FirebasePluginPlatform with ChangeNotifier {

  static final Map<String, RemoteConfig> _firebaseRemoteConfigInstances = {};

  FirebaseRemoteConfigPlatform _delegatePackingProperty;

  FirebaseRemoteConfigPlatform get _delegate {
    if (_delegatePackingProperty == null) {
      _delegatePackingProperty = FirebaseRemoteConfigPlatform.instanceFor(app: app, pluginConstants: pluginConstants);
    }
    return _delegatePackingProperty;
  }

  final FirebaseApp app;

  RemoteConfig._({this.app})
      : super(app.name, 'plugins.flutter.io/firebase_remote_config');

  static RemoteConfig get instance {
     return RemoteConfig.instanceFor(app: Firebase.app());
  }

  static RemoteConfig instanceFor({FirebaseApp app}) {
    assert(app != null);

    if (_firebaseRemoteConfigInstances.containsKey(app.name)) {
      return _firebaseRemoteConfigInstances[app.name];
    }

    RemoteConfig newInstance = RemoteConfig._(app: app);
    _firebaseRemoteConfigInstances[app.name] = newInstance;

    return newInstance;
  }

  Future<bool> activate() async {
    bool configChanged = await _delegate.activate();
    if (configChanged) {
      notifyListeners();
    }
    return configChanged;
  }

  Future<void> insureInitialized() {
    return _delegate.ensureInitialized();
  }

  Future<void> fetch() {
    return _delegate.fetch();
  }

  Future<bool> fetchAndActivate() async {
    bool configChanged = await _delegate.fetchAndActivate();
    if (configChanged) {
      notifyListeners();
    }
    return configChanged;
  }

  Map<String, RemoteConfigValue> getAll() {
    return _delegate.getAll();
  }

  bool getBool(String key) {
    return _delegate.getBool(key);
  }

  int getInt(String key) {
    return _delegate.getInt(key);
  }

  double getDouble(String key) {
    return _delegate.getDouble(key);
  }

  String getString(String key) {
    return _delegate.getString(key);
  }

  RemoteConfigValue getValue(String key) {
    return _delegate.getValue(key);
  }

  Future<void> setConfigSettings(RemoteConfigSettings remoteConfigSettings) {
    return _delegate.setConfigSettings(remoteConfigSettings);
  }

  Future<void> setDefaults(Map<String, dynamic> defaultParameters) {
    return _delegate.setDefaults(defaultParameters);
  }
}
