// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: avoid_unused_constructor_parameters, non_constant_identifier_names, public_member_api_docs

@JS('firebase_remote_config')
library firebase.remote_config_interop;

import 'package:js/js.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart';

@JS()
external RemoteConfigJsImpl getRemoteConfig([AppJsImpl? app]);

@JS()
external PromiseJsImpl<bool> activate(RemoteConfigJsImpl remoteConfig);

@JS()
external PromiseJsImpl<void> ensureInitialized(RemoteConfigJsImpl remoteConfig);

@JS()
external PromiseJsImpl<bool> fetchAndActivate(RemoteConfigJsImpl remoteConfig);

@JS()
external PromiseJsImpl<void> fetchConfig(RemoteConfigJsImpl remoteConfig);

@JS()
external dynamic getAll(RemoteConfigJsImpl remoteConfig);

@JS()
external bool getBoolean(RemoteConfigJsImpl remoteConfig, String key);

@JS()
external num getNumber(RemoteConfigJsImpl remoteConfig, String key);

@JS()
external String getString(RemoteConfigJsImpl remoteConfig, String key);

@JS()
external ValueJsImpl getValue(RemoteConfigJsImpl remoteConfig, String key);

// TODO - api to be implemented
@JS()
external PromiseJsImpl<void> isSupported();

@JS()
external void setLogLevel(RemoteConfigJsImpl remoteConfig, String logLevel);

@JS('RemoteConfig')
abstract class RemoteConfigJsImpl {
  external AppJsImpl get app;
  external SettingsJsImpl get settings;
  external set settings(SettingsJsImpl value);
  external Object get defaultConfig;
  external set defaultConfig(Object value);
  external int get fetchTimeMillis;
  external String get lastFetchStatus;
}

@JS()
@anonymous
abstract class ValueJsImpl {
  external bool asBoolean();
  external num asNumber();
  external String asString();
  external String getSource();
}

@JS()
@anonymous
abstract class SettingsJsImpl {
  external int get minimumFetchIntervalMillis;
  external set minimumFetchIntervalMillis(int value);
  external int get fetchTimeoutMillis;
  external set fetchTimeoutMillis(int value);
}
