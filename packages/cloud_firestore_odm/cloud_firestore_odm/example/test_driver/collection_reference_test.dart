// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm_example/integration.dart';
import 'package:cloud_firestore_odm_example/movie.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

class Foo {
  Foo();
}

void main() {
  group('CollectionReference', () {
    late FirebaseFirestore customFirestore;

    setUpAll(() async {
      customFirestore = FirebaseFirestore.instanceFor(
        app: await Firebase.initializeApp(
          name: 'custom-collection-app',
          options: FirebaseOptions(
            apiKey: Firebase.app().options.apiKey,
            appId: Firebase.app().options.appId,
            messagingSenderId: Firebase.app().options.messagingSenderId,
            projectId: Firebase.app().options.projectId,
          ),
        ),
      );
    });

    test('Injects document ID when annotated by @Id', () async {
      final collection = await initializeTest(MovieCollectionReference());

      await collection.doc('123').set(createMovie(title: 'a'));
      await collection.doc('456').set(createMovie(title: 'b'));

      final a = await collection.doc('123').get();
      final b = await collection.doc('456').get();

      expect(a.data?.id, '123');
      expect(b.data?.id, '456');
    });

    test(
        'When using @Id, set/update do not insert an "id" property in the document',
        () async {
      final collection = await initializeTest(MovieCollectionReference());

      await collection.doc('123').set(createMovie(title: 'a', id: '42'));

      final snapshot = await FirebaseFirestore.instance
          .doc(collection.doc('123').path)
          .get();

      expect(snapshot.data()?.containsKey('id'), false);
    });

    group('any collection', () {
      test('reference', () async {
        expect(
          MovieCollectionReference().reference,
          isA<CollectionReference<Movie>>()
              .having((e) => e.path, 'path', 'firestore-example-app'),
        );

        expect(
          MovieCollectionReference().doc('123').comments.reference,
          isA<CollectionReference<Comment>>().having(
            (e) => e.path,
            'path',
            'firestore-example-app/123/comments',
          ),
        );
      });

      group('get', () {
        test(
          'supports GetOptions',
          () async {
            final collection = await initializeTest(MovieCollectionReference());

            await collection.doc('123').set(createMovie(title: 'title'));
            await collection.doc('123').get();

            expect(
              await collection.get(const GetOptions(source: Source.cache)),
              isA<MovieQuerySnapshot>().having((e) => e.docs, 'doc', [
                isA<MovieQueryDocumentSnapshot>()
                    .having((e) => e.data.title, 'data.title', 'title')
                    .having(
                      (e) => e.metadata.isFromCache,
                      'metadata.isFromCache',
                      true,
                    ),
              ]),
            );
            // TODO figure out why this is somehow failing in the CI
          },
          skip: true,
        );

        test('returns a future that fails if decoding throws', () async {
          final collection = await initializeTest(MovieCollectionReference());

          await FirebaseFirestore.instance
              .collection(collection.path)
              .add(<String, Object?>{'value': 42});

          await expectLater(
            collection.get(),
            throwsA(isA<TypeError>()),
          );
        });
      });

      group('snapshots', () {
        test('calls listeners when value changes', () async {
          final collection = await initializeTest(MovieCollectionReference());

          final stream = StreamQueue(collection.snapshots());

          expect(
            await stream.next,
            isA<MovieQuerySnapshot>().having((e) => e.docs, 'doc', isEmpty),
          );

          unawaited(collection.doc('123').set(createMovie(title: 'title')));

          expect(
            await stream.next,
            isA<MovieQuerySnapshot>().having((e) => e.docs, 'doc', [
              isA<MovieQueryDocumentSnapshot>()
                  .having((e) => e.data.title, 'data.title', 'title')
            ]),
          );
        });

        test('emits an error if decoding fails, but keeps listening to updates',
            () async {
          final collection = await initializeTest(MovieCollectionReference());

          await FirebaseFirestore.instance
              .collection(collection.path)
              .doc('123')
              .set(<String, Object?>{'value': 42});

          final stream = StreamQueue(collection.snapshots());

          await expectLater(
            stream.next,
            throwsA(isA<TypeError>()),
          );

          await collection.doc('123').set(createMovie(title: 'A'));

          expect(
            await stream.next.then((e) => e.docs.single.data.title),
            'A',
          );
        });
      });

      test('metadata', () async {
        final collection = await initializeTest(MovieCollectionReference());

        final snap = await collection.get(
          const GetOptions(source: Source.server),
        );

        expect(snap.metadata.isFromCache, false);

        final snap2 = await collection.get(
          const GetOptions(source: Source.cache),
        );

        expect(snap2.metadata.isFromCache, true);
      });

      group('doc', () {
        test('generates a custom ID for documents if none is specified',
            () async {
          final collection = await initializeTest(MovieCollectionReference());

          final doc = collection.doc();
          final doc2 = collection.doc();

          expect(doc.id, isNot(doc2.id));

          expect(await doc.get().then((d) => d.exists), isFalse);
        });

        test('can specify a custom ID to obtain an existing doc', () async {
          final collection = await initializeTest(MovieCollectionReference());

          await FirebaseFirestore.instance
              .collection('firestore-example-app')
              .doc('123')
              .set(
                MovieCollectionReference.toFirestore(
                  createMovie(title: 'title'),
                  null,
                ),
              );

          final doc = collection.doc('123');
          final doc2 = collection.doc();

          expect(doc.id, isNot(doc2.id));

          expect(
            await doc.get(),
            isA<MovieDocumentSnapshot>()
                .having((e) => e.data?.title, 'data.title', 'title'),
          );
        });
      });

      test('Comments.parent is equal to the parent collection', () {
        expect(
          moviesRef.doc('123').comments.parent,
          moviesRef.doc('123'),
        );
      });

      test('path', () {
        expect(MovieCollectionReference().path, 'firestore-example-app');
        expect(
          MovieCollectionReference().doc('123').comments.path,
          'firestore-example-app/123/comments',
        );
      });

      test('add', () async {
        final collection = await initializeTest(MovieCollectionReference());

        final stream = StreamQueue(collection.snapshots());

        await expectLater(
          stream,
          emits(
            isA<MovieQuerySnapshot>().having((e) => e.docs, 'doc', isEmpty),
          ),
        );

        final newDoc = await collection.add(createMovie(title: 'Foo'));

        await expectLater(
          stream,
          emits(
            isA<MovieQuerySnapshot>().having((e) => e.docs, 'doc', [
              isA<MovieQueryDocumentSnapshot>()
                  .having((e) => e.data.title, 'data.title', 'Foo'),
            ]),
          ),
        );

        expect(
          await newDoc.get(),
          isA<MovieDocumentSnapshot>()
              .having((e) => e.data?.title, 'data.title', 'Foo'),
        );
      });

      group('endAt', () {
        test('supports values', () async {
          final collection = await initializeTest(MovieCollectionReference());

          await collection.add(createMovie(title: 'A'));
          await collection.add(createMovie(title: 'B'));
          await collection.add(createMovie(title: 'C'));

          final querySnap = await collection.orderByTitle(endAt: 'B').get();

          expect(
            querySnap.docs,
            [
              isA<MovieQueryDocumentSnapshot>()
                  .having((d) => d.data.title, 'data.title', 'A'),
              isA<MovieQueryDocumentSnapshot>()
                  .having((d) => d.data.title, 'data.title', 'B'),
            ],
          );
        });

        test('supports document snapshots', () async {
          final collection = await initializeTest(MovieCollectionReference());

          await collection.add(createMovie(title: 'A'));
          final b = await collection.add(createMovie(title: 'B'));
          await collection.add(createMovie(title: 'C'));

          final bSnap = await b.get();

          final querySnap =
              await collection.orderByTitle(endAtDocument: bSnap).get();

          expect(
            querySnap.docs,
            [
              isA<MovieQueryDocumentSnapshot>()
                  .having((d) => d.data.title, 'data.title', 'A'),
              isA<MovieQueryDocumentSnapshot>()
                  .having((d) => d.data.title, 'data.title', 'B'),
            ],
          );
        });
      });

      group('endBefore', () {
        test('supports values', () async {
          final collection = await initializeTest(MovieCollectionReference());

          await collection.add(createMovie(title: 'A'));
          await collection.add(createMovie(title: 'B'));
          await collection.add(createMovie(title: 'C'));

          final querySnap = await collection.orderByTitle(endAt: 'B').get();

          expect(
            querySnap.docs,
            [
              isA<MovieQueryDocumentSnapshot>()
                  .having((d) => d.data.title, 'data.title', 'A'),
              isA<MovieQueryDocumentSnapshot>()
                  .having((d) => d.data.title, 'data.title', 'B'),
            ],
          );
        });

        test('supports document snapshots', () async {
          final collection = await initializeTest(MovieCollectionReference());

          await collection.add(createMovie(title: 'A'));
          final b = await collection.add(createMovie(title: 'B'));
          await collection.add(createMovie(title: 'C'));

          final bSnap = await b.get();

          final querySnap =
              await collection.orderByTitle(endBeforeDocument: bSnap).get();

          expect(
            querySnap.docs,
            [
              isA<MovieQueryDocumentSnapshot>()
                  .having((d) => d.data.title, 'data.title', 'A'),
            ],
          );
        });
      });

      test('orderByFieldPath', () async {
        final collection = await initializeTest(MovieCollectionReference());

        await collection.add(createMovie(title: 'A', rated: '10'));
        await collection.add(createMovie(title: 'B', rated: '1'));
        await collection.add(createMovie(title: 'C', rated: '5'));

        final querySnap = await collection
            .orderByFieldPath(
              FieldPath.fromString('title'),
              startAt: 'B',
            )
            .get();

        expect(
          querySnap.docs.map((e) => e.data.title),
          ['B', 'C'],
        );
      });

      group('arrayContains', () {
        test('supports whereFieldPath', () async {
          final collection = await initializeTest(MovieCollectionReference());

          await collection.add(
            createMovie(title: 'A', genre: ['foo', 'unrelated']),
          );
          await collection.add(
            createMovie(title: 'B', genre: ['bar', 'unrelated']),
          );
          await collection.add(
            createMovie(title: 'C', genre: ['bar', 'unrelated']),
          );

          final querySnap = await collection
              .whereFieldPath(
                FieldPath.fromString('genre'),
                arrayContains: 'bar',
              )
              .orderByTitle()
              .get();

          expect(
            querySnap.docs.map((e) => e.data.title),
            ['B', 'C'],
          );
        });

        test('supports whereProperty', () async {
          final collection = await initializeTest(MovieCollectionReference());

          await collection.add(
            createMovie(title: 'A', genre: ['foo', 'unrelated']),
          );
          await collection.add(
            createMovie(title: 'B', genre: ['bar', 'unrelated']),
          );
          await collection.add(
            createMovie(title: 'C', genre: ['bar', 'unrelated']),
          );

          final querySnap = await collection
              .whereGenre(arrayContains: 'bar')
              .orderByTitle()
              .get();

          expect(
            querySnap.docs.map((e) => e.data.title),
            ['B', 'C'],
          );
        });
      });

      test('whereFieldPath', () async {
        final collection = await initializeTest(MovieCollectionReference());

        await collection.add(createMovie(title: 'A', rated: '4'));
        await collection.add(createMovie(title: 'B', rated: '5'));
        await collection.add(createMovie(title: 'C', rated: '5'));

        final querySnap = await collection
            .whereFieldPath(
              FieldPath.fromString('rated'),
              isEqualTo: '5',
            )
            .orderByTitle()
            .get();

        expect(
          querySnap.docs.map((e) => e.data.title),
          ['B', 'C'],
        );
      });

      group('documentId', () {
        test('orderByDocumentId', () async {
          final collection = await initializeTest(MovieCollectionReference());

          await collection.doc('A').set(createMovie(title: 'title'));
          await collection.doc('B').set(createMovie(title: 'title'));
          await collection.doc('C').set(createMovie(title: 'title'));

          final querySnap =
              await collection.orderByDocumentId(startAt: 'B').get();

          expect(
            querySnap.docs,
            [
              isA<MovieQueryDocumentSnapshot>().having((d) => d.id, 'id', 'B'),
              isA<MovieQueryDocumentSnapshot>().having((d) => d.id, 'id', 'C'),
            ],
          );
        });

        test('whereDocumentId', () async {
          final collection = await initializeTest(MovieCollectionReference());

          await collection.doc('A').set(createMovie(title: 'title'));
          await collection.doc('B').set(createMovie(title: 'title'));
          await collection.doc('C').set(createMovie(title: 'title'));

          final querySnap =
              await collection.whereDocumentId(isEqualTo: 'B').get();

          expect(
            querySnap.docs,
            [
              isA<MovieQueryDocumentSnapshot>().having((d) => d.id, 'id', 'B'),
            ],
          );
        });
      });

      group('where', () {
        test('supports field renaming', () async {
          final collection =
              await initializeTest(AdvancedJsonCollectionReference());

          await collection
              .add(AdvancedJson(firstName: 'John', lastName: 'Doe'));
          await collection
              .add(AdvancedJson(firstName: 'John', lastName: 'Smith'));
          await collection
              .add(AdvancedJson(firstName: 'Mike', lastName: 'Doe'));

          expect(
            await collection.reference
                .orderBy('first_name')
                .orderBy('LAST_NAME')
                .get()
                .then((value) => value.docs.map((e) => e.data().toJson())),
            [
              {'first_name': 'John', 'LAST_NAME': 'Doe'},
              {'first_name': 'John', 'LAST_NAME': 'Smith'},
              {'first_name': 'Mike', 'LAST_NAME': 'Doe'},
            ],
          );

          expect(
            await collection
                .whereFirstName(isEqualTo: 'John')
                .orderByLastName()
                .get()
                .then((value) => value.docs.map((e) => e.data)),
            [
              AdvancedJson(firstName: 'John', lastName: 'Doe'),
              AdvancedJson(firstName: 'John', lastName: 'Smith'),
            ],
          );
          expect(
            await collection
                .whereLastName(isEqualTo: 'Doe')
                .orderByFirstName()
                .get()
                .then((value) => value.docs.map((e) => e.data)),
            [
              AdvancedJson(firstName: 'John', lastName: 'Doe'),
              AdvancedJson(firstName: 'Mike', lastName: 'Doe'),
            ],
          );
        });
      });

      group('orderBy', () {
        test('supports field renaming', () async {
          final collection =
              await initializeTest(AdvancedJsonCollectionReference());

          await collection.add(AdvancedJson(firstName: 'A', lastName: 'A'));
          await collection
              .add(AdvancedJson(firstName: 'John', lastName: 'Doe'));
          await collection
              .add(AdvancedJson(firstName: 'John', lastName: 'Smith'));
          await collection
              .add(AdvancedJson(firstName: 'Mike', lastName: 'Doe'));

          expect(
            await collection.reference
                .orderBy('first_name')
                .orderBy('LAST_NAME')
                .get()
                .then((value) => value.docs.map((e) => e.data().toJson())),
            [
              {'first_name': 'A', 'LAST_NAME': 'A'},
              {'first_name': 'John', 'LAST_NAME': 'Doe'},
              {'first_name': 'John', 'LAST_NAME': 'Smith'},
              {'first_name': 'Mike', 'LAST_NAME': 'Doe'},
            ],
          );

          expect(
            await collection
                .orderByFirstName(startAt: 'B')
                .get()
                .then((value) => value.docs.map((e) => e.data.firstName)),
            ['John', 'John', 'Mike'],
          );
          expect(
            await collection
                .orderByLastName(startAt: 'B')
                .get()
                .then((value) => value.docs.map((e) => e.data.lastName)),
            ['Doe', 'Doe', 'Smith'],
          );
        });
      });

      group('startAt', () {
        test(
          'supports values',
          () async {
            final collection = await initializeTest(MovieCollectionReference());

            await collection.add(createMovie(title: 'A'));
            await collection.add(createMovie(title: 'B'));
            await collection.add(createMovie(title: 'C'));

            final querySnap = await collection.orderByTitle(startAt: 'B').get();

            expect(
              querySnap.docs,
              [
                isA<MovieQueryDocumentSnapshot>()
                    .having((d) => d.data.title, 'data.title', 'B'),
                isA<MovieQueryDocumentSnapshot>()
                    .having((d) => d.data.title, 'data.title', 'C'),
              ],
            );
          },
          timeout: const Timeout.factor(5),
        );

        test(
          'can be used multiple times within a query',
          () async {
            final collection = await initializeTest(MovieCollectionReference());

            await collection.add(createMovie(title: 'A', likes: 1));
            await collection.add(createMovie(title: 'A', likes: 2));
            await collection.add(createMovie(title: 'B', likes: 1));
            await collection.add(createMovie(title: 'B', likes: 2));
            await collection.add(createMovie(title: 'C', likes: 1));
            await collection.add(createMovie(title: 'C', likes: 2));

            final querySnap = await collection
                .orderByTitle(startAt: 'B')
                .orderByLikes(startAt: 2)
                .get();

            expect(
              querySnap.docs,
              [
                isA<MovieQueryDocumentSnapshot>()
                    .having((d) => d.data.title, 'data.title', 'B')
                    .having((d) => d.data.likes, 'data.likes', 2),
                isA<MovieQueryDocumentSnapshot>()
                    .having((d) => d.data.title, 'data.title', 'C')
                    .having((d) => d.data.likes, 'data.likes', 1),
                isA<MovieQueryDocumentSnapshot>()
                    .having((d) => d.data.title, 'data.title', 'C')
                    .having((d) => d.data.likes, 'data.likes', 2),
              ],
            );
          },
          timeout: const Timeout.factor(5),
        );

        test('supports document snapshots', () async {
          final collection = await initializeTest(MovieCollectionReference());

          await collection.add(createMovie(title: 'A'));
          final b = await collection.add(createMovie(title: 'B'));
          await collection.add(createMovie(title: 'C'));

          final bSnap = await b.get();

          final querySnap =
              await collection.orderByTitle(startAtDocument: bSnap).get();

          expect(
            querySnap.docs,
            [
              isA<MovieQueryDocumentSnapshot>()
                  .having((d) => d.data.title, 'data.title', 'B'),
              isA<MovieQueryDocumentSnapshot>()
                  .having((d) => d.data.title, 'data.title', 'C'),
            ],
          );
        });
      });

      group('startAfter', () {
        test('supports values', () async {
          final collection = await initializeTest(MovieCollectionReference());

          await collection.add(createMovie(title: 'A'));
          await collection.add(createMovie(title: 'B'));
          await collection.add(createMovie(title: 'C'));

          final querySnap =
              await collection.orderByTitle(startAfter: 'B').get();

          expect(
            querySnap.docs,
            [
              isA<MovieQueryDocumentSnapshot>()
                  .having((d) => d.data.title, 'data.title', 'C'),
            ],
          );
        });

        test('supports document snapshots', () async {
          final collection = await initializeTest(MovieCollectionReference());

          await collection.add(createMovie(title: 'A'));
          final b = await collection.add(createMovie(title: 'B'));
          await collection.add(createMovie(title: 'C'));

          final bSnap = await b.get();

          final querySnap =
              await collection.orderByTitle(startAfterDocument: bSnap).get();

          expect(
            querySnap.docs,
            [
              isA<MovieQueryDocumentSnapshot>()
                  .having((d) => d.data.title, 'data.title', 'C'),
            ],
          );
        });
      });

      test('limit', () async {
        final collection = await initializeTest(MovieCollectionReference());

        await collection.add(createMovie(title: 'A'));
        await collection.add(createMovie(title: 'B'));
        await collection.add(createMovie(title: 'C'));

        final querySnap = await collection.orderByTitle().limit(2).get();

        expect(
          querySnap.docs,
          [
            isA<MovieQueryDocumentSnapshot>()
                .having((d) => d.data.title, 'data.title', 'A'),
            isA<MovieQueryDocumentSnapshot>()
                .having((d) => d.data.title, 'data.title', 'B'),
          ],
        );
      });

      test('limitToLast', () async {
        final collection = await initializeTest(MovieCollectionReference());

        await collection.add(createMovie(title: 'A'));
        await collection.add(createMovie(title: 'B'));
        await collection.add(createMovie(title: 'C'));

        final querySnap = await collection.orderByTitle().limitToLast(2).get();

        expect(
          querySnap.docs,
          [
            isA<MovieQueryDocumentSnapshot>()
                .having((d) => d.data.title, 'data.title', 'B'),
            isA<MovieQueryDocumentSnapshot>()
                .having((d) => d.data.title, 'data.title', 'C'),
          ],
        );
      });

      test('listens to a document', () async {
        final collection = await initializeTest(MovieCollectionReference());

        expect(
          (await collection.get()).docs,
          isEmpty,
        );

        final doc = await collection.add(
          Movie(
            genre: ['sci-fi'],
            likes: 0,
            poster: 'poster',
            rated: 'rater',
            runtime: 'runtime',
            title: 'title',
            year: 1999,
            id: '_',
          ),
        );
        final snapshot = StreamQueue(doc.snapshots());

        final initial = await snapshot.next;

        expect(initial.data?.genre, ['sci-fi']);
        expect(initial.data?.likes, 0);
        expect(initial.data?.poster, 'poster');
        expect(initial.data?.rated, 'rater');
        expect(initial.data?.runtime, 'runtime');
        expect(initial.data?.title, 'title');
        expect(initial.data?.year, 1999);

        await doc.set(
          Movie(
            genre: ['thriller'],
            likes: 42,
            poster: 'poster2',
            rated: 'rater2',
            runtime: 'runtime2',
            title: 'title2',
            year: 14242,
            id: '_',
          ),
        );

        final updated = await snapshot.next;

        expect(updated.data?.genre, ['thriller']);
        expect(updated.data?.likes, 42);
        expect(updated.data?.poster, 'poster2');
        expect(updated.data?.rated, 'rater2');
        expect(updated.data?.runtime, 'runtime2');
        expect(updated.data?.title, 'title2');
        expect(updated.data?.year, 14242);
      });

      test('listens to a collection', () async {
        final collection = await initializeTest(MovieCollectionReference());

        final snapshot = StreamQueue(collection.snapshots());

        expect(
          (await snapshot.next).docs,
          isEmpty,
        );

        final doc = await collection.add(
          Movie(
            genre: ['sci-fi'],
            likes: 0,
            poster: 'poster',
            rated: 'rater',
            runtime: 'runtime',
            title: 'title',
            year: 1999,
            id: '_',
          ),
        );

        final initial = await snapshot.next;

        expect(initial.docs.single.data.genre, ['sci-fi']);
        expect(initial.docs.single.data.likes, 0);
        expect(initial.docs.single.data.poster, 'poster');
        expect(initial.docs.single.data.rated, 'rater');
        expect(initial.docs.single.data.runtime, 'runtime');
        expect(initial.docs.single.data.title, 'title');
        expect(initial.docs.single.data.year, 1999);

        await doc.set(
          Movie(
            genre: ['thriller'],
            likes: 42,
            poster: 'poster2',
            rated: 'rater2',
            runtime: 'runtime2',
            title: 'title2',
            year: 14242,
            id: '_',
          ),
        );

        final updated = await snapshot.next;

        expect(updated.docs.single.data.genre, ['thriller']);
        expect(updated.docs.single.data.likes, 42);
        expect(updated.docs.single.data.poster, 'poster2');
        expect(updated.docs.single.data.rated, 'rater2');
        expect(updated.docs.single.data.runtime, 'runtime2');
        expect(updated.docs.single.data.title, 'title2');
        expect(updated.docs.single.data.year, 14242);
      });

      test('docChanges', () async {
        final collection = await initializeTest(MovieCollectionReference());

        await collection.add(createMovie(title: 'A'));
        final snapshot = await collection.get();

        expect(snapshot.docChanges.length, 1);
        expect(snapshot.docChanges.single.newIndex, 0);
        expect(snapshot.docChanges.single.oldIndex, -1);
        expect(snapshot.docChanges.single.type, DocumentChangeType.added);
        expect(snapshot.docChanges.single.doc.data?.title, 'A');
      });
    });

    group('root collection', () {
      test('can be instantiated with no parameter', () {});

      test('overrides ==', () {
        expect(
          MovieCollectionReference(),
          MovieCollectionReference(FirebaseFirestore.instance),
        );

        expect(
          MovieCollectionReference(customFirestore),
          isNot(MovieCollectionReference()),
        );

        expect(
          MovieCollectionReference(customFirestore),
          MovieCollectionReference(customFirestore),
        );
      });
    });

    group('sub collection', () {
      test('parent', () {
        expect(
          MovieCollectionReference().doc('123').comments.parent,
          MovieCollectionReference().doc('123'),
        );
      });

      test('overrides ==', () {
        expect(
          MovieCollectionReference().doc('123').comments,
          MovieCollectionReference(FirebaseFirestore.instance)
              .doc('123')
              .comments,
        );
        expect(
          MovieCollectionReference().doc('123').comments,
          isNot(MovieCollectionReference().doc('456').comments),
        );

        expect(
          MovieCollectionReference(customFirestore).doc('123').comments,
          isNot(MovieCollectionReference().doc('123').comments),
        );
        expect(
          MovieCollectionReference(customFirestore).doc('123').comments,
          MovieCollectionReference(customFirestore).doc('123').comments,
        );
      });
    });
  });
}
