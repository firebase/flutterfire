// ignore_for_file: require_trailing_commas
// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_platform_interface/src/pigeon/messages.pigeon.dart';
import 'package:collection/collection.dart';

import 'method_channel_document_change.dart';

/// An implementation of [QuerySnapshotPlatform] that uses [MethodChannel] to
/// communicate with Firebase plugins.
class MethodChannelQuerySnapshot extends QuerySnapshotPlatform {
  /// Creates a [MethodChannelQuerySnapshot] from the given [data]
  MethodChannelQuerySnapshot(
      FirebaseFirestorePlatform firestore, PigeonQuerySnapshot data)
      : super(
            List<DocumentSnapshotPlatform?>.generate(data.documents.length,
                (int index) {
              final document = data.documents[index];
              if (document == null) {
                return null;
              }
              return DocumentSnapshotPlatform(
                firestore,
                document.path,
                <String, dynamic>{
                  'data': Map<String, dynamic>.from(document.data),
                  'metadata': <String, dynamic>{
                    'isFromCache': document.metadata.isFromCache,
                    'hasPendingWrites': document.metadata.hasPendingWrites,
                  },
                },
              );
            }).whereNotNull().toList(),
            List<DocumentChangePlatform>.generate(
                data['documentChanges'].length, (int index) {
              return MethodChannelDocumentChange(
                firestore,
                Map<String, dynamic>.from(data['documentChanges'][index]),
              );
            }),
            SnapshotMetadataPlatform(
              data['metadata']['hasPendingWrites'],
              data['metadata']['isFromCache'],
            ));
}
