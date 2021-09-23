// ignore_for_file: require_trailing_commas
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database;

class OnDisconnect {
  OnDisconnectPlatform _onDisconnectPlatform;

  OnDisconnect._(this._onDisconnectPlatform)
      : path = _onDisconnectPlatform.ref.path;

  final String path;

  Future<void> set(dynamic value, {dynamic priority}) {
    return _onDisconnectPlatform.set(value, priority: priority);
  }

  Future<void> remove() => set(null);

  Future<void> cancel() {
    return _onDisconnectPlatform.cancel();
  }

  Future<void> update(Map<String, dynamic> value) {
    return _onDisconnectPlatform.update(value);
  }
}
