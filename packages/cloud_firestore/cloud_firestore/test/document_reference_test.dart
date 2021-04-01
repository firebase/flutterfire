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
  FirebaseFirestore? firestore;
  FirebaseFirestore? firestoreSecondary;

  group('$DocumentReference', () {
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

    test('equality', () {
      DocumentReference ref = firestore!.doc('foo/bar');
      DocumentReference ref2 = firestore!.doc('foo/bar/baz/bert');

      expect(ref, equals(firestore!.doc('foo/bar')));
      expect(ref2, equals(firestore!.doc('foo/bar/baz/bert')));

      expect(ref == firestoreSecondary!.doc('foo/bar'), isFalse);
      expect(ref2 == firestoreSecondary!.doc('foo/bar/baz/bert'), isFalse);

      expect(ref == ref2, isFalse);
    });

    test('returns document() returns a $DocumentReference', () {
      DocumentReference ref = firestore!.doc('foo/bar');
      DocumentReference ref2 = firestore!.doc('foo/bar/baz/bert');

      expect(ref, isA<DocumentReference>());
      expect(ref2, isA<DocumentReference>());
    });

    test('returns the same firestore instance', () {
      DocumentReference ref = firestore!.doc('foo/bar');
      DocumentReference ref2 = firestoreSecondary!.doc('foo/bar');

      expect(ref.firestore, equals(firestore));
      expect(ref2.firestore, equals(firestoreSecondary));
    });

    test('returns the correct ID', () {
      DocumentReference ref = firestore!.doc('foo/bar');
      DocumentReference ref2 = firestore!.doc('foo/bar/baz/bert');

      expect(ref, isA<DocumentReference>());
      expect(ref.id, equals('bar'));
      expect(ref2.id, equals('bert'));
    });

    group('.parent', () {
      test('returns a $CollectionReference', () {
        DocumentReference ref = firestore!.doc('foo/bar');

        expect(ref.parent, isA<CollectionReference>());
      });

      test('returns the correct $CollectionReference', () {
        DocumentReference ref = firestore!.doc('foo/bar');
        CollectionReference colRef = firestore!.collection('foo');

        expect(ref.parent, equals(colRef));
      });
    });

    test('path must be a non-empty string', () {
      CollectionReference ref = firestore!.collection('foo');
      expect(() => firestore!.doc(''), throwsAssertionError);
      expect(() => ref.doc(''), throwsAssertionError);
    });

    test('path must be even-length', () {
      CollectionReference ref = firestore!.collection('foo');
      expect(() => firestore!.doc('foo'), throwsAssertionError);
      expect(() => firestore!.doc('foo/bar/baz'), throwsAssertionError);
      expect(() => ref.doc('/'), throwsAssertionError);
    });

    test('merge options', () {
      DocumentReference ref = firestore!.collection('foo').doc();
      // can't specify both merge and mergeFields
      expect(() => ref.set({}, SetOptions(merge: true, mergeFields: [])),
          throwsAssertionError);
      expect(() => ref.set({}, SetOptions(merge: false, mergeFields: [])),
          throwsAssertionError);
      // all mergeFields to be a string or a FieldPath
      expect(() => ref.set({}, SetOptions(mergeFields: ['foo', false])),
          throwsAssertionError);
    });
  });
}
