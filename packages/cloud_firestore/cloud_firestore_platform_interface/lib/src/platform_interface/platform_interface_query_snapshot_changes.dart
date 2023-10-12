// ignore_for_file: require_trailing_commas
// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// A interface that contains zero or more [DocumentSnapshotChangesPlatform] objects
/// representing the results of a query.
///
/// The document changes can be accessed as a list by calling [docChanges()]
/// and the number of documents with changes can be determined by calling [size()].
class QuerySnapshotChangesPlatform extends PlatformInterface {
  /// Create a [QuerySnapshotChangesPlatform]
  QuerySnapshotChangesPlatform(
    this.docChanges,
    this.metadata,
  ) : super(token: _token);

  static final Object _token = Object();

  /// Throws an [AssertionError] if [instance] does not extend
  /// [QuerySnapshotChangesPlatform].
  ///
  /// This is used by the app-facing [QuerySnapshotChanges] to ensure that
  /// the object in which it's going to delegate calls has been
  /// constructed properly.
  static void verify(QuerySnapshotChangesPlatform instance) {
    PlatformInterface.verify(instance, _token);
  }

  /// An array of the documents that changed since the last snapshot. If this
  /// is the first snapshot, all documents will be in the list as Added changes.
  final List<DocumentChangePlatform> docChanges;

  /// Metadata for the document
  final SnapshotMetadataPlatform metadata;

  /// The number of documents with changes in this [QuerySnapshotChangesPlatform].
  int get size => docChanges.length;
}
