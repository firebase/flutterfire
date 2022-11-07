// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Represents a query over the data at a particular location.
abstract class QueryPlatform extends PlatformInterface {
  /// The Database instance associated with this query
  final DatabasePlatform database;

  static final Object _token = Object();

  /// Throws an [AssertionError] if [instance] does not extend
  /// [QueryPlatform].
  ///
  /// This is used by the app-facing [Query] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static void verify(QueryPlatform instance) {
    PlatformInterface.verify(instance, _token);
  }

  /// Create a [QueryPlatform] instance
  QueryPlatform({
    required this.database,
  }) : super(token: _token);

  /// Returns the path to this reference.
  String get path {
    throw UnimplementedError('get path not implemented');
  }

  /// Obtains a DatabaseReference corresponding to this query's location.
  DatabaseReferencePlatform get ref {
    throw UnimplementedError('get ref() not implemented');
  }

  /// Assigns the proper event type to a stream for [DatabaseEventPlatform]
  Stream<DatabaseEventPlatform> observe(
    QueryModifiers modifiers,
    DatabaseEventType eventType,
  ) {
    throw UnimplementedError('observe() not implemented');
  }

  /// Gets the most up-to-date result for this query.
  Future<DataSnapshotPlatform> get(QueryModifiers modifiers) {
    throw UnimplementedError('get() not implemented');
  }

  /// Fires when children are added.
  Stream<DatabaseEventPlatform> onChildAdded(QueryModifiers modifiers) =>
      observe(modifiers, DatabaseEventType.childAdded);

  /// Fires when children are removed. `previousChildKey` is null.
  Stream<DatabaseEventPlatform> onChildRemoved(QueryModifiers modifiers) =>
      observe(modifiers, DatabaseEventType.childRemoved);

  /// Fires when children are changed.
  Stream<DatabaseEventPlatform> onChildChanged(QueryModifiers modifiers) =>
      observe(modifiers, DatabaseEventType.childChanged);

  /// Fires when children are moved.
  Stream<DatabaseEventPlatform> onChildMoved(QueryModifiers modifiers) =>
      observe(modifiers, DatabaseEventType.childMoved);

  /// Fires when the data at this location is updated. `previousChildKey` is null.
  Stream<DatabaseEventPlatform> onValue(QueryModifiers modifiers) =>
      observe(modifiers, DatabaseEventType.value);

  /// By calling keepSynced(true) on a location, the data for that location will
  /// automatically be downloaded and kept in sync, even when no listeners are
  /// attached for that location. Additionally, while a location is kept synced,
  /// it will not be evicted from the persistent disk cache.
  Future<void> keepSynced(QueryModifiers modifiers, bool value) {
    throw UnimplementedError('keepSynced() not implemented');
  }
}
