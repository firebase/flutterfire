import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('$Firestore', () {
    Firestore firestore;
    Firestore firestoreWithSettings;

    setUpAll(() async {
      final FirebaseOptions firebaseOptions = const FirebaseOptions(
        googleAppID: '1:79601577497:ios:5f2bcc6ba8cecddd',
        gcmSenderID: '79601577497',
        apiKey: 'AIzaSyArgmRGfB5kiQT6CunAOmKRVKEsxKmy6YI-G72PVU',
        projectID: 'flutter-firestore',
      );
      final FirebaseApp app = await FirebaseApp.configure(
        name: 'test',
        options: firebaseOptions,
      );
      final FirebaseApp app2 = await FirebaseApp.configure(
        name: 'test2',
        options: firebaseOptions,
      );
      firestore = Firestore(app: app);
      firestoreWithSettings = Firestore(app: app2);
      await firestoreWithSettings.settings(
        persistenceEnabled: true,
        host: null,
        sslEnabled: true,
        cacheSizeBytes: 1048576,
      );
    });

    test('getDocumentsWithFirestoreSettings', () async {
      final Query query = firestoreWithSettings.collection('messages').limit(1);
      final QuerySnapshot querySnapshot = await query.getDocuments();
      expect(querySnapshot.documents.length, 1);
    });

    test('getDocumentsFromCollection', () async {
      final Query query = firestore
          .collection('messages')
          .where('message', isEqualTo: 'Hello world!')
          .limit(1);
      final QuerySnapshot querySnapshot = await query.getDocuments();
      expect(querySnapshot.metadata, isNotNull);
      expect(querySnapshot.documents.first['message'], 'Hello world!');
      final DocumentReference firstDoc =
          querySnapshot.documents.first.reference;
      final DocumentSnapshot documentSnapshot = await firstDoc.get();
      expect(documentSnapshot.data['message'], 'Hello world!');
      final DocumentSnapshot cachedSnapshot =
          await firstDoc.get(source: Source.cache);
      expect(cachedSnapshot.data['message'], 'Hello world!');
      final DocumentSnapshot snapshot = await firstDoc.snapshots().first;
      expect(snapshot.data['message'], 'Hello world!');
    });

    test('getDocumentsFromCollectionGroup', () async {
      final Query query = firestore
          .collectionGroup('reviews')
          .where('stars', isEqualTo: 5)
          .limit(1);
      final QuerySnapshot querySnapshot = await query.getDocuments();
      expect(querySnapshot.documents.first['stars'], 5);
      expect(querySnapshot.metadata, isNotNull);
    });

    test('increment', () async {
      final DocumentReference ref = firestore.collection('messages').document();
      await ref.setData(<String, dynamic>{
        'message': 1,
        'created_at': FieldValue.serverTimestamp(),
      });
      DocumentSnapshot snapshot = await ref.get();
      expect(snapshot.data['message'], 1);
      await ref.updateData(<String, dynamic>{
        'message': FieldValue.increment(1),
      });
      snapshot = await ref.get();
      expect(snapshot.data['message'], 2);
      await ref.updateData(<String, dynamic>{
        'message': FieldValue.increment(40.1),
      });
      snapshot = await ref.get();
      expect(snapshot.data['message'], 42.1);

      // Call several times without awaiting the result
      await Future.wait<void>(List<Future<void>>.generate(
        3,
        (int i) => ref.updateData(<String, dynamic>{
          'message': FieldValue.increment(i),
        }),
      ));
      snapshot = await ref.get();
      expect(snapshot.data['message'], 45.1);
      await ref.delete();
    });

    test('includeMetadataChanges', () async {
      final DocumentReference ref = firestore.collection('messages').document();
      final Stream<DocumentSnapshot> snapshotWithoutMetadataChanges =
          ref.snapshots(includeMetadataChanges: false).take(1);
      // It should take either two or three snapshots to make a change when
      // metadata is included, depending on whether `hasPendingWrites` and
      // `isFromCache` update at the same time.
      final Stream<DocumentSnapshot> snapshotsWithMetadataChanges =
          ref.snapshots(includeMetadataChanges: true).take(3);

      ref.setData(<String, dynamic>{'hello': 'world'});

      DocumentSnapshot snapshot = await snapshotWithoutMetadataChanges.first;
      expect(snapshot.metadata.hasPendingWrites, true);
      expect(snapshot.metadata.isFromCache, true);
      expect(snapshot.data['hello'], 'world');

      snapshot = await snapshotsWithMetadataChanges.take(1).first;
      expect(snapshot.metadata.hasPendingWrites, true);
      expect(snapshot.metadata.isFromCache, true);
      expect(snapshot.data['hello'], 'world');

      while (
          snapshot.metadata.hasPendingWrites || snapshot.metadata.isFromCache) {
        snapshot = await snapshotsWithMetadataChanges.take(1).first;
      }
      // At this point, the test is a flake...
      expect(snapshot.data['hello'], 'world');

      await ref.delete();
    });

    test('runTransaction', () async {
      final DocumentReference ref = firestore.collection('messages').document();
      await ref.setData(<String, dynamic>{
        'message': 'testing',
        'created_at': FieldValue.serverTimestamp(),
      });
      final DocumentSnapshot initialSnapshot = await ref.get();
      expect(initialSnapshot.data['message'], 'testing');
      final dynamic result = await firestore.runTransaction(
        (Transaction tx) async {
          final DocumentSnapshot snapshot = await tx.get(ref);
          final Map<String, dynamic> updatedData =
              Map<String, dynamic>.from(snapshot.data);
          updatedData['message'] = 'testing2';
          tx.update(ref, updatedData); // calling await here is optional
          return updatedData;
        },
      );
      expect(result['message'], 'testing2');

      await ref.delete();
      final DocumentSnapshot nonexistentSnapshot = await ref.get();
      expect(nonexistentSnapshot.data, null);
      expect(nonexistentSnapshot.exists, false);
    });

    test('pagination', () async {
      // Populate the database with two test documents
      final CollectionReference messages = firestore.collection('messages');
      final DocumentReference doc1 = messages.document();
      // Use document ID as a unique identifier to ensure that we don't
      // collide with other tests running against this database.
      final String testRun = doc1.documentID;
      await doc1.setData(<String, dynamic>{
        'message': 'pagination testing1',
        'test_run': testRun,
        'created_at': FieldValue.serverTimestamp(),
      });
      final DocumentSnapshot snapshot1 = await doc1.get();
      final DocumentReference doc2 = messages.document();
      await doc2.setData(<String, dynamic>{
        'message': 'pagination testing2',
        'test_run': testRun,
        'created_at': FieldValue.serverTimestamp(),
      });
      final DocumentSnapshot snapshot2 = await doc2.get();

      QuerySnapshot snapshot;
      List<DocumentSnapshot> results;

      // startAtDocument
      snapshot = await messages
          .orderBy('created_at')
          .where('test_run', isEqualTo: testRun)
          .startAtDocument(snapshot1)
          .getDocuments();
      results = snapshot.documents;
      expect(results.length, 2);
      expect(results[0].data['message'], 'pagination testing1');
      expect(results[1].data['message'], 'pagination testing2');

      // startAfterDocument
      snapshot = await messages
          .orderBy('created_at')
          .where('test_run', isEqualTo: testRun)
          .startAfterDocument(snapshot1)
          .getDocuments();
      results = snapshot.documents;
      expect(results.length, 1);
      expect(results[0].data['message'], 'pagination testing2');

      // endAtDocument
      snapshot = await messages
          .orderBy('created_at')
          .where('test_run', isEqualTo: testRun)
          .endAtDocument(snapshot2)
          .getDocuments();
      results = snapshot.documents;
      expect(results.length, 2);
      expect(results[0].data['message'], 'pagination testing1');
      expect(results[1].data['message'], 'pagination testing2');

      // endBeforeDocument
      snapshot = await messages
          .orderBy('created_at')
          .where('test_run', isEqualTo: testRun)
          .endBeforeDocument(snapshot2)
          .getDocuments();
      results = snapshot.documents;
      expect(results.length, 1);
      expect(results[0].data['message'], 'pagination testing1');

      // startAtDocument - endAtDocument
      snapshot = await messages
          .orderBy('created_at')
          .where('test_run', isEqualTo: testRun)
          .startAtDocument(snapshot1)
          .endAtDocument(snapshot2)
          .getDocuments();
      results = snapshot.documents;
      expect(results.length, 2);
      expect(results[0].data['message'], 'pagination testing1');
      expect(results[1].data['message'], 'pagination testing2');

      // startAfterDocument - endBeforeDocument
      snapshot = await messages
          .orderBy('created_at')
          .where('test_run', isEqualTo: testRun)
          .startAfterDocument(snapshot1)
          .endBeforeDocument(snapshot2)
          .getDocuments();
      results = snapshot.documents;
      expect(results.length, 0);

      // Clean up
      await doc1.delete();
      await doc2.delete();
    });

    test('pagination with map', () async {
      // Populate the database with two test documents.
      final CollectionReference messages = firestore.collection('messages');
      final DocumentReference doc1 = messages.document();
      // Use document ID as a unique identifier to ensure that we don't
      // collide with other tests running against this database.
      final String testRun = doc1.documentID;
      await doc1.setData(<String, dynamic>{
        'cake': <String, dynamic>{
          'flavor': <String, dynamic>{'type': 1, 'test_run': testRun}
        }
      });

      final DocumentSnapshot snapshot1 = await doc1.get();
      final DocumentReference doc2 = await messages.add(<String, dynamic>{
        'cake': <String, dynamic>{
          'flavor': <String, dynamic>{'type': 2, 'test_run': testRun}
        }
      });

      QuerySnapshot snapshot;
      List<DocumentSnapshot> results;

      // One pagination call is enough as all of the pagination methods use the same method to get data internally.
      snapshot = await messages
          .orderBy('cake.flavor.type')
          .where('cake.flavor.test_run', isEqualTo: testRun)
          .startAtDocument(snapshot1)
          .getDocuments();
      results = snapshot.documents;

      expect(results.length, 2);
      expect(results[0].data['cake']['flavor']['type'], 1);
      expect(results[1].data['cake']['flavor']['type'], 2);

      await doc1.delete();
      await doc2.delete();
    });

    test('pagination with DocumentReference (#2044)', () async {
      // Populate the database with two test documents
      final CollectionReference messages = firestore.collection('messages');
      final DocumentReference doc1 = messages.document();
      // Use document ID as a unique identifier to ensure that we don't
      // collide with other tests running against this database.
      final String testRun = doc1.documentID;
      await doc1.setData(<String, dynamic>{
        'message': 'pagination testing1',
        'test_run': testRun,
        'some_order': 1,
      });
      final DocumentReference doc2 = messages.document();
      await doc2.setData(<String, dynamic>{
        'message': 'pagination testing2',
        'test_run': testRun,
        'some_order': 2,
        'reference': doc1,
      });
      final DocumentSnapshot snapshot2 = await doc2.get();

      QuerySnapshot snapshot;
      List<DocumentSnapshot> results;

      // startAtDocument with the Snapshot of a doc that contains a DocumentReference.
      snapshot = await messages
          .orderBy('some_order', descending: true)
          .where('test_run', isEqualTo: testRun)
          .startAtDocument(snapshot2)
          .getDocuments();

      results = snapshot.documents;
      expect(results.length, 2);

      // Results are expected in descending order.
      expect(results[0].data['message'], 'pagination testing2');
      expect(results[1].data['message'], 'pagination testing1');

      // Clean up
      await doc2.delete();
      await doc1.delete();
    });

    test('FieldPath.documentId', () async {
      // Populate the database with two test documents.
      final CollectionReference messages = firestore.collection('messages');

      // Use document ID as a unique identifier to ensure that we don't
      // collide with other tests running against this database.
      final DocumentReference doc = messages.document();
      final String documentId = doc.documentID;

      await doc.setData(<String, dynamic>{
        'message': 'testing field path',
        'created_at': FieldValue.serverTimestamp(),
      });

      // This tests the native implementations of the where and
      // orderBy methods handling FieldPath.documentId.
      // There is also an error thrown when ordering by document id
      // natively, however, that is also covered by assertion
      // on the Dart side, which is tested with a unit test.
      final QuerySnapshot querySnapshot = await messages
          .orderBy(FieldPath.documentId)
          .where(FieldPath.documentId, isEqualTo: documentId)
          .getDocuments();

      await doc.delete();

      final List<DocumentSnapshot> results = querySnapshot.documents;
      final DocumentSnapshot result = results[0];

      expect(results.length, 1);
      expect(result.data['message'], 'testing field path');
      expect(result.documentID, documentId);
    });

    test('Query.whereIn', () async {
      final CollectionReference ref = firestore.collection('cities');
      await ref.document('la').setData(<String, dynamic>{
        'country': 'USA',
      });
      await ref.document('tokyo').setData(<String, dynamic>{
        'country': 'Japan',
      });
      await ref.document('maputo').setData(<String, dynamic>{
        'country': 'Mozambique',
      });
      final QuerySnapshot snapshot = await ref.where('country',
          whereIn: <String>['USA', 'Mozambique']).getDocuments();
      final List<DocumentSnapshot> results = snapshot.documents;
      expect(results.length, 2);
      final DocumentSnapshot snapshot1 = results[0];
      final DocumentSnapshot snapshot2 = results[1];
      expect(snapshot1.documentID, 'la');
      expect(snapshot2.documentID, 'maputo');
    });

    test('Query.whereArrayContainsAny', () async {
      final CollectionReference ref = firestore.collection('cities');
      await ref.document('la').setData(<String, dynamic>{
        'country': 'USA',
        'regions': <String>['west-coast', 'east-coast'],
      });
      await ref.document('tokyo').setData(<String, dynamic>{
        'country': 'Japan',
        'regions': <String>['kanto', 'honshu'],
      });
      final QuerySnapshot snapshot = await ref
          .where('regions', arrayContainsAny: <String>['kanto', 'west-coast'])
          .orderBy('country')
          .getDocuments();
      final List<DocumentSnapshot> results = snapshot.documents;
      expect(results.length, 2);
      final DocumentSnapshot snapshot1 = results[0];
      final DocumentSnapshot snapshot2 = results[1];
      expect(snapshot1.documentID, 'tokyo');
      expect(snapshot2.documentID, 'la');
    });

    test('Query.whereArrayContainsAny using DocumentReference', () async {
      final CollectionReference ref = firestore.collection('messages');
      await ref.document('test-docRef-1').setData({"message": "1"});
      await ref.document('test-docRef-2').setData({"message": "2"});

      await ref.document('test-docRef').setData(<String, dynamic>{
        'children': <DocumentReference>[
          ref.document("test-docRef-1"),
          ref.document("test-docRef-2")
        ],
      });

      final QuerySnapshot snapshot = await ref.where('children',
          arrayContainsAny: <DocumentReference>[
            ref.document("test-docRef-1"),
            ref.document("test-docRef-2")
          ]).getDocuments();
      final List<DocumentSnapshot> results = snapshot.documents;
      expect(results.length, 1);
      final DocumentSnapshot actual = results[0];
      expect(actual.documentID, 'test-docRef');
    });

    test('Query.whereIn using DocumentReference', () async {
      final CollectionReference ref = firestore.collection('messages');
      await ref.document('test-docRef-1').setData({"message": "1"});
      await ref.document('test-docRef-2').setData({"message": "2"});

      final QuerySnapshot snapshot = await ref.where(FieldPath.documentId,
          whereIn: <DocumentReference>[
            ref.document("test-docRef-1"),
            ref.document("test-docRef-2")
          ]).getDocuments();
      final List<DocumentSnapshot> results = snapshot.documents;
      expect(results.length, 2);
      expect(results.where((item) => item.documentID == "test-docRef-1").length,
          equals(1));
      expect(results.where((item) => item.documentID == "test-docRef-2").length,
          equals(1));
    });

    test('Query.arrayContains using DocumentReference', () async {
      final CollectionReference ref = firestore.collection('messages');
      await ref.document('test-docRef-1').setData({"message": "1"});
      await ref.document('test-docRef-2').setData({"message": "2"});

      await ref.document('test-docRef').setData(<String, dynamic>{
        'children': <DocumentReference>[
          ref.document("test-docRef-1"),
          ref.document("test-docRef-2")
        ],
      });

      final QuerySnapshot snapshot = await ref
          .where('children', arrayContains: ref.document("test-docRef-1"))
          .getDocuments();
      final List<DocumentSnapshot> results = snapshot.documents;
      expect(results.length, 1);
      final DocumentSnapshot actual = results[0];
      expect(actual.documentID, 'test-docRef');
    });

    test('FieldValue.arrayUnion with DocumentRefrence', () async {
      final CollectionReference ref = firestore.collection('messages');
      await ref.document('test-docRef-1').setData({"message": "1"});
      await ref.document('test-docRef-2').setData({"message": "2"});

      await ref.document('test-docRef').setData(<String, dynamic>{
        'children': <DocumentReference>[
          ref.document("test-docRef-1"),
        ],
      });

      await ref.document("test-docRef").updateData({
        'children': FieldValue.arrayUnion([ref.document('test-docRef-2')])
      });

      final DocumentSnapshot snapshot = await ref.document("test-docRef").get();
      expect(snapshot.data['children'].length, equals(2));
    });

    test('FieldValue.arrayRemove with DocumentReference', () async {
      final CollectionReference ref = firestore.collection('messages');
      await ref.document('test-docRef-1').setData({"message": "1"});
      await ref.document('test-docRef-2').setData({"message": "2"});

      await ref.document('test-docRef').setData(<String, dynamic>{
        'children': <DocumentReference>[
          ref.document("test-docRef-1"),
          ref.document("test-docRef-2"),
        ],
      });

      await ref.document("test-docRef").updateData({
        'children': FieldValue.arrayRemove([ref.document('test-docRef-2')])
      });

      final DocumentSnapshot snapshot = await ref.document("test-docRef").get();
      expect(snapshot.data['children'].length, equals(1));
    });

    test('Decode nested maps with DocumentRefrenceValues', () async {
      final CollectionReference ref = firestore.collection('messages');
      await ref.document('test-docRef-1').setData({"message": "1"});
      await ref.document('test-docRef-2').setData({"message": "2"});

      await ref.document('test-docRef').setData(<String, dynamic>{
        'children': {
          'children': <DocumentReference>[
            ref.document("test-docRef-1"),
            ref.document("test-docRef-2")
          ]
        },
      });

      final List<dynamic> children = (await ref.document("test-docRef").get())
          .data['children']['children'];
      children
          .forEach((item) => expect(item, isInstanceOf<DocumentReference>()));
    });

    test('Equality comparison on FieldValues', () async {
      final FieldValue arrayRemove = FieldValue.arrayRemove([1]);
      expect(arrayRemove, equals(FieldValue.arrayRemove([1])));
      expect(arrayRemove, isNot(equals(FieldValue.arrayRemove([2]))));
      final FieldValue delete = FieldValue.delete();
      expect(delete, equals(FieldValue.delete()));
      expect(arrayRemove, isNot(equals(FieldValue.delete())));
      final FieldValue actualInt = FieldValue.increment(1);
      final FieldValue actualDouble = FieldValue.increment(1.0);
      expect(actualInt, isNot(equals(actualDouble)));
    });
  });
}
