// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

import 'method_channel_document_change.dart';
import 'utils/maps.dart';

/// Contains zero or more [DocumentSnapshotPlatform] objects.
class MethodChannelQuerySnapshot extends QuerySnapshotPlatform {
  /// Creates a [MethodChannelQuerySnapshot] from the given [data]
  MethodChannelQuerySnapshot(
      Map<dynamic, dynamic> data, FirestorePlatform firestore)
      : super(
            List<DocumentSnapshotPlatform>.generate(data['documents'].length,
                (int index) {
              return DocumentSnapshotPlatform(
                data['paths'][index],
                asStringKeyedMap(data['documents'][index]),
                SnapshotMetadataPlatform(
                  data['metadatas'][index]['hasPendingWrites'],
                  data['metadatas'][index]['isFromCache'],
                ),
                firestore,
              );
            }),
            List<DocumentChangePlatform>.generate(
                data['documentChanges'].length, (int index) {
              return MethodChannelDocumentChange(
                data['documentChanges'][index],
                firestore,
              );
            }),
            SnapshotMetadataPlatform(
              data['metadata']['hasPendingWrites'],
              data['metadata']['isFromCache'],
            ));
}
