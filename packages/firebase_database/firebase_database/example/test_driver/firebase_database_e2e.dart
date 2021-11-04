// ignore_for_file: require_trailing_commas
import 'dart:io';

import 'package:drive/drive.dart' as drive;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'query_e2e.dart';

final List<Map<String, Object>> testDocuments = [
  {'ref': 'one', 'value': 23},
  {'ref': 'two', 'value': 56},
  {'ref': 'three', 'value': 9},
  {'ref': 'four', 'value': 40}
];

Future<void> setTestData() {
  final FirebaseDatabase database = FirebaseDatabase.instance;
  const String orderTestPath = 'ordered/';
  return Future.wait(testDocuments.map((map) {
    String child = map['ref']! as String;
    return database.reference().child('$orderTestPath/$child').set(map);
  }));
}

void testsMain() {
  group('FirebaseDatabase', () {
    // initialize the firebase
    setUp(() async {
      await Firebase.initializeApp();
    });

    // set up dummy data
    setUpAll(() async {
      await setTestData();
    });

    test('setPersistenceCacheSizeBytes Integer', () async {
      final FirebaseDatabase database = FirebaseDatabase.instance;

      await database.setPersistenceCacheSizeBytes(2147483647);
      // Skipped because it is not supported on web
    }, skip: kIsWeb);

    test('setPersistenceCacheSizeBytes Long', () async {
      final FirebaseDatabase database = FirebaseDatabase.instance;
      await database.setPersistenceCacheSizeBytes(2147483648);
      // Skipped because it is not supported on web
    }, skip: kIsWeb);

    test('setLoggingEnabled to true', () async {
      final FirebaseDatabase database = FirebaseDatabase.instance;
      await database.setLoggingEnabled(true);
      // Skipped because it needs to be initialized first on android.
    }, skip: !kIsWeb && Platform.isAndroid);

    test('setLoggingEnabled to false', () async {
      final FirebaseDatabase database = FirebaseDatabase.instance;
      await database.setLoggingEnabled(false);
      // Skipped because it needs to be initialized first on android.
    }, skip: !kIsWeb && Platform.isAndroid);

    group('runTransaction', () {
      test('update and check values', () async {
        final FirebaseDatabase database = FirebaseDatabase.instance;
        final DatabaseReference ref = database.reference().child('flutterfire');

        await ref.set(0);

        final DataSnapshot snapshot = await ref.once();
        final int value = snapshot.value ?? 0;
        final TransactionResult transactionResult =
            await ref.runTransaction((MutableData mutableData) {
          mutableData.value = (mutableData.value ?? 0) + 1;
          return mutableData;
        });

        expect(transactionResult.committed, true);
        expect(transactionResult.dataSnapshot!.value > value, true);
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

    test('DataSnapshot supports null childKeys for maps', () async {
      // Regression test for https://github.com/FirebaseExtended/flutterfire/issues/6002

      final ref = FirebaseDatabase.instance.reference().child('flutterfire');

      final transactionResult = await ref.runTransaction((mutableData) {
        mutableData.value = {'v': 'vala'};
        return mutableData;
      });

      expect(transactionResult.committed, true);
      expect(
        transactionResult.dataSnapshot!.value,
        {'v': 'vala'},
      );
    });

    runQueryTests();
  });
}

void main() => drive.main(testsMain);
