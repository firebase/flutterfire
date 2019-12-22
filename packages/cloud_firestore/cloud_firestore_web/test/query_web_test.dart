import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/firestore_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase/firestore.dart' as web;
import 'document_reference_web_test.dart';
import 'test_common.dart';

class MockWebQuery extends Mock implements web.Query {}
class MockFirestoreWeb extends Mock implements FirestoreWeb {}
class MockWebQuerySnapshot extends Mock implements web.QuerySnapshot {}
class MockWebSnapshotMetadata extends Mock implements web.SnapshotMetadata {}
class MockWebDocumentChange extends Mock implements web.DocumentChange {}

const _path = "test/query";

void main() {
  group("$QueryWeb()", (){
    final firestore = MockFirestoreWeb();
    final MockWebQuery mockWebQuery = MockWebQuery();
    QueryWeb query;

    setUp((){
      reset(mockWebQuery);
      query = QueryWeb(firestore, _path, mockWebQuery);
    });

    test("snapshots", (){
      when(mockWebQuery.onSnapshot).thenAnswer((_) => Stream.empty());
      when(mockWebQuery.onSnapshotMetadata).thenAnswer((_) => Stream.empty());
      query.snapshots();
      verify(mockWebQuery.onSnapshot);
      query.snapshots(includeMetadataChanges: false);
      verify(mockWebQuery.onSnapshot);
      query.snapshots(includeMetadataChanges: true);
      verify(mockWebQuery.onSnapshotMetadata);
    });

    test("getDocuments", () async {

      final mockMetaData = MockWebSnapshotMetadata();
      when(mockMetaData.fromCache).thenReturn(true);
      when(mockMetaData.hasPendingWrites).thenReturn(false);

      final mockDocumentReference = MockDocumentReference();
      when(mockDocumentReference.path).thenReturn("test/reference");

      final mockDocumentSnapshot = MockWebDocumentSnapshot();
      when(mockDocumentSnapshot.ref).thenReturn(mockDocumentReference);
      when(mockDocumentSnapshot.data()).thenReturn(Map<String,dynamic>());
      when(mockDocumentSnapshot.metadata).thenReturn(mockMetaData);

      final mockDocumentChange = MockWebDocumentChange();
      when(mockDocumentChange.type).thenReturn("added");
      when(mockDocumentChange.oldIndex).thenReturn(0);
      when(mockDocumentChange.newIndex).thenReturn(1);
      when(mockDocumentChange.doc).thenReturn(mockDocumentSnapshot);

      final mockQuerySnapshot = MockWebQuerySnapshot();
      when(mockQuerySnapshot.docs).thenReturn([]);
      when(mockQuerySnapshot.docChanges()).thenReturn([mockDocumentChange]);
      when(mockQuerySnapshot.metadata).thenReturn(mockMetaData);

      when(mockWebQuery.get()).thenAnswer((_) => Future.value(mockQuerySnapshot));
      final actual = await query.getDocuments();
      verify(mockWebQuery.get());
      expect(actual.documentChanges.first.type, equals(DocumentChangeType.added));


      when(mockDocumentChange.type).thenReturn("modified");
      expect((await query.getDocuments()).documentChanges.first.type, equals(DocumentChangeType.modified));

      when(mockDocumentChange.type).thenReturn("removed");
      expect((await query.getDocuments()).documentChanges.first.type, equals(DocumentChangeType.removed));
    });
  });
}