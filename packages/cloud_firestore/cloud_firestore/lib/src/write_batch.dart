// Copyright 2018, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// A [WriteBatch] is a series of write operations to be performed as one unit.
///
/// Operations done on a [WriteBatch] do not take effect until you [commit].
///
/// Once committed, no further operations can be performed on the [WriteBatch],
/// nor can it be committed again.
class WriteBatch implements platform.WriteBatchPlatform {
  platform.WriteBatch _delegate;
  WriteBatch._(): _delegate = platform.WriteBatch(platform.FirestorePlatform.instance);

  @override
  Future<void> commit() => _delegate.commit();

  @override
  void delete(platform.DocumentReference document) => _delegate.delete(document);

  @override
  void setData(platform.DocumentReference document, Map<String, dynamic> data, {bool merge = false}) =>
      _delegate.setData(document, data, merge: merge);

  @override
  void updateData(platform.DocumentReference document, Map<String, dynamic> data) =>
      _delegate.updateData(document, data);

}
