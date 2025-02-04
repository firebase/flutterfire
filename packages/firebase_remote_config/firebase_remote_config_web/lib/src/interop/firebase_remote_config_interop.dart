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
external JSAny getAll(RemoteConfigJsImpl remoteConfig);

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

@JS('RemoteConfig')
@staticInterop
abstract class RemoteConfigJsImpl {}

extension RemoteConfigJsImplExtension on RemoteConfigJsImpl {
  external AppJsImpl get app;
  external SettingsJsImpl get settings;
  external set settings(SettingsJsImpl value);
  external JSObject get defaultConfig;
  external set defaultConfig(JSObject value);
  external JSNumber get fetchTimeMillis;
  external JSString get lastFetchStatus;
}

@JS()
@staticInterop
@anonymous
abstract class ValueJsImpl {}

extension ValueJsImplExtension on ValueJsImpl {
  external JSBoolean asBoolean();
  external JSNumber asNumber();
  external JSString asString();
  external JSString getSource();
}

@JS()
@staticInterop
@anonymous
abstract class SettingsJsImpl {}

extension SettingsJsImplExtension on SettingsJsImpl {
  external JSNumber get minimumFetchIntervalMillis;
  external set minimumFetchIntervalMillis(JSNumber value);
  external JSNumber get fetchTimeoutMillis;
  external set fetchTimeoutMillis(JSNumber value);
}
