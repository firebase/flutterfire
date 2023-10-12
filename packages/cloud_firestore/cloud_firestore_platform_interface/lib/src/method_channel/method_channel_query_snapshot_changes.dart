// ignore_for_file: require_trailing_commas
// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

import 'method_channel_document_change.dart';

/// An implementation of [QuerySnapshotChangesPlatform] that uses [MethodChannel] to
/// communicate with Firebase plugins.
class MethodChannelQuerySnapshotChanges extends QuerySnapshotChangesPlatform {
  /// Creates a [MethodChannelQuerySnapshotChanges] from the given [data]
  MethodChannelQuerySnapshotChanges(
      FirebaseFirestorePlatform firestore, Map<dynamic, dynamic> data)
      : super(
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
