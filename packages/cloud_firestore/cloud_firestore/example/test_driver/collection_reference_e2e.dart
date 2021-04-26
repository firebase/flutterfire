// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void runCollectionReferenceTests() {
  group('$CollectionReference', () {
    late FirebaseFirestore firestore;

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
      expect(randNum, equals(snapshot.data()!['value']));
    });

    group('withConverter', () {
      test('add/snapshot', () async {
        final foo = await initializeTest('foo');
        final fooConverter = foo.withConverter<int>(
          fromFirebase: (json) => json['value']! as int,
          toFirebase: (value) => {'value': value},
        );

        final fooSnapshot = foo.snapshots();
        final fooConverterSnapshot = fooConverter.snapshots();

        await expectLater(
          fooSnapshot,
          emits(isA<QuerySnapshot>().having((e) => e.docs, 'docs', [])),
        );
        await expectLater(
          fooConverterSnapshot,
          emits(
            isA<WithConverterQuerySnapshot<int>>()
                .having((e) => e.docs, 'docs', []),
          ),
        );

        final newDocument = await fooConverter.add(42);

        await expectLater(
          newDocument.get(),
          completion(
            isA<WithConverterDocumentSnapshot<int>>()
                .having((e) => e.data(), 'data', 42),
          ),
        );

        await expectLater(
          fooSnapshot,
          emits(
            isA<QuerySnapshot>().having((e) => e.docs, 'docs', [
              isA<QueryDocumentSnapshot>()
                  .having((e) => e.data(), 'data', {'value': 42})
            ]),
          ),
        );
        await expectLater(
          fooConverterSnapshot,
          emits(
            isA<WithConverterQuerySnapshot<int>>()
                .having((e) => e.docs, 'docs', [
              isA<WithConverterQueryDocumentSnapshot<int>>()
                  .having((e) => e.data(), 'data', 42)
            ]),
          ),
        );

        await foo.add({'value': 21});

        await expectLater(
          fooSnapshot,
          emits(
            isA<QuerySnapshot>().having(
                (e) => e.docs,
                'docs',
                unorderedEquals([
                  isA<QueryDocumentSnapshot>()
                      .having((e) => e.data(), 'data', {'value': 42}),
                  isA<QueryDocumentSnapshot>()
                      .having((e) => e.data(), 'data', {'value': 21})
                ])),
          ),
        );

        await expectLater(
          fooConverterSnapshot,
          emits(
            isA<WithConverterQuerySnapshot<int>>().having(
                (e) => e.docs,
                'docs',
                unorderedEquals([
                  isA<WithConverterQueryDocumentSnapshot<int>>()
                      .having((e) => e.data(), 'data', 42),
                  isA<WithConverterQueryDocumentSnapshot<int>>()
                      .having((e) => e.data(), 'data', 21)
                ])),
          ),
        );
      });
    });
  });
}
