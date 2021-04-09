// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
// ignore: implementation_imports
import 'package:firebase_core/src/internals.dart';

import 'method_channel_document_change.dart';

/// An implementation of [QuerySnapshotPlatform] that uses [MethodChannel] to
/// communicate with Firebase plugins.
class MethodChannelQuerySnapshot extends QuerySnapshotPlatform {
  /// Creates a [MethodChannelQuerySnapshot] from the given [data]
  MethodChannelQuerySnapshot(
    FirebaseFirestorePlatform firestore,
    Map<Object?, Object?> data,
  ) : super(
          data['documents'].safeCast<List<Object?>>().guard((documents) {
            final paths = (data['paths']! as List<Object?>).cast<String>();
            final metadatas = (data['metadatas']! as List<Object?>).cast<Map>();
            return <DocumentSnapshotPlatform>[
              for (var i = 0; i < documents.length; i++)
                DocumentSnapshotPlatform(
                  firestore,
                  paths[i],
                  <String, dynamic>{
                    'data': Map<String, dynamic>.from(documents[i]! as Map),
                    'metadata': <String, dynamic>{
                      'isFromCache': metadatas[i]['isFromCache'],
                      'hasPendingWrites': metadatas[i]['hasPendingWrites'],
                    },
                  },
                )
            ];
          })!,
          data['documentChanges']
              .safeCast<List<Object?>>()!
              .cast<Map<Object?, Object?>>()
              .map((change) => MethodChannelDocumentChange(
                    firestore,
                    Map<String, dynamic>.from(change),
                  ))
              .toList(),
          data['metadata'].safeCast<Map<Object?, Object?>>().guard((metadata) {
            return SnapshotMetadataPlatform(
              metadata['hasPendingWrites']! as bool,
              metadata['isFromCache']! as bool,
            );
          })!,
        );
}
