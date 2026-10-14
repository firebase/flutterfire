// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'e2e_test.dart';

DatabaseReference _uniqueRef(String name) {
  return database.ref(
    'tests/$name-${DateTime.now().microsecondsSinceEpoch}',
  );
}

void setupDatabaseReferenceTests() {
  group('DatabaseReference', () {
    group('set()', () {
      test('sets value', () async {
        final ref = database.ref('tests/set-value');
        await ref.remove();
        final v = Random.secure().nextInt(1024);
        await ref.set(v);
        final actual = await ref.get();
        expect(actual.value, v);
      });

      test('removes a value if set to null', () async {
        final ref = database.ref('tests/set-null');
        await ref.remove();
        final v = Random.secure().nextInt(1024);
        await ref.set(v);
        final before = await ref.get();
        expect(before.value, v);

        await ref.set(null);
        final after = await ref.get();
        expect(after.value, isNull);
        expect(after.exists, isFalse);
      });

      // Regression test for
      // https://github.com/firebase/flutterfire/issues/18550: the Windows
      // plugin computed a mapped code but sent it without a Pigeon `details`
      // payload, so every native error reached Dart as `unknown` with the code
      // dropped.
      test('a rejected write keeps its native error code and message',
          () async {
        // `denied_read` denies reads and writes in database.rules.json.
        final ref = database.ref('denied_read/rejected-write');

        await expectLater(
          ref.set('probe'),
          throwsA(
            isA<FirebaseException>()
                .having((e) => e.code, 'code', 'permission-denied')
                .having((e) => e.message, 'message', isNotEmpty),
          ),
        );
      });
    });

    group('setPriority()', () {
      test('sets a priority', () async {
        final ref = database.ref('tests/set-priority');
        await ref.remove();
        await ref.set('foo');
        await ref.setPriority(2);
        final snapshot = await ref.get();
        expect(snapshot.priority, 2);
      });
    });

    group('setWithPriority()', () {
      test('sets a non-null value with a non-null priority', () async {
        final ref = database.ref('tests/set-with-priority');
        await ref.remove();
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
        final ref = database.ref('tests/update');
        await ref.remove();
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
      test('aborts a transaction', () async {
        final ref = database.ref('tests/transaction-abort');
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

      // Regression test for
      // https://github.com/firebase/flutterfire/issues/18549: on Windows an
      // abort decided on the handler's *first* invocation threw a
      // FirebaseException instead of resolving with `committed: false`. The
      // desktop C++ SDK completes that path with `kErrorWriteCanceled` and no
      // message, never with the `kErrorTransactionAbortedByUser` the mobile
      // SDKs use.
      test('aborts on the first handler invocation without throwing', () async {
        final ref = _uniqueRef('transaction-abort-first-invocation');
        await ref.set('unchanged');

        var invocations = 0;
        Object? seenValue;
        final result = await ref.runTransaction((value) {
          invocations++;
          seenValue = value;
          return Transaction.abort();
        });

        // Aborting ends the transaction, so the handler runs exactly once and
        // the result reports the data that invocation saw (which is the local
        // cache, not necessarily the stored value).
        expect(invocations, 1);
        expect(result.committed, false);
        expect(result.snapshot.value, seenValue);

        // An aborted transaction must not touch the stored value.
        final snapshot = await ref.get();
        expect(snapshot.value, 'unchanged');
      });

      test(
        'rethrows an error thrown by the handler and does not commit',
        () async {
          final ref = _uniqueRef('transaction-handler-throws');
          await ref.set('unchanged');
          await ref.get();

          await expectLater(
            ref.runTransaction((value) => throw StateError('handler failed')),
            throwsA(isA<StateError>()),
          );

          final snapshot = await ref.get();
          expect(snapshot.value, 'unchanged');
        },
        // On web the handler runs inside a JS callback, so a Dart error thrown
        // from it does not come back as the original Dart error.
        skip: kIsWeb,
      );

      test('does not emit local transaction events when disabled', () async {
        final ref = _uniqueRef('transaction-apply-locally-false');
        await ref.set({'count': 0});

        final initialEvent = Completer<void>();
        final events = <Object?>[];
        final subscription = ref.onValue.listen((event) {
          if (!initialEvent.isCompleted) {
            initialEvent.complete();
            return;
          }

          events.add(event.snapshot.value);
        });

        try {
          await initialEvent.future.timeout(const Duration(seconds: 5));

          await ref.runTransaction(
            (value) => Transaction.success({
              'count': ((value as Map?)?['count'] as int? ?? 0) + 1,
              'timestamp': ServerValue.timestamp,
            }),
            applyLocally: false,
          );

          await Future<void>.delayed(const Duration(seconds: 1));

          expect(events, hasLength(1));
        } finally {
          await database.goOnline();
          await subscription.cancel();
        }
      });

      test('executes transaction', () async {
        final ref = database.ref('tests/transaction-exec');
        await ref.set(0);
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

        final transactionResult = await ref.runTransaction(Transaction.success);

        var value = transactionResult.snapshot.value as dynamic;
        expect(value, isNotNull);
        expect(value['list'], data);
      });

      test('Exception handling', () async {
        final FirebaseDatabase database = FirebaseDatabase.instance;
        final DatabaseReference ref = database.ref('permission-denied');
        final Completer<FirebaseException> errorReceived =
            Completer<FirebaseException>();
        await ref
            .runTransaction((value) => Transaction.success(1))
            .then((result) {
          // No-op
        }).catchError((e) {
          errorReceived.complete(e as FirebaseException);
        });

        // Fail the test rather than hang the suite if the error never arrives.
        final streamError =
            await errorReceived.future.timeout(const Duration(seconds: 30));
        expect(streamError, isA<FirebaseException>());
        if (defaultTargetPlatform == TargetPlatform.windows) {
          // The desktop C++ SDK replaces any non-`datastale` server error on a
          // *sent* transaction with `kErrorUnknownError` and an empty message
          // before the plugin can see it, so the real code cannot reach Dart on
          // this path: https://github.com/firebase/firebase-cpp-sdk/issues/1904
          // Plain writes are unaffected - see the `set()` test above, which
          // asserts `permission-denied` on every platform.
          expect(streamError.code, 'unknown');
        } else {
          expect(streamError.code, 'permission-denied');
        }
      });

      test(
        'Server.increment',
        () async {
          final DatabaseReference ref = _uniqueRef('server-increment');
          await ref.set(ServerValue.increment(1.5));

          final snap = await ref.get();
          var value = snap.value;
          expect(value, 1.5);

          await ref.set(ServerValue.increment(1));
          final snap2 = await ref.get();
          var value2 = snap2.value;
          expect(value2, 2.5);
        },
        // The desktop C++ SDK does not resolve `increment` server-value
        // sentinels, so the client reads back the raw `{'.sv': ...}` map.
        // Pre-existing gap, tracked separately.
        skip: defaultTargetPlatform == TargetPlatform.windows,
      );
    });
  });
}
