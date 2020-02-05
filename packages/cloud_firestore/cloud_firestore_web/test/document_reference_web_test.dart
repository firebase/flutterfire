// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('chrome')
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/src/document_reference_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase/firestore.dart' as web;
import 'test_common.dart';

const _kPath = "test/document";

void main() {
  group("$DocumentReferenceWeb()", () {
    final mockWebDocumentReferences = MockWebDocumentReference();
    DocumentReferenceWeb documentRefernce;
    setUp(() {
      final mockWebFirestore = mockFirestore();
      when(mockWebFirestore.doc(any)).thenReturn(mockWebDocumentReferences);
      documentRefernce = DocumentReferenceWeb(
          mockWebFirestore, FirestorePlatform.instance, _kPath.split("/"));
    });

    test("setData", () {
      documentRefernce.setData({"test": "test"});
      expect(
          verify(mockWebDocumentReferences.set(
                  any, captureThat(isInstanceOf<web.SetOptions>())))
              .captured
              .last
              .merge,
          isFalse);
      documentRefernce.setData({"test": "test"}, merge: true);
      expect(
          verify(mockWebDocumentReferences.set(
                  any, captureThat(isInstanceOf<web.SetOptions>())))
              .captured
              .last
              .merge,
          isTrue);
    });

    test("updateData", () {
      documentRefernce.updateData({"test": "test"});
      verify(mockWebDocumentReferences.update(data: anyNamed("data")));
    });

    test("get", () {
      final mockWebSnapshot = MockWebDocumentSnapshot();
      when(mockWebSnapshot.ref).thenReturn(mockWebDocumentReferences);
      when(mockWebSnapshot.metadata).thenReturn(MockWebSnapshotMetaData());
      when(mockWebDocumentReferences.get())
          .thenAnswer((_) => Future.value(mockWebSnapshot));
      documentRefernce.get();
      verify(mockWebDocumentReferences.get());
    });

    test("delete", () {
      documentRefernce.delete();
      verify(mockWebDocumentReferences.delete());
    });

    test("snapshots", () {
      when(mockWebDocumentReferences.onSnapshot)
          .thenAnswer((_) => Stream.empty());
      when(mockWebDocumentReferences.onMetadataChangesSnapshot)
          .thenAnswer((_) => Stream.empty());
      documentRefernce.snapshots();
      verify(mockWebDocumentReferences.onSnapshot);
      documentRefernce.snapshots(includeMetadataChanges: false);
      verify(mockWebDocumentReferences.onSnapshot);
      documentRefernce.snapshots(includeMetadataChanges: true);
      verify(mockWebDocumentReferences.onMetadataChangesSnapshot);
    });
  });
}
