// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names, public_member_api_docs

@JS('firebase_remote_config')
library;

import 'dart:js_interop';

import 'package:firebase_core_web/firebase_core_web_interop.dart';

@JS()
@staticInterop
external RemoteConfigJsImpl getRemoteConfig([AppJsImpl? app]);

@JS()
@staticInterop
external JSPromise<JSBoolean> activate(RemoteConfigJsImpl remoteConfig);

@JS()
@staticInterop
external JSPromise ensureInitialized(RemoteConfigJsImpl remoteConfig);

@JS()
@staticInterop
external JSPromise<JSBoolean> fetchAndActivate(RemoteConfigJsImpl remoteConfig);

@JS()
@staticInterop
external JSPromise fetchConfig(RemoteConfigJsImpl remoteConfig);

@JS()
@staticInterop
external JSObject getAll(RemoteConfigJsImpl remoteConfig);

@JS()
@staticInterop
external JSBoolean getBoolean(RemoteConfigJsImpl remoteConfig, JSString key);

@JS()
@staticInterop
external JSNumber getNumber(RemoteConfigJsImpl remoteConfig, JSString key);

@JS()
@staticInterop
external JSString getString(RemoteConfigJsImpl remoteConfig, JSString key);

@JS()
@staticInterop
external ValueJsImpl getValue(RemoteConfigJsImpl remoteConfig, JSString key);

@JS()
@staticInterop
external JSPromise isSupported();

@JS()
@staticInterop
external JSPromise setCustomSignals(
  RemoteConfigJsImpl remoteConfig,
  JSObject customSignals,
);

@JS()
@staticInterop
external void setLogLevel(RemoteConfigJsImpl remoteConfig, JSString logLevel);

extension type RemoteConfigJsImpl._(JSObject _) implements JSObject {
  external AppJsImpl get app;
  external SettingsJsImpl get settings;
  external set settings(SettingsJsImpl value);
  external JSObject get defaultConfig;
  external set defaultConfig(JSObject value);
  external JSNumber get fetchTimeMillis;
  external JSString get lastFetchStatus;
}

extension type ValueJsImpl._(JSObject _) implements JSObject {
  external JSBoolean asBoolean();
  external JSNumber asNumber();
  external JSString asString();
  external JSString getSource();
}

extension type SettingsJsImpl._(JSObject _) implements JSObject {
  external JSNumber get minimumFetchIntervalMillis;
  external set minimumFetchIntervalMillis(JSNumber value);
  external JSNumber get fetchTimeoutMillis;
  external set fetchTimeoutMillis(JSNumber value);
}

@JS()
@staticInterop
@anonymous
abstract class ConfigUpdateObserver {
  external factory ConfigUpdateObserver({
    JSAny complete,
    JSAny error,
    JSAny next,
  });
}

extension type ConfigUpdateObserverJsImpl._(JSObject _) implements JSObject {
  external JSAny get next;
  external JSAny get error;
  external JSAny get complete;
}

extension type ConfigUpdateJsImpl._(JSObject _) implements JSObject {
  external JSSet getUpdatedKeys();
}

@JS()
@staticInterop
external JSFunction onConfigUpdate(
  RemoteConfigJsImpl remoteConfig,
  ConfigUpdateObserver observer,
);

@JS('Set')
extension type JSSet._(JSObject _) implements JSObject {
  external void forEach(JSAny callback);
}
