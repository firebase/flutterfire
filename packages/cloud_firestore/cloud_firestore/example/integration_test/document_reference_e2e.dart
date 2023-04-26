// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void runDocumentReferenceTests() {
  group('$DocumentReference', () {
    late FirebaseFirestore firestore;

    setUpAll(() async {
      firestore = FirebaseFirestore.instance;
    });

    Future<DocumentReference<Map<String, dynamic>>> initializeTest(
      String path,
    ) async {
      String prefixedPath = 'flutter-tests/$path';
      await firestore.doc(prefixedPath).delete();
      return firestore.doc(prefixedPath);
    }

    group('DocumentReference.snapshots()', () {
      testWidgets('returns a [Stream]', (_) async {
        DocumentReference<Map<String, dynamic>> document =
            await initializeTest('document-snapshot');
        Stream<DocumentSnapshot<Map<String, dynamic>>> stream =
            document.snapshots();
        expect(stream, isA<Stream<DocumentSnapshot<Map<String, dynamic>>>>());
      });

      testWidgets('can be reused', (_) async {
        final foo = await initializeTest('foo');

        final snapshot = foo.snapshots();
        final snapshot2 = foo.snapshots();

        expect(
          await snapshot.first,
          isA<DocumentSnapshot<Map<String, dynamic>>>()
              .having((e) => e.exists, 'exists', false),
        );
        expect(
          await snapshot2.first,
          isA<DocumentSnapshot<Map<String, dynamic>>>()
              .having((e) => e.exists, 'exists', false),
        );

        await foo.set({'value': 42});

        expect(
          await snapshot.first,
          isA<DocumentSnapshot<Map<String, dynamic>>>()
              .having((e) => e.data(), 'data', {'value': 42}),
        );
        expect(
          await snapshot2.first,
          isA<DocumentSnapshot<Map<String, dynamic>>>()
              .having((e) => e.data(), 'data', {'value': 42}),
        );
      });

      testWidgets('listens to a single response', (_) async {
        DocumentReference<Map<String, dynamic>> document =
            await initializeTest('document-snapshot');
        Stream<DocumentSnapshot<Map<String, dynamic>>> stream =
            document.snapshots();
        int call = 0;

        stream.listen(
          expectAsync1(
            (DocumentSnapshot<Map<String, dynamic>> snapshot) {
              call++;
              if (call == 1) {
                expect(snapshot.exists, isFalse);
              } else {
                fail('Should not have been called');
              }
            },
            count: 1,
            reason: 'Stream should only have been called once.',
          ),
        );
      });

      testWidgets('listens to multiple documents', (_) async {
        DocumentReference<Map<String, dynamic>> doc1 =
            await initializeTest('document-snapshot-1');
        DocumentReference<Map<String, dynamic>> doc2 =
            await initializeTest('document-snapshot-2');

        await doc1.set({'test': 'value1'});
        await doc2.set({'test': 'value2'});

        final value1 = doc1.snapshots().first.then((s) => s.data()!['test']);
        final value2 = doc2.snapshots().first.then((s) => s.data()!['test']);

        await expectLater(value1, completion('value1'));
        await expectLater(value2, completion('value2'));
      });

      testWidgets('listens to a multiple changes response', (_) async {
        DocumentReference<Map<String, dynamic>> document =
            await initializeTest('document-snapshot-multiple');
        Stream<DocumentSnapshot<Map<String, dynamic>>> stream =
            document.snapshots();
        int call = 0;

        StreamSubscription subscription = stream.listen(
          expectAsync1(
            (DocumentSnapshot<Map<String, dynamic>> snapshot) {
              call++;
              if (call == 1) {
                expect(snapshot.exists, isFalse);
              } else if (call == 2) {
                expect(snapshot.exists, isTrue);
                expect(snapshot.data()!['bar'], equals('baz'));
              } else if (call == 3) {
                expect(snapshot.exists, isFalse);
              } else if (call == 4) {
                expect(snapshot.exists, isTrue);
                expect(snapshot.data()!['foo'], equals('bar'));
              } else if (call == 5) {
                expect(snapshot.exists, isTrue);
                expect(snapshot.data()!['foo'], equals('baz'));
              } else {
                fail('Should not have been called');
              }
            },
            count: 5,
            reason: 'Stream should only have been called five times.',
          ),
        );

        await Future.delayed(
          const Duration(seconds: 1),
        ); // allow stream to return a noop-doc
        await document.set({'bar': 'baz'});
        await document.delete();
        await document.set({'foo': 'bar'});
        await document.update({'foo': 'baz'});

        await subscription.cancel();
      });

      testWidgets('listeners throws a [FirebaseException]', (_) async {
        DocumentReference<Map<String, dynamic>> document =
            firestore.doc('not-allowed/document');
        Stream<DocumentSnapshot<Map<String, dynamic>>> stream =
            document.snapshots();

        try {
          await stream.first;
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

    group('DocumentReference.delete()', () {
      testWidgets('delete() deletes a document', (_) async {
        DocumentReference<Map<String, dynamic>> document =
            await initializeTest('document-delete');
        await document.set({
          'foo': 'bar',
        });
        DocumentSnapshot<Map<String, dynamic>> snapshot = await document.get();
        expect(snapshot.exists, isTrue);
        await document.delete();
        DocumentSnapshot<Map<String, dynamic>> snapshot2 = await document.get();
        expect(snapshot2.exists, isFalse);
      });

      testWidgets('throws a [FirebaseException] on error', (_) async {
        DocumentReference<Map<String, dynamic>> document =
            firestore.doc('not-allowed/document');

        try {
          await document.delete();
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

    group('DocumentReference.get()', () {
      testWidgets('gets a document from server', (_) async {
        DocumentReference<Map<String, dynamic>> document =
            await initializeTest('document-get-server');
        await document.set({'foo': 'bar'});
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await document.get(const GetOptions(source: Source.server));
        expect(snapshot.data(), {'foo': 'bar'});
        expect(snapshot.metadata.isFromCache, isFalse);
      });

      testWidgets(
        'gets a document from cache',
        (_) async {
          DocumentReference<Map<String, dynamic>> document =
              await initializeTest('document-get-cache');
          await document.set({'foo': 'bar'});
          DocumentSnapshot<Map<String, dynamic>> snapshot =
              await document.get(const GetOptions(source: Source.cache));
          expect(snapshot.data(), equals({'foo': 'bar'}));
          expect(snapshot.metadata.isFromCache, isTrue);
        },
        skip: kIsWeb,
      );

      testWidgets('throws a [FirebaseException] on error', (_) async {
        DocumentReference<Map<String, dynamic>> document =
            firestore.doc('not-allowed/document');

        try {
          await document.get();
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

    group('DocumentReference.set()', () {
      testWidgets('sets data', (_) async {
        DocumentReference<Map<String, dynamic>> document =
            await initializeTest('document-set');
        await document.set({'foo': 'bar'});
        DocumentSnapshot<Map<String, dynamic>> snapshot = await document.get();
        expect(snapshot.data(), equals({'foo': 'bar'}));
        await document.set({'bar': 'baz'});
        DocumentSnapshot<Map<String, dynamic>> snapshot2 = await document.get();
        expect(snapshot2.data(), equals({'bar': 'baz'}));
      });

      testWidgets('set() merges data', (_) async {
        DocumentReference<Map<String, dynamic>> document =
            await initializeTest('document-set-merge');
        await document.set({'foo': 'bar'});
        DocumentSnapshot<Map<String, dynamic>> snapshot = await document.get();
        expect(snapshot.data(), equals({'foo': 'bar'}));
        await document
            .set({'foo': 'ben', 'bar': 'baz'}, SetOptions(merge: true));
        DocumentSnapshot<Map<String, dynamic>> snapshot2 = await document.get();
        expect(snapshot2.data(), equals({'foo': 'ben', 'bar': 'baz'}));
      });

      testWidgets(
        'set() merges fields',
        (_) async {
          DocumentReference<Map<String, dynamic>> document =
              await initializeTest('document-set-merge-fields');
          Map<String, dynamic> initialData = {
            'foo': 'bar',
            'bar': 123,
            'baz': '456',
          };
          Map<String, dynamic> dataToSet = {
            'foo': 'should-not-merge',
            'bar': 456,
            'baz': 'foo',
          };
          await document.set(initialData);
          DocumentSnapshot<Map<String, dynamic>> snapshot =
              await document.get();
          expect(snapshot.data(), equals(initialData));
          await document.set(
            dataToSet,
            SetOptions(
              mergeFields: [
                'bar',
                FieldPath(const ['baz']),
              ],
            ),
          );
          DocumentSnapshot<Map<String, dynamic>> snapshot2 =
              await document.get();
          expect(
            snapshot2.data(),
            equals({'foo': 'bar', 'bar': 456, 'baz': 'foo'}),
          );
        },
        skip: kIsWeb,
      );

      testWidgets('throws a [FirebaseException] on error', (_) async {
        DocumentReference<Map<String, dynamic>> document =
            firestore.doc('not-allowed/document');

        try {
          await document.set({'foo': 'bar'});
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

      testWidgets('set and return all possible datatypes', (_) async {
        DocumentReference<Map<String, dynamic>> document =
            await initializeTest('document-types');

        await document.set({
          'string': 'foo bar',
          'number_32': 123,
          // Equivalent of `Number.MAX_SAFE_INTEGER` in JS, can't go higher than this.
          'number_64': 9007199254740991,
          'bool_true': true,
          'bool_false': false,
          'map': {
            'foo': 'bar',
            'bar': {'baz': 'ben'}
          },
          'list': [
            1,
            '2',
            true,
            false,
            {'foo': 'bar'}
          ],
          'null': null,
          'timestamp': Timestamp.now(),
          'geopoint': const GeoPoint(1, 2),
          'reference': firestore.doc('foo/bar'),
          'nan': double.nan,
          'infinity': double.infinity,
          'negative_infinity': double.negativeInfinity,
        });

        DocumentSnapshot<Map<String, dynamic>> snapshot = await document.get();
        Map<String, dynamic> data = snapshot.data()!;

        expect(data['string'], equals('foo bar'));
        expect(data['number_32'], equals(123));
        expect(data['number_64'], equals(9007199254740991));
        expect(data['bool_true'], isTrue);
        expect(data['bool_false'], isFalse);
        expect(
          data['map'],
          equals(<String, dynamic>{
            'foo': 'bar',
            'bar': {'baz': 'ben'}
          }),
        );
        expect(
          data['list'],
          equals([
            1,
            '2',
            true,
            false,
            {'foo': 'bar'}
          ]),
        );
        expect(data['null'], equals(null));
        expect(data['timestamp'], isA<Timestamp>());
        expect(data['geopoint'], isA<GeoPoint>());
        expect((data['geopoint'] as GeoPoint).latitude, equals(1));
        expect((data['geopoint'] as GeoPoint).longitude, equals(2));
        expect(data['reference'], isA<DocumentReference>());
        expect((data['reference'] as DocumentReference).id, equals('bar'));
        expect(data['nan'].isNaN, equals(true));
        expect(data['infinity'], equals(double.infinity));
        expect(data['negative_infinity'], equals(double.negativeInfinity));
      });
    });

    group('DocumentReference.update()', () {
      testWidgets('updates data', (_) async {
        DocumentReference<Map<String, dynamic>> document =
            await initializeTest('document-update');
        await document.set({'foo': 'bar'});
        DocumentSnapshot<Map<String, dynamic>> snapshot = await document.get();
        expect(snapshot.data(), equals({'foo': 'bar'}));
        await document.update({'bar': 'baz'});
        DocumentSnapshot<Map<String, dynamic>> snapshot2 = await document.get();
        expect(snapshot2.data(), equals({'foo': 'bar', 'bar': 'baz'}));
      });

      testWidgets('updates nested data using dots', (_) async {
        DocumentReference<Map<String, dynamic>> document =
            await initializeTest('document-update-field-path');
        await document.set({
          'foo': {'bar': 'baz'}
        });
        DocumentSnapshot<Map<String, dynamic>> snapshot = await document.get();
        expect(
          snapshot.data(),
          equals({
            'foo': {'bar': 'baz'}
          }),
        );

        await document.update({'foo.bar': 'toto'});
        DocumentSnapshot<Map<String, dynamic>> snapshot2 = await document.get();
        expect(
          snapshot2.data(),
          equals({
            'foo': {'bar': 'toto'}
          }),
        );
      });

      testWidgets('updates nested data using FieldPath', (_) async {
        DocumentReference<Map<String, dynamic>> document =
            await initializeTest('document-update-field-path');
        await document.set({
          'foo': {'bar': 'baz'}
        });
        DocumentSnapshot<Map<String, dynamic>> snapshot = await document.get();
        expect(
          snapshot.data(),
          equals({
            'foo': {'bar': 'baz'}
          }),
        );

        await document.update({
          FieldPath(const ['foo', 'bar']): 'toto'
        });
        DocumentSnapshot<Map<String, dynamic>> snapshot2 = await document.get();
        expect(
          snapshot2.data(),
          equals({
            'foo': {'bar': 'toto'}
          }),
        );
      });

      testWidgets('updates nested data containing a dot using FieldPath',
          (_) async {
        DocumentReference<Map<String, dynamic>> document =
            await initializeTest('document-update-field-path');
        await document.set({'foo.bar': 'baz'});
        DocumentSnapshot<Map<String, dynamic>> snapshot = await document.get();
        expect(
          snapshot.data(),
          equals({'foo.bar': 'baz'}),
        );

        await document.update({
          FieldPath(const ['foo.bar']): 'toto'
        });
        DocumentSnapshot<Map<String, dynamic>> snapshot2 = await document.get();
        expect(
          snapshot2.data(),
          equals({'foo.bar': 'toto'}),
        );
      });

      testWidgets('throws if document does not exist', (_) async {
        DocumentReference<Map<String, dynamic>> document =
            await initializeTest('document-update-not-exists');
        try {
          await document.update({'foo': 'bar'});
          fail('Should have thrown');
        } catch (e) {
          expect(
            e,
            isA<FirebaseException>().having((e) => e.code, 'code', 'not-found'),
          );
        }
      });
    });

    group('withConverter', () {
      testWidgets(
        'set/snapshot/get',
        (_) async {
          final foo = await initializeTest('foo');
          final fooConverter = foo.withConverter<int>(
            fromFirestore: (snapshots, _) => snapshots.data()!['value']! as int,
            toFirestore: (value, _) => {'value': value},
          );

          final fooSnapshot = foo.snapshots();
          final fooConverterSnapshot = fooConverter.snapshots();

          await expectLater(
            fooSnapshot,
            emits(
              isA<DocumentSnapshot<Map<String, dynamic>>>()
                  .having((e) => e.data(), 'data', null),
            ),
          );
          await expectLater(
            fooConverterSnapshot,
            emits(
              isA<DocumentSnapshot<int>>()
                  .having((e) => e.data(), 'data', null),
            ),
          );

          await fooConverter.set(42);

          await expectLater(
            fooSnapshot,
            emits(
              isA<DocumentSnapshot<Map<String, dynamic>>>()
                  .having((e) => e.data(), 'data', {'value': 42}),
            ),
          );
          await expectLater(
            fooConverterSnapshot,
            emits(
              isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 42),
            ),
          );
          await expectLater(
            fooConverter.get(),
            completion(
              isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 42),
            ),
          );

          await foo.set({'value': 21});

          await expectLater(
            fooSnapshot,
            emits(
              isA<DocumentSnapshot<Map<String, dynamic>>>()
                  .having((e) => e.data(), 'data', {'value': 21}),
            ),
          );

          await expectLater(
            fooConverter.get(),
            completion(
              isA<DocumentSnapshot<int>>().having((e) => e.data(), 'data', 21),
            ),
          );
        },
        timeout: const Timeout.factor(3),
      );
    });
  });
}
