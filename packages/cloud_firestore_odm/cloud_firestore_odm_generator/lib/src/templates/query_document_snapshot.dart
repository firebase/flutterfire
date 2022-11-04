// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/type.dart';

class QueryDocumentSnapshotTemplate {
  QueryDocumentSnapshotTemplate({
    required this.queryDocumentSnapshotName,
    required this.documentSnapshotName,
    required this.documentReferenceName,
    required this.type,
  });

  final String queryDocumentSnapshotName;
  final String documentSnapshotName;
  final String documentReferenceName;
  final DartType type;

  @override
  String toString() {
    return '''
class $queryDocumentSnapshotName extends FirestoreQueryDocumentSnapshot<$type> implements $documentSnapshotName {
  $queryDocumentSnapshotName._(this.snapshot): data = snapshot.data();

  @override
  final QueryDocumentSnapshot<$type> snapshot;

  @override
  final $type data;

  @override
  $documentReferenceName get reference {
    return $documentReferenceName(snapshot.reference);
  }
}
''';
  }
}
