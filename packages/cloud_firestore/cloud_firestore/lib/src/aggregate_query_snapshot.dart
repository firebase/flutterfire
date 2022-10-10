// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// [AggregateQuerySnapshot] represents a response to an [AggregateQuery] request.
class AggregateQuerySnapshot {
  AggregateQuerySnapshot._(this._delegate) {
    AggregateQuerySnapshotPlatform.verifyExtends(_delegate);
  }
  final AggregateQuerySnapshotPlatform _delegate;

  /// Returns the count of the documents that match the query.
  int get count => _delegate.count;
}
