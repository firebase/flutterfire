// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase/firestore.dart' as web;

import 'package:cloud_firestore_web/src/utils/codec_utility.dart';
import 'package:cloud_firestore_web/src/utils/document_reference_utils.dart';
import 'package:cloud_firestore_web/src/document_reference_web.dart';

/// A web specific for [Transaction]
class TransactionWeb extends TransactionPlatform {
  final web.Transaction _webTransaction;
  @override
  FirestorePlatform firestore;

  /// Constructor.
  TransactionWeb(this._webTransaction, this.firestore) : super(firestore);

  @override
  Future<void> delete(DocumentReferencePlatform documentReference) async {
    assert(documentReference is DocumentReferenceWeb);
    await _webTransaction
        .delete((documentReference as DocumentReferenceWeb).delegate);
  }

  @override
  Future<DocumentSnapshotPlatform> get(
    DocumentReferencePlatform documentReference,
  ) async {
    assert(documentReference is DocumentReferenceWeb);
    final webSnapshot = await _webTransaction
        .get((documentReference as DocumentReferenceWeb).delegate);
    return fromWebDocumentSnapshotToPlatformDocumentSnapshot(
        webSnapshot, this.firestore);
  }

  @override
  Future<void> set(
    DocumentReferencePlatform documentReference,
    Map<String, dynamic> data,
  ) async {
    assert(documentReference is DocumentReferenceWeb);
    await _webTransaction.set(
        (documentReference as DocumentReferenceWeb).delegate,
        CodecUtility.encodeMapData(data));
  }

  @override
  Future<void> update(
    DocumentReferencePlatform documentReference,
    Map<String, dynamic> data,
  ) async {
    assert(documentReference is DocumentReferenceWeb);
    await _webTransaction.update(
        (documentReference as DocumentReferenceWeb).delegate,
        data: CodecUtility.encodeMapData(data));
  }

  @override
  Future<void> finish() {
    return Future.value();
  }
}
