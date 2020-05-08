// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database;

class OnDisconnect {
  platform.OnDisconnectPlatform _delegate;
  OnDisconnect._(this._delegate);

  Future<void> set(dynamic value, {dynamic priority}) {
    return _delegate.set(value, priority: priority);
  }

  Future<void> remove() => set(null);

  Future<void> cancel() {
    return _delegate.cancel();
  }

  Future<void> update(Map<String, dynamic> value) {
    return _delegate.update(value);
  }
}
