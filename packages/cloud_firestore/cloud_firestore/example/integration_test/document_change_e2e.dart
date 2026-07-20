// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void runDocumentChangeTests() {
  group('$DocumentChange', () {
    late FirebaseFirestore firestore;

    setUpAll(() async {
      firestore = FirebaseFirestore.instance;
    });

    Future<CollectionReference<Map<String, dynamic>>> initializeTest(
      String id,
    ) async {
      CollectionReference<Map<String, dynamic>> collection =
          firestore.collection('flutter-tests/$id/query-tests');

      QuerySnapshot<Map<String, dynamic>> snapshot = await collection.get();

      await Future.forEach(snapshot.docs,
          (DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
        return documentSnapshot.reference.delete();
      });
      return collection;
    }

    test(
      'can add/update values to null in the document',
      () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('null-test');
        DocumentReference<Map<String, dynamic>> doc1 = collection.doc('doc1');

        await expectLater(
          doc1.snapshots(),
          emits(
            isA<DocumentSnapshot<Map<String, dynamic>>>()
                .having((q) => q.exists, 'exists', false),
          ),
        );

        await doc1.set(<String, Object?>{
          'key': null,
          'key2': 42,
        });

        await expectLater(
          doc1.snapshots(),
          emits(
            isA<DocumentSnapshot<Map<String, dynamic>>>()
                .having((q) => q.exists, 'exists', true)
                .having((q) => q.data(), 'data()', <String, Object?>{
              'key': null,
              'key2': 42,
            }),
          ),
        );

        await doc1.set({
          'key': null,
          'key2': null,
        });

        await expectLater(
          doc1.snapshots(),
          emits(
            isA<DocumentSnapshot<Map<String, dynamic>>>()
                .having((q) => q.exists, 'exists', true)
                .having((q) => q.data(), 'data()', <String, Object?>{
              'key': null,
              'key2': null,
            }),
          ),
        );
      },
      timeout: const Timeout.factor(8),
      skip: defaultTargetPlatform == TargetPlatform.windows,
    );

    test(
      'returns the correct metadata when adding and removing',
      () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('add-remove-document');
        DocumentReference<Map<String, dynamic>> doc1 = collection.doc('doc1');

        // Set something in the database
        await doc1.set({'name': 'doc1'});

        final snapshots = <QuerySnapshot<Map<String, dynamic>>>[];
        final receivedAll = Completer<void>();

        StreamSubscription subscription =
            collection.snapshots().listen((snapshot) {
          snapshots.add(snapshot);
          if (snapshots.length >= 2 && !receivedAll.isCompleted) {
            receivedAll.complete();
          }
        });

        // Wait for the initial snapshot before modifying
        await Future.delayed(const Duration(milliseconds: 500));
        await doc1.delete();

        await receivedAll.future.timeout(const Duration(seconds: 30));
        await subscription.cancel();

        // Verify first snapshot (added)
        expect(snapshots[0].docs.length, equals(1));
        expect(snapshots[0].docChanges.length, equals(1));
        DocumentChange<Map<String, dynamic>> addChange =
            snapshots[0].docChanges[0];
        expect(addChange.newIndex, equals(0));
        expect(addChange.oldIndex, equals(-1));
        expect(addChange.type, equals(DocumentChangeType.added));
        expect(addChange.doc.data()!['name'], equals('doc1'));

        // Verify second snapshot (removed)
        expect(snapshots[1].docs.length, equals(0));
        expect(snapshots[1].docChanges.length, equals(1));
        DocumentChange<Map<String, dynamic>> removeChange =
            snapshots[1].docChanges[0];
        expect(removeChange.newIndex, equals(-1));
        expect(removeChange.oldIndex, equals(0));
        expect(removeChange.type, equals(DocumentChangeType.removed));
        expect(removeChange.doc.data()!['name'], equals('doc1'));
      },
      skip: defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.android,
    );

    test(
      'returns the correct metadata when modifying',
      () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('add-modify-document');
        DocumentReference<Map<String, dynamic>> doc1 = collection.doc('doc1');
        DocumentReference<Map<String, dynamic>> doc2 = collection.doc('doc2');
        DocumentReference<Map<String, dynamic>> doc3 = collection.doc('doc3');

        await doc1.set({'value': 1});
        await doc2.set({'value': 2});
        await doc3.set({'value': 3});

        final snapshots = <QuerySnapshot<Map<String, dynamic>>>[];
        final receivedAll = Completer<void>();

        StreamSubscription subscription =
            collection.orderBy('value').snapshots().listen((snapshot) {
          snapshots.add(snapshot);
          if (snapshots.length >= 2 && !receivedAll.isCompleted) {
            receivedAll.complete();
          }
        });

        // Wait for the initial snapshot before modifying
        await Future.delayed(const Duration(milliseconds: 500));
        await doc1.update({'value': 4});

        await receivedAll.future.timeout(const Duration(seconds: 30));
        await subscription.cancel();

        // Verify first snapshot (all 3 docs added)
        expect(snapshots[0].docs.length, equals(3));
        expect(snapshots[0].docChanges.length, equals(3));
        snapshots[0]
            .docChanges
            .asMap()
            .forEach((int index, DocumentChange<Map<String, dynamic>> change) {
          expect(change.oldIndex, equals(-1));
          expect(change.newIndex, equals(index));
          expect(change.type, equals(DocumentChangeType.added));
          expect(change.doc.data()!['value'], equals(index + 1));
        });

        // Verify second snapshot (doc1 modified, moved to end)
        expect(snapshots[1].docs.length, equals(3));
        expect(snapshots[1].docChanges.length, equals(1));
        DocumentChange<Map<String, dynamic>> change =
            snapshots[1].docChanges[0];
        expect(change.oldIndex, equals(0));
        expect(change.newIndex, equals(2));
        expect(change.type, equals(DocumentChangeType.modified));
        expect(change.doc.id, equals('doc1'));
      },
      skip: defaultTargetPlatform == TargetPlatform.windows,
    );
  });
}
