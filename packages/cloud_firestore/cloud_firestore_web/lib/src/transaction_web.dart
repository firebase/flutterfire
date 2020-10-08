// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/src/utils/exception.dart';
import 'package:firebase/firestore.dart' as web;

import 'package:cloud_firestore_web/src/utils/codec_utility.dart';
import 'package:cloud_firestore_web/src/utils/web_utils.dart';

/// A web specific implementation of [Transaction].
class TransactionWeb extends TransactionPlatform {
  final web.Firestore _webFirestoreDelegate;
  final web.Transaction _webTransactionDelegate;

  FirebaseFirestorePlatform _firestore;

  /// Constructor.
  TransactionWeb(
      this._firestore, this._webFirestoreDelegate, this._webTransactionDelegate)
      : super();

  @override
  TransactionWeb delete(String documentPath) {
    _webTransactionDelegate.delete(_webFirestoreDelegate.doc(documentPath));
    return this;
  }

  @override
  Future<DocumentSnapshotPlatform> get(String documentPath) async {
    try {
      final webDocumentSnapshot = await _webTransactionDelegate
          .get(_webFirestoreDelegate.doc(documentPath));

      return convertWebDocumentSnapshot(this._firestore, webDocumentSnapshot);
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  TransactionWeb set(String documentPath, Map<String, dynamic> data,
      [SetOptions options]) {
    _webTransactionDelegate.set(
      _webFirestoreDelegate.doc(documentPath),
      CodecUtility.encodeMapData(data),
      // TODO(ehesp): web implementation missing mergeFields support
      options != null ? web.SetOptions(merge: options.merge) : null,
    );
    return this;
  }

  @override
  TransactionWeb update(
    String documentPath,
    Map<String, dynamic> data,
  ) {
    _webTransactionDelegate.update(_webFirestoreDelegate.doc(documentPath),
        data: CodecUtility.encodeMapData(data));
    return this;
  }
}
