// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:firebase/firestore.dart' as web;

import 'package:cloud_firestore_web/src/utils/codec_utility.dart';
import 'package:cloud_firestore_web/src/document_reference_web.dart';

/// A web specific for [WriteBatch]
class WriteBatchWeb extends WriteBatchPlatform {
  final web.WriteBatch _delegate;

  /// Constructor.
  WriteBatchWeb(this._delegate);

  @override
  Future<void> commit() async {
    await _delegate.commit();
  }

  @override
  void delete(DocumentReferencePlatform document) {
    assert(document is DocumentReferenceWeb);
    _delegate.delete((document as DocumentReferenceWeb).delegate);
  }

  @override
  void setData(
    DocumentReferencePlatform document,
    Map<String, dynamic> data, {
    bool merge = false,
  }) {
    assert(document is DocumentReferenceWeb);
    _delegate.set(
        (document as DocumentReferenceWeb).delegate,
        CodecUtility.encodeMapData(data),
        merge ? web.SetOptions(merge: merge) : null);
  }

  @override
  void updateData(
    DocumentReferencePlatform document,
    Map<String, dynamic> data,
  ) {
    assert(document is DocumentReferenceWeb);
    _delegate.update((document as DocumentReferenceWeb).delegate,
        data: CodecUtility.encodeMapData(data));
  }
}
