// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:collection/collection.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';

void setupQueryTests() {
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

      test(
        'streams respect orderByChild with numeric startAt',
        () async {
          await ref.set({
            't1': {'timestamp': 1, 'value': 'old'},
            't2': {'timestamp': 1000, 'value': 'current'},
          });

          final events = await ref
              .orderByChild('timestamp')
              .startAt(1000)
              .onChildAdded
              .take(1)
              .toList();

          expect(events.single.snapshot.key, 't2');
          expect(events.single.snapshot.child('value').value, 'current');
        },
      );

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

        // TODO(ehesp): Using `get` returns the wrong results. Have flagged with SDK team.
        final e = await ref.orderByValue().startAfter(2).once();

        final expected = ['c', 'd'];

        expect(e.snapshot.children.length, expected.length);
        e.snapshot.children.toList().forEachIndexed((i, childSnapshot) {
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

      test('streams emit limited maps', () async {
        await ref.set({
          'a': 'foo',
          'b': 'bar',
          'c': 'baz',
        });

        final event = await ref.orderByKey().limitToFirst(2).onValue.first;

        expect(
          event.snapshot.value,
          equals({
            'a': 'foo',
            'b': 'bar',
          }),
        );
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

        final expected = [null, 'bar', 'baz'];
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

      test('streams emit limited maps', () async {
        await ref.set({
          'a': 'foo',
          'b': 'bar',
          'c': 'baz',
        });

        final event = await ref.orderByKey().limitToLast(2).onValue.first;

        expect(
          event.snapshot.value,
          equals({
            'b': 'bar',
            'c': 'baz',
          }),
        );
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
        expect(snapshot.children.length, equals(expected.length));
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

    group('onChildAdded', () {
      test(
        'emits an event when a child is added',
        () async {
          expect(
            ref.onChildAdded,
            emitsInOrder([
              isA<DatabaseEvent>()
                  .having((s) => s.snapshot.value, 'value', 'foo')
                  .having((e) => e.type, 'type', DatabaseEventType.childAdded),
              isA<DatabaseEvent>()
                  .having((s) => s.snapshot.value, 'value', 'bar')
                  .having((e) => e.type, 'type', DatabaseEventType.childAdded),
            ]),
          );

          await ref.child('foo').set('foo');
          await ref.child('bar').set('bar');
        },
        retry: 2,
      );
    });

    group('onChildRemoved', () {
      test(
        'emits an event when a child is removed',
        () async {
          await ref.child('foo').set('foo');
          await ref.child('bar').set('bar');

          expect(
            ref.onChildRemoved,
            emitsInOrder([
              isA<DatabaseEvent>()
                  .having((s) => s.snapshot.value, 'value', 'bar')
                  .having(
                    (e) => e.type,
                    'type',
                    DatabaseEventType.childRemoved,
                  ),
            ]),
          );
          // Give time for listen to be registered on native.
          // TODO is there a better way to do this?
          await Future.delayed(const Duration(seconds: 1));
          await ref.child('bar').remove();
        },
        retry: 2,
      );
    });

    group('onChildChanged', () {
      // Create own reference as this clashed with previous tests on web platform
      late DatabaseReference childRef;
      setUp(() async {
        childRef = FirebaseDatabase.instance.ref('tests').child('child-ref');
        // Wipe the database before each test
        await childRef.remove();
      });

      test(
        'emits an event when a child is changed',
        () async {
          await childRef.child('foo').set('foo');
          await childRef.child('bar').set('bar');

          expect(
            childRef.onChildChanged,
            emitsInOrder([
              isA<DatabaseEvent>()
                  .having((s) => s.snapshot.key, 'key', 'bar')
                  .having((s) => s.snapshot.value, 'value', 'baz')
                  .having(
                    (e) => e.type,
                    'type',
                    DatabaseEventType.childChanged,
                  ),
              isA<DatabaseEvent>()
                  .having((s) => s.snapshot.key, 'key', 'foo')
                  .having((s) => s.snapshot.value, 'value', 'bar')
                  .having(
                    (e) => e.type,
                    'type',
                    DatabaseEventType.childChanged,
                  ),
            ]),
          );
          // Give time for listen to be registered on native.
          // TODO is there a better way to do this?
          await Future.delayed(const Duration(seconds: 1));
          await childRef.child('bar').set('baz');
          await childRef.child('foo').set('bar');
        },
        retry: 2,
      );
    });

    group('onChildMoved', () {
      test(
        'emits an event when a child is moved',
        () async {
          await ref.set({
            'alex': {'nuggets': 60},
            'rob': {'nuggets': 56},
            'vassili': {'nuggets': 55.5},
            'tony': {'nuggets': 52},
            'greg': {'nuggets': 52},
          });

          expect(
            ref.orderByChild('nuggets').onChildMoved,
            emitsInOrder([
              isA<DatabaseEvent>().having((s) => s.snapshot.value, 'value', {
                'nuggets': 57,
              }).having((e) => e.type, 'type', DatabaseEventType.childMoved),
              isA<DatabaseEvent>().having((s) => s.snapshot.value, 'value', {
                'nuggets': 61,
              }).having((e) => e.type, 'type', DatabaseEventType.childMoved),
            ]),
          );
          // Give time for listen to be registered on native.
          // TODO is there a better way to do this?
          await Future.delayed(const Duration(seconds: 1));
          await ref.child('greg/nuggets').set(57);
          await ref.child('rob/nuggets').set(61);
        },
        retry: 2,
      );
    });

    group('onValue', () {
      test('emits an event when the data changes', () async {
        await ref.set({
          'a': 2,
          'b': 3,
          'c': 1,
        });
        expect(
          ref.onValue,
          emitsInOrder([
            isA<DatabaseEvent>().having((s) => s.snapshot.value, 'value', {
              'a': 2,
              'b': 3,
              'c': 1,
            }).having((e) => e.type, 'type', DatabaseEventType.value),
          ]),
        );
      });

      test(
          'throw a `permission-denied` exception when accessing restricted data',
          () async {
        final Completer<FirebaseException> errorReceived =
            Completer<FirebaseException>();
        FirebaseDatabase.instance.ref().child('restricted').onValue.listen(
          (event) {
            // Do nothing
          },
          onError: (error) {
            errorReceived.complete(error);
          },
        );

        final streamError = await errorReceived.future;
        expect(streamError, isA<FirebaseException>());
        expect(streamError.code, 'permission-denied');
      });
    });
  });
}
