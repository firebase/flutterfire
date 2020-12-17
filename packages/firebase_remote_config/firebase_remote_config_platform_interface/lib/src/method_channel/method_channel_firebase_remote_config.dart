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

  MethodChannelFirebaseRemoteConfig._() : super(app: null);

  MethodChannelFirebaseRemoteConfig({FirebaseApp app}) : super(app: app);

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
  }

  @override
  Future<void> ensureInitialized() async {
    await channel.invokeMethod<void>('RemoteConfig#ensureInitialized');
  }

  @override
  Future<void> activate() async {
    Map<dynamic, dynamic> parameters = await channel.invokeMapMethod<String, dynamic>('RemoteConfig#activate');
    _activeParameters = Map<String, RemoteConfigValue>.from(parameters);
    notifyListeners();
  }

  @override
  Future<void> fetch() async {
    await channel.invokeMethod<void>('RemoteConfig#fetch');
  }

  @override
  Future<bool> fetchAndActivate() async {
    bool configChanged = await channel.invokeMethod<bool>('RemoteConfig#fetchAndActivate');
    if (configChanged) {
      Map<dynamic, dynamic> parameters = await channel.invokeMapMethod<String, dynamic>('RemoteConfig#getAll');
      _activeParameters = Map<String, RemoteConfigValue>.from(parameters);
      notifyListeners();
    }
    return configChanged;
  }

  @override
  Map<String, RemoteConfigValue> getAll() {
    return _activeParameters;
  }

  @override
  bool getBool(String key) {
    return _activeParameters[key].asBool();
  }

  @override
  int getInt(String key) {
    return _activeParameters[key].asInt();
  }

  @override
  double getDouble(String key) {
    return _activeParameters[key].asDouble();
  }

  @override
  String getString(String key) {
    return _activeParameters[key].asString();
  }

  @override
  RemoteConfigValue getValue(String key) {
    return _activeParameters[key];
  }

  @override
  Future<void> setConfigSettings(RemoteConfigSettings remoteConfigSettings) async {
    await channel.invokeMethod('RemoteConfig#setConfigSettings', <String, dynamic>{
      'fetchTimeout': remoteConfigSettings.fetchTimeout,
      'minimumFetchInterval': remoteConfigSettings.minimumFetchInterval,
    });
  }

  @override
  void setDefaults(Map<String, dynamic> defaultParameters) {
    for (var key in defaultParameters.keys) {
      _activeParameters[key] = RemoteConfigValue(defaultParameters[key], ValueSource.valueDefault);
    }
  }
}
