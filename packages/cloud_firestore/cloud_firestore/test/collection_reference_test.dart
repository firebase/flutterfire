// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import './mock.dart';

void main() {
  setupCloudFirestoreMocks();
  late FirebaseFirestore firestore;
  late FirebaseFirestore firestoreSecondary;

  group('$CollectionReference', () {
    setUpAll(() async {
      await Firebase.initializeApp();
      FirebaseApp secondaryApp = await Firebase.initializeApp(
          name: 'foo',
          options: const FirebaseOptions(
            apiKey: '123',
            appId: '123',
            messagingSenderId: '123',
            projectId: '123',
          ));

      firestore = FirebaseFirestore.instance;
      firestoreSecondary = FirebaseFirestore.instanceFor(app: secondaryApp);
    });

    test('extends $Query', () {
      // The `firestore` property is publically accessible via Query.
      // Is there a better way to test this?
      CollectionReference ref = firestore.collection('foo');

      expect(ref.firestore, equals(firestore));
    });

    test('equality', () {
      CollectionReference ref = firestore.collection('foo');
      CollectionReference ref2 = firestoreSecondary.collection('foo');
      CollectionReference ref3 = firestore.collection('bar');

      expect(ref == firestore.collection('foo'), isTrue);
      expect(ref2 == firestoreSecondary.collection('foo'), isTrue);
      expect(ref3 == ref, isFalse);

      DocumentReference docRef = firestore.collection('foo').doc('bar');
      DocumentReference docRef2 =
          firestoreSecondary.collection('foo').doc('bar');

      expect(docRef, firestore.collection('foo').doc('bar'));
      expect(docRef2, firestoreSecondary.collection('foo').doc('bar'));
      expect(docRef == docRef2, isFalse);
    });

    test('returns the correct id', () {
      CollectionReference ref = firestore.collection('foo');
      CollectionReference ref2 = firestore.collection('foo/bar/baz');

      expect(ref.id, equals('foo'));
      expect(ref2.id, equals('baz'));
    });

    test('returns the correct parent', () {
      CollectionReference ref = firestore.collection('foo');
      CollectionReference ref2 = firestore.collection('foo/bar/baz');

      expect(ref.parent, isNull);
      expect(ref2.parent, isA<DocumentReference>());

      DocumentReference docRef = firestore.doc('foo/bar');
      expect(ref2.parent, equals(docRef));
    });

    test('returns the correct path', () {
      CollectionReference ref = firestore.collection('foo');
      CollectionReference ref2 = firestore.collection('foo/bar/baz');

      expect(ref.path, equals('foo'));
      expect(ref2.path, equals('foo/bar/baz'));
    });

    test('doc() returns the correct $DocumentReference', () {
      CollectionReference ref = firestore.collection('foo');

      expect(ref.doc('bar'), firestore.doc('foo/bar'));
    });

    test('path must be non-empty strings', () {
      DocumentReference docRef = firestore.doc('foo/bar');
      expect(() => firestore.collection(''), throwsAssertionError);
      expect(() => docRef.collection(''), throwsAssertionError);
    });

    test('path must be odd length', () {
      DocumentReference docRef = firestore.doc('foo/bar');
      expect(() => firestore.collection('foo/bar'), throwsAssertionError);
      expect(
          () => firestore.collection('foo/bar/baz/quu'), throwsAssertionError);
      expect(() => docRef.collection('foo/bar'), throwsAssertionError);
      expect(() => docRef.collection('foo/bar/baz/quu'), throwsAssertionError);
    });

    test('must not have empty segments', () {
      // NOTE: Leading / trailing slashes are okay.
      firestore.collection('/foo/');
      firestore.collection('/foo');
      firestore.collection('foo/');

      const badPaths = ['foo//bar//baz', '//foo', 'foo//'];
      CollectionReference colRef = firestore.collection('test-collection');
      DocumentReference docRef = colRef.doc('test-document');

      for (final path in badPaths) {
        expect(() => firestore.collection(path), throwsAssertionError);
        expect(() => firestore.doc(path), throwsAssertionError);
        expect(() => colRef.doc(path), throwsAssertionError);
        expect(() => docRef.collection(path), throwsAssertionError);
      }
    });

    group('validate', () {
      test('path must be non-empty strings', () {
        DocumentReference docRef = firestore.doc('foo/bar');
        expect(() => firestore.collection(''), throwsAssertionError);
        expect(() => docRef.collection(''), throwsAssertionError);
      });

      test('path must be odd length', () {
        DocumentReference docRef = firestore.doc('foo/bar');
        expect(() => firestore.collection('foo/bar'), throwsAssertionError);
        expect(() => firestore.collection('foo/bar/baz/quu'),
            throwsAssertionError);
        expect(() => docRef.collection('foo/bar'), throwsAssertionError);
        expect(
            () => docRef.collection('foo/bar/baz/quu'), throwsAssertionError);
      });

      test('must not have empty segments', () {
        // NOTE: Leading / trailing slashes are okay.
        firestore.collection('/foo/');
        firestore.collection('/foo');
        firestore.collection('foo/');

        final badPaths = ['foo//bar//baz', '//foo', 'foo//'];
        CollectionReference colRef = firestore.collection('test-collection');
        DocumentReference docRef = colRef.doc('test-document');

        for (final String path in badPaths) {
          expect(() => firestore.collection(path), throwsAssertionError);
          expect(() => firestore.doc(path), throwsAssertionError);
          expect(() => colRef.doc(path), throwsAssertionError);
          expect(() => docRef.collection(path), throwsAssertionError);
        }
      });
    });

    group('withConverter', () {
      test('implements ==', () {
        int fromFirebase(Map json) => 42;
        Map<String, dynamic> toFirebase(Object value) => {};

        final foo = firestore.collection('foo');
        final bar = firestore.collection('bar');

        final intFoo = foo.withConverter<int>(
          fromFirebase: fromFirebase,
          toFirebase: toFirebase,
        );

        // utilities to check == in both directions as it is possible that
        // a == b is true but b == a is false since the former invoke a's == operator
        // while the latter invoke b's == operator
        void expectEqual(Object? a, Object? b) {
          expect(a, b);
          expect(b, a);
        }

        void expectNotEqual(Object? a, Object? b) {
          expect(a, isNot(b));
          expect(b, isNot(a));
        }

        expectEqual(
          foo.withConverter<int>(
            fromFirebase: fromFirebase,
            toFirebase: toFirebase,
          ),
          intFoo,
        );

        expectNotEqual(
          bar.withConverter<int>(
            fromFirebase: fromFirebase,
            toFirebase: toFirebase,
          ),
          intFoo,
        );

        expectNotEqual(
          foo.withConverter<Object>(
            fromFirebase: fromFirebase,
            toFirebase: toFirebase,
          ),
          intFoo,
        );

        expectNotEqual(
          foo.withConverter<int>(
            fromFirebase: (_) => 42,
            toFirebase: toFirebase,
          ),
          intFoo,
        );

        expectNotEqual(
          foo.withConverter<int>(
            fromFirebase: fromFirebase,
            toFirebase: (_) => {},
          ),
          intFoo,
        );
      });

      test('toString', () {
        final foo = firestore.collection('foo');

        expect(
          foo
              .withConverter<int>(
                fromFirebase: (map) => 42,
                toFirebase: (value) => {},
              )
              .toString(),
          'WithConverterCollectionReference<int>(foo)',
        );

        expect(
          foo
              .withConverter<double>(
                fromFirebase: (map) => 42,
                toFirebase: (value) => {},
              )
              .toString(),
          'WithConverterCollectionReference<double>(foo)',
        );
      });

      test('id', () {
        final foo = firestore.collection('foo');

        expect(
          foo.withConverter(fromFirebase: (_) => 42, toFirebase: (_) => {}).id,
          foo.id,
        );
      });

      test('path', () {
        final subCollection =
            firestore.collection('foo').doc('42').collection('bar');

        expect(
          subCollection
              .withConverter(fromFirebase: (_) => 42, toFirebase: (_) => {})
              .path,
          subCollection.path,
        );
      });

      test('parent', () {
        final subCollection =
            firestore.collection('foo').doc('42').collection('bar');

        expect(
          subCollection
              .withConverter(fromFirebase: (_) => 42, toFirebase: (_) => {})
              .parent,
          subCollection.parent,
        );
      });

      test('doc', () {
        final foo = firestore.collection('foo');

        int fromFirebase(Map json) => 42;
        Map<String, dynamic> toFirebase(Object value) => {};

        expect(
          foo
              .withConverter(
                fromFirebase: fromFirebase,
                toFirebase: toFirebase,
              )
              .doc('42'),
          foo.doc('42').withConverter(
                fromFirebase: fromFirebase,
                toFirebase: toFirebase,
              ),
        );
      });
    });
  });
}
