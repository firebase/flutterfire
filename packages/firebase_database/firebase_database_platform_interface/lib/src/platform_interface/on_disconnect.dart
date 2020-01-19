// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database_platform_interface;

abstract class OnDisconnect {
  OnDisconnect._(this._database, DatabaseReference reference)
      : path = reference.path;

  final DatabasePlatform _database;
  final String path;

  Future<void> set(dynamic value, {dynamic priority}) {
    throw UnimplementedError("update() not implemented");
  }

  Future<void> remove() => set(null);

  Future<void> cancel() {
    throw UnimplementedError("cancel() not implemented");
  }

  Future<void> update(Map<String, dynamic> value) {
    throw UnimplementedError("update() not implemented");
  }
}
