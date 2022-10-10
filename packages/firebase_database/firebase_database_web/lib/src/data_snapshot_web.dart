// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_database_web;

/// Web implementation for firebase [DataSnapshotPlatform]
class DataSnapshotWeb extends DataSnapshotPlatform {
  final database_interop.DataSnapshot _delegate;

  DataSnapshotWeb(DatabaseReferencePlatform ref, this._delegate)
      : super(ref, <String, dynamic>{
          'key': _delegate.key,
          'value': _delegate.val(),
          'priority': _delegate.getPriority(),
        });

  @override
  DataSnapshotPlatform child(String childPath) {
    return DataSnapshotWeb(ref, _delegate.child(childPath));
  }

  @override
  Iterable<DataSnapshotPlatform> get children {
    List<database_interop.DataSnapshot> snapshots = [];

    // This creates an in-order array
    _delegate.forEach((snapshot) {
      snapshots.add(snapshot);
    });

    return Iterable<DataSnapshotPlatform>.generate(snapshots.length,
        (int index) {
      database_interop.DataSnapshot snapshot = snapshots[index];
      return DataSnapshotWeb(ref.child(snapshot.key), snapshot);
    });
  }
}
