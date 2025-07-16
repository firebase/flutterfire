// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import './mock.dart';

void main() {
  setupCloudFirestoreMocks();
  FirebaseFirestore? firestore;
  FirebaseFirestore? firestoreSecondary;
  FirebaseApp? secondaryApp;

  group('$FirebaseFirestore', () {
    setUpAll(() async {
      await Firebase.initializeApp();
      secondaryApp = await Firebase.initializeApp(
        name: 'foo',
        options: const FirebaseOptions(
          apiKey: '123',
          appId: '123',
          messagingSenderId: '123',
          projectId: '123',
        ),
      );

      firestore = FirebaseFirestore.instance;
      firestoreSecondary = FirebaseFirestore.instanceFor(app: secondaryApp!);
    });

    test('equality', () {
      expect(firestore, equals(FirebaseFirestore.instance));
      expect(firestore.hashCode, firestore.hashCode);
      expect(
        firestoreSecondary,
        equals(FirebaseFirestore.instanceFor(app: secondaryApp!)),
      );
    });

    test('databaseId and databaseURL', () {
      final firestore = FirebaseFirestore.instanceFor(
        // ignore: deprecated_member_use_from_same_package
        app: Firebase.app(), databaseURL: 'foo',
      );

      // ignore: deprecated_member_use_from_same_package
      expect(firestore.databaseURL, equals('foo'));

      expect(firestore.databaseId, equals('foo'));

      final firestore2 =
          FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'bar');

      // ignore: deprecated_member_use_from_same_package
      expect(firestore2.databaseURL, equals('bar'));

      expect(firestore2.databaseId, equals('bar'));

      final firestore3 = FirebaseFirestore.instanceFor(
        // ignore: deprecated_member_use_from_same_package
        app: Firebase.app(), databaseId: 'fire', databaseURL: 'not-this',
      );

      // databaseId should take precedence
      expect(firestore3.databaseId, equals('fire'));
      // ignore: deprecated_member_use_from_same_package
      expect(firestore3.databaseURL, equals('fire'));
    });

    test('returns the correct $FirebaseApp', () {
      expect(firestore!.app, equals(Firebase.app()));
      expect(firestoreSecondary!.app, equals(Firebase.app('foo')));
    });

    group('.collection', () {
      test('returns a $CollectionReference', () {
        expect(firestore!.collection('foo'), isA<CollectionReference>());
      });

      test('does not expect an empty path', () {
        expect(() => firestore!.collection(''), throwsArgumentError);
      });

      test('does accept an invalid path', () {
        // 'foo/bar' points to a document
        expect(() => firestore!.collection('foo/bar'), throwsArgumentError);
      });
    });

    group('.collectionGroup', () {
      test('returns a $Query', () {
        expect(firestore!.collectionGroup('foo'), isA<Query>());
      });

      test('does not expect an empty path', () {
        expect(() => firestore!.collectionGroup(''), throwsArgumentError);
      });

      test('does accept a path containing "/"', () {
        expect(
          () => firestore!.collectionGroup('foo/bar/baz'),
          throwsArgumentError,
        );
      });
    });

    group('.document', () {
      test('returns a $DocumentReference', () {
        expect(firestore!.doc('foo/bar'), isA<DocumentReference>());
      });

      test('does not expect an empty path', () {
        expect(() => firestore!.doc(''), throwsArgumentError);
      });

      test('does accept an invalid path', () {
        // 'foo' points to a collection
        expect(() => firestore!.doc('bar'), throwsArgumentError);
      });
    });
  });
}
