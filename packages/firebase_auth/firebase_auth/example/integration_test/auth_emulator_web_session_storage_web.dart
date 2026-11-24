// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

extension type _WebStorage._(JSObject _) implements JSObject {
  external void setItem(String key, String value);
  external void removeItem(String key);
  external String? getItem(String key);
}

@JS('sessionStorage')
external _WebStorage get _sessionStorage;

@JS('localStorage')
external _WebStorage get _localStorage;

@JS('firebase_core.getApp')
external JSObject _firebaseGetApp(JSString name);

@JS('firebase_auth.getAuth')
external JSObject _firebaseGetAuth(JSObject app);

String _storageKey(String appName) => '$appName-firebaseEmulatorOrigin';

void setAuthEmulatorOrigin(String appName, String origin) {
  _sessionStorage.setItem(_storageKey(appName), origin);
}

void clearAuthEmulatorOrigin(String appName) {
  _sessionStorage.removeItem(_storageKey(appName));
}

String? getAuthEmulatorOrigin(String appName) {
  return _sessionStorage.getItem(_storageKey(appName));
}

String? getAuthEmulatorOriginLocal(String appName) {
  return _localStorage.getItem(_storageKey(appName));
}

void clearAuthEmulatorOriginLocal(String appName) {
  _localStorage.removeItem(_storageKey(appName));
}

/// The JS SDK refuses `connectAuthEmulator` once a network call has started,
/// by clearing `_canInitEmulator`. Set that flag so the test does not have to
/// sign in against production and wait on that request.
void lockAuthInstanceOnProduction(String appName) {
  final JSObject auth = _firebaseGetAuth(_firebaseGetApp(appName.toJS));
  auth.setProperty('_canInitEmulator'.toJS, false.toJS);
}
