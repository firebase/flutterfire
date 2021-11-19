import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
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

    test('aborts a transaction', () async {
      await ref.set(5);
      final snapshot = await ref.get();
      expect(snapshot.value, 5);

      final result = await ref.runTransaction((value) {
        final nextValue = (value as int? ?? 0) + 1;
        if (nextValue > 5) {
          throw AbortTransactionException();
        }
        return nextValue;
      });

      expect(result.committed, false);
      expect(result.snapshot.value, 5);
    });

    test('executes transaction', () async {
      final snapshot = await ref.get();
      final value = (snapshot.value ?? 0) as int;
      final result = await ref.runTransaction((value) {
        return (value as int? ?? 0) + 1;
      });

      expect(result.committed, true);
      expect((result.snapshot.value ?? 0) as int > value, true);
      expect(result.snapshot.key, ref.key);
    });

    test('get primitive list values', () async {
      List<String> data = ['first', 'second'];
      final FirebaseDatabase database = FirebaseDatabase.instance;
      final DatabaseReference ref = database.ref('list-values');

      await ref.set({'list': data});

      final transactionResult = await ref.runTransaction((mutableData) {
        return mutableData;
      });

      var value = transactionResult.snapshot.value as dynamic;
      expect(value, isNotNull);
      expect(value['list'], data);
    });
  });

  group('DatabaseReference.set()', () {
    test('sets value', () async {
      final v = Random.secure().nextInt(1024);
      await ref.set(v);
      final actual = await ref.get();
      expect(actual.value, v);
    });

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

  group('DatabaseReference.setWithPriority()', () {
    test('sets a non-null value with a non-null priority', () async {
      final ref = database.ref('priority_test');

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

  group('DatabaseReference.update(newValue)', () {
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
        expect((snapshot.value as dynamic)['first'], newValue);
        expect((snapshot.value as dynamic)['second'], 2);
        expect((snapshot.value as dynamic)['third'], 3);
      },
    );
  });

  group('DatabaseReference.setPriority(newPriority)', () {
    setUp(setupPrioritiesTestData);

    test('updates the priority of a node', () async {
      final ref = database.ref('priority_test');
      // Confirm initial priority is null.
      await ref.setPriority(null);
      final snapshotNullPriority = await ref.get();
      expect(snapshotNullPriority.priority, isNull);
      // Confirm priority is set.
      await ref.setPriority(123);
      final snapshotWithPriority = await ref.get();
      expect(snapshotWithPriority.priority, isNotNull);
      expect(snapshotWithPriority.priority, 123);
    });

    test('clears the priority of the node if set to null', () async {
      final ref = database.ref('priority_test');
      // Confirm priority is initially set.
      await ref.setPriority(123);
      final snapshotWithPriority = await ref.get();
      expect(snapshotWithPriority.priority, isNotNull);
      expect(snapshotWithPriority.priority, 123);
      // Confirm priority is updated to null.
      await ref.setPriority(null);
      final snapshotNullPriority = await ref.get();
      expect(snapshotNullPriority.priority, isNull);
    });
  });
}
