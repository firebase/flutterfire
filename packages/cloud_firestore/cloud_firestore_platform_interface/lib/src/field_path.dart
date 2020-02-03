// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'internal/field_path_type.dart';

/// A [FieldPath] refers to a field in a document.
class FieldPath {
  const FieldPath._(this.type);

  /// The type of this field path (used in [FirestoreMessageCodec])
  final FieldPathType type;

  /// The path to the document id, which can be used in queries.
  static FieldPath get documentId =>
      const FieldPath._(FieldPathType.documentId);
}
