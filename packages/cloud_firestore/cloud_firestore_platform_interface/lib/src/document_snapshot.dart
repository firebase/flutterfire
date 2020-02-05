// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

/// Contains data read from a document in your Firestore
/// database.
///
/// The data can be extracted with the [data] property or by using subscript
/// syntax to access a specific field.
class DocumentSnapshotPlatform {
  /// Constructs a [DocumentSnapshotPlatform] using the provided [FirestorePlatform].
  DocumentSnapshotPlatform(
      this._path, this.data, this.metadata, this.firestore);

  final String _path;

  /// The [FirestorePlatform] used to produce this [DocumentSnapshotPlatform].
  final FirestorePlatform firestore;

  /// The reference that produced this snapshot.
  DocumentReferencePlatform get reference => firestore.document(_path);

  /// Contains all the data of this snapshot.
  final Map<String, dynamic> data;

  /// Metadata about this snapshot concerning its source and if it has local
  /// modifications.
  final SnapshotMetadataPlatform metadata;

  /// Reads individual values from the snapshot.
  dynamic operator [](String key) => data[key];

  /// The database ID of the snapshot's document.
  String get documentID => _path.split('/').last;

  /// Returns `true` if the document exists.
  bool get exists => data != null;
}
