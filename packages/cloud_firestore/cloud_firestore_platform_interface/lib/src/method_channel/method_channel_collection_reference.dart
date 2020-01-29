// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore_platform_interface;

/// A CollectionReference object can be used for adding documents, getting
/// document references, and querying for documents (using the methods
/// inherited from [QueryPlatform]).
class MethodChannelCollectionReference extends MethodChannelQuery
    implements CollectionReferencePlatform {
  /// Create a [MethodChannelCollectionReference] from [pathComponents]
  MethodChannelCollectionReference(
      FirestorePlatform firestore, List<String> pathComponents)
      : super(firestore: firestore, pathComponents: pathComponents);

  /// ID of the referenced collection.
  String get id => pathComponents.isEmpty ? null : pathComponents.last;

  @override
  DocumentReferencePlatform parent() {
    if (pathComponents.length < 2) {
      return null;
    }
    return MethodChannelDocumentReference(
      firestore,
      (List<String>.from(pathComponents)..removeLast()),
    );
  }

  @override
  DocumentReferencePlatform document([String path]) {
    List<String> childPath;
    if (path == null) {
      final String key = AutoIdGenerator.autoId();
      childPath = List<String>.from(pathComponents)..add(key);
    } else {
      childPath = List<String>.from(pathComponents)..addAll(path.split(('/')));
    }
    return MethodChannelDocumentReference(firestore, childPath);
  }

  @override
  Future<DocumentReferencePlatform> add(Map<String, dynamic> data) async {
    final DocumentReferencePlatform newDocument = document();
    await newDocument.setData(data);
    return newDocument;
  }
}
