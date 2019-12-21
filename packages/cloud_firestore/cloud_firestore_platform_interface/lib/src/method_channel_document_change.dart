// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore_platform_interface;

/// A DocumentChange represents a change to the documents matching a query.
///
/// It contains the document affected and the type of change that occurred
/// (added, modified, or removed).
class MethodChannelDocumentChange extends DocumentChange {
  /// Create instance of [MethodChannelDocumentChange] using [data]
  MethodChannelDocumentChange(
      Map<dynamic, dynamic> data, FirestorePlatform firestore)
      : super(DocumentChangeType.values.firstWhere((DocumentChangeType type) {
          return type.toString() == data['type'];
        }),
            data['oldIndex'],
            data['newIndex'],
            DocumentSnapshot(
              data['path'],
              _asStringKeyedMap(data['document']),
              SnapshotMetadata(data['metadata']['hasPendingWrites'],
                  data['metadata']['isFromCache']),
              firestore,
            ));
}
