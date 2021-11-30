import 'dart:async';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
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
  final orderedRef = database.ref('tests/ordered');

  await Future.wait(
    testDocuments.map((map) {
      String key = map['ref']! as String;
      return orderedRef.child(key).set(map);
    }),
  );
}

Future<void> setupPriorityData() async {
  final priorityRef = database.ref('tests/priority');

  await Future.wait([
    priorityRef.child('first').setWithPriority(1, 10),
    priorityRef.child('second').setWithPriority(2, 1),
    priorityRef.child('third').setWithPriority(3, 5),
  ]);
}

void runQueryTests() {
  group('Query', () {
    setUp(() async {
      await database.ref('tests/flutterfire').set(0);

      await setupOrderedData();
      await setupPriorityData();
    });

    test('once()', () async {
      final event = await database.ref('tests/ordered/one').once();
      final snapshot = event.snapshot;
      expect(snapshot, isNot(null));
      expect(snapshot.key, 'one');
      expect((snapshot.value as dynamic)['ref'], 'one');
      expect((snapshot.value as dynamic)['value'], 23);
    });

    test(
      'once() throws "permission-denied" on a ref with no read permission',
      () async {
        await expectLater(
          database.ref('denied_read').once(),
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

    test('get()', () async {
      final snapshot = await database.ref('tests/ordered/two').get();
      expect(snapshot, isNot(null));
      expect(snapshot.key, 'two');
      expect((snapshot.value as dynamic)['ref'], 'two');
      expect((snapshot.value as dynamic)['value'], 56);
    });

    test(
      'throws "index-not-defined" on a ref with no index',
      () async {
        final ref = database.ref('tests/messages');
        try {
          await ref.orderByValue().get();
          throw Exception('should have thrown FirebaseDatabaseException');
        } on FirebaseException catch (e) {
          expect(e.code, 'index-not-defined');
          expect(
            e.message!.startsWith('Index not defined, add ".indexOn": '),
            true,
          );
        }
      },
    );

    test('orderByChild()', () async {
      final event =
          await database.ref('tests/ordered').orderByChild('value').once();
      final snapshot = event.snapshot;
      final keys = snapshot.children.map((child) => child.key).toList();
      expect(keys, ['three', 'one', 'four', 'two']);
    });

    test('orderByPriority()', () async {
      final ref = database.ref('tests/priority');

      final s = await ref.orderByPriority().get();
      expect(s.keys, ['second', 'third', 'first']);
    });

    test('orderByValue()', () async {
      final ref = database.ref('tests/priority');

      final event = await ref.orderByValue().once();
      final snapshot = event.snapshot;
      expect(snapshot.keys, ['first', 'second', 'third']);
    });

    test('limitToFirst()', () async {
      final event = await database.ref('tests/ordered').limitToFirst(2).once();
      final snapshot = event.snapshot;
      Map<dynamic, dynamic> data = snapshot.value as dynamic;
      expect(data.length, 2);

      final event2 = await database
          .ref('tests/ordered')
          .limitToFirst(testDocuments.length + 2)
          .once();
      final snapshot2 = event2.snapshot;
      Map<dynamic, dynamic> data1 = snapshot2.value as dynamic;
      expect(data1.length, testDocuments.length);
    });

    test('limitToLast()', () async {
      final event = await database.ref('tests/ordered').limitToLast(3).once();
      final snapshot = event.snapshot;
      Map<dynamic, dynamic> data = snapshot.value as dynamic;
      expect(data.length, 3);

      final event2 = await database
          .ref('tests/ordered')
          .limitToLast(testDocuments.length + 2)
          .once();
      final snapshot2 = event2.snapshot;
      Map<dynamic, dynamic> data1 = snapshot2.value as dynamic;
      expect(data1.length, testDocuments.length);
    });

    test('startAt() & endAt() once', () async {
      // query to get the data that has key starts with t only
      final event = await database
          .ref('tests/ordered')
          .orderByKey()
          .startAt('t')
          .endAt('t\uf8ff')
          .once();
      final snapshot = event.snapshot;
      Map<dynamic, dynamic> data = snapshot.value as dynamic;
      bool eachKeyStartsWithF = true;
      data.forEach((key, value) {
        if (!key.toString().startsWith('t')) {
          eachKeyStartsWithF = false;
        }
      });
      expect(eachKeyStartsWithF, true);
      // as there are two snaps that starts with t (two, three)
      expect(data.length, 2);

      final event2 = await database
          .ref('tests/ordered')
          .orderByKey()
          .startAt('t')
          .endAt('three')
          .once();
      final snapshot2 = event2.snapshot;
      Map<dynamic, dynamic> data2 = snapshot2.value as dynamic;
      // as the endAt is equal to 'three' and this will skip the data with key 'two'.
      expect(data2.length, 1);
    });

    // https://github.com/FirebaseExtended/flutterfire/issues/7221
    test(
      'startAt() & endAt() get',
      () async {
        final s = await database
            .ref('tests/ordered')
            .orderByChild('value')
            .startAt(9)
            .endAt(40)
            .get();

        final keys = Set.from((s.value as dynamic).keys);
        expect(keys.containsAll(['four', 'one', 'three']), true);
      },
      skip:
          true, // TODO Fails on CI even though works locally (Firebase Emulator issue)
    );

    test('endBefore()', () async {
      final ref = database.ref('tests/ordered');
      final snapshot = await ref.orderByKey().endBefore('two').get();

      expect(snapshot.keys, ['four', 'one', 'three']);
    });

    test('startAfter()', () async {
      final ref = database.ref('tests/priority');
      final snapshot = await ref.orderByKey().startAfter('first').get();
      final keys = snapshot.children.map((child) => child.key).toList();
      expect(keys, ['second', 'third']);
    });

    test('equalTo()', () async {
      final event = await database
          .ref('tests/ordered')
          .orderByKey()
          .equalTo('one')
          .once();
      final snapshot = event.snapshot;
      Map<dynamic, dynamic> data = snapshot.value as dynamic;

      expect(data.containsKey('one'), true);
      expect(data['one']['ref'], 'one');
      expect(data['one']['value'], 23);
    });
  });

  group('Query subscriptions', () {
    late final ref = database.ref('tests/priority');

    void verifyEventType(List<DatabaseEvent> events, DatabaseEventType type) {
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
      verifyEventType(events, DatabaseEventType.childAdded);

      final values = events.map((e) => e.snapshot.value).toList();
      final childKeys = events.map((e) => e.previousChildKey).toList();

      expect(values, [2, 3, 1]);
      expect(childKeys, [null, 'second', 'third']);
    });

    test('onChildChanged emits correct events', () async {
      final newValues = [
        Random.secure().nextInt(255),
        Random.secure().nextInt(255),
      ];

      final eventsFuture = ref.onChildChanged.take(2).toList();

      await ref.onValue.first;

      await ref.child('first').set(newValues[0]);
      await ref.child('second').set(newValues[1]);

      final events = await eventsFuture;

      verifyEventType(events, DatabaseEventType.childChanged);

      final values = events.map((e) => e.snapshot.value).toList();
      expect(values, newValues);
    });

    test('onValue emits correct events', () async {
      final newValues = [
        Random.secure().nextInt(255),
        Random.secure().nextInt(255),
      ];

      final eventsFuture = ref.onValue.take(2).toList();

      await ref.child('first').set(newValues[0]);
      await ref.child('second').set(newValues[1]);

      final events = await eventsFuture;

      verifyEventType(events, DatabaseEventType.value);

      expect((events[0].snapshot.value as dynamic)['first'], newValues[0]);
      expect((events[0].snapshot.value as dynamic)['second'], 2);
      expect((events[0].snapshot.value as dynamic)['third'], 3);

      expect((events[1].snapshot.value as dynamic)['first'], newValues[0]);
      expect((events[1].snapshot.value as dynamic)['second'], newValues[1]);
      expect((events[1].snapshot.value as dynamic)['third'], 3);
    });

    test('onChildMoved emits correct events', () async {
      final eventsFuture = ref.orderByPriority().onChildMoved.take(2).toList();

      await ref.onValue.first;

      await ref.child('second').setPriority(20);
      await ref.child('first').setPriority(0);

      final events = await eventsFuture;

      final keys = events.map((e) => e.snapshot.key).toList();
      final values = events.map((e) => e.snapshot.value).toList();
      final childKeys = events.map((e) => e.previousChildKey).toList();

      verifyEventType(events, DatabaseEventType.childMoved);

      expect(keys, ['second', 'first']);
      expect(values, [2, 1]);
      expect(childKeys, ['first', null]);
    });

    test('onChildRemoved emits correct events', () async {
      final eventsFuture =
          ref.orderByPriority().onChildRemoved.take(1).toList();

      await ref.onValue.first;

      await ref.child('third').remove();

      final events = await eventsFuture;
      final event = events.first;

      expect(event.type, DatabaseEventType.childRemoved);
      expect(event.snapshot.value, 3);
      expect(event.snapshot.key, 'third');
    });

    // https://github.com/FirebaseExtended/flutterfire/issues/7048
    test("sequential subscriptions don't override each other", () async {
      final result = await Future.wait([
        database.ref('tests/ordered').onChildAdded.take(4).toList(),
        database.ref('tests/ordered').onChildAdded.take(4).toList(),
      ]);

      final values0 =
          result[0].map((e) => (e.snapshot.value as dynamic)['value']).toList();
      final values1 =
          result[1].map((e) => (e.snapshot.value as dynamic)['value']).toList();

      expect(values0, values1);
    });
  });
}
