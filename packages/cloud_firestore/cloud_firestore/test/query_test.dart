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
  Query? query;

  group('$Query', () {
    setUpAll(() async {
      await Firebase.initializeApp();
      // secondary app
      await Firebase.initializeApp(
          name: 'foo',
          options: const FirebaseOptions(
            apiKey: '123',
            appId: '123',
            messagingSenderId: '123',
            projectId: '123',
          ));

      firestore = FirebaseFirestore.instance;
    });

    setUp(() {
      // Reset the query before each test
      query = firestore!.collection('foo');
    });

    test('.limit() throws if limit is negative', () {
      expect(() => query!.limit(0), throwsAssertionError);
      expect(() => query!.limitToLast(-1), throwsAssertionError);
    });

    group('.where()', () {
      test('throws if field is invalid', () {
        expect(() => query!.where(123), throwsAssertionError);
      });

      test('throws if multiple inequalities on different paths is provided',
          () {
        expect(
            () => query!
                .where('foo.bar', isGreaterThanOrEqualTo: 123)
                .where('bar', isLessThan: 123),
            throwsAssertionError);
      });

      test('allows inequality on the same path', () {
        query!
            .where('foo.bar', isGreaterThan: 123)
            .where('foo.bar', isGreaterThan: 1234);
      });

      test('throws if inequality is different to first orderBy', () {
        expect(() => query!.where('foo', isGreaterThan: 123).orderBy('bar'),
            throwsAssertionError);
        expect(() => query!.orderBy('bar').where('foo', isGreaterThan: 123),
            throwsAssertionError);
        expect(
            () => query!
                .where('foo', isGreaterThan: 123)
                .orderBy('bar')
                .orderBy('foo'),
            throwsAssertionError);
        expect(
            () => query!
                .orderBy('bar')
                .orderBy('foo')
                .where('foo', isGreaterThan: 123),
            throwsAssertionError);
      });

      test('throws if whereIn query length is greater than 10', () {
        expect(
            () => query!
                .where('foo.bar', whereIn: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]),
            throwsAssertionError);
      });

      test('throws if arrayContainsAny query length is greater than 10', () {
        expect(
            () => query!.where('foo',
                arrayContainsAny: [1, 2, 3, 4, 5, 6, 7, 8, 9, 9, 9]),
            throwsAssertionError);
      });

      test('throws if empty array used for whereIn filters', () {
        expect(() => query!.where('foo', whereIn: []), throwsAssertionError);
      });

      test('throws if empty array used for arrayContainsAny filters', () {
        expect(() => query!.where('foo', arrayContainsAny: []),
            throwsAssertionError);
      });

      test('throws if multiple array filters in query', () {
        expect(
            () => query!
                .where('foo.bar', arrayContains: 1)
                .where('foo.bar', arrayContains: 2),
            throwsAssertionError);
        expect(
            () => query!
                .where('foo.bar', arrayContains: 1)
                .where('foo.bar', arrayContainsAny: [2, 3]),
            throwsAssertionError);
        expect(
            () => query!.where('foo.bar',
                arrayContainsAny: [1, 2]).where('foo.bar', arrayContains: 3),
            throwsAssertionError);
      });

      test('throws if multiple disjunctive filters in query', () {
        expect(
            () => query!
                .where('foo', whereIn: [1, 2]).where('foo', whereIn: [2, 3]),
            throwsAssertionError);
        expect(
            () => query!.where('foo', arrayContainsAny: [1]).where('foo',
                arrayContainsAny: [2, 3]),
            throwsAssertionError);
        expect(
            () => query!.where('foo', arrayContainsAny: [2, 3]).where('foo',
                whereIn: [2, 3]),
            throwsAssertionError);
        expect(
            () => query!.where('foo', whereIn: [2, 3]).where('foo',
                arrayContainsAny: [2, 3]),
            throwsAssertionError);
        expect(
            () => query!
                .where('foo', whereIn: [2, 3])
                .where('foo', arrayContains: 1)
                .where('foo', arrayContainsAny: [2]),
            throwsAssertionError);
        expect(
            () => query!.where('foo', arrayContains: 1).where('foo',
                whereIn: [2, 3]).where('foo', arrayContainsAny: [2]),
            throwsAssertionError);
      });

      test('allows arrayContains with whereIn filter', () {
        query!.where('foo', arrayContains: 1).where('foo', whereIn: [2, 3]);
        query!.where('foo', whereIn: [2, 3]).where('foo', arrayContains: 1);
        // cannot use more than one 'array-contains' or 'whereIn' filter
        expect(
            () => query!
                .where('foo', whereIn: [2, 3])
                .where('foo', arrayContains: 1)
                .where('foo', arrayContains: 2),
            throwsAssertionError);
        expect(
            () => query!
                .where('foo', arrayContains: 1)
                .where('foo', whereIn: [2, 3]).where('foo', whereIn: [2, 3]),
            throwsAssertionError);
      });
    });

    group('cursor queries', () {
      test('throws if starting or ending point specified after orderBy', () {
        Query q = query!.orderBy('foo');
        expect(() => q.startAt([1]).orderBy('bar'), throwsAssertionError);
        expect(() => q.startAfter([1]).orderBy('bar'), throwsAssertionError);
        expect(() => q.endAt([1]).orderBy('bar'), throwsAssertionError);
        expect(() => q.endBefore([1]).orderBy('bar'), throwsAssertionError);
      });

      test('throws if inconsistent arguments number', () {
        expect(() => query!.orderBy('foo').startAt(['bar', 'baz']),
            throwsAssertionError);
        expect(() => query!.orderBy('foo').startAfter(['bar', 'baz']),
            throwsAssertionError);
        expect(() => query!.orderBy('foo').endAt(['bar', 'baz']),
            throwsAssertionError);
        expect(() => query!.orderBy('foo').endBefore(['bar', 'baz']),
            throwsAssertionError);
      });

      test('throws if fields are not a String or FieldPath', () {
        expect(() => query!.endAt([123, {}]), throwsAssertionError);
        expect(() => query!.startAt(['123', []]), throwsAssertionError);
        expect(() => query!.endBefore([true]), throwsAssertionError);
        expect(() => query!.startAfter([false]), throwsAssertionError);
      });

      test('throws if fields is greater than the number of orders', () {
        expect(() => query!.endAt(['123']), throwsAssertionError);
        expect(
            () => query!.startAt([
                  FieldPath(const ['123'])
                ]),
            throwsAssertionError);
      });

      test('endAt() replaces all end parameters', () {
        Query q = query!.orderBy('foo').endBefore(['123']);
        expect(q.parameters['endBefore'], equals(['123']));
        q = q.endAt(['456']);
        expect(q.parameters['endBefore'], isNull);
        expect(q.parameters['endAt'], equals(['456']));
      });
    });
  });
}
