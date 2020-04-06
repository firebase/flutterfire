// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn("chrome")
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase/firestore.dart' as web;
import 'package:cloud_firestore_web/src/query_web.dart';
import 'test_common.dart';

class MockWebQuery extends Mock implements web.Query {}

class MockFirestoreWeb extends Mock implements FirestoreWeb {}

class MockWebQuerySnapshot extends Mock implements web.QuerySnapshot {}

class MockWebSnapshotMetadata extends Mock implements web.SnapshotMetadata {}

class MockWebDocumentChange extends Mock implements web.DocumentChange {}

const _path = "test/query";

void main() {
  group("$QueryWeb()", () {
    final firestore = MockFirestoreWeb();
    final MockWebQuery mockWebQuery = MockWebQuery();
    QueryWeb query;

    setUp(() {
      reset(mockWebQuery);
      query = QueryWeb(firestore, _path, mockWebQuery);
    });

    test("snapshots", () {
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

      final mockDocumentReference = MockWebDocumentReference();
      when(mockDocumentReference.path).thenReturn("test/reference");

      final mockDocumentSnapshot = MockWebDocumentSnapshot();
      when(mockDocumentSnapshot.ref).thenReturn(mockDocumentReference);
      when(mockDocumentSnapshot.data()).thenReturn(Map<String, dynamic>());
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

      when(mockWebQuery.get())
          .thenAnswer((_) => Future.value(mockQuerySnapshot));
      final actual = await query.getDocuments();
      verify(mockWebQuery.get());
      expect(
          actual.documentChanges.first.type, equals(DocumentChangeType.added));

      when(mockDocumentChange.type).thenReturn("modified");
      expect((await query.getDocuments()).documentChanges.first.type,
          equals(DocumentChangeType.modified));

      when(mockDocumentChange.type).thenReturn("removed");
      expect((await query.getDocuments()).documentChanges.first.type,
          equals(DocumentChangeType.removed));
    });

    test("endAt", () {
      query.endAt([Timestamp.now()]);
      verify(mockWebQuery.endAt(
          fieldValues:
              argThat(contains(isA<DateTime>()), named: "fieldValues")));
    });

    test("endAtDocument", () {
      final DateTime date = DateTime.now();
      final mockDocumentSnapshot = MockDocumentSnapshot();
      when(mockDocumentSnapshot.data).thenReturn({
        'test': Timestamp.fromDate(date),
      });
      query.orderBy("test");
      query.endAtDocument(mockDocumentSnapshot);
      verify(mockWebQuery.endAt(
          fieldValues: argThat(equals([date]), named: "fieldValues")));
    });

    test("endBefore", () {
      query.endBefore([Timestamp.now()]);
      verify(mockWebQuery.endBefore(
          fieldValues:
              argThat(contains(isA<DateTime>()), named: "fieldValues")));
    });

    test("endBeforeDocument", () {
      final DateTime date = DateTime.now();
      final mockDocumentSnapshot = MockDocumentSnapshot();
      when(mockDocumentSnapshot.data).thenReturn({
        'test': Timestamp.fromDate(date),
      });
      query.orderBy("test");
      query.endBeforeDocument(mockDocumentSnapshot);
      verify(mockWebQuery.endBefore(
          fieldValues: argThat(equals([date]), named: "fieldValues")));
    });

    test("startAfter", () {
      query.startAfter([Timestamp.now()]);
      verify(mockWebQuery.startAfter(
          fieldValues:
              argThat(contains(isA<DateTime>()), named: "fieldValues")));
    });

    test("startAfterDocument", () {
      final DateTime date = DateTime.now();
      final mockDocumentSnapshot = MockDocumentSnapshot();
      when(mockDocumentSnapshot.data).thenReturn({
        'test': Timestamp.fromDate(date),
      });
      query.orderBy("test");
      query.startAfterDocument(mockDocumentSnapshot);
      verify(mockWebQuery.startAfter(
          fieldValues: argThat(equals([date]), named: "fieldValues")));
    });

    test("startAt", () {
      query.startAt([Timestamp.now()]);
      verify(mockWebQuery.startAt(
          fieldValues:
              argThat(contains(isA<DateTime>()), named: "fieldValues")));
    });

    test("startAtDocument", () {
      final DateTime date = DateTime.now();
      final mockDocumentSnapshot = MockDocumentSnapshot();
      when(mockDocumentSnapshot.data).thenReturn({
        'test': Timestamp.fromDate(date),
      });
      query.orderBy("test");
      query.startAtDocument(mockDocumentSnapshot);
      verify(mockWebQuery.startAt(
          fieldValues: argThat(equals([date]), named: "fieldValues")));
    });

    test("limit", () {
      query.limit(1);
      verify(mockWebQuery.limit(1));
    });

    test("where", () {
      query.where("test", isNull: true);
      verify(mockWebQuery.where("test", "==", null));

      query.where("test", whereIn: [1, 2, 3]);
      verify(mockWebQuery.where("test", "in", [1, 2, 3]));

      query.where("test", arrayContainsAny: [1, 2, 3]);
      verify(mockWebQuery.where("test", "array-contains-any", [1, 2, 3]));

      query.where("test", arrayContains: [1, 2, 3]);
      verify(mockWebQuery.where("test", "array-contains", [1, 2, 3]));

      query.where("test", isGreaterThanOrEqualTo: 1);
      verify(mockWebQuery.where("test", ">=", 1));

      query.where("test", isGreaterThan: 1);
      verify(mockWebQuery.where("test", ">", 1));

      query.where("test", isLessThan: 1);
      verify(mockWebQuery.where("test", "<", 1));

      query.where("test", isLessThanOrEqualTo: 1);
      verify(mockWebQuery.where("test", "<=", 1));

      query.where("test", isEqualTo: 1);
      verify(mockWebQuery.where("test", "==", 1));
    });
  });
}
