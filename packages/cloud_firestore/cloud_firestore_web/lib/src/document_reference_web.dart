// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase/firestore.dart' as web;

import 'package:cloud_firestore_web/src/collection_reference_web.dart';
import 'package:cloud_firestore_web/src/utils/document_reference_utils.dart';
import 'package:cloud_firestore_web/src/utils/codec_utility.dart';

/// Web implementation for firestore [DocumentReferencePlatform]
class DocumentReferenceWeb extends DocumentReferencePlatform {
  /// instance of Firestore from the web plugin
  final web.Firestore firestoreWeb;

  /// instance of DocumentReference from the web plugin
  final web.DocumentReference delegate;

  /// Creates an instance of [CollectionReferenceWeb] which represents path
  /// at [pathComponents] and uses implementation of [firestoreWeb]
  DocumentReferenceWeb(
    this.firestoreWeb,
    FirestorePlatform firestore,
    List<String> pathComponents,
  )   : delegate = firestoreWeb.doc(pathComponents.join("/")),
        super(firestore, pathComponents);

  @override
  Future<void> setData(
    Map<String, dynamic> data, {
    bool merge = false,
  }) =>
      delegate.set(
        CodecUtility.encodeMapData(data),
        web.SetOptions(merge: merge),
      );

  @override
  Future<void> updateData(Map<String, dynamic> data) =>
      delegate.update(data: CodecUtility.encodeMapData(data));

  @override
  Future<DocumentSnapshotPlatform> get({
    Source source = Source.serverAndCache,
  }) async {
    return fromWebDocumentSnapshotToPlatformDocumentSnapshot(
        await delegate.get(), this.firestore);
  }

  @override
  Future<void> delete() => delegate.delete();

  @override
  Stream<DocumentSnapshotPlatform> snapshots({
    bool includeMetadataChanges = false,
  }) {
    Stream<web.DocumentSnapshot> querySnapshots = delegate.onSnapshot;
    if (includeMetadataChanges) {
      querySnapshots = delegate.onMetadataChangesSnapshot;
    }
    return querySnapshots.map((webSnapshot) =>
        fromWebDocumentSnapshotToPlatformDocumentSnapshot(
            webSnapshot, this.firestore));
  }
}
