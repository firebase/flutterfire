import 'dart:async';

import 'package:collection/collection.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firebase_database_e2e.dart';

void runQueryTests() {
  group('Query', () {
    late DatabaseReference ref;

    setUp(() async {
      ref = FirebaseDatabase.instance.ref('tests');

      // Wipe the database before each test
      await ref.remove();
    });

    group('startAt', () {
      test('returns null when no order modifier is applied', () async {
        await ref.set({
          'a': 1,
          'b': 2,
          'c': 3,
        });

        final snapshot = await ref.startAt(2).get();
        expect(snapshot.value, isNull);
      });

      test('starts at the correct value', () async {
        await ref.set({
          'a': 1,
          'b': 2,
          'c': 3,
          'd': 4,
        });

        final snapshot = await ref.orderByValue().startAt(2).get();

        final expected = ['b', 'c', 'd'];

        expect(snapshot.children.length, expected.length);
        snapshot.children.toList().forEachIndexed((i, childSnapshot) {
          expect(childSnapshot.key, expected[i]);
        });
      });
    });

    group('startAfter', () {
      test('returns null when no order modifier is applied', () async {
        await ref.set({
          'a': 1,
          'b': 2,
          'c': 3,
        });

        final snapshot = await ref.startAfter(2).get();
        expect(snapshot.value, isNull);
      });

      test('starts after the correct value', () async {
        await ref.set({
          'a': 1,
          'b': 2,
          'c': 3,
          'd': 4,
        });

        final snapshot = await ref.orderByValue().startAfter(2).get();

        final expected = ['c', 'd'];

        expect(snapshot.children.length, expected.length);
        snapshot.children.toList().forEachIndexed((i, childSnapshot) {
          expect(childSnapshot.key, expected[i]);
        });
      });
    });

    group('endAt', () {
      test('returns all values when no order modifier is applied', () async {
        await ref.set({
          'a': 1,
          'b': 2,
          'c': 3,
        });

        final expected = ['a', 'b', 'c'];

        final snapshot = await ref.endAt(2).get();

        expect(snapshot.children.length, expected.length);
        snapshot.children.toList().forEachIndexed((i, childSnapshot) {
          expect(childSnapshot.key, expected[i]);
        });
      });

      test('ends at the correct value', () async {
        await ref.set({
          'a': 1,
          'b': 2,
          'c': 3,
          'd': 4,
        });

        final snapshot = await ref.orderByValue().endAt(2).get();

        final expected = ['a', 'b'];

        expect(snapshot.children.length, expected.length);
        snapshot.children.toList().forEachIndexed((i, childSnapshot) {
          expect(childSnapshot.key, expected[i]);
        });
      });
    });

    group('endBefore', () {
      test('returns all values when no order modifier is applied', () async {
        await ref.set({
          'a': 1,
          'b': 2,
          'c': 3,
        });

        final expected = ['a', 'b', 'c'];

        final snapshot = await ref.endBefore(2).get();

        expect(snapshot.children.length, expected.length);
        snapshot.children.toList().forEachIndexed((i, childSnapshot) {
          expect(childSnapshot.key, expected[i]);
        });
      });

      test('ends before the correct value', () async {
        await ref.set({
          'a': 1,
          'b': 2,
          'c': 3,
          'd': 4,
        });

        final snapshot = await ref.orderByValue().endBefore(2).get();

        final expected = ['a'];

        expect(snapshot.children.length, expected.length);
        snapshot.children.toList().forEachIndexed((i, childSnapshot) {
          expect(childSnapshot.key, expected[i]);
        });
      });
    });

    group('equalTo', () {
      test('returns null when no order modifier is applied', () async {
        await ref.set({
          'a': 1,
          'b': 2,
          'c': 3,
        });

        final snapshot = await ref.equalTo(2).get();
        expect(snapshot.value, isNull);
      });

      test('returns the correct value', () async {
        await ref.set({
          'a': 1,
          'b': 2,
          'c': 3,
          'd': 4,
          'e': 2,
        });

        final snapshot = await ref.orderByValue().equalTo(2).get();

        final expected = ['b', 'e'];

        expect(snapshot.children.length, expected.length);
        snapshot.children.toList().forEachIndexed((i, childSnapshot) {
          expect(childSnapshot.key, expected[i]);
        });
      });
    });

    group('limitToFirst', () {
      test('returns a limited array', () async {
        await ref.set({
          0: 'foo',
          1: 'bar',
          2: 'baz',
        });

        final snapshot = await ref.limitToFirst(2).get();

        final expected = ['foo', 'bar'];
        expect(snapshot.value, equals(expected));
      });

      test('returns a limited object', () async {
        await ref.set({
          'a': 'foo',
          'b': 'bar',
          'c': 'baz',
        });

        final snapshot = await ref.limitToFirst(2).get();

        final expected = {
          'a': 'foo',
          'b': 'bar',
        };

        expect(snapshot.value, equals(expected));
      });

      test('returns null when no limit is possible', () async {
        await ref.set('foo');

        final snapshot = await ref.limitToFirst(2).get();

        expect(snapshot.value, isNull);
      });
    });

    group('limitToLast', () {
      test('returns a limited array', () async {
        await ref.set({
          0: 'foo',
          1: 'bar',
          2: 'baz',
        });

        final snapshot = await ref.limitToLast(2).get();

        // TODO(ehesp): JS returns an empty/null value as the first element
        final expected = ['bar', 'baz'];
        expect(snapshot.value, equals(expected));
      });

      test('returns a limited object', () async {
        await ref.set({
          'a': 'foo',
          'b': 'bar',
          'c': 'baz',
        });

        final snapshot = await ref.limitToLast(2).get();

        final expected = {
          'b': 'bar',
          'c': 'baz',
        };

        expect(snapshot.value, equals(expected));
      });

      test('returns null when no limit is possible', () async {
        await ref.set('foo');

        final snapshot = await ref.limitToLast(2).get();

        expect(snapshot.value, isNull);
      });
    });

    group('orderByChild', () {
      test('orders by a child value', () async {
        await ref.set({
          'a': {
            'string': 'foo',
            'number': 10,
          },
          'b': {
            'string': 'bar',
            'number': 5,
          },
          'c': {
            'string': 'baz',
            'number': 8,
          },
        });

        final snapshot = await ref.orderByChild('number').get();

        final expected = ['b', 'c', 'a'];
        expect(snapshot.children.length, equals(expected));
        snapshot.children.toList().forEachIndexed((i, childSnapshot) {
          expect(childSnapshot.key, expected[i]);
        });
      });
    });

    group('orderByKey', () {
      test('orders by a key', () async {
        await ref.set({
          'b': {
            'string': 'bar',
            'number': 5,
          },
          'a': {
            'string': 'foo',
            'number': 10,
          },
          'c': {
            'string': 'baz',
            'number': 8,
          },
        });

        final snapshot = await ref.orderByKey().get();

        final expected = ['a', 'b', 'c'];

        expect(snapshot.children.length, expected.length);
        snapshot.children.toList().forEachIndexed((i, childSnapshot) {
          expect(childSnapshot.key, expected[i]);
        });
      });
    });

    group('orderByPriority', () {
      test('orders by priority', () async {
        await ref.set({
          'a': {
            'string': 'foo',
            'number': 10,
          },
          'b': {
            'string': 'bar',
            'number': 5,
          },
          'c': {
            'string': 'baz',
            'number': 8,
          },
        });

        await Future.wait([
          ref.child('a').setPriority(2),
          ref.child('b').setPriority(3),
          ref.child('c').setPriority(1),
        ]);

        final snapshot = await ref.orderByPriority().get();

        final expected = ['c', 'a', 'b'];
        expect(snapshot.children.length, equals(expected.length));
        snapshot.children.toList().forEachIndexed((i, childSnapshot) {
          expect(childSnapshot.key, expected[i]);
        });
      });
    });

    group('orderByValue', () {
      test('orders by a value', () async {
        await ref.set({
          'a': 2,
          'b': 3,
          'c': 1,
        });

        await Future.wait([
          ref.child('a').setPriority(2),
          ref.child('b').setPriority(3),
          ref.child('c').setPriority(1),
        ]);

        final snapshot = await ref.orderByValue().get();

        final expected = ['c', 'a', 'b'];
        expect(snapshot.children.length, equals(expected.length));
        snapshot.children.toList().forEachIndexed((i, childSnapshot) {
          expect(childSnapshot.key, expected[i]);
        });
      });
    });
  });

// group('Query', () {
//   setUp(() async {
//     await database.ref('tests/flutterfire').set(0);
//
//     await setupOrderedData();
//     await setupPriorityData();
//   });
//
//   test('once()', () async {
//     final event = await database.ref('tests/ordered/one').once();
//     final snapshot = event.snapshot;
//     expect(snapshot, isNot(null));
//     expect(snapshot.key, 'one');
//     expect((snapshot.value as dynamic)['ref'], 'one');
//     expect((snapshot.value as dynamic)['value'], 23);
//   });
//
//   test(
//     'once() throws "permission-denied" on a ref with no read permission',
//     () async {
//       await expectLater(
//         database.ref('denied_read').once(),
//         throwsA(
//           isA<FirebaseException>()
//               .having(
//                 (error) => error.code,
//                 'code',
//                 'permission-denied',
//               )
//               .having(
//                 (error) => error.message,
//                 'message',
//                 predicate(
//                   (String message) =>
//                       message.contains("doesn't have permission"),
//                 ),
//               ),
//         ),
//       );
//     },
//     skip: true, // TODO Fails on CI even though works locally
//   );
//
//   test('get()', () async {
//     final snapshot = await database.ref('tests/ordered/two').get();
//     expect(snapshot, isNot(null));
//     expect(snapshot.key, 'two');
//     expect((snapshot.value as dynamic)['ref'], 'two');
//     expect((snapshot.value as dynamic)['value'], 56);
//   });
//
//   test(
//     'throws "index-not-defined" on a ref with no index',
//     () async {
//       final ref = database.ref('tests/messages');
//       try {
//         await ref.orderByValue().get();
//         throw Exception('should have thrown FirebaseDatabaseException');
//       } on FirebaseException catch (e) {
//         expect(e.code, 'index-not-defined');
//         expect(
//           e.message!.startsWith('Index not defined, add ".indexOn": '),
//           true,
//         );
//       }
//     },
//   );
//
//   test('orderByChild()', () async {
//     final event =
//         await database.ref('tests/ordered').orderByChild('value').once();
//     final snapshot = event.snapshot;
//     final keys = snapshot.children.map((child) => child.key).toList();
//     expect(keys, ['three', 'one', 'four', 'two']);
//   });
//
//   test('orderByPriority()', () async {
//     final ref = database.ref('tests/priority');
//
//     final s = await ref.orderByPriority().get();
//     expect(s.keys, ['second', 'third', 'first']);
//   });
//
//   test('orderByValue()', () async {
//     final ref = database.ref('tests/priority');
//
//     final event = await ref.orderByValue().once();
//     final snapshot = event.snapshot;
//     expect(snapshot.keys, ['first', 'second', 'third']);
//   });
//
//   test('limitToFirst()', () async {
//     final event = await database.ref('tests/ordered').limitToFirst(2).once();
//     final snapshot = event.snapshot;
//     Map<dynamic, dynamic> data = snapshot.value as dynamic;
//     expect(data.length, 2);
//
//     final event2 = await database
//         .ref('tests/ordered')
//         .limitToFirst(testDocuments.length + 2)
//         .once();
//     final snapshot2 = event2.snapshot;
//     Map<dynamic, dynamic> data1 = snapshot2.value as dynamic;
//     expect(data1.length, testDocuments.length);
//   });
//
//   test('limitToLast()', () async {
//     final event = await database.ref('tests/ordered').limitToLast(3).once();
//     final snapshot = event.snapshot;
//     Map<dynamic, dynamic> data = snapshot.value as dynamic;
//     expect(data.length, 3);
//
//     final event2 = await database
//         .ref('tests/ordered')
//         .limitToLast(testDocuments.length + 2)
//         .once();
//     final snapshot2 = event2.snapshot;
//     Map<dynamic, dynamic> data1 = snapshot2.value as dynamic;
//     expect(data1.length, testDocuments.length);
//   });
//
//   test('startAt() & endAt() once', () async {
//     // query to get the data that has key starts with t only
//     final event = await database
//         .ref('tests/ordered')
//         .orderByKey()
//         .startAt('t')
//         .endAt('t\uf8ff')
//         .once();
//     final snapshot = event.snapshot;
//     Map<dynamic, dynamic> data = snapshot.value as dynamic;
//     bool eachKeyStartsWithF = true;
//     data.forEach((key, value) {
//       if (!key.toString().startsWith('t')) {
//         eachKeyStartsWithF = false;
//       }
//     });
//     expect(eachKeyStartsWithF, true);
//     // as there are two snaps that starts with t (two, three)
//     expect(data.length, 2);
//
//     final event2 = await database
//         .ref('tests/ordered')
//         .orderByKey()
//         .startAt('t')
//         .endAt('three')
//         .once();
//     final snapshot2 = event2.snapshot;
//     Map<dynamic, dynamic> data2 = snapshot2.value as dynamic;
//     // as the endAt is equal to 'three' and this will skip the data with key 'two'.
//     expect(data2.length, 1);
//   });
//
//   // https://github.com/FirebaseExtended/flutterfire/issues/7221
//   test(
//     'startAt() & endAt() get',
//     () async {
//       final s = await database
//           .ref('tests/ordered')
//           .orderByChild('value')
//           .startAt(9)
//           .endAt(40)
//           .get();
//
//       final keys = Set.from((s.value as dynamic).keys);
//       expect(keys.containsAll(['four', 'one', 'three']), true);
//     },
//     skip:
//         true, // TODO Fails on CI even though works locally (Firebase Emulator issue)
//   );
//
//   test('endBefore()', () async {
//     final ref = database.ref('tests/ordered');
//     final snapshot = await ref.orderByKey().endBefore('two').get();
//
//     expect(snapshot.keys, ['four', 'one', 'three']);
//   });
//
//   test('startAfter()', () async {
//     final ref = database.ref('tests/priority');
//     final snapshot = await ref.orderByKey().startAfter('first').get();
//     final keys = snapshot.children.map((child) => child.key).toList();
//     expect(keys, ['second', 'third']);
//   });
//
//   test('equalTo()', () async {
//     final event = await database
//         .ref('tests/ordered')
//         .orderByKey()
//         .equalTo('one')
//         .once();
//     final snapshot = event.snapshot;
//     Map<dynamic, dynamic> data = snapshot.value as dynamic;
//
//     expect(data.containsKey('one'), true);
//     expect(data['one']['ref'], 'one');
//     expect(data['one']['value'], 23);
//   });
// });
//
// group('Query subscriptions', () {
//   late final ref = database.ref('tests/priority');
//
//   void verifyEventType(List<DatabaseEvent> events, DatabaseEventType type) {
//     expect(
//       events.every((element) => element.type == type),
//       true,
//     );
//   }
//
//   setUp(() async {
//     await setupPriorityData();
//   });
//
//   test('onChildAdded emits correct events', () async {
//     final events = await ref.orderByPriority().onChildAdded.take(3).toList();
//     verifyEventType(events, DatabaseEventType.childAdded);
//
//     final values = events.map((e) => e.snapshot.value).toList();
//     final childKeys = events.map((e) => e.previousChildKey).toList();
//
//     expect(values, [2, 3, 1]);
//     expect(childKeys, [null, 'second', 'third']);
//   });
//
//   test('onChildChanged emits correct events', () async {
//     final newValues = [
//       Random.secure().nextInt(255),
//       Random.secure().nextInt(255),
//     ];
//
//     final eventsFuture = ref.onChildChanged.take(2).toList();
//
//     await ref.onValue.first;
//
//     await ref.child('first').set(newValues[0]);
//     await ref.child('second').set(newValues[1]);
//
//     final events = await eventsFuture;
//
//     verifyEventType(events, DatabaseEventType.childChanged);
//
//     final values = events.map((e) => e.snapshot.value).toList();
//     expect(values, newValues);
//   });
//
//   test('onValue emits correct events', () async {
//     final newValues = [
//       Random.secure().nextInt(255),
//       Random.secure().nextInt(255),
//     ];
//
//     final eventsFuture = ref.onValue.take(2).toList();
//
//     await ref.child('first').set(newValues[0]);
//     await ref.child('second').set(newValues[1]);
//
//     final events = await eventsFuture;
//
//     verifyEventType(events, DatabaseEventType.value);
//
//     expect((events[0].snapshot.value as dynamic)['first'], newValues[0]);
//     expect((events[0].snapshot.value as dynamic)['second'], 2);
//     expect((events[0].snapshot.value as dynamic)['third'], 3);
//
//     expect((events[1].snapshot.value as dynamic)['first'], newValues[0]);
//     expect((events[1].snapshot.value as dynamic)['second'], newValues[1]);
//     expect((events[1].snapshot.value as dynamic)['third'], 3);
//   });
//
//   test('onChildMoved emits correct events', () async {
//     final eventsFuture = ref.orderByPriority().onChildMoved.take(2).toList();
//
//     await ref.onValue.first;
//
//     await ref.child('second').setPriority(20);
//     await ref.child('first').setPriority(0);
//
//     final events = await eventsFuture;
//
//     final keys = events.map((e) => e.snapshot.key).toList();
//     final values = events.map((e) => e.snapshot.value).toList();
//     final childKeys = events.map((e) => e.previousChildKey).toList();
//
//     verifyEventType(events, DatabaseEventType.childMoved);
//
//     expect(keys, ['second', 'first']);
//     expect(values, [2, 1]);
//     expect(childKeys, ['first', null]);
//   });
//
//   test('onChildRemoved emits correct events', () async {
//     final eventsFuture =
//         ref.orderByPriority().onChildRemoved.take(1).toList();
//
//     await ref.onValue.first;
//
//     await ref.child('third').remove();
//
//     final events = await eventsFuture;
//     final event = events.first;
//
//     expect(event.type, DatabaseEventType.childRemoved);
//     expect(event.snapshot.value, 3);
//     expect(event.snapshot.key, 'third');
//   });
//
//   // https://github.com/FirebaseExtended/flutterfire/issues/7048
//   test("sequential subscriptions don't override each other", () async {
//     final result = await Future.wait([
//       database.ref('tests/ordered').onChildAdded.take(4).toList(),
//       database.ref('tests/ordered').onChildAdded.take(4).toList(),
//     ]);
//
//     final values0 =
//         result[0].map((e) => (e.snapshot.value as dynamic)['value']).toList();
//     final values1 =
//         result[1].map((e) => (e.snapshot.value as dynamic)['value']).toList();
//
//     expect(values0, values1);
//   });
// });
}
