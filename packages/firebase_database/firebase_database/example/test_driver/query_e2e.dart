// ignore_for_file: require_trailing_commas

import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firebase_database_e2e.dart';

void runQueryTests() {
  group('$Query', () {
    test('once', () async {
      final dataSnapshot = await database.ref('ordered/one').once();
      expect(dataSnapshot, isNot(null));
      expect(dataSnapshot.key, 'one');
      expect(dataSnapshot.value['ref'], 'one');
      expect(dataSnapshot.value['value'], 23);
    });

    test('get', () async {
      final dataSnapshot = await database.ref('ordered/two').get();
      expect(dataSnapshot, isNot(null));
      expect(dataSnapshot.key, 'two');
      expect(dataSnapshot.value['ref'], 'two');
      expect(dataSnapshot.value['value'], 56);
    });

    test('DataSnapshot.exists is false for no data', () async {
      final databaseRef = database.ref('a-non-existing-reference');
      final dataSnapshot = await databaseRef.get();
      expect(dataSnapshot.exists, false);
    });

    test('DataSnapshot.exists is true for existing data', () async {
      final databaseRef = database.ref('ordered/one');
      final dataSnapshot = await databaseRef.get();
      expect(dataSnapshot.exists, true);
    });

    test('correct order returned from query', () async {
      final c = Completer<List<Map<String, dynamic>>>();
      final items = <Map<String, dynamic>>[];

      // ignore: unawaited_futures
      database
          .ref('ordered')
          .orderByChild('value')
          .onChildAdded
          .forEach((element) {
        items.add(element.snapshot.value.cast<String, dynamic>());
        if (items.length == testDocuments.length) c.complete(items);
      });

      final snapshots = await c.future;

      final documents = snapshots.map((v) => v['value'] as int).toList();
      final ordered = testDocuments.map((doc) => doc['value']).toList()..sort();

      expect(documents[0], ordered[0]);
      expect(documents[1], ordered[1]);
      expect(documents[2], ordered[2]);
      expect(documents[3], ordered[3]);
    });

    test('limitToFirst', () async {
      final snapshot = await database.ref('ordered').limitToFirst(2).once();
      Map<dynamic, dynamic> data = snapshot.value;
      expect(data.length, 2);

      final snapshot1 = await database
          .ref('ordered')
          .limitToFirst(testDocuments.length + 2)
          .once();
      Map<dynamic, dynamic> data1 = snapshot1.value;
      expect(data1.length, testDocuments.length);
    });

    test('limitToLast', () async {
      final snapshot = await database.ref('ordered').limitToLast(3).once();
      Map<dynamic, dynamic> data = snapshot.value;
      expect(data.length, 3);

      final snapshot1 = await database
          .ref('ordered')
          .limitToLast(testDocuments.length + 2)
          .once();
      Map<dynamic, dynamic> data1 = snapshot1.value;
      expect(data1.length, testDocuments.length);
    });

    test('startAt & endAt', () async {
      // query to get the data that has key starts with t only
      final snapshot = await database
          .ref('ordered')
          .orderByKey()
          .startAt('t')
          .endAt('t\uf8ff')
          .once();
      Map<dynamic, dynamic> data = snapshot.value;
      bool eachKeyStartsWithF = true;
      data.forEach((key, value) {
        if (!key.toString().startsWith('t')) {
          eachKeyStartsWithF = false;
        }
      });
      expect(eachKeyStartsWithF, true);
      // as there are two snaps that starts with t (two, three)
      expect(data.length, 2);

      final snapshot1 = await database
          .ref('ordered')
          .orderByKey()
          .startAt('t')
          .endAt('three')
          .once();
      Map<dynamic, dynamic> data1 = snapshot1.value;
      // as the endAt is equal to 'three' and this will skip the data with key 'two'.
      expect(data1.length, 1);
    });

    test('equalTo', () async {
      final snapshot =
          await database.ref('ordered').orderByKey().equalTo('one').once();

      Map<dynamic, dynamic> data = snapshot.value;

      expect(data.containsKey('one'), true);
      expect(data['one']['ref'], 'one');
      expect(data['one']['value'], 23);
    });
  });
}
