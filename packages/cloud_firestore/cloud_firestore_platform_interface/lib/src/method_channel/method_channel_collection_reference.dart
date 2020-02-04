// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:async';

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';

import 'method_channel_query.dart';
import 'method_channel_document_reference.dart';
import 'utils/auto_id_generator.dart';

/// A CollectionReference object can be used for adding documents, getting
/// document references, and querying for documents (using the methods
/// inherited from [QueryPlatform]).
///
/// Note that this class *should* extend [CollectionReferencePlatform], but
/// it doesn't because of the extensive changes required to [MethodChannelQuery]
/// (which *does* extend its Platform class). If you changed
/// [CollectionReferencePlatform] and this class started throwing compilation
/// errors, now you know why.
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
