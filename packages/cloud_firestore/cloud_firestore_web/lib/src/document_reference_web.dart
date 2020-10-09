// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/src/utils/exception.dart';
import 'package:firebase/firestore.dart' as web;

import 'package:cloud_firestore_web/src/utils/web_utils.dart';
import 'package:cloud_firestore_web/src/utils/codec_utility.dart';

/// Web implementation for Firestore [DocumentReferencePlatform].
class DocumentReferenceWeb extends DocumentReferencePlatform {
  /// instance of Firestore from the web plugin
  final web.Firestore firestoreWeb;

  /// instance of DocumentReference from the web plugin
  final web.DocumentReference _delegate;

  /// Creates an instance of [DocumentReferenceWeb] which represents path
  /// at [pathComponents] and uses implementation of [firestoreWeb]
  DocumentReferenceWeb(
    FirebaseFirestorePlatform firestore,
    this.firestoreWeb,
    String path,
  )   : _delegate = firestoreWeb.doc(path),
        super(firestore, path);

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions options]) async {
    try {
      await _delegate.set(
        CodecUtility.encodeMapData(data),
        // TODO(ehesp): `mergeFields` missing from web implementation
        options != null ? web.SetOptions(merge: options.merge) : null,
      );
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<void> update(Map<String, dynamic> data) async {
    try {
      await _delegate.update(data: CodecUtility.encodeMapData(data));
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<DocumentSnapshotPlatform> get([GetOptions options]) async {
    // TODO(ehesp): web implementation not handling options
    try {
      web.DocumentSnapshot documentSnapshot = await _delegate.get();
      return convertWebDocumentSnapshot(this.firestore, documentSnapshot);
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<void> delete() async {
    try {
      await _delegate.delete();
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Stream<DocumentSnapshotPlatform> snapshots({
    bool includeMetadataChanges = false,
  }) {
    Stream<web.DocumentSnapshot> querySnapshots = _delegate.onSnapshot;
    if (includeMetadataChanges) {
      querySnapshots = _delegate.onMetadataChangesSnapshot;
    }
    return querySnapshots
        .map((webSnapshot) =>
            convertWebDocumentSnapshot(this.firestore, webSnapshot))
        .handleError((e) {
      throw convertPlatformException(e);
    });
  }
}
