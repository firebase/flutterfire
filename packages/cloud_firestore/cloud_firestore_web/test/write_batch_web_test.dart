// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn("chrome")
import 'package:cloud_firestore_web/src/write_batch_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'test_common.dart';

void main() {
  group("$WriteBatchWeb()", () {
    final mockWebTransaction = MockWebWriteBatch();
    final mockWebDocumentReference = MockWebDocumentReference();
    final mockDocumentReference = MockDocumentReference();
    final transaction = WriteBatchWeb(mockWebTransaction);

    setUp(() {
      when(mockDocumentReference.delegate).thenReturn(mockWebDocumentReference);
    });

    test("delete", () async {
      await transaction.delete(mockDocumentReference);
      verify(mockWebTransaction.delete(mockWebDocumentReference));
    });

    test("setData", () async {
      await transaction.setData(mockDocumentReference, {});
      verify(mockWebTransaction.set(mockWebDocumentReference, {}, null));
    });

    test("updateData", () async {
      await transaction.updateData(mockDocumentReference, {});
      verify(mockWebTransaction.update(mockWebDocumentReference,
          data: argThat(equals({}), named: "data")));
    });
  });
}
