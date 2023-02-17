// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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
      testWidgets('handles deeply compares query parameters', (_) async {
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

      testWidgets('differentiate queries from a different app instance',
          (_) async {
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

      testWidgets('differentiate collection group', (_) async {
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
      testWidgets('returns a data via a sub-collection', (_) async {
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
    });

    /**
     * get
     */
    group('Query.get()', () {
      testWidgets('returns a [QuerySnapshot]', (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('get');
        QuerySnapshot<Map<String, dynamic>> qs = await collection.get();
        expect(qs, isA<QuerySnapshot<Map<String, dynamic>>>());
      });

      testWidgets('uses [GetOptions] cache', (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('get');
        QuerySnapshot<Map<String, dynamic>> qs =
            await collection.get(const GetOptions(source: Source.cache));
        expect(qs, isA<QuerySnapshot<Map<String, dynamic>>>());
        expect(qs.metadata.isFromCache, isTrue);
      });

      testWidgets('uses [GetOptions] server', (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('get');
        QuerySnapshot<Map<String, dynamic>> qs =
            await collection.get(const GetOptions(source: Source.server));
        expect(qs, isA<QuerySnapshot<Map<String, dynamic>>>());
        expect(qs.metadata.isFromCache, isFalse);
      });

      testWidgets('uses [GetOptions] serverTimestampBehavior previous',
          (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('get');
        QuerySnapshot<Map<String, dynamic>> qs = await collection.get(
          const GetOptions(
            serverTimestampBehavior: ServerTimestampBehavior.previous,
          ),
        );
        expect(qs, isA<QuerySnapshot<Map<String, dynamic>>>());
      });

      testWidgets('uses [GetOptions] serverTimestampBehavior estimate',
          (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('get');
        QuerySnapshot<Map<String, dynamic>> qs = await collection.get(
          const GetOptions(
            serverTimestampBehavior: ServerTimestampBehavior.estimate,
          ),
        );
        expect(qs, isA<QuerySnapshot<Map<String, dynamic>>>());
      });

      testWidgets('throws a [FirebaseException]', (_) async {
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
      });
    });

    /**
     * snapshots
     */
    group('Query.snapshots()', () {
      testWidgets('returns a [Stream]', (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('get');
        Stream<QuerySnapshot<Map<String, dynamic>>> stream =
            collection.snapshots();
        expect(stream, isA<Stream<QuerySnapshot<Map<String, dynamic>>>>());
      });

      testWidgets('listens to a single response', (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('get-single');
        await collection.add({'foo': 'bar'});
        Stream<QuerySnapshot<Map<String, dynamic>>> stream =
            collection.snapshots();
        int call = 0;

        stream.listen(
          expectAsync1(
            (QuerySnapshot<Map<String, dynamic>> snapshot) {
              call++;
              if (call == 1) {
                expect(snapshot.docs.length, equals(1));

                expect(snapshot.docs[0], isA<QueryDocumentSnapshot>());
                QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot =
                    snapshot.docs[0];
                expect(documentSnapshot.data()['foo'], equals('bar'));
              } else {
                fail('Should not have been called');
              }
            },
            count: 1,
            reason: 'Stream should only have been called once.',
          ),
        );
      });

      testWidgets('listens to multiple queries', (_) async {
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

      testWidgets('listens to a multiple changes response', (_) async {
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

      testWidgets('listeners throws a [FirebaseException]', (_) async {
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
      });
    });

    /**
     * End At
     */

    group('Query.endAt{Document}()', () {
      testWidgets('ends at string field paths', (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endAt-string');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
            'bar': {'value': 1}
          }),
          collection.doc('doc2').set({
            'foo': 2,
            'bar': {'value': 2}
          }),
          collection.doc('doc3').set({
            'foo': 3,
            'bar': {'value': 3}
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

      testWidgets('ends at string field paths with Iterable', (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endAt-string');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
            'bar': {'value': 1}
          }),
          collection.doc('doc2').set({
            'foo': 2,
            'bar': {'value': 2}
          }),
          collection.doc('doc3').set({
            'foo': 3,
            'bar': {'value': 3}
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

      testWidgets('ends at field paths', (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endAt-field-path');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
            'bar': {'value': 1}
          }),
          collection.doc('doc2').set({
            'foo': 2,
            'bar': {'value': 2}
          }),
          collection.doc('doc3').set({
            'foo': 3,
            'bar': {'value': 3}
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

      testWidgets('endAtDocument() ends at a document field value', (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endAt-document');
        await Future.wait([
          collection.doc('doc1').set({
            'bar': {'value': 3}
          }),
          collection.doc('doc2').set({
            'bar': {'value': 2}
          }),
          collection.doc('doc3').set({
            'bar': {'value': 1}
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

      testWidgets('endAtDocument() ends at a document', (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endAt-document');
        await Future.wait([
          collection.doc('doc1').set({
            'bar': {'value': 1}
          }),
          collection.doc('doc2').set({
            'bar': {'value': 2}
          }),
          collection.doc('doc3').set({
            'bar': {'value': 3}
          }),
          collection.doc('doc4').set({
            'bar': {'value': 4}
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
      testWidgets('starts at string field paths', (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startAt-string');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
            'bar': {'value': 1}
          }),
          collection.doc('doc2').set({
            'foo': 2,
            'bar': {'value': 2}
          }),
          collection.doc('doc3').set({
            'foo': 3,
            'bar': {'value': 3}
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

      testWidgets('starts at string field paths with Iterable', (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startAt-string');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
            'bar': {'value': 1}
          }),
          collection.doc('doc2').set({
            'foo': 2,
            'bar': {'value': 2}
          }),
          collection.doc('doc3').set({
            'foo': 3,
            'bar': {'value': 3}
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

      testWidgets('starts at field paths', (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startAt-field-path');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
            'bar': {'value': 1}
          }),
          collection.doc('doc2').set({
            'foo': 2,
            'bar': {'value': 2}
          }),
          collection.doc('doc3').set({
            'foo': 3,
            'bar': {'value': 3}
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

      testWidgets('startAtDocument() starts at a document field value',
          (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startAt-document-field-value');
        await Future.wait([
          collection.doc('doc1').set({
            'bar': {'value': 3}
          }),
          collection.doc('doc2').set({
            'bar': {'value': 2}
          }),
          collection.doc('doc3').set({
            'bar': {'value': 1}
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

      testWidgets('startAtDocument() starts at a document', (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startAt-document');
        await Future.wait([
          collection.doc('doc1').set({
            'bar': {'value': 1}
          }),
          collection.doc('doc2').set({
            'bar': {'value': 2}
          }),
          collection.doc('doc3').set({
            'bar': {'value': 3}
          }),
          collection.doc('doc4').set({
            'bar': {'value': 4}
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
      testWidgets('ends before string field paths', (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endBefore-string');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
            'bar': {'value': 1}
          }),
          collection.doc('doc2').set({
            'foo': 2,
            'bar': {'value': 2}
          }),
          collection.doc('doc3').set({
            'foo': 3,
            'bar': {'value': 3}
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

      testWidgets('ends before string field paths with Iterable', (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endBefore-string');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
            'bar': {'value': 1}
          }),
          collection.doc('doc2').set({
            'foo': 2,
            'bar': {'value': 2}
          }),
          collection.doc('doc3').set({
            'foo': 3,
            'bar': {'value': 3}
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

      testWidgets('ends before field paths', (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endBefore-field-path');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
            'bar': {'value': 1}
          }),
          collection.doc('doc2').set({
            'foo': 2,
            'bar': {'value': 2}
          }),
          collection.doc('doc3').set({
            'foo': 3,
            'bar': {'value': 3}
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

      testWidgets('endbeforeDocument() ends before a document field value',
          (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endBefore-document-field-value');
        await Future.wait([
          collection.doc('doc1').set({
            'bar': {'value': 3}
          }),
          collection.doc('doc2').set({
            'bar': {'value': 2}
          }),
          collection.doc('doc3').set({
            'bar': {'value': 1}
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

      testWidgets('endBeforeDocument() ends before a document', (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('endBefore-document');
        await Future.wait([
          collection.doc('doc1').set({
            'bar': {'value': 1}
          }),
          collection.doc('doc2').set({
            'bar': {'value': 2}
          }),
          collection.doc('doc3').set({
            'bar': {'value': 3}
          }),
          collection.doc('doc4').set({
            'bar': {'value': 4}
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
      testWidgets('starts after string field paths', (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startAfter-string');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
            'bar': {'value': 1}
          }),
          collection.doc('doc2').set({
            'foo': 2,
            'bar': {'value': 2}
          }),
          collection.doc('doc3').set({
            'foo': 3,
            'bar': {'value': 3}
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

      testWidgets('starts after field paths', (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startAfter-field-path');
        await Future.wait([
          collection.doc('doc1').set({
            'foo': 1,
            'bar': {'value': 1}
          }),
          collection.doc('doc2').set({
            'foo': 2,
            'bar': {'value': 2}
          }),
          collection.doc('doc3').set({
            'foo': 3,
            'bar': {'value': 3}
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

      testWidgets('startAfterDocument() starts after a document field value',
          (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startAfter-document-field-value');
        await Future.wait([
          collection.doc('doc1').set({
            'bar': {'value': 3}
          }),
          collection.doc('doc2').set({
            'bar': {'value': 2}
          }),
          collection.doc('doc3').set({
            'bar': {'value': 1}
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

      testWidgets('startAfterDocument() starts after a document', (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('startAfter-document');
        await Future.wait([
          collection.doc('doc1').set({
            'bar': {'value': 1}
          }),
          collection.doc('doc2').set({
            'bar': {'value': 2}
          }),
          collection.doc('doc3').set({
            'bar': {'value': 3}
          }),
          collection.doc('doc4').set({
            'bar': {'value': 4}
          }),
        ]);

        DocumentSnapshot startAtSnapshot = await collection.doc('doc2').get();

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.startAfterDocument(startAtSnapshot).get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].id, equals('doc3'));
        expect(snapshot.docs[1].id, equals('doc4'));
      });
    });

    /**
     * Start & End
     */

    group('Query.startAt/endAt', () {
      testWidgets('starts at & ends at a document', (_) async {
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

      testWidgets('starts at & ends before a document', (_) async {
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

      testWidgets('starts after & ends at a document', (_) async {
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

      testWidgets('starts a document and ends before document', (_) async {
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
      testWidgets('limits documents', (_) async {
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

      testWidgets('limits to last documents', (_) async {
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
      testWidgets('allows ordering by documentId', (_) async {
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

      testWidgets('orders async by default', (_) async {
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

      testWidgets('orders descending', (_) async {
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
      testWidgets(
          'returns documents when querying for properties that are not null',
          (_) async {
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

      testWidgets(
          'returns documents when querying properties that are equal to null',
          (_) async {
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

      testWidgets('returns with equal checks', (_) async {
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

      testWidgets('returns with not equal checks', (_) async {
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

      testWidgets('returns with greater than checks', (_) async {
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

      testWidgets('returns with greater than or equal to checks', (_) async {
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

      testWidgets('returns with less than checks', (_) async {
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

      testWidgets('returns with less than equal checks', (_) async {
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

      testWidgets('returns with array-contains filter', (_) async {
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

      testWidgets('returns with in filter', (_) async {
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

      testWidgets('returns with in filter using Iterable', (_) async {
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

      testWidgets('returns with in filter using Set', (_) async {
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

      testWidgets('returns with not-in filter', (_) async {
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

      testWidgets('returns with not-in filter with Iterable', (_) async {
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

      testWidgets('returns with array-contains-any filter', (_) async {
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

      testWidgets('returns with array-contains-any filter using Set',
          (_) async {
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
      testWidgets('returns where FieldPath', (_) async {
        CollectionReference<Map<String, dynamic>> collection =
            await initializeTest('where-field-path');

        FieldPath fieldPath = FieldPath(const ['nested', 'foo.bar@gmail.com']);

        await Future.wait([
          collection.doc('doc1').set({
            'nested': {
              'foo.bar@gmail.com': true,
            }
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
            }
          }),
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await collection.where(fieldPath, isEqualTo: true).get();

        expect(snapshot.docs.length, equals(2));
        expect(snapshot.docs[0].get(fieldPath), isTrue);
        expect(snapshot.docs[1].get(fieldPath), isTrue);
        expect(snapshot.docs[1].get('foo'), equals('bar'));
      });

      testWidgets('returns results using FieldPath.documentId', (_) async {
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

      testWidgets('returns an encoded DocumentReference', (_) async {
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
          })
        ]);

        QuerySnapshot<Map<String, dynamic>> snapshot = await collection
            .where('foo', isEqualTo: FirebaseFirestore.instance.doc('foo/bar'))
            .get();

        expect(snapshot.docs.length, equals(1));
        expect(snapshot.docs[0].get('foo'), equals(ref));
      });
    });

    group('withConverter', () {
      testWidgets(
        'from a query instead of collection',
        (_) async {
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
                isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 42)
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
                        .having((e) => e.data(), 'data', 21)
                  ],
                ),
              ),
            ),
          );
        },
        timeout: const Timeout.factor(3),
      );

      testWidgets(
        'snapshots',
        (_) async {
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
                isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 42)
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
                      .having((e) => e.data(), 'data', 21)
                ]),
              ),
            ),
          );
        },
        timeout: const Timeout.factor(3),
      );

      testWidgets(
        'get',
        (_) async {
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

      testWidgets(
        'orderBy',
        (_) async {
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
              isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 42)
            ],
          );
        },
        timeout: const Timeout.factor(3),
      );

      testWidgets(
        'limit',
        (_) async {
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

      testWidgets(
        'limitToLast',
        (_) async {
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

      testWidgets('endAt', (_) async {
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

      testWidgets('endAt with Iterable', (_) async {
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

      testWidgets(
        'endAtDocument',
        (_) async {
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

      testWidgets('endBefore', (_) async {
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

      testWidgets('endBefore with Iterable', (_) async {
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

      testWidgets(
        'endBeforeDocument',
        (_) async {
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

      testWidgets(
        'startAt',
        (_) async {
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

      testWidgets(
        'startAt with Iterable',
        (_) async {
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

      testWidgets(
        'startAtDocument',
        (_) async {
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

      testWidgets(
        'startAfter',
        (_) async {
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

      testWidgets(
        'startAfter with Iterable',
        (_) async {
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

      testWidgets(
        'startAfterDocument',
        (_) async {
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

      testWidgets(
        'count()',
        (_) async {
          final collection = await initializeTest('count');

          await Future.wait([
            collection.add({'foo': 'bar'}),
            collection.add({'bar': 'baz'})
          ]);

          AggregateQuery query = collection.count();

          AggregateQuerySnapshot snapshot = await query.get();

          expect(
            snapshot.count,
            2,
          );
        },
      );

      testWidgets(
        'count() with query',
        (_) async {
          final collection = await initializeTest('count');

          await Future.wait([
            collection.add({'foo': 'bar'}),
            collection.add({'foo': 'baz'})
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
    });

    group('startAfterDocument', () {
      testWidgets(
          'startAfterDocument() accept DocumentReference in query parameters',
          (_) async {
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
  });
}
