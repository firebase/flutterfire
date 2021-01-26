// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_firestore;

/// A [QueryDocumentSnapshot] contains data read from a document in your [FirebaseFirestore]
/// database as part of a query.
///
/// A [QueryDocumentSnapshot] offers the same API surface as a [DocumentSnapshot].
/// Since query results contain only existing documents, the exists property
/// will always be `true` and [data()] will never return `null`.
class QueryDocumentSnapshot extends DocumentSnapshot {
  QueryDocumentSnapshot._(_firestore, _delegate)
      : super._(_firestore, _delegate);

  @override
  bool get exists => true;
}
