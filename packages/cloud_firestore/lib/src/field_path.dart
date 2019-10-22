// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// A [FieldPath] refers to a field in a document.
class FieldPath {
  /// The path to the document id, which can be used in queries.
  static String get documentId => '__name__';
}
