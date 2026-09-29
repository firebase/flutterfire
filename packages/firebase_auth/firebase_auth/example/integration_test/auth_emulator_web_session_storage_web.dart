// Copyright 2026 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:js_interop';

@JS('sessionStorage')
external _SessionStorage get _sessionStorage;

extension type _SessionStorage._(JSObject _) implements JSObject {
  external void setItem(String key, String value);
  external void removeItem(String key);
}

void setAuthEmulatorOrigin(String appName, String origin) {
  _sessionStorage.setItem('$appName-firebaseEmulatorOrigin', origin);
}

void clearAuthEmulatorOrigin(String appName) {
  _sessionStorage.removeItem('$appName-firebaseEmulatorOrigin');
}
