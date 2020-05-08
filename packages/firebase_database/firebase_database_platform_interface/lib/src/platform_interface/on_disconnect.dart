// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_database_platform_interface;

/// The [onDisconnect] class allows you to write or clear data when your client disconnects from the Database server.
/// These updates occur whether your client disconnects cleanly or not, so you can rely on them to clean up data even if a connection is dropped or a client crashes.
abstract class OnDisconnectPlatform extends PlatformInterface {
  /// Create a [OnDisconnectPlatform] instance
  OnDisconnectPlatform({this.database, this.reference});

  /// The Database instance associated with this [OnDisconnectPlatform] class
  final DatabasePlatform database;

  /// The DatabaseReference instance associated with this [OnDisconnectPlatform] class
  final DatabaseReferencePlatform reference;

  /// Ensures the data at this location is set to the specified value when the client is disconnected
  Future<void> set(dynamic value, {dynamic priority}) {
    throw UnimplementedError("set() not implemented");
  }

  /// Ensures the data at this location is deleted when the client is disconnected
  Future<void> remove() => set(null);

  /// Cancels all previously queued onDisconnect() set or update events for this location and all children.
  Future<void> cancel() {
    throw UnimplementedError("cancel() not implemented");
  }

  /// Writes multiple values at this location when the client is disconnected
  Future<void> update(Map<String, dynamic> value) {
    throw UnimplementedError("update() not implemented");
  }
}
