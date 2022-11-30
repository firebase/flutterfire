// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert' show utf8;
import 'package:firebase_core_web/firebase_core_web_interop.dart';
import 'package:firebase_remote_config_platform_interface/firebase_remote_config_platform_interface.dart';
import 'firebase_remote_config_interop.dart' as remote_config_interop;

/// Given an AppJSImp, return the Remote Config instance.
RemoteConfig getRemoteConfigInstance(App? app) {
  if (app == null) {
    return RemoteConfig.getInstance(remote_config_interop.getRemoteConfig());
  }
  return RemoteConfig.getInstance(
    remote_config_interop.getRemoteConfig(app.jsObject),
  );
}

/// Provides access to Remote Config service.
class RemoteConfig
    extends JsObjectWrapper<remote_config_interop.RemoteConfigJsImpl> {
  static final _expando = Expando<RemoteConfig>();

  static RemoteConfig getInstance(
    remote_config_interop.RemoteConfigJsImpl jsObject,
  ) =>
      _expando[jsObject] ??= RemoteConfig._fromJsObject(jsObject);

  RemoteConfig._fromJsObject(remote_config_interop.RemoteConfigJsImpl jsObject)
      : super.fromJsObject(jsObject);

  /// Defines configuration for the Remote Config SDK.
  RemoteConfigSettings get settings =>
      RemoteConfigSettings._fromJsObject(jsObject.settings);

  /// Contains default values for configs. To set default config, compose a map and then assign it to `defaultConfig`.
  /// Any modifications to the map after the assignment will not take effect.
  ///
  /// Example:
  /// ```dart
  ///
  /// final remoteConfig = firebase.remoteConfig();
  /// Map<String, dynamic> defaultsMap = {'title': 'Hello', counter: 1};
  /// remoteConfig.defaultConfig = defaultsMap;   // Correct.
  /// defaultsMap['x'] = 1;                       // remoteConfig.defaultConfig will not be updated.
  /// remoteConfig.defaultConfig['x'] = 1;        // Runtime error: attempt to modify an unmodifiable map.
  /// ```
  Map<String, dynamic> get defaultConfig =>
      Map.unmodifiable(dartify(jsObject.defaultConfig));

  set defaultConfig(Map<String, dynamic> value) {
    jsObject.defaultConfig = jsify(value);
  }

  /// Returns the timestamp of the last *successful* fetch.
  DateTime get fetchTime {
    return DateTime.fromMillisecondsSinceEpoch(jsObject.fetchTimeMillis);
  }

  /// The status of the last fetch attempt.
  RemoteConfigFetchStatus get lastFetchStatus {
    switch (jsObject.lastFetchStatus) {
      case 'no-fetch-yet':
        return RemoteConfigFetchStatus.notFetchedYet;
      case 'success':
        return RemoteConfigFetchStatus.success;
      case 'failure':
        return RemoteConfigFetchStatus.failure;
      case 'throttle':
        return RemoteConfigFetchStatus.throttle;
      default:
        throw UnimplementedError(jsObject.lastFetchStatus);
    }
  }

  ///  Makes the last fetched config available to the getters.
  ///  Returns a future which resolves to `true` if the current call activated the fetched configs.
  ///  If the fetched configs were already activated, the promise will resolve to `false`.
  Future<bool> activate() async =>
      handleThenable(remote_config_interop.activate(jsObject));

  ///  Ensures the last activated config are available to the getters.
  Future<void> ensureInitialized() async =>
      handleThenable(remote_config_interop.ensureInitialized(jsObject));

  /// Fetches and caches configuration from the Remote Config service.
  Future<void> fetch() async =>
      handleThenable(remote_config_interop.fetchConfig(jsObject));

  /// Performs fetch and activate operations, as a convenience.
  /// Returns a promise which resolves to true if the current call activated the fetched configs.
  /// If the fetched configs were already activated, the promise will resolve to false.
  Future<bool> fetchAndActivate() async =>
      handleThenable(remote_config_interop.fetchAndActivate(jsObject));

  /// Returns all config values.
  Map<String, RemoteConfigValue> getAll() {
    final keys = objectKeys(remote_config_interop.getAll(jsObject));
    final entries = keys.map<MapEntry<String, RemoteConfigValue>>(
      (dynamic k) => MapEntry<String, RemoteConfigValue>(k, getValue(k)),
    );
    return Map<String, RemoteConfigValue>.fromEntries(entries);
  }

  RemoteConfigValue getValue(String key) => RemoteConfigValue(
        utf8.encode(remote_config_interop.getValue(jsObject, key).asString()),
        getSource(remote_config_interop.getValue(jsObject, key).getSource()),
      );

  ///  Gets the value for the given key as a boolean.
  ///  Convenience method for calling `remoteConfig.getValue(key).asString()`.
  bool getBoolean(String key) =>
      remote_config_interop.getBoolean(jsObject, key);

  ///  Gets the value for the given key as a number.
  ///  Convenience method for calling `remoteConfig.getValue(key).asNumber()`.
  num getNumber(String key) => remote_config_interop.getNumber(jsObject, key);

  ///  Gets the value for the given key as a string.
  ///  Convenience method for calling `remoteConfig.getValue(key).asString()`.
  String getString(String key) =>
      remote_config_interop.getString(jsObject, key);

  void setLogLevel(RemoteConfigLogLevel value) {
    remote_config_interop.setLogLevel(
      jsObject,
      const {
        RemoteConfigLogLevel.debug: 'debug',
        RemoteConfigLogLevel.error: 'error',
        RemoteConfigLogLevel.silent: 'silent',
      }[value]!,
    );
  }
}

ValueSource getSource(String source) {
  switch (source) {
    case 'static':
      return ValueSource.valueStatic;
    case 'default':
      return ValueSource.valueDefault;
    case 'remote':
      return ValueSource.valueRemote;
    default:
      throw UnimplementedError(source);
  }
}

/// Defines configuration options for the Remote Config SDK.
class RemoteConfigSettings
    extends JsObjectWrapper<remote_config_interop.SettingsJsImpl> {
  RemoteConfigSettings._fromJsObject(
    remote_config_interop.SettingsJsImpl jsObject,
  ) : super.fromJsObject(jsObject);

  ///  Defines the maximum age in milliseconds of an entry in the config cache before
  ///  it is considered stale. Defaults to twelve hours.
  Duration get minimumFetchInterval =>
      Duration(milliseconds: jsObject.minimumFetchIntervalMillis);

  set minimumFetchInterval(Duration value) {
    jsObject.minimumFetchIntervalMillis = value.inMilliseconds;
  }

  /// Defines the maximum amount of time to wait for a response when fetching
  /// configuration from the Remote Config server. Defaults to one minute.
  Duration get fetchTimeoutMillis =>
      Duration(milliseconds: jsObject.fetchTimeoutMillis);

  set fetchTimeoutMillis(Duration value) {
    jsObject.fetchTimeoutMillis = value.inMilliseconds;
  }
}

/// Summarizes the outcome of the last attempt to fetch config from the Firebase Remote Config server.
enum RemoteConfigFetchStatus {
  /// Indicates the config has not been fetched yet or that SDK initialization is incomplete.
  notFetchedYet,

  /// Indicates the last attempt succeeded.
  success,

  /// Indicates the last attempt failed.
  failure,

  /// Indicates the last attempt was rate-limited.
  throttle,
}

/// Defines levels of Remote Config logging.
enum RemoteConfigLogLevel {
  debug,
  error,
  silent,
}
