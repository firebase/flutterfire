// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../collection_generator.dart';
import 'template.dart';

class DocumentSnapshotTemplate extends Template<CollectionData> {
  @override
  String generate(CollectionData data) {
    return '''
class ${data.documentSnapshotName} extends FirestoreDocumentSnapshot<${data.type}> {
  ${data.documentSnapshotName}._(
    this.snapshot,
    this.data,
  );

  @override
  final DocumentSnapshot<${data.type}> snapshot;

  @override
  ${data.documentReferenceName} get reference {
    return ${data.documentReferenceName}(
      snapshot.reference,
    );
  }

  @override
  final ${data.type}? data;
}
''';
  }
}
