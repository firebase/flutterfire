// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../cloud_firestore.dart';

/// Provides methods to create pipelines from different sources
class PipelineSource {
  final FirebaseFirestore _firestore;

  PipelineSource._(this._firestore);

  /// Creates a pipeline from a collection path
  Pipeline collection(String collectionPath) {
    if (collectionPath.isEmpty) {
      throw ArgumentError('A collection path must be a non-empty string.');
    } else if (collectionPath.contains('//')) {
      throw ArgumentError('A collection path must not contain "//".');
    }

    final stage = _CollectionPipelineStage(collectionPath);
    final delegate = _firestore._delegate.pipeline([stage.toMap()]);
    return Pipeline._(_firestore, delegate);
  }

  /// Creates a pipeline from a collection reference
  Pipeline collectionReference(
      CollectionReference<Map<String, dynamic>> collectionReference) {
    final stage = _CollectionPipelineStage(collectionReference.path);
    final delegate = _firestore._delegate.pipeline([stage.toMap()]);
    return Pipeline._(_firestore, delegate);
  }

  /// Creates a pipeline from a collection group
  Pipeline collectionGroup(String collectionId) {
    if (collectionId.isEmpty) {
      throw ArgumentError('A collection ID must be a non-empty string.');
    } else if (collectionId.contains('/')) {
      throw ArgumentError(
        'A collection ID passed to collectionGroup() cannot contain "/".',
      );
    }

    final stage = _CollectionGroupPipelineStage(collectionId);
    final delegate = _firestore._delegate.pipeline([stage.toMap()]);
    return Pipeline._(_firestore, delegate);
  }

  /// Creates a pipeline from a list of document references
  Pipeline documents(List<DocumentReference<Map<String, dynamic>>> documents) {
    if (documents.isEmpty) {
      throw ArgumentError('Documents list must not be empty.');
    }

    final stage = _DocumentsPipelineStage(documents);
    final delegate = _firestore._delegate.pipeline([stage.toMap()]);
    return Pipeline._(_firestore, delegate);
  }

  /// Creates a pipeline from the entire database
  Pipeline database() {
    final stage = _DatabasePipelineStage();
    final delegate = _firestore._delegate.pipeline([stage.toMap()]);
    return Pipeline._(_firestore, delegate);
  }
}
