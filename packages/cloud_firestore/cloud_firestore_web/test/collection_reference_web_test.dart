@TestOn('chrome')
import 'dart:js' as js;

import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:cloud_firestore_web/firestore_web.dart';
import 'package:firebase/firestore.dart' as web;
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

const _kCollectionId = "test";

class MockFirestoreWeb extends Mock implements web.Firestore {}

class MockDocumentReference extends Mock implements web.DocumentReference {}

class MockQueryWeb extends Mock implements QueryWeb {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

void main() {
  group("$CollectionReferenceWeb()", () {
    final mockFirestoreWeb = MockFirestoreWeb();
    final mockDocumentReference = MockDocumentReference();
    CollectionReferenceWeb collectionReference;
    setUp(() {
      final js.JsObject firebaseMock = js.JsObject.jsify(<String, dynamic>{
        'firestore': js.allowInterop((_) => mockFirestoreWeb),
        'app': js.allowInterop((String name) {
          return js.JsObject.jsify(<String, dynamic>{
            'name': name,
            'options': <String, String>{'appId': '123'},
          });
        })
      });
      js.context['firebase'] = firebaseMock;
      FirebaseCorePlatform.instance = FirebaseCoreWeb();
      FirestorePlatform.instance = FirestoreWeb();
      collectionReference = CollectionReferenceWeb(FirestorePlatform.instance,
          js.context['firebase']['firestore'](""), [_kCollectionId]);
      collectionReference.queryDelegate = MockQueryWeb();
      when(mockFirestoreWeb.doc(any)).thenReturn(mockDocumentReference);
      when(collectionReference.queryDelegate.resetQueryDelegate())
          .thenReturn(collectionReference.queryDelegate);
    });

    test("parent", () {
      expect(collectionReference.parent(), isNull);
      expect(
          CollectionReferenceWeb(
              FirestorePlatform.instance,
              js.context['firebase']['firestore'](""),
              [_kCollectionId, _kCollectionId, _kCollectionId]).parent(),
          isInstanceOf<DocumentReferenceWeb>());
    });

    test("document", () {
      final newDocument = collectionReference.document();
      expect(newDocument.path.split("/").length,
          collectionReference.pathComponents.length + 1);
      final newDocumentWithPath = collectionReference.document("test1");
      expect(newDocumentWithPath.path,
          equals("${collectionReference.path}/test1"));
    });

    test("add", () async {
      expect(await collectionReference.add({}),
          isInstanceOf<DocumentReferenceWeb>());
    });

    test("buildArguments", () async {
      collectionReference.buildArguments();
      verify(collectionReference.queryDelegate.buildArguments());
    });

    test("getDocuments", () async {
      await collectionReference.getDocuments();
      verify(collectionReference.queryDelegate.getDocuments());
    });

    test("reference", () async {
      collectionReference.reference();
      verify(collectionReference.queryDelegate.reference());
    });

    test("snapshots", () async {
      collectionReference.snapshots(includeMetadataChanges: true);
      verify(collectionReference.queryDelegate
          .snapshots(includeMetadataChanges: true));
      collectionReference.snapshots(includeMetadataChanges: false);
      verify(collectionReference.queryDelegate
          .snapshots(includeMetadataChanges: false));
    });

    test("where", () async {
      collectionReference.where("test");
      verify(collectionReference.queryDelegate.where("test"));
    });

    test("startAt", () async {
      collectionReference.startAt([]);
      verify(collectionReference.queryDelegate.startAt([]));
    });

    test("startAfter", () async {
      collectionReference.startAfter([]);
      verify(collectionReference.queryDelegate.startAfter([]));
    });

    test("endBefore", () async {
      collectionReference.endBefore([]);
      verify(collectionReference.queryDelegate.endBefore([]));
    });

    test("endAt", () async {
      collectionReference.endAt([]);
      verify(collectionReference.queryDelegate.endAt([]));
    });

    test("limit", () async {
      collectionReference.limit(1);
      verify(collectionReference.queryDelegate.limit(1));
    });

    test("orderBy", () async {
      collectionReference.orderBy("test");
      verify(collectionReference.queryDelegate.orderBy("test"));
      collectionReference.orderBy("test", descending: true);
      verify(
          collectionReference.queryDelegate.orderBy("test", descending: true));
    });

    test("startAfterDocument", () async {
      final mockSnapshot = MockDocumentSnapshot();
      collectionReference.startAfterDocument(mockSnapshot);
      verify(
          collectionReference.queryDelegate.startAfterDocument(mockSnapshot));
    });

    test("startAtDocument", () async {
      final mockSnapshot = MockDocumentSnapshot();
      collectionReference.startAtDocument(mockSnapshot);
      verify(collectionReference.queryDelegate.startAtDocument(mockSnapshot));
    });

    test("endBeforeDocument", () async {
      final mockSnapshot = MockDocumentSnapshot();
      collectionReference.endBeforeDocument(mockSnapshot);
      verify(collectionReference.queryDelegate.endBeforeDocument(mockSnapshot));
    });

    test("endAtDocument", () async {
      final mockSnapshot = MockDocumentSnapshot();
      collectionReference.endAtDocument(mockSnapshot);
      verify(collectionReference.queryDelegate.endAtDocument(mockSnapshot));
    });
  });
}
