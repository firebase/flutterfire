// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

import 'interop/firestore.dart' as firestore_interop;
import 'utils/codec_utility.dart';
import 'utils/web_utils.dart';
import 'utils/exception.dart';

/// A web specific implementation of [Transaction].
class TransactionWeb extends TransactionPlatform {
  final firestore_interop.Firestore _webFirestoreDelegate;
  final firestore_interop.Transaction _webTransactionDelegate;

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

      return convertWebDocumentSnapshot(_firestore, webDocumentSnapshot);
    } catch (e) {
      throw getFirebaseException(e);
    }
  }

  @override
  TransactionWeb set(String documentPath, Map<String, dynamic> data,
      [SetOptions? options]) {
    _webTransactionDelegate.set(_webFirestoreDelegate.doc(documentPath),
        CodecUtility.encodeMapData(data)!, convertSetOptions(options));
    return this;
  }

  @override
  TransactionWeb update(
    String documentPath,
    Map<String, dynamic> data,
  ) {
    _webTransactionDelegate.update(_webFirestoreDelegate.doc(documentPath),
        CodecUtility.encodeMapData(data)!);
    return this;
  }
}
