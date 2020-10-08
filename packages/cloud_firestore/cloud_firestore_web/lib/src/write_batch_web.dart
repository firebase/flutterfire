// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

import 'interop/firestore.dart' as firestore_interop;
import 'utils/exception.dart';
import 'utils/codec_utility.dart';

/// A web specific implementation of [WriteBatch].
class WriteBatchWeb extends WriteBatchPlatform {
  final firestore_interop.Firestore _webFirestoreDelegate;
  firestore_interop.WriteBatch _webWriteBatchDelegate;

  /// Constructor.
  WriteBatchWeb(this._webFirestoreDelegate)
      : _webWriteBatchDelegate = _webFirestoreDelegate.batch(),
        super();

  @override
  Future<void> commit() async {
    try {
      await _webWriteBatchDelegate.commit();
    } catch (e) {
      throw getFirebaseException(e);
    }
  }

  @override
  void delete(String documentPath) {
    _webWriteBatchDelegate.delete(_webFirestoreDelegate.doc(documentPath));
  }

  @override
  void set(String documentPath, Map<String, dynamic> data,
      [SetOptions options]) {
    _webWriteBatchDelegate.set(
        _webFirestoreDelegate.doc(documentPath),
        CodecUtility.encodeMapData(data),
        // TODO(ehesp): web implementation missing mergeFields support
        options != null ? firestore_interop.SetOptions(merge: options.merge) : null);
  }

  @override
  void update(
    String documentPath,
    Map<String, dynamic> data,
  ) {
    _webWriteBatchDelegate.update(_webFirestoreDelegate.doc(documentPath),
        data: CodecUtility.encodeMapData(data));
  }
}
