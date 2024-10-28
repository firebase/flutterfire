// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// [VectorQuery] represents the data at a particular location for retrieving metadata
/// without retrieving the actual documents.
class VectorQuery {
  VectorQuery._(this._delegate, this.query) {
    VectorQueryPlatform.verify(_delegate);
  }

  /// [Query] represents the query over the data at a particular location used by the [VectorQuery] to
  /// retrieve the metadata.
  final Query query;

  final VectorQueryPlatform _delegate;

  /// Returns an [VectorQuerySnapshot] with the count of the documents that match the query.
  Future<VectorQuerySnapshot> get({
    VectorSource source = VectorSource.server,
  }) async {
    return VectorQuerySnapshot._(await _delegate.get(source: source), query);
  }

  /// Represents an [VectorQuery] over the data at a particular location for retrieving metadata
  /// without retrieving the actual documents.
  VectorQuery count() {
    return VectorQuery._(_delegate.count(), query);
  }
}
