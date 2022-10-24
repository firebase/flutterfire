// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/type.dart';

class QuerySnapshotTemplate {
  QuerySnapshotTemplate({
    required this.queryDocumentSnapshotName,
    required this.querySnapshotName,
    required this.documentSnapshotName,
    required this.type,
  });

  final String queryDocumentSnapshotName;
  final String querySnapshotName;
  final String documentSnapshotName;
  final DartType type;

  @override
  String toString() {
    return '''
class $querySnapshotName extends FirestoreQuerySnapshot<$type, $queryDocumentSnapshotName> {
  $querySnapshotName._(
    this.snapshot,
    this.docs,
    this.docChanges,
  );

  factory $querySnapshotName._fromQuerySnapshot(
    QuerySnapshot<$type> snapshot,
  ) {
    final docs = snapshot
      .docs
      .map($queryDocumentSnapshotName._)
      .toList();

    final docChanges = snapshot.docChanges.map((change) {
      return _decodeDocumentChange(
        change,
        $documentSnapshotName._,
      );
    }).toList();

    return $querySnapshotName._(
      snapshot,
      docs,
      docChanges,
    );
  }

  static FirestoreDocumentChange<$documentSnapshotName> _decodeDocumentChange<T>(
    DocumentChange<T> docChange,
    $documentSnapshotName Function(DocumentSnapshot<T> doc) decodeDoc,
  ) {
    return FirestoreDocumentChange<$documentSnapshotName>(
      type: docChange.type,
      oldIndex: docChange.oldIndex,
      newIndex: docChange.newIndex,
      doc: decodeDoc(docChange.doc),
    );
  }

  final QuerySnapshot<$type> snapshot;

  @override
  final List<$queryDocumentSnapshotName> docs;

  @override
  final List<FirestoreDocumentChange<$documentSnapshotName>> docChanges;
}
''';
  }
}
