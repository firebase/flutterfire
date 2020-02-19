// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn("chrome")
import 'package:cloud_firestore_web/src/transaction_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'test_common.dart';

void main() {
  group("$TransactionWeb()", () {
    final mockWebTransaction = MockWebTransaction();
    final mockWebDocumentReference = MockWebDocumentReference();
    final mockDocumentReference = MockDocumentReference();
    final mockFirestore = MockFirestore();
    final transaction = TransactionWeb(mockWebTransaction, mockFirestore);

    setUp(() {
      when(mockDocumentReference.delegate).thenReturn(mockWebDocumentReference);
    });

    test("delete", () async {
      await transaction.delete(mockDocumentReference);
      verify(mockWebTransaction.delete(mockWebDocumentReference));
    });

    test("get", () async {
      final mockWebSnapshot = MockWebDocumentSnapshot();
      final mockWebDocumentReference = MockWebDocumentReference();
      final mockWebSnapshotMetaData = MockWebSnapshotMetaData();
      when(mockWebSnapshotMetaData.hasPendingWrites).thenReturn(true);
      when(mockWebSnapshotMetaData.fromCache).thenReturn(true);
      when(mockWebDocumentReference.path).thenReturn("test/path");
      when(mockWebSnapshot.ref).thenReturn(mockWebDocumentReference);
      when(mockWebSnapshot.data()).thenReturn(Map());
      when(mockWebSnapshot.metadata).thenReturn(mockWebSnapshotMetaData);

      when(mockWebTransaction.get(any))
          .thenAnswer((_) => Future.value(mockWebSnapshot));
      await transaction.get(mockDocumentReference);
      verify(mockWebTransaction.get(any));
    });

    test("set", () async {
      await transaction.set(mockDocumentReference, {});
      verify(mockWebTransaction.set(mockWebDocumentReference, {}));
    });

    test("update", () async {
      await transaction.update(mockDocumentReference, {});
      verify(mockWebTransaction.update(mockWebDocumentReference,
          data: argThat(equals({}), named: "data")));
    });
  });
}
