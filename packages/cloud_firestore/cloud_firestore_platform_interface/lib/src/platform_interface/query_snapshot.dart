// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

/// A QuerySnapshot contains zero or more DocumentSnapshot objects.
class QuerySnapshotPlatform extends PlatformInterface {
  /// Create a [QuerySnapshotPlatform]
  QuerySnapshotPlatform(
    this.documents,
    this.documentChanges,
    this.metadata,
  ) : super(token: _token);

  static final Object _token = Object();

  /// Throws an [AssertionError] if [instance] does not extend
  /// [QuerySnapshotPlatform].
  ///
  /// This is used by the app-facing [QuerySnapshot] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static verifyExtends(QuerySnapshotPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
  }

  /// Gets a list of all the documents included in this snapshot
  final List<DocumentSnapshotPlatform> documents;

  /// An array of the documents that changed since the last snapshot. If this
  /// is the first snapshot, all documents will be in the list as Added changes.
  final List<DocumentChangePlatform> documentChanges;

  /// Metadata for the document
  final SnapshotMetadataPlatform metadata;
}
