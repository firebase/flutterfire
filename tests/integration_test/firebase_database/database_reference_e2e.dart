// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firebase_database_e2e_test.dart';

void setupDatabaseReferenceTests() {
  group('DatabaseReference', () {
    late DatabaseReference ref;

    setUp(() async {
      ref = database.ref('tests');
      await ref.remove();
    });

    group('set()', () {
      test('sets value', () async {
        final v = Random.secure().nextInt(1024);
        await ref.set(v);
        final actual = await ref.get();
        expect(actual.value, v);
      });

      test(
        'throws "permission-denied" on a ref with no read permission',
        () async {
          await expectLater(
            database.ref('denied_read').get(),
            throwsA(
              isA<FirebaseException>()
                  .having(
                    (error) => error.code,
                    'code',
                    'permission-denied',
                  )
                  .having(
                    (error) => error.message,
                    'message',
                    predicate(
                      (String message) =>
                          message.contains("doesn't have permission"),
                    ),
                  ),
            ),
          );
        },
        skip: true, // TODO Fails on CI even though works locally
      );

      test('removes a value if set to null', () async {
        final v = Random.secure().nextInt(1024);
        await ref.set(v);
        final before = await ref.get();
        expect(before.value, v);

        await ref.set(null);
        final after = await ref.get();
        expect(after.value, isNull);
        expect(after.exists, isFalse);
      });
    });

    group('setPriority()', () {
      test('sets a priority', () async {
        await ref.set('foo');
        await ref.setPriority(2);
        final snapshot = await ref.get();
        expect(snapshot.priority, 2);
      });
    });

    group('setWithPriority()', () {
      test('sets a non-null value with a non-null priority', () async {
        await Future.wait([
          ref.child('first').setWithPriority(1, 10),
          ref.child('second').setWithPriority(2, 1),
          ref.child('third').setWithPriority(3, 5),
        ]);

        final snapshot = await ref.orderByPriority().get();
        final keys = snapshot.children.map((child) => child.key).toList();
        expect(keys, ['second', 'third', 'first']);
      });
    });

    group('update()', () {
      test('updates value at given location', () async {
        await ref.set({'foo': 'bar'});
        final newValue = Random.secure().nextInt(255) + 1;
        await ref.update({'bar': newValue});
        final actual = await ref.get();

        expect(actual.value, {
          'foo': 'bar',
          'bar': newValue,
        });
      });
    });

    group('runTransaction()', () {
      setUp(() async {
        await ref.set(0);
      });

      test('aborts a transaction', () async {
        await ref.set(5);
        final snapshot = await ref.get();
        expect(snapshot.value, 5);

        final result = await ref.runTransaction((value) {
          final nextValue = (value as int? ?? 0) + 1;
          if (nextValue > 5) {
            return Transaction.abort();
          }
          return Transaction.success(nextValue);
        });

        expect(result.committed, false);
        expect(result.snapshot.value, 5);
      });

      test('executes transaction', () async {
        final snapshot = await ref.get();
        final value = (snapshot.value ?? 0) as int;
        final result = await ref.runTransaction((value) {
          return Transaction.success((value as int? ?? 0) + 1);
        });

        expect(result.committed, true);
        expect((result.snapshot.value ?? 0) as int > value, true);
        expect(result.snapshot.key, ref.key);
      });

      test('get primitive list values', () async {
        List<String> data = ['first', 'second'];
        final FirebaseDatabase database = FirebaseDatabase.instance;
        final DatabaseReference ref = database.ref('tests/list-values');

        await ref.set({'list': data});

        final transactionResult = await ref.runTransaction((mutableData) {
          return Transaction.success(mutableData);
        });

        var value = transactionResult.snapshot.value as dynamic;
        expect(value, isNotNull);
        expect(value['list'], data);
      });

      test('Server.increment', () async {
        final FirebaseDatabase database = FirebaseDatabase.instance;
        final DatabaseReference ref = database.ref('tests/server-increment');
        await ref.set(ServerValue.increment(1.5));

        final snap = await ref.get();
        var value = snap.value;
        expect(value, 1.5);

        await ref.set(ServerValue.increment(1));
        final snap2 = await ref.get();
        var value2 = snap2.value;
        expect(value2, 2.5);
      });
    });
  });
}
