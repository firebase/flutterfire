@TestOn("chrome")
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/firestore_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'test_common.dart';

void main() {
  group("$WriteBatch()", () {
    final mockWebTransaction = MockWebWriteBatch();
    final mockWebDocumentReference = MockWebDocumentReference();
    final mockDocumentReference = MockDocumentReference();
    final mockFirestore = MockFirestore();
    final transaction = WriteBatchWeb(mockWebTransaction);

    setUp(() {
      when(mockFirestore.appName()).thenReturn("test");
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
