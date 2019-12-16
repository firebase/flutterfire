// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore_platform_interface;

/// A CollectionReference object can be used for adding documents, getting
/// document references, and querying for documents (using the methods
/// inherited from [Query]).
abstract class CollectionReference extends Query {
  CollectionReference(FirestorePlatform firestore, List<String> pathComponents)
      : super(firestore: firestore, pathComponents: pathComponents);

  /// ID of the referenced collection.
  String get id => pathComponents.isEmpty ? null : pathComponents.last;

  /// For subcollections, parent returns the containing [DocumentReference].
  ///
  /// For root collections, null is returned.
  DocumentReference parent() {
    throw UnimplementedError("parent() is not implemented");
  }
  
  /// Returns a `DocumentReference` with the provided path.
  ///
  /// If no [path] is provided, an auto-generated ID is used.
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  DocumentReference document([String path]) {
    throw UnimplementedError("document() is not implemented");
  }

  /// Returns a `DocumentReference` with an auto-generated ID, after
  /// populating it with provided [data].
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  Future<DocumentReference> add(Map<String, dynamic> data) async {
    throw UnimplementedError("add() is not implemented");
  }
}
