// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore_platform_interface;

/// A CollectionReference object can be used for adding documents, getting
/// document references, and querying for documents (using the methods
/// inherited from [Query]).
class MethodChannelCollectionReference extends CollectionReference {
  MethodChannelCollectionReference(FirestorePlatform firestore, List<String> pathComponents)
      : super(firestore,pathComponents);

  /// ID of the referenced collection.
  String get id => _pathComponents.isEmpty ? null : _pathComponents.last;

  @override
  DocumentReference parent() {
    if (_pathComponents.length < 2) {
      return null;
    }
    return MethodChannelDocumentReference(
      firestore,
      (List<String>.from(_pathComponents)..removeLast()),
    );
  }

  @override
  DocumentReference document([String path]) {
    List<String> childPath;
    if (path == null) {
      final String key = AutoIdGenerator.autoId();
      childPath = List<String>.from(_pathComponents)..add(key);
    } else {
      childPath = List<String>.from(_pathComponents)..addAll(path.split(('/')));
    }
    return MethodChannelDocumentReference(firestore, childPath);
  }

  @override
  Future<DocumentReference> add(Map<String, dynamic> data) async {
    final DocumentReference newDocument = document();
    await newDocument.setData(data);
    return newDocument;
  }
}
