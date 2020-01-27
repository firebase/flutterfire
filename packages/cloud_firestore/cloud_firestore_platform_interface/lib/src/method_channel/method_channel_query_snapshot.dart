// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore_platform_interface;

/// Contains zero or more [DocumentSnapshot] objects.
class MethodChannelQuerySnapshot extends QuerySnapshot {
  /// Creates a [MethodChannelQuerySnapshot] from the given [data]
  MethodChannelQuerySnapshot(
      Map<dynamic, dynamic> data, FirestorePlatform firestore)
      : super(
            List<DocumentSnapshot>.generate(data['documents'].length,
                (int index) {
              return DocumentSnapshot(
                data['paths'][index],
                asStringKeyedMap(data['documents'][index]),
                SnapshotMetadata(
                  data['metadatas'][index]['hasPendingWrites'],
                  data['metadatas'][index]['isFromCache'],
                ),
                firestore,
              );
            }),
            List<DocumentChange>.generate(data['documentChanges'].length,
                (int index) {
              return MethodChannelDocumentChange(
                data['documentChanges'][index],
                firestore,
              );
            }),
            SnapshotMetadata(
              data['metadata']['hasPendingWrites'],
              data['metadata']['isFromCache'],
            ));
}
