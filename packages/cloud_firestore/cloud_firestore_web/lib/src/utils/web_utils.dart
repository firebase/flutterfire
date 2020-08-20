// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase/firestore.dart' as web;

import 'package:cloud_firestore_web/src/utils/codec_utility.dart';

const _kChangeTypeAdded = "added";
const _kChangeTypeModified = "modified";
const _kChangeTypeRemoved = "removed";

/// Converts a [web.QuerySnapshot] to a [QuerySnapshotPlatform].
QuerySnapshotPlatform convertWebQuerySnapshot(
    FirebaseFirestorePlatform firestore, web.QuerySnapshot webQuerySnapshot) {
  return QuerySnapshotPlatform(
    webQuerySnapshot.docs
        .map((webDocumentSnapshot) =>
            convertWebDocumentSnapshot(firestore, webDocumentSnapshot))
        .toList(),
    webQuerySnapshot
        .docChanges()
        .map((webDocumentChange) =>
            convertWebDocumentChange(firestore, webDocumentChange))
        .toList(),
    convertWebSnapshotMetadata(webQuerySnapshot.metadata),
  );
}

/// Converts a [web.DocumentSnapshot] to a [DocumentSnapshotPlatform].
DocumentSnapshotPlatform convertWebDocumentSnapshot(
    FirebaseFirestorePlatform firestore, web.DocumentSnapshot webSnapshot) {
  return DocumentSnapshotPlatform(
    firestore,
    webSnapshot.ref.path,
    <String, dynamic>{
      'data': CodecUtility.decodeMapData(webSnapshot.data()),
      'metadata': <String, bool>{
        'hasPendingWrites': webSnapshot.metadata.hasPendingWrites,
        'isFromCache': webSnapshot.metadata.fromCache,
      },
    },
  );
}

/// Converts a [web.DocumentChange] to a [DocumentChangePlatform].
DocumentChangePlatform convertWebDocumentChange(
    FirebaseFirestorePlatform firestore, web.DocumentChange webDocumentChange) {
  return (DocumentChangePlatform(
      convertWebDocumentChangeType(webDocumentChange.type),
      webDocumentChange.oldIndex,
      webDocumentChange.newIndex,
      convertWebDocumentSnapshot(firestore, webDocumentChange.doc)));
}

/// Converts a [web.DocumentChange] type into a [DocumentChangeType].
DocumentChangeType convertWebDocumentChangeType(String changeType) {
  switch (changeType.toLowerCase()) {
    case _kChangeTypeAdded:
      return DocumentChangeType.added;
    case _kChangeTypeModified:
      return DocumentChangeType.modified;
    case _kChangeTypeRemoved:
      return DocumentChangeType.removed;
    default:
      throw FallThroughError();
  }
}

/// Converts a [web.SnapshotMetadata] to a [SnapshotMetadataPlatform].
SnapshotMetadataPlatform convertWebSnapshotMetadata(
    web.SnapshotMetadata webSnapshotMetadata) {
  return SnapshotMetadataPlatform(
      webSnapshotMetadata.hasPendingWrites, webSnapshotMetadata.fromCache);
}
