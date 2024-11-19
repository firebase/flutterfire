// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void runQueryTests() {
  group('$Query', () {
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
          (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
        return documentSnapshot.reference.delete();
      });
      return collection;
    }

    group('equality', () {
      // testing == override using e2e tests as it is dependent on the platform
      test('handles deeply compares query parameters', () async {
        final movies = firestore.collection('/movies');
        final starWarsComments =
            firestore.collection('/movies/star-wars/comments');

        expect(
          movies.where('genre', arrayContains: ['Flutter']),
          movies.where('genre', arrayContains: ['Flutter']),
        );
        expect(
          movies.where('genre', arrayContains: ['Flutter']),
          isNot(movies.where('genre', arrayContains: ['React'])),
        );
        expect(
          movies.where('genre', arrayContains: ['Flutter']),
          isNot(starWarsComments.where('genre', arrayContains: ['Flutter'])),
        );
      });

      test('differentiate queries from a different app instance', () async {
        final fooApp = await Firebase.initializeApp(
          name: 'foo',
          options: Firebase.app().options,
        );

        expect(
          FirebaseFirestore.instanceFor(app: fooApp)
              .collection('movies')
              .limit(42),
          FirebaseFirestore.instanceFor(app: fooApp)
              .collection('movies')
              .limit(42),
        );

        expect(
          FirebaseFirestore.instance.collection('movies').limit(42),
          isNot(
            FirebaseFirestore.instanceFor(app: fooApp)
                .collection('movies')
                .limit(42),
          ),
        );
      });

      test('differentiate collection group', () async {
        expect(
          firestore.collectionGroup('comments').limit(42),
          firestore.collectionGroup('comments').limit(42),
        );
        expect(
          firestore.collectionGroup('comments').limit(42),
          isNot(firestore.collection('comments').limit(42)),
        );
      });
    });

    /**
     * collectionGroup
     */
    group('collectionGroup()', () {
      test('returns a data via a sub-collection', () async {
        CollectionReference<Map<String, dynamic>> collection =
            firestore.collection('flutter-tests/collection-group/group-test');
        QuerySnapshot<Map<String, dynamic>> snapshot = await collection.get();

        await Future.forEach(snapshot.docs,
            (DocumentSnapshot documentSnapshot) {
          return documentSnapshot.reference.delete();
        });

        await collection.doc('doc1').set({'foo': 1});
        await collection.doc('doc2').set({'foo': 2});

        QuerySnapshot<Map<String, dynamic>> groupSnapshot = await firestore
            .collectionGroup('group-test')
            .orderBy('foo', descending: true)
            .get();
        expect(groupSnapshot.size, equals(2));
        expect(groupSnapshot.docs[0].data()['foo'], equals(2));
        expect(groupSnapshot.docs[1].data()['foo'], equals(1));
      });

      test(
          'should respond with a FirebaseException, the query requires an index',
          () async {
        try {
          await FirebaseFirestore.instance
              .collectionGroup('collection-group')
              .where('number', isGreaterThan: 1, isLessThan: 3)
              .where('foo', isEqualTo: 'bar')
              .get();
        } catch (error) {
          expect(
            (error as FirebaseException).code,
            equals('failed-precondition'),
          );
          expect(
            error.message,
            'The query requires an index',
          );
        }
      });
    });

    /**
     * get
     */
    group('Query.get()', () {
      test('returns a [QuerySnapshot]', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('get');
        QuerySnapshot<Map<String, dynamic>> qs = await collection.get();
        expect(qs, isA<QuerySnapshot<Map<String, dynamic>>>());
      });

      test('uses [GetOptions] cache', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('get');
        QuerySnapshot<Map<String, dynamic>> qs =
            await collection.get(const GetOptions(source: Source.cache));
        expect(qs, isA<QuerySnapshot<Map<String, dynamic>>>());
        expect(qs.metadata.isFromCache, isTrue);
      });

      test('uses [GetOptions] server', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('get');
        QuerySnapshot<Map<String, dynamic>> qs =
            await collection.get(const GetOptions(source: Source.server));
        expect(qs, isA<QuerySnapshot<Map<String, dynamic>>>());
        expect(qs.metadata.isFromCache, isFalse);
      });

      test('uses [GetOptions] serverTimestampBehavior previous', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('get');
        QuerySnapshot<Map<String, dynamic>> qs = await collection.get(
          const GetOptions(
            serverTimestampBehavior: ServerTimestampBehavior.previous,
          ),
        );
        expect(qs, isA<QuerySnapshot<Map<String, dynamic>>>());
      });

      test('uses [GetOptions] serverTimestampBehavior estimate', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('get');
        QuerySnapshot<Map<String, dynamic>> qs = await collection.get(
          const GetOptions(
            serverTimestampBehavior: ServerTimestampBehavior.estimate,
          ),
        );
        expect(qs, isA<QuerySnapshot<Map<String, dynamic>>>());
      });

      test(
        'throws a [FirebaseException]',
        () async {
          CollectionReference<Map<String, dynamic>> collection =
              firestore.collection('not-allowed');

          try {
            await collection.get();
          } catch (error) {
            expect(error, isA<FirebaseException>());
            expect(
              (error as FirebaseException).code,
              equals('permission-denied'),
            );
            return;
          }
          fail('Should have thrown a [FirebaseException]');
        },
      );

      test(
        'should respond with a FirebaseException, the query requires an index',
        () async {
          try {
            await FirebaseFirestore.instance
                .collection('flutter-tests')
                .where('number', isGreaterThan: 1, isLessThan: 3)
                .where('foo', isEqualTo: 'bar')
                .get();
          } catch (error) {
            expect(
              (error as FirebaseException).code,
              equals('failed-precondition'),
            );
            expect(
              error.message,
              'The query requires an index',
            );
          }
        },
      );
    });

    /**
     * snapshots
     */
    group('Query.snapshots()', () {
      test('returns a [Stream]', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('get');
        Stream<QuerySnapshot<Map<String, dynamic>>> stream =
            collection.snapshots();
        expect(stream, isA<Stream<QuerySnapshot<Map<String, dynamic>>>>());
      });

      test('listens to a single response', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('get-single');
        await collection.add({'foo': 'bar'});
        Stream<QuerySnapshot<Map<String, dynamic>>> stream =
            collection.snapshots();
        StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? subscription;

        subscription = stream.listen(
          expectAsync1(
            (QuerySnapshot<Map<String, dynamic>> snapshot) {
              expect(snapshot.docs.length, equals(1));
              expect(snapshot.docs[0], isA<QueryDocumentSnapshot>());
              QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot =
                  snapshot.docs[0];
              expect(documentSnapshot.data()['foo'], equals('bar'));
            },
            reason: 'Stream should only have been called once.',
          ),
        );
        addTearDown(() async {
          await subscription?.cancel();
        });
      });

      test(
        'listens to a single response from cache with QuerySnapshot',
        () async {
          CollectionReference<Map<String, dynamic>> collection =
              await initializeTest('get-single-cache');
          await collection.add({'foo': 'bar'});
          Stream<QuerySnapshot<Map<String, dynamic>>> stream =
              collection.snapshots(source: ListenSource.cache);
          StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? subscription;

          subscription = stream.listen(
            expectAsync1(
              (QuerySnapshot<Map<String, dynamic>> snapshot) {
                expect(snapshot.docs.length, equals(1));
                expect(snapshot.docs[0], isA<QueryDocumentSnapshot>());
                QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot =
                    snapshot.docs[0];
                expect(documentSnapshot.data()['foo'], equals('bar'));
              },
              reason: 'Stream should only have been called once.',
            ),
          );
          addTearDown(() async {
            await subscription?.cancel();
          });
        },
        // Failing on CI but works locally
        skip: kIsWeb,
      );

      test('listens to multiple queries', () async {
        CollectionReference<Map<String, dynamic>> collection1 =
            await initializeTest('document-snapshot-1');
        CollectionReference<Map<String, dynamic>> collection2 =
            await initializeTest('document-snapshot-2');

        await collection1.add({'test': 'value1'});
        await collection2.add({'test': 'value2'});

        final value1 = collection1
            .snapshots()
            .first
            .then((s) => s.docs.first.data()['test']);
        final value2 = collection2
            .snapshots()
            .first
            .then((s) => s.docs.first.data()['test']);

        await expectLater(value1, completion('value1'));
        await expectLater(value2, completion('value2'));
      });

      test('listens to a multiple changes response', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('get-multiple');
        await collection.add({'foo': 'bar'});

        Stream<QuerySnapshot<Map<String, dynamic>>> stream =
            collection.snapshots();
        int call = 0;

        StreamSubscription subscription = stream.listen(
          expectAsync1(
            (QuerySnapshot<Map<String, dynamic>> snapshot) {
              call++;
              if (call == 1) {
                expect(snapshot.docs.length, equals(1));
                QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot =
                    snapshot.docs[0];
                expect(documentSnapshot.data()['foo'], equals('bar'));
              } else if (call == 2) {
                expect(snapshot.docs.length, equals(2));
                QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot =
                    snapshot.docs.firstWhere((doc) => doc.id == 'doc1');
                expect(documentSnapshot.data()['bar'], equals('baz'));
              } else if (call == 3) {
                expect(snapshot.docs.length, equals(1));
                expect(
                  snapshot.docs.where((doc) => doc.id == 'doc1').isEmpty,
                  isTrue,
                );
              } else if (call == 4) {
                expect(snapshot.docs.length, equals(2));
                QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot =
                    snapshot.docs.firstWhere((doc) => doc.id == 'doc2');
                expect(documentSnapshot.data()['foo'], equals('bar'));
              } else if (call == 5) {
                expect(snapshot.docs.length, equals(2));
                QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot =
                    snapshot.docs.firstWhere((doc) => doc.id == 'doc2');
                expect(documentSnapshot.data()['foo'], equals('baz'));
              } else {
                fail('Should not have been called');
              }
            },
            count: 5,
            reason: 'Stream should only have been called five times.',
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        await collection.doc('doc1').set({'bar': 'baz'});
        await collection.doc('doc1').delete();
        await collection.doc('doc2').set({'foo': 'bar'});
        await collection.doc('doc2').update({'foo': 'baz'});

        await subscription.cancel();
      });

      test(
        'listeners throws a [FirebaseException] with Query',
        () async {
          CollectionReference<Map<String, dynamic>> collection =
              firestore.collection('not-allowed');
          Stream<QuerySnapshot<Map<String, dynamic>>> stream =
              collection.snapshots();

          try {
            await stream.first;
          } catch (error) {
            expect(error, isA<FirebaseException>());
            expect(
              (error as FirebaseException).code,
              equals(
                'permission-denied',
              ),
            );
            return;
          }

          fail('Should have thrown a [FirebaseException]');
        },
      );
    });

    /**
     * End At
     */

    group('Query.endAt{Document}()', () {
      test('ends at string field paths', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endAt-string');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
            'bar': {'value': 1},
          }),
          collection.doc('doc2').set({
            'foo': 2,
            'bar': {'value': 2},
          }),
          collection.doc('doc3').set({
            'foo': 3,
            'bar': {'value': 3},
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .orderBy('bar.value', descending: true)
            .endAt([2]).get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc3'));
        expect(snapshot.docs[1].id, equals('doc2'));

        QuerySnapshot<Map<String, dynamic>> snapshot2 =
            await collection.orderBy('foo').endAt([2]).get();

        expect(snapshot2.docs.length, equals(2));
        expect(snapshot2.docs[0].id, equals('doc1'));
        expect(snapshot2.docs[1].id, equals('doc2'));
      });

      test('ends at string field paths with Iterable', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endAt-string');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
            'bar': {'value': 1},
          }),
          collection.doc('doc2').set({
            'foo': 2,
            'bar': {'value': 2},
          }),
          collection.doc('doc3').set({
            'foo': 3,
            'bar': {'value': 3},
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .orderBy('bar.value', descending: true)
            .endAt({2}).get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc3'));
        expect(snapshot.docs[1].id, equals('doc2'));

        QuerySnapshot<Map<String, dynamic>> snapshot2 =
            await collection.orderBy('foo').endAt([2]).get();

        expect(snapshot2.docs.length, equals(2));
        expect(snapshot2.docs[0].id, equals('doc1'));
        expect(snapshot2.docs[1].id, equals('doc2'));
      });

      test('ends at field paths', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endAt-field-path');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
            'bar': {'value': 1},
          }),
          collection.doc('doc2').set({
            'foo': 2,
            'bar': {'value': 2},
          }),
          collection.doc('doc3').set({
            'foo': 3,
            'bar': {'value': 3},
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .orderBy(FieldPath(const ['bar', 'value']), descending: true)
            .endAt([2]).get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc3'));
        expect(snapshot.docs[1].id, equals('doc2'));

        QuerySnapshot<Map<String, dynamic>> snapshot2 =
            await collection.orderBy(FieldPath(const ['foo'])).endAt([2]).get();

        expect(snapshot2.docs.length, equals(2));
        expect(snapshot2.docs[0].id, equals('doc1'));
        expect(snapshot2.docs[1].id, equals('doc2'));
      });

      test('endAtDocument() ends at a document field value', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endAt-document');
        await Future.wait([
          collection.doc('doc1').set({
            'bar': {'value': 3},
          }),
          collection.doc('doc2').set({
            'bar': {'value': 2},
          }),
          collection.doc('doc3').set({
            'bar': {'value': 1},
          }),
        ]);

        DocumentSnapshot endAtSnapshot = await collection.doc('doc2').get();

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .orderBy('bar.value')
            .endAtDocument(endAtSnapshot)
            .get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc3'));
        expect(snapshot.docs[1].id, equals('doc2'));
      });

      test('endAtDocument() ends at a document', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endAt-document');
        await Future.wait([
          collection.doc('doc1').set({
            'bar': {'value': 1},
          }),
          collection.doc('doc2').set({
            'bar': {'value': 2},
          }),
          collection.doc('doc3').set({
            'bar': {'value': 3},
          }),
          collection.doc('doc4').set({
            'bar': {'value': 4},
          }),
        ]);

        DocumentSnapshot endAtSnapshot = await collection.doc('doc3').get();

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.endAtDocument(endAtSnapshot).get();

        expect(snapshot.docs.length, equals(3));
        expect(snapshot.docs[0].id, equals('doc1'));
        expect(snapshot.docs[1].id, equals('doc2'));
        expect(snapshot.docs[2].id, equals('doc3'));
      });
    });

    /**
     * Start At
     */

    group('Query.startAt{Document}()', () {
      test('starts at string field paths', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startAt-string');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
            'bar': {'value': 1},
          }),
          collection.doc('doc2').set({
            'foo': 2,
            'bar': {'value': 2},
          }),
          collection.doc('doc3').set({
            'foo': 3,
            'bar': {'value': 3},
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .orderBy('bar.value', descending: true)
            .startAt([2]).get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc2'));
        expect(snapshot.docs[1].id, equals('doc1'));

        QuerySnapshot<Map<String, dynamic>> snapshot2 =
            await collection.orderBy('foo').startAt([2]).get();

        expect(snapshot2.docs.length, equals(2));
        expect(snapshot2.docs[0].id, equals('doc2'));
        expect(snapshot2.docs[1].id, equals('doc3'));
      });

      test('starts at string field paths with Iterable', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startAt-string');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
            'bar': {'value': 1},
          }),
          collection.doc('doc2').set({
            'foo': 2,
            'bar': {'value': 2},
          }),
          collection.doc('doc3').set({
            'foo': 3,
            'bar': {'value': 3},
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .orderBy('bar.value', descending: true)
            .startAt([2]).get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc2'));
        expect(snapshot.docs[1].id, equals('doc1'));

        QuerySnapshot<Map<String, dynamic>> snapshot2 =
            await collection.orderBy('foo').startAt({2}).get();

        expect(snapshot2.docs.length, equals(2));
        expect(snapshot2.docs[0].id, equals('doc2'));
        expect(snapshot2.docs[1].id, equals('doc3'));
      });

      test('starts at field paths', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startAt-field-path');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
            'bar': {'value': 1},
          }),
          collection.doc('doc2').set({
            'foo': 2,
            'bar': {'value': 2},
          }),
          collection.doc('doc3').set({
            'foo': 3,
            'bar': {'value': 3},
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .orderBy(FieldPath(const ['bar', 'value']), descending: true)
            .startAt([2]).get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc2'));
        expect(snapshot.docs[1].id, equals('doc1'));

        QuerySnapshot<Map<String, dynamic>> snapshot2 = await collection
            .orderBy(FieldPath(const ['foo']))
            .startAt([2]).get();

        expect(snapshot2.docs.length, equals(2));
        expect(snapshot2.docs[0].id, equals('doc2'));
        expect(snapshot2.docs[1].id, equals('doc3'));
      });

      test('startAtDocument() starts at a document field value', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startAt-document-field-value');
        await Future.wait([
          collection.doc('doc1').set({
            'bar': {'value': 3},
          }),
          collection.doc('doc2').set({
            'bar': {'value': 2},
          }),
          collection.doc('doc3').set({
            'bar': {'value': 1},
          }),
        ]);

        DocumentSnapshot startAtSnapshot = await collection.doc('doc2').get();

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .orderBy('bar.value')
            .startAtDocument(startAtSnapshot)
            .get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc2'));
        expect(snapshot.docs[1].id, equals('doc1'));
      });

      test('startAtDocument() starts at a document', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startAt-document');
        await Future.wait([
          collection.doc('doc1').set({
            'bar': {'value': 1},
          }),
          collection.doc('doc2').set({
            'bar': {'value': 2},
          }),
          collection.doc('doc3').set({
            'bar': {'value': 3},
          }),
          collection.doc('doc4').set({
            'bar': {'value': 4},
          }),
        ]);

        DocumentSnapshot startAtSnapshot = await collection.doc('doc3').get();

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.startAtDocument(startAtSnapshot).get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc3'));
        expect(snapshot.docs[1].id, equals('doc4'));
      });
    });

    /**
     * End Before
     */

    group('Query.endBefore{Document}()', () {
      test('ends before string field paths', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endBefore-string');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
            'bar': {'value': 1},
          }),
          collection.doc('doc2').set({
            'foo': 2,
            'bar': {'value': 2},
          }),
          collection.doc('doc3').set({
            'foo': 3,
            'bar': {'value': 3},
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .orderBy('bar.value', descending: true)
            .endBefore([1]).get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc3'));
        expect(snapshot.docs[1].id, equals('doc2'));

        QuerySnapshot<Map<String, dynamic>> snapshot2 =
            await collection.orderBy('foo').endBefore([3]).get();

        expect(snapshot2.docs.length, equals(2));
        expect(snapshot2.docs[0].id, equals('doc1'));
        expect(snapshot2.docs[1].id, equals('doc2'));
      });

      test('ends before string field paths with Iterable', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endBefore-string');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
            'bar': {'value': 1},
          }),
          collection.doc('doc2').set({
            'foo': 2,
            'bar': {'value': 2},
          }),
          collection.doc('doc3').set({
            'foo': 3,
            'bar': {'value': 3},
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .orderBy('bar.value', descending: true)
            .endBefore({1}).get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc3'));
        expect(snapshot.docs[1].id, equals('doc2'));

        QuerySnapshot<Map<String, dynamic>> snapshot2 =
            await collection.orderBy('foo').endBefore([3]).get();

        expect(snapshot2.docs.length, equals(2));
        expect(snapshot2.docs[0].id, equals('doc1'));
        expect(snapshot2.docs[1].id, equals('doc2'));
      });

      test('ends before field paths', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endBefore-field-path');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
            'bar': {'value': 1},
          }),
          collection.doc('doc2').set({
            'foo': 2,
            'bar': {'value': 2},
          }),
          collection.doc('doc3').set({
            'foo': 3,
            'bar': {'value': 3},
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .orderBy(FieldPath(const ['bar', 'value']), descending: true)
            .endBefore([1]).get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc3'));
        expect(snapshot.docs[1].id, equals('doc2'));

        QuerySnapshot<Map<String, dynamic>> snapshot2 = await collection
            .orderBy(FieldPath(const ['foo']))
            .endBefore([3]).get();

        expect(snapshot2.docs.length, equals(2));
        expect(snapshot2.docs[0].id, equals('doc1'));
        expect(snapshot2.docs[1].id, equals('doc2'));
      });

      test('endbeforeDocument() ends before a document field value', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endBefore-document-field-value');
        await Future.wait([
          collection.doc('doc1').set({
            'bar': {'value': 3},
          }),
          collection.doc('doc2').set({
            'bar': {'value': 2},
          }),
          collection.doc('doc3').set({
            'bar': {'value': 1},
          }),
        ]);

        DocumentSnapshot endAtSnapshot = await collection.doc('doc1').get();

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .orderBy('bar.value')
            .endBeforeDocument(endAtSnapshot)
            .get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc3'));
        expect(snapshot.docs[1].id, equals('doc2'));
      });

      test('endBeforeDocument() ends before a document', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endBefore-document');
        await Future.wait([
          collection.doc('doc1').set({
            'bar': {'value': 1},
          }),
          collection.doc('doc2').set({
            'bar': {'value': 2},
          }),
          collection.doc('doc3').set({
            'bar': {'value': 3},
          }),
          collection.doc('doc4').set({
            'bar': {'value': 4},
          }),
        ]);

        DocumentSnapshot endAtSnapshot = await collection.doc('doc4').get();

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.endBeforeDocument(endAtSnapshot).get();

        expect(snapshot.docs.length, equals(3));
        expect(snapshot.docs[0].id, equals('doc1'));
        expect(snapshot.docs[1].id, equals('doc2'));
        expect(snapshot.docs[2].id, equals('doc3'));
      });
    });

    /**
     * Start after
     */
    group('Query.startAfter{Document}()', () {
      test('starts after string field paths', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startAfter-string');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
            'bar': {'value': 1},
          }),
          collection.doc('doc2').set({
            'foo': 2,
            'bar': {'value': 2},
          }),
          collection.doc('doc3').set({
            'foo': 3,
            'bar': {'value': 3},
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .orderBy('bar.value', descending: true)
            .startAfter([3]).get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc2'));
        expect(snapshot.docs[1].id, equals('doc1'));

        QuerySnapshot<Map<String, dynamic>> snapshot2 =
            await collection.orderBy('foo').startAfter([1]).get();

        expect(snapshot2.docs.length, equals(2));
        expect(snapshot2.docs[0].id, equals('doc2'));
        expect(snapshot2.docs[1].id, equals('doc3'));
      });

      test('starts after field paths', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startAfter-field-path');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
            'bar': {'value': 1},
          }),
          collection.doc('doc2').set({
            'foo': 2,
            'bar': {'value': 2},
          }),
          collection.doc('doc3').set({
            'foo': 3,
            'bar': {'value': 3},
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .orderBy(FieldPath(const ['bar', 'value']), descending: true)
            .startAfter([3]).get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc2'));
        expect(snapshot.docs[1].id, equals('doc1'));

        QuerySnapshot<Map<String, dynamic>> snapshot2 = await collection
            .orderBy(FieldPath(const ['foo']))
            .startAfter([1]).get();

        expect(snapshot2.docs.length, equals(2));
        expect(snapshot2.docs[0].id, equals('doc2'));
        expect(snapshot2.docs[1].id, equals('doc3'));
      });

      test('startAfterDocument() starts after a document field value',
          () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startAfter-document-field-value');
        await Future.wait([
          collection.doc('doc1').set({
            'bar': {'value': 3},
          }),
          collection.doc('doc2').set({
            'bar': {'value': 2},
          }),
          collection.doc('doc3').set({
            'bar': {'value': 1},
          }),
        ]);

        DocumentSnapshot startAfterSnapshot =
            await collection.doc('doc3').get();

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .orderBy('bar.value')
            .startAfterDocument(startAfterSnapshot)
            .get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc2'));
        expect(snapshot.docs[1].id, equals('doc1'));
      });

      test('startAfterDocument() starts after a document', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startAfter-document');
        await Future.wait([
          collection.doc('doc1').set({
            'bar': {'value': 1},
          }),
          collection.doc('doc2').set({
            'bar': {'value': 2},
          }),
          collection.doc('doc3').set({
            'bar': {'value': 3},
          }),
          collection.doc('doc4').set({
            'bar': {'value': 4},
          }),
        ]);

        DocumentSnapshot startAtSnapshot = await collection.doc('doc2').get();

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.startAfterDocument(startAtSnapshot).get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc3'));
        expect(snapshot.docs[1].id, equals('doc4'));
      });

      testWidgets(
        'throws exception without orderBy() on field used for inequality query',
        (_) async {
          CollectionReference<Map<String, dynamic>> collection =
              await initializeTest('startAfterDocument-inequality-field-throw');
          await Future.wait([
            collection.doc('doc1').set({
              'bar': {'value': 2},
            }),
            collection.doc('doc2').set({
              'bar': {'value': 10},
            }),
            collection.doc('doc3').set({
              'bar': {'value': 10},
            }),
            collection.doc('doc4').set({
              'bar': {'value': 10},
            }),
          ]);

          DocumentSnapshot startAtSnapshot = await collection.doc('doc2').get();
          Query inequalityQuery =
              collection.where('bar.value', isGreaterThan: 5);

          await expectLater(
            inequalityQuery.startAfterDocument(startAtSnapshot).get(),
            throwsA(
              isA<FirebaseException>().having(
                (e) => e.message,
                'message',
                contains(
                  'Client specified an invalid argument',
                ),
              ),
            ),
          );
        },
        // firebase-js-sdk does not require an orderBy() field to be set for this to work
        skip: kIsWeb,
      );

      testWidgets(
        'throws exception without correct orderBy("wrong-field") field used for inequality query',
        (_) async {
          CollectionReference<Map<String, dynamic>> collection =
              await initializeTest(
            'startAfterDocument-wrong-inequality-field-throw',
          );
          await Future.wait([
            collection.doc('doc1').set({
              'bar': {'value': 2},
            }),
            collection.doc('doc2').set(
              {
                'bar': {'value': 10},
                'wrong-field': 2,
              },
            ),
            collection.doc('doc3').set(
              {
                'bar': {'value': 10},
                'wrong-field': 2,
              },
            ),
            collection.doc('doc4').set(
              {
                'bar': {'value': 10},
                'wrong-field': 2,
              },
            ),
          ]);

          DocumentSnapshot startAtSnapshot = await collection.doc('doc2').get();
          Query inequalityQuery =
              collection.where('bar.value', isGreaterThan: 5);
          await expectLater(
            inequalityQuery
                .orderBy('wrong-field')
                .startAfterDocument(startAtSnapshot)
                .get(),
            throwsA(
              isA<FirebaseException>().having(
                (e) => e.message,
                'message',
                contains(
                  'Client specified an invalid argument',
                ),
              ),
            ),
          );
        },
        // firebase-js-sdk does not require an orderBy() field to be set for this to work
        skip: kIsWeb,
      );

      testWidgets(
          'Successful request when using orderBy() with same field used on inequality query',
          (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startAfterDocument-correct-inequality-field');
        await Future.wait([
          collection.doc('doc1').set({
            'bar': 2,
          }),
          collection.doc('doc2').set({
            'bar': 10,
          }),
          collection.doc('doc3').set({
            'bar': 11,
          }),
          collection.doc('doc4').set({
            'bar': 12,
          }),
        ]);

        DocumentSnapshot startAtSnapshot = await collection.doc('doc2').get();
        Query inequalityQuery = collection.where('bar', isGreaterThan: 5);

        final result = await inequalityQuery
            .orderBy('bar')
            .startAfterDocument(startAtSnapshot)
            .get();

        expect(result.size, equals(2));
        expect(result.docs[0].id, equals('doc3'));
        expect(result.docs[1].id, equals('doc4'));
      });
    });

    /**
     * Start & End
     */

    group('Query.startAt/endAt', () {
      test('starts at & ends at a document', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('start-end-string');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
          }),
          collection.doc('doc2').set({
            'foo': 2,
          }),
          collection.doc('doc3').set({
            'foo': 3,
          }),
          collection.doc('doc4').set({
            'foo': 4,
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.orderBy('foo').startAt([2]).endAt([3]).get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc2'));
        expect(snapshot.docs[1].id, equals('doc3'));
      });

      test('starts at & ends before a document', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('start-end-string');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
          }),
          collection.doc('doc2').set({
            'foo': 2,
          }),
          collection.doc('doc3').set({
            'foo': 3,
          }),
          collection.doc('doc4').set({
            'foo': 4,
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.orderBy('foo').startAt([2]).endBefore([4]).get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc2'));
        expect(snapshot.docs[1].id, equals('doc3'));
      });

      test('starts after & ends at a document', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('start-end-field-path');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
          }),
          collection.doc('doc2').set({
            'foo': 2,
          }),
          collection.doc('doc3').set({
            'foo': 3,
          }),
          collection.doc('doc4').set({
            'foo': 4,
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.orderBy('foo').startAfter([1]).endAt([3]).get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc2'));
        expect(snapshot.docs[1].id, equals('doc3'));
      });

      test('starts a document and ends before document', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('start-end-document');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
          }),
          collection.doc('doc2').set({
            'foo': 2,
          }),
          collection.doc('doc3').set({
            'foo': 3,
          }),
          collection.doc('doc4').set({
            'foo': 4,
          }),
        ]);

        DocumentSnapshot startAtSnapshot = await collection.doc('doc2').get();
        DocumentSnapshot endBeforeSnapshot = await collection.doc('doc4').get();

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .startAtDocument(startAtSnapshot)
            .endBeforeDocument(endBeforeSnapshot)
            .get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc2'));
        expect(snapshot.docs[1].id, equals('doc3'));
      });
    });

    /**
     * Limit
     */

    group('Query.limit{toLast}()', () {
      test('limits documents', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('limit');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
          }),
          collection.doc('doc2').set({
            'foo': 2,
          }),
          collection.doc('doc3').set({
            'foo': 3,
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.limit(2).get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc1'));
        expect(snapshot.docs[1].id, equals('doc2'));

        QuerySnapshot<Map<String, dynamic>> snapshot2 =
            await collection.orderBy('foo', descending: true).limit(2).get();

        expect(snapshot2.docs.length, equals(2));
        expect(snapshot2.docs[0].id, equals('doc3'));
        expect(snapshot2.docs[1].id, equals('doc2'));
      });

      test('limits to last documents', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('limitToLast');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
          }),
          collection.doc('doc2').set({
            'foo': 2,
          }),
          collection.doc('doc3').set({
            'foo': 3,
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.orderBy('foo').limitToLast(2).get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc2'));
        expect(snapshot.docs[1].id, equals('doc3'));

        QuerySnapshot<Map<String, dynamic>> snapshot2 = await collection
            .orderBy('foo', descending: true)
            .limitToLast(2)
            .get();

        expect(snapshot2.docs.length, equals(2));
        expect(snapshot2.docs[0].id, equals('doc2'));
        expect(snapshot2.docs[1].id, equals('doc1'));
      });
    });

    /**
     * Order
     */
    group('Query.orderBy()', () {
      test('allows ordering by documentId', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('order-document-id');

        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
          }),
          collection.doc('doc2').set({
            'foo': 1,
          }),
          collection.doc('doc3').set({
            'foo': 1,
          }),
          collection.doc('doc4').set({
            'bar': 1,
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.orderBy('foo').orderBy(FieldPath.documentId).get();

        expect(snapshot.docs.length, equals(3));
        expect(snapshot.docs[0].id, equals('doc1'));
        expect(snapshot.docs[1].id, equals('doc2'));
        expect(snapshot.docs[2].id, equals('doc3'));
      });

      test('orders async by default', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('order-asc');

        await Future.wait([
          collection.doc('doc1').set({
            'foo': 3,
          }),
          collection.doc('doc2').set({
            'foo': 2,
          }),
          collection.doc('doc3').set({
            'foo': 1,
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.orderBy('foo').get();

        expect(snapshot.docs.length, equals(3));
        expect(snapshot.docs[0].id, equals('doc3'));
        expect(snapshot.docs[1].id, equals('doc2'));
        expect(snapshot.docs[2].id, equals('doc1'));
      });

      test('orders descending', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('order-desc');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
          }),
          collection.doc('doc2').set({
            'foo': 2,
          }),
          collection.doc('doc3').set({
            'foo': 3,
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.orderBy('foo', descending: true).get();

        expect(snapshot.docs.length, equals(3));
        expect(snapshot.docs[0].id, equals('doc3'));
        expect(snapshot.docs[1].id, equals('doc2'));
        expect(snapshot.docs[2].id, equals('doc1'));
      });
    });

    /**
     * Where filters
     */

    group('Query.where()', () {
      test('returns documents when querying for properties that are not null',
          () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('not-null');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 'bar',
          }),
          collection.doc('doc2').set({
            'foo': 'bar',
          }),
          collection.doc('doc3').set({
            'foo': null,
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.where('foo', isNull: false).get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc1'));
        expect(snapshot.docs[1].id, equals('doc2'));
      });

      test('returns documents when querying properties that are equal to null',
          () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('not-null');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 'bar',
          }),
          collection.doc('doc2').set({
            'foo': 'bar',
          }),
          collection.doc('doc3').set({
            'foo': null,
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.where('foo', isNull: true).get();

        expect(snapshot.docs.length, equals(1));
        expect(snapshot.docs[0].id, equals('doc3'));
      });

      test('returns with equal checks', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-equal');
        int rand = Random().nextInt(9999);

        await Future.wait([
          collection.doc('doc1').set({
            'foo': rand,
          }),
          collection.doc('doc2').set({
            'foo': rand,
          }),
          collection.doc('doc3').set({
            'foo': rand + 1,
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.where('foo', isEqualTo: rand).get();

        expect(snapshot.docs.length, equals(2));
        snapshot.docs.forEach((doc) {
          expect(doc.data()['foo'], equals(rand));
        });
      });

      test('returns with not equal checks', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-not-equal');
        int rand = Random().nextInt(9999);

        await Future.wait([
          collection.doc('doc1').set({
            'foo': rand,
          }),
          collection.doc('doc2').set({
            'foo': rand,
          }),
          collection.doc('doc3').set({
            'foo': rand + 1,
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.where('foo', isNotEqualTo: rand).get();

        expect(snapshot.docs.length, equals(1));
        snapshot.docs.forEach((doc) {
          expect(doc.data()['foo'], equals(rand + 1));
        });
      });

      test('returns with greater than checks', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-greater-than');
        int rand = Random().nextInt(9999);

        await Future.wait([
          collection.doc('doc1').set({
            'foo': rand - 1,
          }),
          collection.doc('doc2').set({
            'foo': rand,
          }),
          collection.doc('doc3').set({
            'foo': rand + 1,
          }),
          collection.doc('doc4').set({
            'foo': rand + 2,
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.where('foo', isGreaterThan: rand).get();

        expect(snapshot.docs.length, equals(2));
        snapshot.docs.forEach((doc) {
          expect(doc.data()['foo'] > rand, isTrue);
        });
      });

      test('returns with greater than or equal to checks', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-greater-than-equal');
        int rand = Random().nextInt(9999);

        await Future.wait([
          collection.doc('doc1').set({
            'foo': rand - 1,
          }),
          collection.doc('doc2').set({
            'foo': rand,
          }),
          collection.doc('doc3').set({
            'foo': rand + 1,
          }),
          collection.doc('doc4').set({
            'foo': rand + 2,
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.where('foo', isGreaterThanOrEqualTo: rand).get();

        expect(snapshot.docs.length, equals(3));
        snapshot.docs.forEach((doc) {
          expect(doc.data()['foo'] >= rand, isTrue);
        });
      });

      test('returns with less than checks', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-less-than');
        int rand = Random().nextInt(9999);

        await Future.wait([
          collection.doc('doc1').set({
            'foo': -rand + 1,
          }),
          collection.doc('doc2').set({
            'foo': -rand + 2,
          }),
          collection.doc('doc3').set({
            'foo': rand,
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.where('foo', isLessThan: rand).get();

        expect(snapshot.docs.length, equals(2));
        snapshot.docs.forEach((doc) {
          expect(doc.data()['foo'] < rand, isTrue);
        });
      });

      test('returns with less than equal checks', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-less-than');
        int rand = Random().nextInt(9999);

        await Future.wait([
          collection.doc('doc1').set({
            'foo': -rand + 1,
          }),
          collection.doc('doc2').set({
            'foo': -rand + 2,
          }),
          collection.doc('doc3').set({
            'foo': rand,
          }),
          collection.doc('doc4').set({
            'foo': rand + 1,
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.where('foo', isLessThanOrEqualTo: rand).get();

        expect(snapshot.docs.length, equals(3));
        snapshot.docs.forEach((doc) {
          expect(doc.data()['foo'] <= rand, isTrue);
        });
      });

      test('returns with array-contains filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-array-contains');
        int rand = Random().nextInt(9999);

        await Future.wait([
          collection.doc('doc1').set({
            'foo': [1, '2', rand],
          }),
          collection.doc('doc2').set({
            'foo': [1, '2', '$rand'],
          }),
          collection.doc('doc3').set({
            'foo': [1, '2', '$rand'],
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.where('foo', arrayContains: '$rand').get();

        expect(snapshot.docs.length, equals(2));
        snapshot.docs.forEach((doc) {
          expect(doc.data()['foo'], equals([1, '2', '$rand']));
        });
      });

      test('returns with in filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-in');

        await Future.wait([
          collection.doc('doc1').set({
            'status': 'Ordered',
          }),
          collection.doc('doc2').set({
            'status': 'Ready to Ship',
          }),
          collection.doc('doc3').set({
            'status': 'Ready to Ship',
          }),
          collection.doc('doc4').set({
            'status': 'Incomplete',
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .where('status', whereIn: ['Ready to Ship', 'Ordered']).get();

        expect(snapshot.docs.length, equals(3));
        snapshot.docs.forEach((doc) {
          String status = doc.data()['status'];
          expect(status == 'Ready to Ship' || status == 'Ordered', isTrue);
        });
      });

      test('returns with in filter using Iterable', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-in-iterable');

        await Future.wait([
          collection.doc('doc1').set({
            'status': 'Ordered',
          }),
          collection.doc('doc2').set({
            'status': 'Ready to Ship',
          }),
          collection.doc('doc3').set({
            'status': 'Ready to Ship',
          }),
          collection.doc('doc4').set({
            'status': 'Incomplete',
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .where(
              'status',
              // To force the list to be an iterable
              whereIn: ['Ready to Ship', 'Ordered'].map((e) => e),
            )
            .get();

        expect(snapshot.docs.length, equals(3));
        snapshot.docs.forEach((doc) {
          String status = doc.data()['status'];
          expect(status == 'Ready to Ship' || status == 'Ordered', isTrue);
        });
      });

      test('returns with in filter using Set', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-in');

        await Future.wait([
          collection.doc('doc1').set({
            'status': 'Ordered',
          }),
          collection.doc('doc2').set({
            'status': 'Ready to Ship',
          }),
          collection.doc('doc3').set({
            'status': 'Ready to Ship',
          }),
          collection.doc('doc4').set({
            'status': 'Incomplete',
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .where('status', whereIn: {'Ready to Ship', 'Ordered'}).get();

        expect(snapshot.docs.length, equals(3));
        snapshot.docs.forEach((doc) {
          String status = doc.data()['status'];
          expect(status == 'Ready to Ship' || status == 'Ordered', isTrue);
        });
      });

      test('returns with not-in filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-not-in');

        await Future.wait([
          collection.doc('doc1').set({
            'status': 'Ordered',
          }),
          collection.doc('doc2').set({
            'status': 'Ready to Ship',
          }),
          collection.doc('doc3').set({
            'status': 'Ready to Ship',
          }),
          collection.doc('doc4').set({
            'status': 'Incomplete',
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .where('status', whereNotIn: ['Ready to Ship', 'Ordered']).get();

        expect(snapshot.docs.length, equals(1));
        snapshot.docs.forEach((doc) {
          String status = doc.data()['status'];
          expect(status == 'Incomplete', isTrue);
        });
      });

      test('returns with not-in filter with Iterable', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-not-in');

        await Future.wait([
          collection.doc('doc1').set({
            'status': 'Ordered',
          }),
          collection.doc('doc2').set({
            'status': 'Ready to Ship',
          }),
          collection.doc('doc3').set({
            'status': 'Ready to Ship',
          }),
          collection.doc('doc4').set({
            'status': 'Incomplete',
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .where('status', whereNotIn: {'Ready to Ship', 'Ordered'}).get();

        expect(snapshot.docs.length, equals(1));
        snapshot.docs.forEach((doc) {
          String status = doc.data()['status'];
          expect(status == 'Incomplete', isTrue);
        });
      });

      test('returns with array-contains-any filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-array-contains-any');

        await Future.wait([
          collection.doc('doc1').set({
            'category': ['Appliances', 'Housewares', 'Cooking'],
          }),
          collection.doc('doc2').set({
            'category': ['Appliances', 'Electronics', 'Nursery'],
          }),
          collection.doc('doc3').set({
            'category': ['Audio/Video', 'Electronics'],
          }),
          collection.doc('doc4').set({
            'category': ['Beauty'],
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection.where(
          'category',
          arrayContainsAny: ['Appliances', 'Electronics'],
        ).get();

        // 2nd record should only be returned once
        expect(snapshot.docs.length, equals(3));
      });

      test('returns with array-contains-any filter using Set', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-array-contains-any');

        await Future.wait([
          collection.doc('doc1').set({
            'category': ['Appliances', 'Housewares', 'Cooking'],
          }),
          collection.doc('doc2').set({
            'category': ['Appliances', 'Electronics', 'Nursery'],
          }),
          collection.doc('doc3').set({
            'category': ['Audio/Video', 'Electronics'],
          }),
          collection.doc('doc4').set({
            'category': ['Beauty'],
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection.where(
          'category',
          arrayContainsAny: {'Appliances', 'Electronics'},
        ).get();

        // 2nd record should only be returned once
        expect(snapshot.docs.length, equals(3));
      });

      // When documents have a key with a '.' in them, only a [FieldPath]
      // can access the value, rather than a raw string
      test('returns where FieldPath', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-field-path');

        FieldPath fieldPath = FieldPath(const ['nested', 'foo.bar@gmail.com']);

        await Future.wait([
          collection.doc('doc1').set({
            'nested': {
              'foo.bar@gmail.com': true,
            },
          }),
          collection.doc('doc2').set({
            'nested': {
              'foo.bar@gmail.com': true,
            },
            'foo': 'bar',
          }),
          collection.doc('doc3').set({
            'nested': {
              'foo.bar@gmail.com': false,
            },
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.where(fieldPath, isEqualTo: true).get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].get(fieldPath), isTrue);
        expect(snapshot.docs[1].get(fieldPath), isTrue);
        expect(snapshot.docs[1].get('foo'), equals('bar'));
      });

      test('returns results using FieldPath.documentId', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-field-path-document-id');

        DocumentReference<Map<String, dynamic>> docRef = await collection.add({
          'foo': 'bar',
        });

        // Add secondary document for sanity check
        await collection.add({
          'bar': 'baz',
        });

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .where(FieldPath.documentId, isEqualTo: docRef.id)
            .get();

        expect(snapshot.docs.length, equals(1));
        expect(snapshot.docs[0].get('foo'), equals('bar'));
      });

      test('returns an encoded DocumentReference', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-document-reference');

        DocumentReference<Map<String, dynamic>> ref =
            FirebaseFirestore.instance.doc('foo/bar');

        await Future.wait([
          collection.add({
            'foo': ref,
          }),
          collection.add({
            'foo': FirebaseFirestore.instance.doc('bar/baz'),
          }),
          collection.add({
            'foo': 'foo/bar',
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .where('foo', isEqualTo: FirebaseFirestore.instance.doc('foo/bar'))
            .get();

        expect(snapshot.docs.length, equals(1));
        expect(snapshot.docs[0].get('foo'), equals(ref));
      });
    });

    group('Query.where() with Filter class', () {
      test(
          'returns documents with `DocumentReference` as an argument in `isEqualTo`',
          () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('doc-ref-arg-isequal-to');
        final ref = FirebaseFirestore.instance.doc('foo/bar');
        final ref2 = FirebaseFirestore.instance.doc('foo/foo');
        await Future.wait([
          collection.doc('doc1').set({
            'genre': 'fantasy',
            'title': 'Book A',
            'ref': FirebaseFirestore.instance.doc('foo/bar'),
          }),
          collection.doc('doc2').set({
            'genre': 'fantasy',
            'title': 'Book B',
            'ref': FirebaseFirestore.instance.doc('foo/bar'),
          }),
          collection.doc('doc3').set({
            'genre': 'fantasy',
            'title': 'Book C',
            'ref': ref2,
          }),
        ]);

        final results = await collection
            .where(
              Filter.or(
                Filter.and(
                  Filter('genre', isEqualTo: 'fantasy'),
                  Filter('ref', isEqualTo: ref),
                ),
                Filter.and(
                  Filter('genre', isEqualTo: 'fantasy'),
                  Filter(
                    'ref',
                    isEqualTo: ref2,
                  ),
                ),
              ),
            )
            .orderBy('title', descending: true)
            .get();

        expect(results.docs.length, equals(3));
        expect(results.docs[0].data()['title'], equals('Book C'));
        expect(results.docs[1].data()['title'], equals('Book B'));
        expect(results.docs[2].data()['title'], equals('Book A'));
      });

      test(
          'returns documents with `DocumentReference` as an argument in `arrayContains`',
          () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('doc-ref-arg-array-contains');
        final ref = FirebaseFirestore.instance.doc('foo/bar');
        final ref2 = FirebaseFirestore.instance.doc('foo/foo');
        await Future.wait([
          collection.doc('doc1').set({
            'genre': 'fantasy',
            'title': 'Book A',
            'ref': [ref],
          }),
          collection.doc('doc2').set({
            'genre': 'fantasy',
            'title': 'Book B',
            'ref': [ref],
          }),
          collection.doc('doc3').set({
            'genre': 'adventure',
            'title': 'Book C',
            'ref': [ref2],
          }),
        ]);

        final results = await collection
            .where(
              Filter.or(
                Filter.and(
                  Filter('genre', isEqualTo: 'fantasy'),
                  Filter('ref', arrayContains: ref),
                ),
                Filter.and(
                  Filter('genre', isEqualTo: 'adventure'),
                  Filter(
                    'ref',
                    arrayContains: ref2,
                  ),
                ),
              ),
            )
            .orderBy('title', descending: true)
            .get();

        expect(results.docs.length, equals(3));
        expect(results.docs[0].data()['title'], equals('Book C'));
        expect(results.docs[1].data()['title'], equals('Book B'));
        expect(results.docs[2].data()['title'], equals('Book A'));
      });

      test('returns documents with OR filter for arrayContainsAny', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-filter-array-contains-any');
        await Future.wait([
          collection.doc('doc1').set({
            'genre': ['fantasy', 'action'],
            'title': 'Book A',
          }),
          collection.doc('doc2').set({
            'genre': ['sci-fi', 'thriller'],
            'title': 'Book B',
          }),
          collection.doc('doc3').set({
            'genre': ['mystery', 'thriller'],
            'title': 'Book C',
          }),
        ]);

        final results = await collection
            .where(
              Filter.or(
                Filter('genre', arrayContainsAny: ['fantasy']),
                Filter('genre', arrayContainsAny: ['sci-fi']),
              ),
            )
            .orderBy('title', descending: true)
            .get();

        expect(results.docs.length, equals(2));
        expect(results.docs[0].data()['title'], equals('Book B'));
        expect(results.docs[1].data()['title'], equals('Book A'));
      });

      test('returns documents with AND filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-filter-and');
        await Future.wait([
          collection.doc('doc1').set({
            'genre': ['fantasy', 'action'],
            'rating': 4.5,
          }),
          collection.doc('doc2').set({
            'genre': ['sci-fi', 'thriller'],
            'rating': 3.8,
          }),
          collection.doc('doc3').set({
            'genre': ['sci-fi', 'action'],
            'rating': 4.2,
          }),
        ]);

        final results = await collection
            .where(
              Filter.and(
                Filter('genre', arrayContains: 'sci-fi'),
                Filter('rating', isGreaterThanOrEqualTo: 4.0),
              ),
            )
            .orderBy('rating', descending: true)
            .get();

        expect(results.docs.length, equals(1));
        expect(results.docs[0].id, equals('doc3'));
        expect(results.docs[0].data()['rating'], equals(4.2));
        expect(results.docs[0].data()['genre'], equals(['sci-fi', 'action']));
      });

      test('returns documents with OR filter and a previous condition',
          () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-filter-and');
        await Future.wait([
          collection.doc('doc1').set({
            'genre': 'fantasy',
            'rating': 4.5,
            'year': 1970,
          }),
          collection.doc('doc2').set({
            'genre': 'fantasy',
            'rating': 3.8,
            'year': 1980,
          }),
          collection.doc('doc3').set({
            'genre': 'sci-fi',
            'rating': 4.2,
            'year': 1980,
          }),
        ]);

        final results = await collection
            .where('genre', isEqualTo: 'fantasy')
            .where(
              Filter.or(
                Filter('year', isEqualTo: 1980),
                Filter('rating', isGreaterThanOrEqualTo: 4.0),
              ),
            )
            .orderBy('rating')
            .get();

        expect(results.docs.length, equals(2));
        expect(results.docs[0].id, equals('doc2'));
        expect(results.docs[0].data()['rating'], equals(3.8));
        expect(results.docs[1].id, equals('doc1'));
        expect(results.docs[1].data()['rating'], equals(4.5));
      });

      test('returns documents with nested OR and AND filters', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-filter-nested');
        await Future.wait([
          collection.doc('doc1').set({
            'genre': ['fantasy', 'action'],
            'rating': 4.5,
          }),
          collection.doc('doc2').set({
            'genre': ['sci-fi', 'thriller'],
            'rating': 3.8,
          }),
          collection.doc('doc3').set({
            'genre': ['sci-fi', 'action'],
            'rating': 4.2,
          }),
          collection.doc('doc4').set({
            'genre': ['mystery', 'action'],
            'rating': 4.7,
          }),
        ]);

        final results = await collection
            .where(
              Filter.or(
                Filter.and(
                  Filter('genre', arrayContains: 'sci-fi'),
                  Filter('rating', isGreaterThanOrEqualTo: 4.0),
                ),
                Filter.and(
                  Filter('genre', arrayContains: 'mystery'),
                  Filter('rating', isGreaterThanOrEqualTo: 4.5),
                ),
              ),
            )
            .orderBy('rating', descending: true)
            .get();

        expect(results.docs.length, equals(2));
        expect(results.docs[0].id, equals('doc4'));
        expect(results.docs[0].data()['rating'], equals(4.7));
        expect(
          results.docs[0].data()['genre'],
          equals(['mystery', 'action']),
        );
        expect(results.docs[1].id, equals('doc3'));
        expect(results.docs[1].data()['rating'], equals(4.2));
        expect(results.docs[1].data()['genre'], equals(['sci-fi', 'action']));
      });

      test('allow FieldPathType for Filter queries', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('filter-path-type');

        await Future.wait([
          collection.doc('doc1').set({
            'genre': ['fantasy', 'action'],
            'rating': 4.5,
          }),
          collection.doc('doc2').set({
            'genre': ['sci-fi', 'thriller'],
            'rating': 3.8,
          }),
          collection.doc('doc3').set({
            'genre': ['sci-fi', 'action'],
            'rating': 4.2,
          }),
          collection.doc('doc4').set({
            'genre': ['mystery', 'action'],
            'rating': 4.7,
          }),
        ]);

        final results = await collection
            .where(
              Filter.or(
                Filter.and(
                  Filter(FieldPath.documentId, isEqualTo: 'doc1'),
                  Filter('rating', isEqualTo: 4.5),
                ),
                Filter.and(
                  Filter(FieldPath.documentId, isEqualTo: 'doc2'),
                  Filter('rating', isEqualTo: 3.8),
                ),
              ),
            )
            .orderBy(FieldPath.documentId, descending: false)
            .get();

        expect(results.docs.length, equals(2));
        expect(results.docs[0].id, equals('doc1'));
        expect(results.docs[0].data()['rating'], equals(4.5));

        expect(results.docs[1].id, equals('doc2'));
        expect(results.docs[1].data()['rating'], equals(3.8));
      });

      test('allow multiple conjunctive queries', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('multiple-conjunctive-queries');

        final matchMap = {
          'rating1': 3.8,
          'year1': 1970,
          'runtime1': 90,
          'director1': 'Director2',
          'producer1': 'Producer2',
          'budget1': 20000000,
          'boxOffice1': 50000000,
          'actor1': 'Actor2',
          'language1': 'English',
          'award1': 'Award2',
          'genre1': ['sci-fi', 'thriller'],
          'country1': 'USA',
          'released1': true,
          'screenplay1': 'Screenplay2',
          'cinematography1': 'Cinematography2',
          'music1': 'Music2',
          'rating2': 4.2,
          'year2': 1982,
          'runtime2': 60,
          'director2': 'Director3',
          'producer2': 'Producer3',
          'budget2': 30000000,
          'boxOffice2': 60000000,
          'actor2': 'Actor3',
          'language2': 'Korean',
          'award2': 'Award3',
          'genre2': ['sci-fi', 'action'],
          'country2': 'South Korea',
          'released2': false,
          'screenplay2': 'Screenplay3',
        };

        await Future.wait([
          collection.doc('doc1').set({
            'genre': ['fantasy', 'action'],
            'rating': 4.5,
            'director': 'Director1',
            'producer': 'Producer1',
            'budget': 10000000,
            'boxOffice': 25000000,
            'actor': 'Actor1',
            'language': 'English',
            'award': 'Award1',
          }),
          collection.doc('doc2').set(matchMap),
          collection.doc('doc3').set(matchMap),
        ]);

        final results = await collection
            .where(
              Filter.and(
                Filter('rating1', isEqualTo: 3.8),
                Filter('year1', isEqualTo: 1970),
                Filter('runtime1', isEqualTo: 90),
                Filter('director1', isEqualTo: 'Director2'),
                Filter('producer1', isEqualTo: 'Producer2'),
                Filter('budget1', isEqualTo: 20000000),
                Filter('boxOffice1', isEqualTo: 50000000),
                Filter('actor1', isEqualTo: 'Actor2'),
                Filter('language1', isEqualTo: 'English'),
                Filter('award1', isEqualTo: 'Award2'),
                Filter('genre1', arrayContainsAny: ['sci-fi']),
                Filter('country1', isEqualTo: 'USA'),
                Filter('released1', isEqualTo: true),
                Filter('screenplay1', isEqualTo: 'Screenplay2'),
                Filter('cinematography1', isEqualTo: 'Cinematography2'),
                Filter('music1', isEqualTo: 'Music2'),
                Filter('rating2', isEqualTo: 4.2),
                Filter('year2', isEqualTo: 1982),
                Filter('runtime2', isEqualTo: 60),
                Filter('director2', isEqualTo: 'Director3'),
                Filter('producer2', isEqualTo: 'Producer3'),
                Filter('budget2', isEqualTo: 30000000),
                Filter('boxOffice2', isEqualTo: 60000000),
                Filter('actor2', isEqualTo: 'Actor3'),
                Filter('language2', isEqualTo: 'Korean'),
                Filter('award2', isEqualTo: 'Award3'),
                Filter('genre2', isEqualTo: ['sci-fi', 'action']),
                Filter('country2', isEqualTo: 'South Korea'),
                Filter('released2', isEqualTo: false),
                Filter('screenplay2', isEqualTo: 'Screenplay3'),
              ),
            )
            .orderBy('rating1', descending: true)
            .get();

        expect(results.docs.length, equals(2));
        expect(results.docs[0].id, equals('doc3'));
        expect(results.docs[1].id, equals('doc2'));
      });

      test(
        'Can combine `arrayContainsAny` & `isNotEqualTo` in multiple conjunctive queries',
        () async {
          CollectionReference<Map<String, dynamic>> collection =
              await initializeTest(
            'array-contain-not-equal-conjunctive-queries',
          );

          await Future.wait([
            collection.doc('doc1').set({
              'genre': ['fantasy', 'sci-fi'],
              'screenplay2': 'bar',
            }),
            collection.doc('doc2').set({
              'genre': ['fantasy', 'sci-fi'],
              'screenplay2': 'bar',
            }),
            collection.doc('doc3').set({
              'genre': ['fantasy', 'sci-fi'],
              'screenplay2': 'foo',
            }),
          ]);

          final results = await collection
              .where(
                Filter.and(
                  Filter('genre', arrayContainsAny: ['sci-fi']),
                  Filter('screenplay2', isNotEqualTo: 'foo'),
                ),
              )
              .orderBy('screenplay2', descending: true)
              .get();

          expect(results.docs.length, equals(2));
          expect(results.docs[0].id, equals('doc2'));
          expect(results.docs[1].id, equals('doc1'));
        },
      );

      test('allow multiple disjunctive queries', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('multiple-disjunctive-queries');

        await Future.wait([
          collection.doc('doc1').set({
            'genre': ['fantasy', 'action'],
            'rating': 4.5,
            'director': 'Director1',
            'producer': 'Producer1',
            'country': 'USA',
            'budget': 10000000,
            'boxOffice': 25000000,
            'actor': 'Actor1',
          }),
          collection.doc('doc2').set({
            'genre': ['sci-fi', 'thriller'],
            'rating': 3.8,
            'year': 1970,
            'runtime': 90,
            'released': true,
            'country': 'Wales',
            'director': 'Director2',
            'producer': 'Producer2',
            'budget': 20000000,
            'boxOffice': 50000000,
            'actor': 'Actor2',
            'language': 'English',
            'award': 'Award2',
          }),
          collection.doc('doc3').set({
            'genre': ['sci-fi', 'thriller'],
            'rating': 4.2,
            'year': 1982,
            'runtime': 60,
            'released': false,
            'country': 'Wales',
            'director': 'Director3',
            'producer': 'Producer3',
            'budget': 30000000,
            'boxOffice': 60000000,
            'actor': 'Actor3',
            'language': 'Korean',
            'award': 'Award3',
          }),
          collection.doc('doc4').set({
            'genre': ['sci-fi', 'thriller'],
            'rating': 4.7,
            'year': 1990,
            'runtime': 120,
            'released': true,
            'country': 'Wales',
            'director': 'Director4',
            'producer': 'Producer4',
            'budget': 40000000,
            'boxOffice': 80000000,
            'actor': 'Actor4',
            'language': 'Welsh',
            'award': 'Award4',
          }),
        ]);

        final results = await collection
            .where(
              Filter.or(
                Filter('rating', isEqualTo: 3.8),
                Filter('year', isEqualTo: 1970),
                Filter('runtime', isEqualTo: 90),
                Filter('director', isEqualTo: 'Director2'),
                Filter('country', isEqualTo: 'Wales'),
                Filter('budget', isEqualTo: 20000000),
                Filter('boxOffice', isEqualTo: 50000000),
                Filter('genre', arrayContainsAny: ['sci-fi']),
                Filter('actor', isEqualTo: 'Actor2'),
                Filter('language', isEqualTo: 'English'),
                Filter('award', isEqualTo: 'Award2'),
                Filter('screenWriter', isEqualTo: 'ScreenWriter2'),
                Filter('editor', isEqualTo: 'Editor2'),
                Filter('cinematographer', isEqualTo: 'Cinematographer2'),
                Filter('releaseCountry', isEqualTo: 'Country2'),
                Filter('distributor', isEqualTo: 'Distributor2'),
                Filter('ratingSystem', isEqualTo: 'RatingSystem2'),
                Filter('soundtrackComposer', isEqualTo: 'Composer2'),
                Filter('visualEffectsCompany', isEqualTo: 'EffectsCompany2'),
                Filter('productionCompany', isEqualTo: 'ProductionCompany2'),
                Filter('filmFormat', isEqualTo: 'FilmFormat2'),
                Filter('aspectRatio', isEqualTo: 'AspectRatio2'),
                Filter('colorProcess', isEqualTo: 'ColorProcess2'),
                Filter('soundProcess', isEqualTo: 'SoundProcess2'),
                Filter('numberOfTheaters', isEqualTo: 2000),
                Filter('openingWeekendRevenue', isEqualTo: 10000000),
                Filter('totalDomesticRevenue', isEqualTo: 60000000),
                Filter('totalWorldwideRevenue', isEqualTo: 200000000),
                Filter('estimatedProfit', isEqualTo: 140000000),
                Filter('mainCharacter', isEqualTo: 'MainCharacter2'),
              ),
            )
            .orderBy('rating', descending: true)
            .get();

        expect(results.docs.length, equals(3));
        expect(results.docs[0].id, equals('doc4'));
        expect(results.docs[0].data()['rating'], equals(4.7));
        expect(
          results.docs[0].data()['genre'],
          equals(['sci-fi', 'thriller']),
        );
        expect(results.docs[1].id, equals('doc3'));
        expect(results.docs[1].data()['rating'], equals(4.2));
        expect(results.docs[1].data()['genre'], equals(['sci-fi', 'thriller']));
        expect(results.docs[2].id, equals('doc2'));
        expect(results.docs[2].data()['rating'], equals(3.8));
        expect(results.docs[2].data()['genre'], equals(['sci-fi', 'thriller']));
      });

      test(
        'Can combine  `arrayContainsAny` & `isNotEqualTo` in disjunctive queries',
        () async {
          CollectionReference<Map<String, dynamic>> collection =
              await initializeTest(
            'array-contain-not-equal-disjunctive-queries',
          );

          await Future.wait([
            collection.doc('doc1').set({
              'genre': ['fantasy', 'sci-fi'],
              'screenplay2': 'bar',
            }),
            collection.doc('doc2').set({
              'genre': ['fantasy', 'sci-fi'],
              'mainCharacter': 'MainCharacter2',
            }),
            collection.doc('doc3').set({
              'genre': ['fantasy', 'something else'],
              'mainCharacter': 'foo',
            }),
            collection.doc('doc4').set({
              'genre': ['fantasy', 'something else'],
              'mainCharacter': 'MainCharacter2',
            }),
          ]);

          final results = await collection
              .where(
                Filter.or(
                  Filter('genre', arrayContainsAny: ['sci-fi']),
                  Filter('mainCharacter', isNotEqualTo: 'MainCharacter2'),
                ),
              )
              .orderBy('mainCharacter', descending: true)
              .get();

          expect(results.docs.length, equals(2));
          expect(results.docs[0].id, equals('doc3'));
          expect(results.docs[1].id, equals('doc2'));
        },
      );

      test(
          'allow multiple disjunctive queries for "arrayContainsAny" using ".where() API"',
          () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('multiple-disjunctive-where');

        await Future.wait([
          collection.doc('doc1').set({
            'genre': ['Not', 'Here'],
            'number': 1,
          }),
          collection.doc('doc2').set({
            'genre': ['Animation', 'Another'],
            'number': 2,
          }),
          collection.doc('doc3').set({
            'genre': ['Adventure', 'Another'],
            'number': 3,
          }),
        ]);
        final genres = [
          'Action',
          'Adventure',
          'Animation',
          'Biography',
          'Comedy',
          'Crime',
          'Drama',
          'Documentary',
          'Family',
          'Fantasy',
          'Film-Noir',
          'History',
          'Horror',
          'Music',
          'Musical',
          'Mystery',
          'Romance',
          'Sci-Fi',
          'Sport',
          'Thriller',
          'War',
          'Western',
          'Epic',
          'Tragedy',
          'Satire',
          'Romantic Comedy',
          'Black Comedy',
          'Paranormal',
          'Non-fiction',
          'Realism',
        ];

        final results = await collection
            .where(
              'genre',
              arrayContainsAny: genres,
            )
            .orderBy('number')
            .get();

        expect(results.docs.length, equals(2));
        expect(results.docs[0].id, equals('doc2'));
        expect(results.docs[1].id, equals('doc3'));
      });

      test(
          'allow multiple disjunctive queries for "whereIn" using ".where() API"',
          () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('multiple-disjunctive-where');

        await Future.wait([
          collection.doc('doc1').set({'genre': 'Not this', 'number': 1}),
          collection.doc('doc2').set({'genre': 'Animation', 'number': 2}),
          collection.doc('doc3').set({'genre': 'Adventure', 'number': 3}),
        ]);
        final genres = [
          'Action',
          'Adventure',
          'Animation',
          'Biography',
          'Comedy',
          'Crime',
          'Drama',
          'Documentary',
          'Family',
          'Fantasy',
          'Film-Noir',
          'History',
          'Horror',
          'Music',
          'Musical',
          'Mystery',
          'Romance',
          'Sci-Fi',
          'Sport',
          'Thriller',
          'War',
          'Western',
          'Epic',
          'Tragedy',
          'Satire',
          'Romantic Comedy',
          'Black Comedy',
          'Paranormal',
          'Non-fiction',
          'Realism',
        ];

        final results = await collection
            .where(
              'genre',
              whereIn: genres,
            )
            .orderBy('number')
            .get();

        expect(results.docs.length, equals(2));
        expect(results.docs[0].id, equals('doc2'));
        expect(results.docs[1].id, equals('doc3'));
      });

      test('"whereIn" query combined with "arrayContainsAny"', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-filter-arraycontainsany-in-combined');
        await Future.wait([
          collection.doc('doc1').set({
            'value': [1, 2, 3],
            'prop': 'foo',
          }),
          collection.doc('doc2').set({
            'value': [2, 4, 5],
            'prop': 'bar',
          }),
          collection.doc('doc3').set({
            'value': [6, 7, 8],
            'prop': 'basalt',
          }),
        ]);

        final results = await collection
            .where(
              'value',
              arrayContainsAny: [1, 7],
            )
            .where(
              'prop',
              whereIn: ['foo', 'basalt'],
            )
            .orderBy('prop')
            .get();

        expect(results.docs.length, equals(2));
        expect(results.docs[0].id, equals('doc3'));
        expect(results.docs[1].id, equals('doc1'));
      });

      test('isEqualTo filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-filter-isequalto');
        await Future.wait([
          collection.doc('doc1').set({'value': 5}),
          collection.doc('doc2').set({'value': 5}),
          collection.doc('doc3').set({'value': 7}),
        ]);

        final results = await collection
            .where(
              Filter('value', isEqualTo: 5),
            )
            .get();

        expect(results.docs.length, equals(2));
        expect(results.docs[0].id, equals('doc1'));
        expect(results.docs[1].id, equals('doc2'));
      });

      test('isNotEqualTo filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-filter-isnotequalto');
        await Future.wait([
          collection.doc('doc1').set({'value': 5}),
          collection.doc('doc2').set({'value': 5}),
          collection.doc('doc3').set({'value': 7}),
        ]);

        final results = await collection
            .where(
              Filter('value', isNotEqualTo: 5),
            )
            .get();

        expect(results.docs.length, equals(1));
        expect(results.docs[0].id, equals('doc3'));
      });

      test('isLessThan filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-filter-islessthan');
        await Future.wait([
          collection.doc('doc1').set({'value': 5}),
          collection.doc('doc2').set({'value': 7}),
          collection.doc('doc3').set({'value': 9}),
        ]);

        final results = await collection
            .where(
              Filter('value', isLessThan: 7),
            )
            .get();

        expect(results.docs.length, equals(1));
        expect(results.docs[0].id, equals('doc1'));
      });

      test('isLessThanOrEqualTo filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-filter-islessthanequalto');
        await Future.wait([
          collection.doc('doc1').set({'value': 5}),
          collection.doc('doc2').set({'value': 7}),
          collection.doc('doc3').set({'value': 9}),
        ]);

        final results = await collection
            .where(
              Filter('value', isLessThanOrEqualTo: 7),
            )
            .get();

        expect(results.docs.length, equals(2));
        expect(results.docs[0].id, equals('doc1'));
        expect(results.docs[1].id, equals('doc2'));
      });

      test('isGreaterThan filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-filter-isgreaterthan');
        await Future.wait([
          collection.doc('doc1').set({'value': 5}),
          collection.doc('doc2').set({'value': 7}),
          collection.doc('doc3').set({'value': 9}),
        ]);

        final results = await collection
            .where(
              Filter('value', isGreaterThan: 5),
            )
            .get();

        expect(results.docs.length, equals(2));
        expect(results.docs[0].id, equals('doc2'));
        expect(results.docs[1].id, equals('doc3'));
      });

      test('isGreaterThanOrEqualTo filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-filter-isgreaterthanequalto');
        await Future.wait([
          collection.doc('doc1').set({'value': 5}),
          collection.doc('doc2').set({'value': 7}),
          collection.doc('doc3').set({'value': 9}),
        ]);

        final results = await collection
            .where(
              Filter('value', isGreaterThanOrEqualTo: 7),
            )
            .get();

        expect(results.docs.length, equals(2));
        expect(results.docs[0].id, equals('doc2'));
        expect(results.docs[1].id, equals('doc3'));
      });

      test('arrayContains filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-filter-arraycontains');
        await Future.wait([
          collection.doc('doc1').set({
            'value': [1, 2, 3],
          }),
          collection.doc('doc2').set({
            'value': [1, 4, 5],
          }),
          collection.doc('doc3').set({
            'value': [6, 7, 8],
          }),
        ]);

        final results = await collection
            .where(
              Filter('value', arrayContains: 1),
            )
            .get();

        expect(results.docs.length, equals(2));
        expect(results.docs[0].id, equals('doc1'));
        expect(results.docs[1].id, equals('doc2'));
      });

      test('arrayContainsAny filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-filter-arraycontainsany');
        await Future.wait([
          collection.doc('doc1').set({
            'value': [1, 2, 3],
          }),
          collection.doc('doc2').set({
            'value': [1, 4, 5],
          }),
          collection.doc('doc3').set({
            'value': [6, 7, 8],
          }),
        ]);

        final results = await collection
            .where(
              Filter('value', arrayContainsAny: [1, 7]),
            )
            .get();

        expect(results.docs.length, equals(3));
      });

      test('whereIn filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-filter-wherein');
        await Future.wait([
          collection.doc('doc1').set({'value': 'A'}),
          collection.doc('doc2').set({'value': 'B'}),
          collection.doc('doc3').set({'value': 'C'}),
        ]);

        final results = await collection
            .where(
              Filter('value', whereIn: ['A', 'C']),
            )
            .get();

        expect(results.docs.length, equals(2));
        expect(results.docs[0].id, equals('doc1'));
        expect(results.docs[1].id, equals('doc3'));
      });

      test('whereNotIn filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-filter-wherenotin');
        await Future.wait([
          collection.doc('doc1').set({'value': 'A'}),
          collection.doc('doc2').set({'value': 'B'}),
          collection.doc('doc3').set({'value': 'C'}),
        ]);

        final results = await collection
            .where(
              Filter('value', whereNotIn: ['A', 'C']),
            )
            .get();

        expect(results.docs.length, equals(1));
        expect(results.docs[0].id, equals('doc2'));
      });

      test('isNull filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-filter-isnull');
        await Future.wait([
          collection.doc('doc1').set({'value': 'A'}),
          collection.doc('doc2').set({'value': null}),
          collection.doc('doc3').set({'value': 'C'}),
        ]);

        final results = await collection
            .where(
              Filter('value', isNull: true),
            )
            .get();

        expect(results.docs.length, equals(1));
        expect(results.docs[0].id, equals('doc2'));
      });

      test('endAt filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endat-filter');
        await Future.wait([
          collection.doc('doc1').set({'value': 1, 'title': 'A'}),
          collection.doc('doc2').set({'value': 2, 'title': 'B'}),
          collection.doc('doc3').set({'value': 3, 'title': 'C'}),
          collection.doc('doc4').set({'value': 4, 'title': 'D'}),
          collection.doc('doc5').set({'value': 5, 'title': 'E'}),
        ]);

        QuerySnapshot<Map<String, dynamic>> results;

        results = await collection
            .where(Filter('value', isGreaterThan: 1))
            .orderBy('value', descending: false)
            .endAt([3]).get();
        expect(results.docs.length, equals(2));
        expect(results.docs[0].data()['title'], equals('B'));
        expect(results.docs[1].data()['title'], equals('C'));
      });

      test('endBefore filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endbefore-filter');
        await Future.wait([
          collection.doc('doc1').set({'value': 1, 'title': 'A'}),
          collection.doc('doc2').set({'value': 2, 'title': 'B'}),
          collection.doc('doc3').set({'value': 3, 'title': 'C'}),
          collection.doc('doc4').set({'value': 4, 'title': 'D'}),
          collection.doc('doc5').set({'value': 5, 'title': 'E'}),
        ]);

        QuerySnapshot<Map<String, dynamic>> results;

        // endBefore
        results = await collection
            .where(Filter('value', isGreaterThan: 1))
            .orderBy('value', descending: false)
            .endBefore([4]).get();
        expect(results.docs.length, equals(2));
        expect(results.docs[0].data()['title'], equals('B'));
        expect(results.docs[1].data()['title'], equals('C'));
      });

      test('endBeforeDocument filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endbeforedocument-filter');
        await Future.wait([
          collection.doc('doc1').set({'value': 1, 'title': 'A'}),
          collection.doc('doc2').set({'value': 2, 'title': 'B'}),
          collection.doc('doc3').set({'value': 3, 'title': 'C'}),
          collection.doc('doc4').set({'value': 4, 'title': 'D'}),
          collection.doc('doc5').set({'value': 5, 'title': 'E'}),
        ]);

        QuerySnapshot<Map<String, dynamic>> results;

        final documentSnapshot = await collection.doc('doc4').get();

        // endBeforeDocument
        results = await collection
            .where(Filter('value', isGreaterThan: 1))
            .orderBy('value', descending: false)
            .endBeforeDocument(documentSnapshot)
            .get();
        expect(results.docs.length, equals(2));
        expect(results.docs[0].data()['title'], equals('B'));
        expect(results.docs[1].data()['title'], equals('C'));
      });

      test('limit filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('limit-filter');
        await Future.wait([
          collection.doc('doc1').set({'value': 1, 'title': 'A'}),
          collection.doc('doc2').set({'value': 2, 'title': 'B'}),
          collection.doc('doc3').set({'value': 3, 'title': 'C'}),
          collection.doc('doc4').set({'value': 4, 'title': 'D'}),
          collection.doc('doc5').set({'value': 5, 'title': 'E'}),
        ]);

        QuerySnapshot<Map<String, dynamic>> results;

        // limit
        results = await collection
            .where(Filter('value', isGreaterThan: 1))
            .orderBy('value', descending: false)
            .limit(2)
            .get();
        expect(results.docs.length, equals(2));
        expect(results.docs[0].data()['title'], equals('B'));
        expect(results.docs[1].data()['title'], equals('C'));
      });

      test('limitToLast filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('limittolast-filter');
        await Future.wait([
          collection.doc('doc1').set({'value': 1, 'title': 'A'}),
          collection.doc('doc2').set({'value': 2, 'title': 'B'}),
          collection.doc('doc3').set({'value': 3, 'title': 'C'}),
          collection.doc('doc4').set({'value': 4, 'title': 'D'}),
          collection.doc('doc5').set({'value': 5, 'title': 'E'}),
        ]);

        QuerySnapshot<Map<String, dynamic>> results;

        // limitToLast
        results = await collection
            .where(Filter('value', isGreaterThan: 1))
            .orderBy('value', descending: false)
            .limitToLast(2)
            .get();
        expect(results.docs.length, equals(2));
        expect(results.docs[0].data()['title'], equals('D'));
        expect(results.docs[1].data()['title'], equals('E'));
      });

      test('orderBy filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('orderby-filter');
        await Future.wait([
          collection.doc('doc1').set({'value': 1, 'title': 'A'}),
          collection.doc('doc2').set({'value': 2, 'title': 'B'}),
          collection.doc('doc3').set({'value': 3, 'title': 'C'}),
          collection.doc('doc4').set({'value': 4, 'title': 'D'}),
          collection.doc('doc5').set({'value': 5, 'title': 'E'}),
        ]);

        QuerySnapshot<Map<String, dynamic>> results;

        // orderBy
        results = await collection
            .where(Filter('value', isGreaterThan: 1))
            .orderBy('value', descending: true)
            .get();
        expect(results.docs.length, equals(4));
        expect(results.docs[0].data()['title'], equals('E'));
        expect(results.docs[1].data()['title'], equals('D'));
        expect(results.docs[2].data()['title'], equals('C'));
        expect(results.docs[3].data()['title'], equals('B'));
      });

      test('startAfter filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startafter-filter');
        await Future.wait([
          collection.doc('doc1').set({'value': 1, 'title': 'A'}),
          collection.doc('doc2').set({'value': 2, 'title': 'B'}),
          collection.doc('doc3').set({'value': 3, 'title': 'C'}),
          collection.doc('doc4').set({'value': 4, 'title': 'D'}),
          collection.doc('doc5').set({'value': 5, 'title': 'E'}),
        ]);

        QuerySnapshot<Map<String, dynamic>> results;

        // startAfter
        results = await collection
            .where(Filter('value', isGreaterThan: 3))
            .orderBy('value', descending: false)
            .startAfter([2]).get();
        expect(results.docs.length, equals(2));
        expect(results.docs[0].data()['title'], equals('D'));
        expect(results.docs[1].data()['title'], equals('E'));
      });

      test('startAfterDocument filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startafterdocument-filter');
        await Future.wait([
          collection.doc('doc1').set({'value': 1, 'title': 'A'}),
          collection.doc('doc2').set({'value': 2, 'title': 'B'}),
          collection.doc('doc3').set({'value': 3, 'title': 'C'}),
          collection.doc('doc4').set({'value': 4, 'title': 'D'}),
          collection.doc('doc5').set({'value': 5, 'title': 'E'}),
        ]);

        QuerySnapshot<Map<String, dynamic>> results;

        final documentSnapshot = await collection.doc('doc2').get();

// startAfterDocument
        results = await collection
            .where(Filter('value', isGreaterThan: 1))
            .orderBy('value', descending: false)
            .startAfterDocument(documentSnapshot)
            .get();
        expect(results.docs.length, equals(3));
        expect(results.docs[0].data()['title'], equals('C'));
        expect(results.docs[1].data()['title'], equals('D'));
        expect(results.docs[2].data()['title'], equals('E'));
      });

      test('startAt filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startat-filter');
        await Future.wait([
          collection.doc('doc1').set({'value': 1, 'title': 'A'}),
          collection.doc('doc2').set({'value': 2, 'title': 'B'}),
          collection.doc('doc3').set({'value': 3, 'title': 'C'}),
          collection.doc('doc4').set({'value': 4, 'title': 'D'}),
          collection.doc('doc5').set({'value': 5, 'title': 'E'}),
        ]);

        QuerySnapshot<Map<String, dynamic>> results;

// startAt
        results = await collection
            .where(Filter('value', isGreaterThan: 1))
            .orderBy('value', descending: false)
            .startAt([2]).get();
        expect(results.docs.length, equals(4));
        expect(results.docs[0].data()['title'], equals('B'));
        expect(results.docs[1].data()['title'], equals('C'));
        expect(results.docs[2].data()['title'], equals('D'));
        expect(results.docs[3].data()['title'], equals('E'));
      });

      test('startAtDocument filter', () async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startatdocument-filter');
        await Future.wait([
          collection.doc('doc1').set({'value': 1, 'title': 'A'}),
          collection.doc('doc2').set({'value': 2, 'title': 'B'}),
          collection.doc('doc3').set({'value': 3, 'title': 'C'}),
          collection.doc('doc4').set({'value': 4, 'title': 'D'}),
          collection.doc('doc5').set({'value': 5, 'title': 'E'}),
        ]);

        QuerySnapshot<Map<String, dynamic>> results;

        final documentSnapshot = await collection.doc('doc2').get();

// startAtDocument
        results = await collection
            .where(Filter('value', isGreaterThan: 1))
            .orderBy('value', descending: false)
            .startAtDocument(documentSnapshot)
            .get();
        expect(results.docs.length, equals(4));
        expect(results.docs[0].data()['title'], equals('B'));
        expect(results.docs[1].data()['title'], equals('C'));
        expect(results.docs[2].data()['title'], equals('D'));
        expect(results.docs[3].data()['title'], equals('E'));
      });
    });

    group('withConverter', () {
      test(
        'from a query instead of collection',
        () async {
          final collection = await initializeTest('foo');

          final query = collection //
              .where('value', isGreaterThan: 0)
              .withConverter<int>(
                fromFirestore: (snapshots, _) =>
                    snapshots.data()!['value']! as int,
                toFirestore: (value, _) => {'value': value},
              );

          await collection.add({'value': 42});
          await collection.add({'value': -1});

          final snapshot = query.snapshots();

          await expectLater(
            snapshot,
            emits(
              isA<QuerySnapshot<int>>().having((e) => e.docs, 'docs', [
                isA<DocumentSnapshot<int>>()
                    .having((e) => e.data(), 'data', 42),
              ]),
            ),
          );

          await collection.add({'value': 21});

          await expectLater(
            snapshot,
            emits(
              isA<QuerySnapshot<int>>().having(
                (e) => e.docs,
                'docs',
                unorderedEquals(
                  [
                    isA<DocumentSnapshot<int>>()
                        .having((e) => e.data(), 'data', 42),
                    isA<DocumentSnapshot<int>>()
                        .having((e) => e.data(), 'data', 21),
                  ],
                ),
              ),
            ),
          );
        },
        timeout: const Timeout.factor(3),
      );

      test(
        'from a Filter query instead of collection',
        () async {
          final collection = await initializeTest('foo');

          final query = collection
              .where(Filter('value', isGreaterThan: 0))
              .withConverter<int>(
                fromFirestore: (snapshots, _) =>
                    snapshots.data()!['value']! as int,
                toFirestore: (value, _) => {'value': value},
              );

          await collection.add({'value': 42});
          await collection.add({'value': -1});

          final snapshot = query.snapshots();

          await expectLater(
            snapshot,
            emits(
              isA<QuerySnapshot<int>>().having((e) => e.docs, 'docs', [
                isA<DocumentSnapshot<int>>()
                    .having((e) => e.data(), 'data', 42),
              ]),
            ),
          );

          await collection.add({'value': 21});

          await expectLater(
            snapshot,
            emits(
              isA<QuerySnapshot<int>>().having(
                (e) => e.docs,
                'docs',
                unorderedEquals(
                  [
                    isA<DocumentSnapshot<int>>()
                        .having((e) => e.data(), 'data', 42),
                    isA<DocumentSnapshot<int>>()
                        .having((e) => e.data(), 'data', 21),
                  ],
                ),
              ),
            ),
          );
        },
        timeout: const Timeout.factor(3),
      );

      test(
        'snapshots',
        () async {
          final collection = await initializeTest('foo');

          final converted = collection.withConverter<int>(
            fromFirestore: (snapshots, _) => snapshots.data()!['value']! as int,
            toFirestore: (value, _) => {'value': value},
          );

          await converted.add(42);
          await converted.add(-1);

          final snapshot =
              converted.where('value', isGreaterThan: 0).snapshots();

          await expectLater(
            snapshot,
            emits(
              isA<QuerySnapshot<int>>().having((e) => e.docs, 'docs', [
                isA<DocumentSnapshot<int>>()
                    .having((e) => e.data(), 'data', 42),
              ]),
            ),
          );

          await converted.add(21);

          await expectLater(
            snapshot,
            emits(
              isA<QuerySnapshot<int>>().having(
                (e) => e.docs,
                'docs',
                unorderedEquals([
                  isA<DocumentSnapshot<int>>()
                      .having((e) => e.data(), 'data', 42),
                  isA<DocumentSnapshot<int>>()
                      .having((e) => e.data(), 'data', 21),
                ]),
              ),
            ),
          );
        },
        timeout: const Timeout.factor(3),
      );

      test(
        'get',
        () async {
          final collection = await initializeTest('foo');

          final converted = collection.withConverter<int>(
            fromFirestore: (snapshots, _) => snapshots.data()!['value']! as int,
            toFirestore: (value, _) => {'value': value},
          );

          await converted.add(42);
          await converted.add(-1);

          expect(
            await converted
                .where('value', isGreaterThan: 0)
                .get()
                .then((d) => d.docs),
            [isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 42)],
          );
        },
        timeout: const Timeout.factor(3),
      );

      test(
        'orderBy',
        () async {
          final collection = await initializeTest('foo');

          final converted = collection.withConverter<int>(
            fromFirestore: (snapshots, _) => snapshots.data()!['value']! as int,
            toFirestore: (value, _) => {'value': value},
          );

          await converted.add(42);
          await converted.add(21);

          expect(
            await converted.orderBy('value').get().then((d) => d.docs),
            [
              isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 21),
              isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 42),
            ],
          );
        },
        timeout: const Timeout.factor(3),
      );

      test(
        'limit',
        () async {
          final collection = await initializeTest('foo');

          final converted = collection.withConverter<int>(
            fromFirestore: (snapshots, _) => snapshots.data()!['value']! as int,
            toFirestore: (value, _) => {'value': value},
          );

          await converted.add(42);
          await converted.add(21);

          expect(
            await converted.orderBy('value').limit(1).get().then((d) => d.docs),
            [
              isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 21),
            ],
          );
        },
        timeout: const Timeout.factor(3),
      );

      test(
        'limitToLast',
        () async {
          final collection = await initializeTest('foo');

          final converted = collection.withConverter<int>(
            fromFirestore: (snapshots, _) => snapshots.data()!['value']! as int,
            toFirestore: (value, _) => {'value': value},
          );

          await converted.add(42);
          await converted.add(21);

          expect(
            await converted
                .orderBy('value')
                .limitToLast(1)
                .get()
                .then((d) => d.docs),
            [
              isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 42),
            ],
          );
        },
        timeout: const Timeout.factor(3),
      );

      test('endAt', () async {
        final collection = await initializeTest('foo');

        final converted = collection.withConverter<int>(
          fromFirestore: (snapshots, _) => snapshots.data()!['value']! as int,
          toFirestore: (value, _) => {'value': value},
        );

        await converted.add(1);
        await converted.add(2);
        await converted.add(3);

        expect(
          await converted.orderBy('value').endAt([2]).get().then((d) => d.docs),
          [
            isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 1),
            isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 2),
          ],
        );
      });

      test('endAt with Iterable', () async {
        final collection = await initializeTest('foo');

        final converted = collection.withConverter<int>(
          fromFirestore: (snapshots, _) => snapshots.data()!['value']! as int,
          toFirestore: (value, _) => {'value': value},
        );

        await converted.add(1);
        await converted.add(2);
        await converted.add(3);

        expect(
          await converted.orderBy('value').endAt({2}).get().then((d) => d.docs),
          [
            isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 1),
            isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 2),
          ],
        );
      });

      test(
        'endAtDocument',
        () async {
          final collection = await initializeTest('foo');

          final converted = collection.withConverter<int>(
            fromFirestore: (snapshots, _) => snapshots.data()!['value']! as int,
            toFirestore: (value, _) => {'value': value},
          );

          await converted.add(1);
          final doc2 = await converted.add(2);
          await converted.add(3);

          expect(
            await converted
                .orderBy('value')
                .endAtDocument(await doc2.get())
                .get()
                .then((d) => d.docs),
            [
              isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 1),
              isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 2),
            ],
          );
        },
        timeout: const Timeout.factor(3),
      );

      test('endBefore', () async {
        final collection = await initializeTest('foo');

        final converted = collection.withConverter<int>(
          fromFirestore: (snapshots, _) => snapshots.data()!['value']! as int,
          toFirestore: (value, _) => {'value': value},
        );

        await converted.add(1);
        await converted.add(2);
        await converted.add(3);

        expect(
          await converted
              .orderBy('value')
              .endBefore([2])
              .get()
              .then((d) => d.docs),
          [isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 1)],
        );
      });

      test('endBefore with Iterable', () async {
        final collection = await initializeTest('foo');

        final converted = collection.withConverter<int>(
          fromFirestore: (snapshots, _) => snapshots.data()!['value']! as int,
          toFirestore: (value, _) => {'value': value},
        );

        await converted.add(1);
        await converted.add(2);
        await converted.add(3);

        expect(
          await converted
              .orderBy('value')
              .endBefore({2})
              .get()
              .then((d) => d.docs),
          [isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 1)],
        );
      });

      test(
        'endBeforeDocument',
        () async {
          final collection = await initializeTest('foo');

          final converted = collection.withConverter<int>(
            fromFirestore: (snapshots, _) => snapshots.data()!['value']! as int,
            toFirestore: (value, _) => {'value': value},
          );

          await converted.add(1);
          final doc2 = await converted.add(2);
          await converted.add(3);

          expect(
            await converted
                .orderBy('value')
                .endBeforeDocument(await doc2.get())
                .get()
                .then((d) => d.docs),
            [isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 1)],
          );
        },
        timeout: const Timeout.factor(3),
      );

      test(
        'startAt',
        () async {
          final collection = await initializeTest('foo');

          final converted = collection.withConverter<int>(
            fromFirestore: (snapshots, _) => snapshots.data()!['value']! as int,
            toFirestore: (value, _) => {'value': value},
          );

          await converted.add(1);
          await converted.add(2);
          await converted.add(3);

          expect(
            await converted
                .orderBy('value')
                .startAt([2])
                .get()
                .then((d) => d.docs),
            [
              isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 2),
              isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 3),
            ],
          );
        },
        timeout: const Timeout.factor(3),
      );

      test(
        'startAt with Iterable',
        () async {
          final collection = await initializeTest('foo');

          final converted = collection.withConverter<int>(
            fromFirestore: (snapshots, _) => snapshots.data()!['value']! as int,
            toFirestore: (value, _) => {'value': value},
          );

          await converted.add(1);
          await converted.add(2);
          await converted.add(3);

          expect(
            await converted
                .orderBy('value')
                .startAt({2})
                .get()
                .then((d) => d.docs),
            [
              isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 2),
              isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 3),
            ],
          );
        },
        timeout: const Timeout.factor(3),
      );

      test(
        'startAtDocument',
        () async {
          final collection = await initializeTest('foo');

          final converted = collection.withConverter<int>(
            fromFirestore: (snapshots, _) => snapshots.data()!['value']! as int,
            toFirestore: (value, _) => {'value': value},
          );

          await converted.add(1);
          final doc2 = await converted.add(2);
          await converted.add(3);

          expect(
            await converted
                .orderBy('value')
                .startAtDocument(await doc2.get())
                .get()
                .then((d) => d.docs),
            [
              isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 2),
              isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 3),
            ],
          );
        },
        timeout: const Timeout.factor(3),
      );

      test(
        'startAfter',
        () async {
          final collection = await initializeTest('foo');

          final converted = collection.withConverter<int>(
            fromFirestore: (snapshots, _) => snapshots.data()!['value']! as int,
            toFirestore: (value, _) => {'value': value},
          );

          await converted.add(1);
          await converted.add(2);
          await converted.add(3);

          expect(
            await converted
                .orderBy('value')
                .startAfter([2])
                .get()
                .then((d) => d.docs),
            [isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 3)],
          );
        },
        timeout: const Timeout.factor(3),
      );

      test(
        'startAfter with Iterable',
        () async {
          final collection = await initializeTest('foo');

          final converted = collection.withConverter<int>(
            fromFirestore: (snapshots, _) => snapshots.data()!['value']! as int,
            toFirestore: (value, _) => {'value': value},
          );

          await converted.add(1);
          await converted.add(2);
          await converted.add(3);

          expect(
            await converted
                .orderBy('value')
                .startAfter({2})
                .get()
                .then((d) => d.docs),
            [isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 3)],
          );
        },
        timeout: const Timeout.factor(3),
      );

      test(
        'startAfterDocument',
        () async {
          final collection = await initializeTest('foo');

          final converted = collection.withConverter<int>(
            fromFirestore: (snapshots, _) => snapshots.data()!['value']! as int,
            toFirestore: (value, _) => {'value': value},
          );

          await converted.add(1);
          final doc2 = await converted.add(2);
          await converted.add(3);

          expect(
            await converted
                .orderBy('value')
                .startAfterDocument(await doc2.get())
                .get()
                .then((d) => d.docs),
            [isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 3)],
          );
        },
        timeout: const Timeout.factor(3),
      );
    });

    group('Aggregate Queries', () {
      test(
        'count()',
        () async {
          final collection = await initializeTest('count');

          await Future.wait([
            collection.add({'foo': 'bar'}),
            collection.add({'bar': 'baz'}),
          ]);

          AggregateQuery query = collection.count();

          AggregateQuerySnapshot snapshot = await query.get();

          expect(
            snapshot.count,
            2,
          );
        },
      );

      test(
        'count() with query',
        () async {
          final collection = await initializeTest('count');

          await Future.wait([
            collection.add({'foo': 'bar'}),
            collection.add({'foo': 'baz'}),
          ]);

          AggregateQuery query =
              collection.where('foo', isEqualTo: 'bar').count();

          AggregateQuerySnapshot snapshot = await query.get();

          expect(
            snapshot.count,
            1,
          );
        },
      );

      test(
        'sum()',
        () async {
          final collection = await initializeTest('sum');

          await Future.wait([
            collection.add({'foo': 1}),
            collection.add({'foo': 2}),
          ]);

          AggregateQuery query = collection.aggregate(sum('foo'));

          AggregateQuerySnapshot snapshot = await query.get();

          expect(
            snapshot.getSum('foo'),
            3,
          );
        },
      );

      test(
        'sum() with query',
        () async {
          final collection = await initializeTest('sum');

          await Future.wait([
            collection.add({'foo': 1}),
            collection.add({'foo': 2}),
          ]);

          AggregateQuery query =
              collection.where('foo', isEqualTo: 1).aggregate(sum('foo'));

          AggregateQuerySnapshot snapshot = await query.get();

          expect(
            snapshot.getSum('foo'),
            1,
          );
        },
      );

      test(
        'average()',
        () async {
          final collection = await initializeTest('avg');

          await Future.wait([
            collection.add({'foo': 1}),
            collection.add({'foo': 2}),
          ]);

          AggregateQuery query = collection.aggregate(average('foo'));

          AggregateQuerySnapshot snapshot = await query.get();

          expect(
            snapshot.getAverage('foo'),
            1.5,
          );
        },
      );

      test(
        'average() with query',
        () async {
          final collection = await initializeTest('avg');

          await Future.wait([
            collection.add({'foo': 1}),
            collection.add({'foo': 2}),
          ]);

          AggregateQuery query =
              collection.where('foo', isEqualTo: 1).aggregate(average('foo'));

          AggregateQuerySnapshot snapshot = await query.get();

          expect(
            snapshot.getAverage('foo'),
            1,
          );
        },
      );

      test(
        'chaining aggregate queries',
        () async {
          final collection = await initializeTest('chaining');

          await Future.wait([
            collection.add({'foo': 1}),
            collection.add({'foo': 2}),
          ]);

          AggregateQuery query =
              collection.aggregate(count(), sum('foo'), average('foo'));
          AggregateQuerySnapshot snapshot = await query.get();

          expect(
            snapshot.count,
            2,
          );

          expect(
            snapshot.getSum('foo'),
            3,
          );

          expect(
            snapshot.getAverage('foo'),
            1.5,
          );
        },
      );

      test('chaining multiples aggregate queries', () async {
        final collection = await initializeTest('chaining');

        await Future.wait([
          collection.add({'foo': 1}),
          collection.add({'foo': 2}),
        ]);

        AggregateQuery query = collection
            .where('foo', isEqualTo: 1)
            .aggregate(count(), sum('foo'), average('foo'));

        AggregateQuerySnapshot snapshot = await query.get();

        expect(
          snapshot.count,
          1,
        );

        expect(
          snapshot.getSum('foo'),
          1,
        );

        expect(
          snapshot.getAverage('foo'),
          1,
        );
      });

      test(
        'count() with collectionGroup',
        () async {
          const subCollection = 'aggregate-group-count';
          final doc1 = FirebaseFirestore.instance
              .collection('flutter-tests')
              .doc('agg1');
          final doc2 = FirebaseFirestore.instance
              .collection('flutter-tests')
              .doc('agg2');
          await Future.wait([
            doc1.set({'foo': 'bar'}),
            doc2.set({'foo': 'baz'}),
          ]);

          final collection = doc1.collection(subCollection);
          final collection2 = doc2.collection(subCollection);

          await Future.wait([
            // 6 sub-documents
            collection.doc('agg1').set({'foo': 'bar'}),
            collection.doc('agg2').set({'foo': 'bar'}),
            collection.doc('agg3').set({'foo': 'bar'}),
            collection2.doc('agg4').set({'foo': 'bar'}),
            collection2.doc('agg5').set({'foo': 'bar'}),
            collection2.doc('agg6').set({'foo': 'bar'}),
          ]);

          AggregateQuery query =
              FirebaseFirestore.instance.collectionGroup(subCollection).count();

          AggregateQuerySnapshot snapshot = await query.get();

          expect(
            snapshot.count,
            6,
          );
        },
      );

      test('count(), average() & sum() on empty collection', () async {
        final collection = await initializeTest('empty-collection');

        final snapshot = await collection
            .aggregate(count(), sum('foo'), average('foo'))
            .get();
        expect(snapshot.count, 0);
        expect(snapshot.getSum('foo'), 0);
        expect(snapshot.getAverage('foo'), null);
      });
    });

    group('startAfterDocument', () {
      test('startAfterDocument() accept DocumentReference in query parameters',
          () async {
        final collection = await initializeTest('start-after-document');

        final doc1 = collection.doc('1');
        final doc2 = collection.doc('2');
        final doc3 = collection.doc('3');
        final doc4 = collection.doc('4');
        await doc1.set({'ref': doc1});
        await doc2.set({'ref': doc2});
        await doc3.set({'ref': doc3});
        await doc4.set({'ref': null});

        final q = collection
            .where('ref', isNull: false)
            .orderBy('ref')
            .startAfterDocument(await doc1.get());

        final res = await q.get();
        expect(res.docs.map((e) => e.reference), [doc2, doc3]);
      });
    });

    group('WhereIn Filter', () {
      test('Multiple whereIn filters should not trigger an assertion',
          () async {
        try {
          final collection = await initializeTest('multipe-whereIn-clause');

          Map<String, String> data = {};

          for (int i = 1; i <= 10; i++) {
            data['field$i'] = 'value$i';
          }

          await collection.doc().set(data);

          Query<Map<String, dynamic>> query = collection;
          data.forEach((field, values) {
            query = query.where(field, whereIn: [values]);
          });

          await query.get();
        } on AssertionError catch (e) {
          fail('Test failed due to AssertionError: $e');
        }
      });

      test(
          'Multiple whereIn filters exceeding DNF 30 clause limit should trigger an assertion',
          () async {
        try {
          final collection = await initializeTest('multipe-whereIn-clause');

          await collection.doc().set({'genre': 'fiction'});
          await collection.doc().set({'author': 'Author A'});

          // DNF for this query = 36 (6 genres * 6 authors) exceeding the 30 clause limit
          await collection.where(
            'genre',
            whereIn: [
              'fiction',
              'non-fiction',
              'fantasy',
              'science-fiction',
              'mystery',
              'thriller',
            ],
          ).where(
            'author',
            whereIn: [
              'Author A',
              'Author B',
              'Author C',
              'Author D',
              'Author E',
              'Author F',
            ],
          ).get();
        } catch (error) {
          expect(error, isA<FirebaseException>());
        }
      });
    });
  });
}
