import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firebase_database_e2e.dart';

void runDatabaseReferenceTests() {
  late DatabaseReference ref;

  setUp(() async {
    ref = database.ref('flutterfire');
  });

  group('DatabaseReference.runTransaction', () {
    test('executes transaction', () async {
      final snapshot = await ref.get();

      final value = snapshot.value ?? 0;

      final result = await ref.runTransaction((MutableData mutableData) {
        mutableData.value = (mutableData.value ?? 0) + 1;
        return mutableData;
      });

      expect(result.committed, true);
      expect(result.dataSnapshot!.value > value, true);
    });

    test('throws exception if transaction timed out', () async {
      const timeout = Duration(milliseconds: 1);
      try {
        await ref.runTransaction(
          (mutableData) {
            final now = DateTime.now();
            while (DateTime.now().difference(now) < timeout) {}

            mutableData.value = (mutableData.value ?? 0) + 1;
            return mutableData;
          },
          timeout: timeout,
        );

        throw Exception('should timeout');
      } catch (e) {
        expect(e, isA<FirebaseDatabaseException>());

        final dbException = e as FirebaseDatabaseException;
        expect(dbException.code, 'transaction-timeout');
      }
    });

    test('get primitive list values', () async {
      List<String> data = ['first', 'second'];
      final FirebaseDatabase database = FirebaseDatabase.instance;
      final DatabaseReference ref = database.reference().child('list-values');

      await ref.set({'list': data});

      final transactionResult = await ref.runTransaction((mutableData) {
        return mutableData;
      });

      expect(transactionResult.dataSnapshot!.value['list'], data);
    });
  });

  group('DatabaseReference.set', () {
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
}
