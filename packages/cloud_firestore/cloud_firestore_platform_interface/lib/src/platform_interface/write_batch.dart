// Copyright 2018, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

/// A [WriteBatch] is a series of write operations to be performed as one unit.
///
/// Operations done on a [WriteBatch] do not take effect until you [commit].
///
/// Once committed, no further operations can be performed on the [WriteBatch],
/// nor can it be committed again.
abstract class WriteBatchPlatform extends PlatformInterface {
  /// Overridable constructor
  WriteBatchPlatform() : super(token: _token);

  static final Object _token = Object();

  /// Throws an [AssertionError] if [instance] does not extend
  /// [WriteBatchPlatform].
  /// This is used by the app-facing [WriteBatch] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static verifyExtends(WriteBatchPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  /// Commits all of the writes in this write batch as a single atomic unit.
  ///
  /// Calling this method prevents any future operations from being added.
  Future<void> commit() async {
    throw UnimplementedError("commit() not implemented");
  }

  /// Deletes the document referred to by [document].
  void delete(DocumentReferencePlatform document) {
    throw UnimplementedError("commit() not implemented");
  }

  /// Writes to the document referred to by [document].
  ///
  /// If the document does not yet exist, it will be created.
  ///
  /// If [merge] is true, the provided data will be merged into an
  /// existing document instead of overwriting.
  void setData(
    DocumentReferencePlatform document,
    Map<String, dynamic> data, {
    bool merge = false,
  }) {
    throw UnimplementedError("commit() not implemented");
  }

  /// Updates fields in the document referred to by [document].
  ///
  /// If the document does not exist, the operation will fail.
  void updateData(
    DocumentReferencePlatform document,
    Map<String, dynamic> data,
  ) {
    throw UnimplementedError("commit() not implemented");
  }
}
