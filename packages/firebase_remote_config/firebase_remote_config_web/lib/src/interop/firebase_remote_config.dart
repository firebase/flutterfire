// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert' show utf8;
import 'dart:js_interop';

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
  Map<String, dynamic> get defaultConfig => Map.unmodifiable(
        jsObject.defaultConfig.dartify()! as Map<String, dynamic>,
      );

  set defaultConfig(Map<String, dynamic> value) {
    jsObject.defaultConfig = value.jsify()! as JSObject;
  }

  /// Returns the timestamp of the last *successful* fetch.
  DateTime get fetchTime {
    return DateTime.fromMillisecondsSinceEpoch(
      jsObject.fetchTimeMillis.toDartInt,
    );
  }

  /// The status of the last fetch attempt.
  RemoteConfigFetchStatus get lastFetchStatus {
    switch (jsObject.lastFetchStatus.toDart) {
      case 'no-fetch-yet':
        return RemoteConfigFetchStatus.notFetchedYet;
      case 'success':
        return RemoteConfigFetchStatus.success;
      case 'failure':
        return RemoteConfigFetchStatus.failure;
      case 'throttle':
        return RemoteConfigFetchStatus.throttle;
      default:
        throw UnimplementedError(jsObject.lastFetchStatus.toDart);
    }
  }

  ///  Makes the last fetched config available to the getters.
  ///  Returns a future which resolves to `true` if the current call activated the fetched configs.
  ///  If the fetched configs were already activated, the promise will resolve to `false`.
  Future<bool> activate() async => remote_config_interop
      .activate(jsObject)
      .toDart
      .then((value) => value.toDart);

  ///  Ensures the last activated config are available to the getters.
  Future<void> ensureInitialized() async =>
      remote_config_interop.ensureInitialized(jsObject).toDart;

  /// Fetches and caches configuration from the Remote Config service.
  Future<void> fetch() async =>
      remote_config_interop.fetchConfig(jsObject).toDart;

  /// Performs fetch and activate operations, as a convenience.
  /// Returns a promise which resolves to true if the current call activated the fetched configs.
  /// If the fetched configs were already activated, the promise will resolve to false.
  Future<bool> fetchAndActivate() async =>
      remote_config_interop.fetchAndActivate(jsObject).toDart.then(
            (value) => value.toDart,
          );

  /// Returns all config values.
  Map<String, RemoteConfigValue> getAll() {
    // Return type is Map<Object?, Object?>
    final map = remote_config_interop.getAll(jsObject).dartify()!
        as Map<Object?, Object?>;
    // Cast the map to <String, Object?> to mirror expected return type: Record<string, Value>;
    final castMap = map.cast<String, Object?>();
    final entries = castMap.keys.map<MapEntry<String, RemoteConfigValue>>(
      (dynamic k) => MapEntry<String, RemoteConfigValue>(k, getValue(k)),
    );
    return Map<String, RemoteConfigValue>.fromEntries(entries);
  }

  RemoteConfigValue getValue(String key) => RemoteConfigValue(
        utf8.encode(
          remote_config_interop.getValue(jsObject, key.toJS).asString().toDart,
        ),
        getSource(
          remote_config_interop.getValue(jsObject, key.toJS).getSource().toDart,
        ),
      );

  ///  Gets the value for the given key as a boolean.
  ///  Convenience method for calling `remoteConfig.getValue(key).asString()`.
  bool getBoolean(String key) =>
      remote_config_interop.getBoolean(jsObject, key.toJS).toDart;

  ///  Gets the value for the given key as a number.
  ///  Convenience method for calling `remoteConfig.getValue(key).asNumber()`.
  num getNumber(String key) =>
      remote_config_interop.getNumber(jsObject, key.toJS).toDartDouble;

  ///  Gets the value for the given key as a string.
  ///  Convenience method for calling `remoteConfig.getValue(key).asString()`.
  String getString(String key) =>
      remote_config_interop.getString(jsObject, key.toJS).toDart;

  void setLogLevel(RemoteConfigLogLevel value) {
    remote_config_interop.setLogLevel(
      jsObject,
      const {
        RemoteConfigLogLevel.debug: 'debug',
        RemoteConfigLogLevel.error: 'error',
        RemoteConfigLogLevel.silent: 'silent',
      }[value]!
          .toJS,
    );
  }

  Future<void> setCustomSignals(Map<String, Object?> customSignals) {
    return remote_config_interop
        .setCustomSignals(jsObject, customSignals.jsify()! as JSObject)
        .toDart;
  }

  StreamController<RemoteConfigUpdatePayload>? _onConfigUpdatedController;

  Stream<RemoteConfigUpdatePayload> get onConfigUpdated {
    if (_onConfigUpdatedController == null) {
      _onConfigUpdatedController =
          StreamController<RemoteConfigUpdatePayload>.broadcast(sync: true);
      final errorWrapper = (JSObject error) {
        _onConfigUpdatedController?.addError(error);
      };
      final nextWrapper =
          (remote_config_interop.ConfigUpdateJsImpl configUpdate) {
        _onConfigUpdatedController
            ?.add(RemoteConfigUpdatePayload._fromJsObject(configUpdate));
      };
      remote_config_interop.ConfigUpdateObserver observer =
          remote_config_interop.ConfigUpdateObserver(
        error: errorWrapper.toJS,
        next: nextWrapper.toJS,
      );

      remote_config_interop.onConfigUpdate(jsObject, observer);
    }

    return _onConfigUpdatedController!.stream;
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
      Duration(milliseconds: jsObject.minimumFetchIntervalMillis.toDartInt);

  set minimumFetchInterval(Duration value) {
    jsObject.minimumFetchIntervalMillis = value.inMilliseconds.toJS;
  }

  /// Defines the maximum amount of time to wait for a response when fetching
  /// configuration from the Remote Config server. Defaults to one minute.
  Duration get fetchTimeoutMillis =>
      Duration(milliseconds: jsObject.fetchTimeoutMillis.toDartInt);

  set fetchTimeoutMillis(Duration value) {
    jsObject.fetchTimeoutMillis = value.inMilliseconds.toJS;
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

class RemoteConfigUpdatePayload
    extends JsObjectWrapper<remote_config_interop.ConfigUpdateJsImpl> {
  RemoteConfigUpdatePayload._fromJsObject(
    remote_config_interop.ConfigUpdateJsImpl jsObject,
  ) : super.fromJsObject(jsObject);

  Set<String> get updatedKeys {
    final updatedKeysSet = <String>{};
    final callback = (JSAny key, JSString value, JSAny set) {
      updatedKeysSet.add(value.toDart);
    };
    jsObject.getUpdatedKeys().forEach(callback.toJS);
    return updatedKeysSet;
  }
}
