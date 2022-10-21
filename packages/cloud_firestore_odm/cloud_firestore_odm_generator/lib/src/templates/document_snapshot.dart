// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/type.dart';

class DocumentSnapshotTemplate {
  DocumentSnapshotTemplate({
    required this.documentSnapshotName,
    required this.documentReferenceName,
    required this.type,
  });

  final String documentSnapshotName;
  final String documentReferenceName;
  final DartType type;

  @override
  String toString() {
    return '''
class $documentSnapshotName extends FirestoreDocumentSnapshot<$type> {
  $documentSnapshotName._(this.snapshot): data = snapshot.data();

  @override
  final DocumentSnapshot<$type> snapshot;

  @override
  $documentReferenceName get reference {
    return $documentReferenceName(
      snapshot.reference,
    );
  }

  @override
  final $type? data;
}
''';
  }
}
