// Copyright 2018, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore_platform_interface;

/// A [WriteBatch] is a series of write operations to be performed as one unit.
///
/// Operations done on a [WriteBatch] do not take effect until you [commit].
///
/// Once committed, no further operations can be performed on the [WriteBatch],
/// nor can it be committed again.
abstract class WriteBatchPlatform {
  WriteBatchPlatform._();
  
  final List<Future<dynamic>> _actions = <Future<dynamic>>[];

  /// Indicator to whether or not this [WriteBatch] has been committed.
  bool _committed = false;

  /// Commits all of the writes in this write batch as a single atomic unit.
  ///
  /// Calling this method prevents any future operations from being added.
  Future<void> commit() async {
    throw UnimplementedError("commit() not implemented");
  }

  /// Deletes the document referred to by [document].
  void delete(DocumentReference document) {
    throw UnimplementedError("commit() not implemented");
  }

  /// Writes to the document referred to by [document].
  ///
  /// If the document does not yet exist, it will be created.
  ///
  /// If [merge] is true, the provided data will be merged into an
  /// existing document instead of overwriting.
  void setData(DocumentReference document, Map<String, dynamic> data,
      {bool merge = false}) {
    throw UnimplementedError("commit() not implemented");
  }

  /// Updates fields in the document referred to by [document].
  ///
  /// If the document does not exist, the operation will fail.
  void updateData(DocumentReference document, Map<String, dynamic> data) {
    throw UnimplementedError("commit() not implemented");
  }
}
