// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore_platform_interface;

enum _FieldPathType {
  documentId,
}

/// A [FieldPath] refers to a field in a document.
class FieldPath {
  const FieldPath._(this.type);

  @visibleForTesting
  // ignoring lint rule here as it's only visible for testing
  // ignore: public_member_api_docs
  final _FieldPathType type;

  /// The path to the document id, which can be used in queries.
  static FieldPath get documentId =>
      const FieldPath._(_FieldPathType.documentId);
}
