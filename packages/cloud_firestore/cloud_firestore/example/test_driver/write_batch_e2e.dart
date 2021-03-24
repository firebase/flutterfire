// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void runWriteBatchTests() {
  group('$WriteBatch', () {
    FirebaseFirestore /*?*/ firestore;

    setUpAll(() async {
      firestore = FirebaseFirestore.instance;
    });

    Future<CollectionReference> initializeTest(String id) async {
      CollectionReference collection =
          firestore.collection('flutter-tests/$id/query-tests');
      QuerySnapshot snapshot = await collection.get();
      await Future.forEach(snapshot.docs, (DocumentSnapshot documentSnapshot) {
        return documentSnapshot.reference.delete();
      });
      return collection;
    }

    test('performs batch operations', () async {
      CollectionReference collection = await initializeTest('write-batch-ops');
      WriteBatch batch = firestore.batch();

      DocumentReference doc1 = collection.doc('doc1'); // delete
      DocumentReference doc2 = collection.doc('doc2'); // set
      DocumentReference doc3 = collection.doc('doc3'); // update
      DocumentReference doc4 = collection.doc('doc4'); // update w/ merge
      DocumentReference doc5 = collection.doc('doc5'); // update w/ mergeFields

      await Future.wait([
        doc1.set({'foo': 'bar'}),
        doc2.set({'foo': 'bar'}),
        doc3.set({'foo': 'bar', 'bar': 'baz'}),
        doc4.set({'foo': 'bar'}),
        doc5.set({'foo': 'bar', 'bar': 'baz'}),
      ]);

      batch.delete(doc1);
      batch.set(doc2, <String, dynamic>{'bar': 'baz'});
      batch.update(doc3, <String, dynamic>{'bar': 'ben'});
      batch.set(doc4, <String, dynamic>{'bar': 'ben'}, SetOptions(merge: true));

      // TODO(ehesp): firebase-dart does not support mergeFields
      if (!kIsWeb) {
        batch.set(doc5, <String, dynamic>{'bar': 'ben'},
            SetOptions(mergeFields: ['bar']));
      }

      await batch.commit();

      QuerySnapshot snapshot = await collection.get();

      expect(snapshot.docs.length, equals(4));
      expect(snapshot.docs.where((doc) => doc.id == 'doc1').isEmpty, isTrue);
      expect(
          snapshot.docs.firstWhere((doc) => doc.id == 'doc2').data(),
          equals(<String, dynamic>{
            'bar': 'baz',
          }));
      expect(
          snapshot.docs.firstWhere((doc) => doc.id == 'doc3').data(),
          equals(<String, dynamic>{
            'foo': 'bar',
            'bar': 'ben',
          }));
      expect(
          snapshot.docs.firstWhere((doc) => doc.id == 'doc4').data(),
          equals(<String, dynamic>{
            'foo': 'bar',
            'bar': 'ben',
          }));
      // ignore: todo
      // TODO(ehesp): firebase-dart does not support mergeFields
      if (!kIsWeb) {
        expect(
            snapshot.docs.firstWhere((doc) => doc.id == 'doc5').data(),
            equals(<String, dynamic>{
              'foo': 'bar',
              'bar': 'ben',
            }));
      }
    });
  });
}
