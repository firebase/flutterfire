import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firebase_database_e2e.dart';
import 'utils/extensions.dart';

final List<Map<String, Object>> testDocuments = [
  {'ref': 'one', 'value': 23},
  {'ref': 'two', 'value': 56},
  {'ref': 'three', 'value': 9},
  {'ref': 'four', 'value': 40}
];

Future<void> setupOrderedData() async {
  final orderedRef = database.ref('ordered');

  await Future.wait(
    testDocuments.map((map) {
      String key = map['ref']! as String;
      return orderedRef.child(key).set(map);
    }),
  );
}

Future<void> setupPriorityData() async {
  final priorityRef = database.ref('priority_test');

  await Future.wait([
    priorityRef.child('first').set(1, priority: 10),
    priorityRef.child('second').set(2, priority: 1),
    priorityRef.child('third').set(3, priority: 5),
  ]);
}

void runQueryTests() {
  group('Query', () {
    setUp(() async {
      await database.ref('flutterfire').set(0);

      await setupOrderedData();
      await setupPriorityData();
    });

    test('once()', () async {
      final dataSnapshot = await database.ref('ordered/one').once();
      expect(dataSnapshot, isNot(null));
      expect(dataSnapshot.key, 'one');
      expect(dataSnapshot.value['ref'], 'one');
      expect(dataSnapshot.value['value'], 23);
    });

    test('get()', () async {
      final dataSnapshot = await database.ref('ordered/two').get();
      expect(dataSnapshot, isNot(null));
      expect(dataSnapshot.key, 'two');
      expect(dataSnapshot.value['ref'], 'two');
      expect(dataSnapshot.value['value'], 56);
    });

    test(
      'throws "index-not-defined" if oredering applied to a ref with no index',
      () async {
        final ref = database.ref('messages');
        try {
          await ref.orderByValue().get();
          throw Exception('should have thrown FirebaseDatabaseException');
        } on FirebaseDatabaseException catch (e) {
          expect(e.code, 'index-not-defined');
          expect(
            e.message!.startsWith('Index not defined, add ".indexOn": '),
            true,
          );
        }
      },
    );

    test('orderByChild()', () async {
      final s = await database.ref('ordered').orderByChild('value').once();

      expect(s.keys, ['three', 'one', 'four', 'two']);
    });

    test('orderByPriority()', () async {
      final ref = database.ref('priority_test');

      final s = await ref.orderByPriority().get();
      expect(s.keys, ['second', 'third', 'first']);
    });

    test('orderByValue()', () async {
      final ref = database.ref('priority_test');

      final s = await ref.orderByValue().once();
      expect(s.keys, ['first', 'second', 'third']);
    });

    test('limitToFirst()', () async {
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

    test('limitToLast()', () async {
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

    test('startAt() & endAt() once', () async {
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

    // https://github.com/FirebaseExtended/flutterfire/issues/7221
    test('startAt() & endAt() get', () async {
      final s = await database
          .ref('ordered')
          .orderByChild('value')
          .startAt(9)
          .endAt(40)
          .get();

      final keys = Set.from(s.value.keys);
      expect(keys.containsAll(['four', 'one', 'three']), true);
    });

    test('endBefore()', () async {
      final ref = database.ref('ordered');
      final snapshot = await ref.orderByKey().endBefore('two').get();

      expect(snapshot.keys, ['four', 'one', 'three']);
    });

    test('startAfter()', () async {
      final ref = database.ref('priority_test');
      final snapshot = await ref.orderByKey().startAfter('first').get();

      final keys = List<String>.from(snapshot.value.keys);

      expect(keys, ['second', 'third']);
    });

    test('equalTo()', () async {
      final snapshot =
          await database.ref('ordered').orderByKey().equalTo('one').once();

      Map<dynamic, dynamic> data = snapshot.value;

      expect(data.containsKey('one'), true);
      expect(data['one']['ref'], 'one');
      expect(data['one']['value'], 23);
    });
  });

  group('Query subscriptions', () {
    late final ref = database.ref('priority_test');

    void verifyEventType(List<Event> events, EventType type) {
      expect(
        events.every((element) => element.type == type),
        true,
      );
    }

    setUp(() async {
      await setupPriorityData();
    });

    test('onChildAdded emits correct events', () async {
      final events = await ref.orderByPriority().onChildAdded.take(3).toList();
      verifyEventType(events, EventType.childAdded);

      final values = events.map((e) => e.snapshot.value).toList();
      final siblingKeys = events.map((e) => e.previousSiblingKey).toList();

      expect(values, [2, 3, 1]);
      expect(siblingKeys, [null, 'second', 'third']);
    });

    test('onChildChanged emits correct events', () async {
      final newValues = [
        Random.secure().nextInt(255),
        Random.secure().nextInt(255),
      ];

      final eventsFuture = ref.onChildChanged.take(2).toList();

      await Future.delayed(const Duration(milliseconds: 300));

      await ref.child('first').set(newValues[0]);
      await ref.child('second').set(newValues[1]);

      final events = await eventsFuture;

      verifyEventType(events, EventType.childChanged);

      final values = events.map((e) => e.snapshot.value).toList();
      expect(values, newValues);
    });

    test('onValue emits correct events', () async {
      final newValues = [
        Random.secure().nextInt(255),
        Random.secure().nextInt(255),
      ];

      final eventsFuture = ref.onValue.take(3).toList();

      await Future.delayed(const Duration(milliseconds: 300));

      await ref.child('first').set(newValues[0]);
      await ref.child('second').set(newValues[1]);

      final events = await eventsFuture;

      verifyEventType(events, EventType.value);

      expect(events[0].snapshot.keys, ['second', 'third', 'first']);

      expect(events[0].snapshot.value['first'], 1);
      expect(events[0].snapshot.value['second'], 2);
      expect(events[0].snapshot.value['third'], 3);

      expect(events[1].snapshot.keys, ['first', 'second', 'third']);

      expect(events[1].snapshot.value['first'], newValues[0]);
      expect(events[1].snapshot.value['second'], 2);
      expect(events[1].snapshot.value['third'], 3);

      expect(events[2].snapshot.keys, ['first', 'second', 'third']);

      expect(events[2].snapshot.value['first'], newValues[0]);
      expect(events[2].snapshot.value['second'], newValues[1]);
      expect(events[2].snapshot.value['third'], 3);
    });

    test('onChildMoved emits correct events', () async {
      final eventsFuture = ref.orderByPriority().onChildMoved.take(2).toList();

      await Future.delayed(const Duration(milliseconds: 300));

      await ref.child('second').setPriority(20);
      await ref.child('first').setPriority(0);

      final events = await eventsFuture;

      final keys = events.map((e) => e.snapshot.key).toList();
      final values = events.map((e) => e.snapshot.value).toList();
      final siblingKeys = events.map((e) => e.previousSiblingKey).toList();

      verifyEventType(events, EventType.childMoved);

      expect(keys, ['second', 'first']);
      expect(values, [2, 1]);
      expect(siblingKeys, ['first', null]);
    });

    test('onChildRemoved emits correct events', () async {
      final eventsFuture =
          ref.orderByPriority().onChildRemoved.take(1).toList();

      await Future.delayed(const Duration(milliseconds: 300));

      await ref.child('first').remove();

      final events = await eventsFuture;
      final event = events.first;

      expect(event.type, EventType.childRemoved);
      expect(event.snapshot.value, 1);
      expect(event.snapshot.key, 'first');
    });
  });
}
