// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database;

/// A DataSnapshot contains data from a Firebase Database location.
/// Any time you read Firebase data, you receive the data as a DataSnapshot.
class DataSnapshot {
  final DataSnapshotPlatform _delegate;

  DataSnapshot._(this._delegate) {
    DataSnapshotPlatform.verify(_delegate);
  }

  /// The key of the location that generated this DataSnapshot or null if at
  /// database root.
  String? get key => _delegate.key;

  /// The Reference for the location that generated this DataSnapshot.
  DatabaseReference get ref => DatabaseReference._(_delegate.ref);

  /// Returns the contents of this data snapshot as native types.
  Object? get value => _delegate.value;

  /// Gets the priority value of the data in this [DataSnapshot] or null if no
  /// priority set.
  Object? get priority => _delegate.priority;

  /// Ascertains whether the value exists at the Firebase Database location.
  bool get exists => _delegate.exists;

  /// Returns true if the specified child path has (non-null) data.
  bool hasChild(String path) => _delegate.hasChild(path);

  /// Gets another [DataSnapshot] for the location at the specified relative path.
  /// The relative path can either be a simple child name (for example, "ada")
  /// or a deeper, slash-separated path (for example, "ada/name/first").
  /// If the child location has no data, an empty DataSnapshot (that is, a
  /// DataSnapshot whose [value] is null) is returned.
  DataSnapshot child(String path) => DataSnapshot._(_delegate.child(path));

  /// An iterator for snapshots of the child nodes in this snapshot.
  Iterable<DataSnapshot> get children => _delegate.children.map(DataSnapshot._);
}
