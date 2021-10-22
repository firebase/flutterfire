import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firebase_database_e2e.dart';

Future<void> setupPrioritiesTestData() async {
  await database
      .ref('priority_test')
      .set({'first': 1, 'second': 2, 'third': 3});
}

void runDatabaseReferenceTests() {
  late DatabaseReference ref;

  setUp(() async {
    ref = database.ref('flutterfire');
  });

  group('DatabaseReference.runTransaction', () {
    setUp(() async {
      await ref.set(0);
    });

    test('executes transaction', () async {
      final snapshot = await ref.get();

      final value = snapshot.value ?? 0;

      final result = await ref.runTransaction((value) {
        return (value as int? ?? 0) + 1;
      });

      expect(result.committed, true);
      expect(result.dataSnapshot!.value > value, true);
    });

    test(
      'throws exception if transaction timed out',
      () async {
        const timeout = Duration(milliseconds: 1);
        try {
          await ref.runTransaction(
            (value) {
              final now = DateTime.now();
              while (DateTime.now().difference(now) < timeout) {}

              return (value ?? 0) + 1;
            },
            timeout: timeout,
          );

          throw Exception('should timeout');
        } catch (e) {
          expect(e, isA<FirebaseDatabaseException>());

          final dbException = e as FirebaseDatabaseException;
          expect(dbException.code, 'transaction-timeout');
        }
      },
      skip: kIsWeb,
    );

    test('get primitive list values', () async {
      List<String> data = ['first', 'second'];
      final FirebaseDatabase database = FirebaseDatabase.instance;
      final DatabaseReference ref = database.ref('list-values');

      await ref.set({'list': data});

      final transactionResult = await ref.runTransaction((mutableData) {
        return mutableData;
      });

      expect(transactionResult.dataSnapshot!.value['list'], data);
    });
  });

  group('DatabaseReference.set(value, [priority])', () {
    test('sets value', () async {
      final v = Random.secure().nextInt(1024);
      await ref.set(v);
      final actual = await ref.get();

      expect(v, actual.value);
    });

    test('sets value with priority', () async {
      final ref = database.ref('priority_test');

      await Future.wait([
        ref.child('first').set(1, priority: 10),
        ref.child('second').set(2, priority: 1),
        ref.child('third').set(3, priority: 5),
      ]);

      final v = await ref.get();
      final keys = List<String>.from(v.value.keys);

      expect(keys, ['second', 'third', 'first']);
    });
  });

  group('DatabaseReference.update(newvValue)', () {
    setUp(setupPrioritiesTestData);

    test('updates value at given location', () async {
      final ref = database.ref('priority_test');

      final newValue = Random.secure().nextInt(255) + 1;
      await ref.update({'first': newValue});
      final actual = await ref.child('first').get();

      expect(actual.value, newValue);
    });

    test(
      "doesn't remove values that weren't present in the update map",
      () async {
        final ref = database.ref('priority_test');

        final newValue = Random.secure().nextInt(255);
        await ref.update({'first': newValue});

        final snapshot = await ref.get();
        expect(snapshot.value['first'], newValue);
        expect(snapshot.value['second'], 2);
        expect(snapshot.value['third'], 3);
      },
    );
  });

  group('DatabaseRefrence.setPriority(newPriority)', () {
    setUp(setupPrioritiesTestData);

    test('updates the priority of the node', () async {
      final ref = database.ref('priority_test');
      final snapshot = await ref.get();
      final currentOrder = List<String>.from(snapshot.value.keys);

      for (int i = 0; i < currentOrder.length; i++) {
        final key = currentOrder[currentOrder.length - 1 - i];
        await ref.child(key).setPriority(i);
      }

      final newSnapshot = await ref.get();
      final newOrder = List<String>.from(newSnapshot.value.keys);

      expect(newOrder, currentOrder.reversed.toList());
    });
  });
}
