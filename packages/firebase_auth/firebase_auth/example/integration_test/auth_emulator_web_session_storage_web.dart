// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

extension type _WebStorage._(JSObject _) implements JSObject {
  external void setItem(String key, String value);
  external void removeItem(String key);
  external String? getItem(String key);
}

@JS('sessionStorage')
external _WebStorage get _sessionStorage;

@JS('localStorage')
external _WebStorage get _localStorage;

String _storageKey(String appName) => '$appName-firebaseEmulatorOrigin';

void setAuthEmulatorOrigin(String appName, String origin) {
  _sessionStorage.setItem(_storageKey(appName), origin);
}

void clearAuthEmulatorOrigin(String appName) {
  _sessionStorage.removeItem(_storageKey(appName));
}

String? getAuthEmulatorOriginLocal(String appName) {
  return _localStorage.getItem(_storageKey(appName));
}

void clearAuthEmulatorOriginLocal(String appName) {
  _localStorage.removeItem(_storageKey(appName));
}
