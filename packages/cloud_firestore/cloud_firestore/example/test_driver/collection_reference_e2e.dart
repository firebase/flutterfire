// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void runCollectionReferenceTests() {
  group('$CollectionReference', () {
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

    test('add() adds a document', () async {
      CollectionReference collection =
          await initializeTest('collection-reference-add');
      var rand = Random();
      var randNum = rand.nextInt(999999);
      DocumentReference doc = await collection.add({
        'value': randNum,
      });
      DocumentSnapshot snapshot = await doc.get();
      expect(randNum, equals(snapshot.data()['value']));
    });
  });
}
