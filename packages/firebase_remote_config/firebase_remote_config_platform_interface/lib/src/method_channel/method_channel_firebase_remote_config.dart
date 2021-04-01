// @dart=2.9

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import '../../firebase_remote_config_platform_interface.dart';
import 'utils/exception.dart';

/// Method Channel delegate for [FirebaseRemoteConfigPlatform].
class MethodChannelFirebaseRemoteConfig extends FirebaseRemoteConfigPlatform {
  /// Creates a new instance for a given [FirebaseApp].
  MethodChannelFirebaseRemoteConfig({@required FirebaseApp app})
      : super(appInstance: app);

  /// Internal stub class initializer.
  ///
  /// When the user code calls a Remote Config method, the real instance
  /// is initialized via the [delegateFor] method.
  MethodChannelFirebaseRemoteConfig._() : super(appInstance: null);

  /// Keeps an internal handle ID for the channel.
  static int _methodChannelHandleId = 0;

  /// Increments and returns the next channel ID handler for RemoteConfig.
  static int get nextMethodChannelHandleId => _methodChannelHandleId++;

  /// The [MethodChannelRemoteConfig] method channel.
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_remote_config');

  static Map<String, MethodChannelFirebaseRemoteConfig>
      _methodChannelFirebaseRemoteConfigInstances =
      <String, MethodChannelFirebaseRemoteConfig>{};

  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebaseRemoteConfig get instance {
    return MethodChannelFirebaseRemoteConfig._();
  }

  Map<String, RemoteConfigValue> _activeParameters;
  RemoteConfigSettings _settings;
  DateTime _lastFetchTime;
  RemoteConfigFetchStatus _lastFetchStatus;

  /// Gets a [FirebaseRemoteConfigPlatform] instance for a specific
  /// [FirebaseApp].
  ///
  /// Instances are cached and reused for incoming event handlers.
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
      {Map<dynamic, dynamic> remoteConfigValues}) {
    final fetchTimeout = Duration(seconds: remoteConfigValues['fetchTimeout']);
    final minimumFetchInterval =
        Duration(seconds: remoteConfigValues['minimumFetchInterval']);
    final lastFetchMillis = remoteConfigValues['lastFetchTime'];
    final lastFetchStatus = remoteConfigValues['lastFetchStatus'];

    _settings = RemoteConfigSettings(
      fetchTimeout: fetchTimeout,
      minimumFetchInterval: minimumFetchInterval,
    );
    _lastFetchTime = DateTime.fromMillisecondsSinceEpoch(lastFetchMillis);
    _lastFetchStatus = _parseFetchStatus(lastFetchStatus);
    _activeParameters = _parseParameters(remoteConfigValues['parameters']);
    return this;
  }

  RemoteConfigFetchStatus _parseFetchStatus(String status) {
    switch (status) {
      case 'noFetchYet':
        return RemoteConfigFetchStatus.noFetchYet;
      case 'success':
        return RemoteConfigFetchStatus.success;
      case 'failure':
        return RemoteConfigFetchStatus.failure;
      case 'throttle':
        return RemoteConfigFetchStatus.throttle;
      default:
        return RemoteConfigFetchStatus.noFetchYet;
    }
  }

  @override
  DateTime get lastFetchTime => _lastFetchTime;

  @override
  RemoteConfigFetchStatus get lastFetchStatus => _lastFetchStatus;

  @override
  RemoteConfigSettings get settings => _settings;

  @override
  Future<void> ensureInitialized() async {
    try {
      await channel.invokeMethod<void>(
          'RemoteConfig#ensureInitialized', <String, dynamic>{
        'appName': app.name,
      });
    } catch (exception, stackTrace) {
      throw convertPlatformException(exception, stackTrace);
    }
  }

  @override
  Future<bool> activate() async {
    try {
      bool configChanged = await channel
          .invokeMethod<bool>('RemoteConfig#activate', <String, dynamic>{
        'appName': app.name,
      });
      await _updateConfigParameters();
      return configChanged;
    } catch (exception, stackTrace) {
      throw convertPlatformException(exception, stackTrace);
    }
  }

  @override
  Future<void> fetch() async {
    try {
      await channel.invokeMethod<void>('RemoteConfig#fetch', <String, dynamic>{
        'appName': app.name,
      });
      await _updateConfigProperties();
    } catch (exception, stackTrace) {
      // Ensure that fetch status is updated.
      await _updateConfigProperties();
      throw convertPlatformException(exception, stackTrace);
    }
  }

  @override
  Future<bool> fetchAndActivate() async {
    try {
      bool configChanged = await channel.invokeMethod<bool>(
          'RemoteConfig#fetchAndActivate', <String, dynamic>{
        'appName': app.name,
      });
      await _updateConfigParameters();
      await _updateConfigProperties();
      return configChanged;
    } catch (exception, stackTrace) {
      // Ensure that fetch status is updated.
      await _updateConfigProperties();
      throw convertPlatformException(exception, stackTrace);
    }
  }

  @override
  Map<String, RemoteConfigValue> getAll() {
    return _activeParameters;
  }

  @override
  bool getBool(String key) {
    if (!_activeParameters.containsKey(key)) {
      return RemoteConfigValue.defaultValueForBool;
    }
    return _activeParameters[key].asBool();
  }

  @override
  int getInt(String key) {
    if (!_activeParameters.containsKey(key)) {
      return RemoteConfigValue.defaultValueForInt;
    }
    return _activeParameters[key].asInt();
  }

  @override
  double getDouble(String key) {
    if (!_activeParameters.containsKey(key)) {
      return RemoteConfigValue.defaultValueForDouble;
    }
    return _activeParameters[key].asDouble();
  }

  @override
  String getString(String key) {
    if (!_activeParameters.containsKey(key)) {
      return RemoteConfigValue.defaultValueForString;
    }
    return _activeParameters[key].asString();
  }

  @override
  RemoteConfigValue getValue(String key) {
    if (!_activeParameters.containsKey(key)) {
      return RemoteConfigValue(null, ValueSource.valueStatic);
    }
    return _activeParameters[key];
  }

  @override
  Future<void> setConfigSettings(
      RemoteConfigSettings remoteConfigSettings) async {
    try {
      await channel
          .invokeMethod('RemoteConfig#setConfigSettings', <String, dynamic>{
        'appName': app.name,
        'fetchTimeout': remoteConfigSettings.fetchTimeout.inSeconds,
        'minimumFetchInterval':
            remoteConfigSettings.minimumFetchInterval.inSeconds,
      });
      await _updateConfigProperties();
    } catch (exception, stackTrace) {
      throw convertPlatformException(exception, stackTrace);
    }
  }

  @override
  Future<void> setDefaults(Map<String, dynamic> defaultParameters) async {
    try {
      await channel.invokeMethod('RemoteConfig#setDefaults', <String, dynamic>{
        'appName': app.name,
        'defaults': defaultParameters
      });
      await _updateConfigParameters();
    } catch (exception, stackTrace) {
      throw convertPlatformException(exception, stackTrace);
    }
  }

  Future<void> _updateConfigParameters() async {
    Map<dynamic, dynamic> parameters = await channel
        .invokeMapMethod<dynamic, dynamic>(
            'RemoteConfig#getAll', <String, dynamic>{
      'appName': app.name,
    });
    _activeParameters = _parseParameters(parameters);
  }

  Future<void> _updateConfigProperties() async {
    Map<dynamic, dynamic> properties = await channel
        .invokeMapMethod<dynamic, dynamic>(
            'RemoteConfig#getProperties', <String, dynamic>{
      'appName': app.name,
    });
    final fetchTimeout = Duration(seconds: properties['fetchTimeout']);
    final minimumFetchInterval =
        Duration(seconds: properties['minimumFetchInterval']);
    final lastFetchMillis = properties['lastFetchTime'];
    final lastFetchStatus = properties['lastFetchStatus'];

    _settings = RemoteConfigSettings(
      fetchTimeout: fetchTimeout,
      minimumFetchInterval: minimumFetchInterval,
    );
    _lastFetchTime = DateTime.fromMillisecondsSinceEpoch(lastFetchMillis);
    _lastFetchStatus = _parseFetchStatus(lastFetchStatus);
  }

  Map<String, RemoteConfigValue> _parseParameters(
      Map<dynamic, dynamic> rawParameters) {
    var parameters = <String, RemoteConfigValue>{};
    for (final key in rawParameters.keys) {
      final rawValue = rawParameters[key];
      parameters[key] = RemoteConfigValue(
          rawValue['value'], _parseValueSource(rawValue['source']));
    }
    return parameters;
  }

  ValueSource _parseValueSource(String sourceStr) {
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
}
