// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';

void setupDataSnapshotTests() {
  group('DataSnapshot', () {
    late DatabaseReference ref;

    setUp(() async {
      ref = FirebaseDatabase.instance.ref('tests');

      // Wipe the database before each test
      await ref.remove();
    });

    test('it returns the correct key', () async {
      final s = await ref.get();
      expect(s.key, 'tests');
    });

    test('it returns a string value', () async {
      await ref.set('foo');
      final s = await ref.get();
      expect(s.value, 'foo');
    });

    test('it returns a number value', () async {
      await ref.set(123);
      final s = await ref.get();
      expect(s.value, 123);
    });

    test('it returns a bool value', () async {
      await ref.set(false);
      final s = await ref.get();
      expect(s.value, false);
    });

    test('it returns a null value', () async {
      await ref.set(null);
      final s = await ref.get();
      expect(s.value, isNull);
    });

    test('it returns a List value', () async {
      final data = [
        'a',
        2,
        true,
        ['foo'],
        {
          0: 'hello',
          1: 'foo',
        }
      ];
      await ref.set(data);
      final s = await ref.get();
      expect(
        s.value,
        equals([
          'a',
          2,
          true,
          ['foo'],
          ['hello', 'foo']
        ]),
      );
    });

    test('it returns a Map value', () async {
      final data = {'foo': 'bar'};
      await ref.set(data);
      final s = await ref.get();
      expect(s.value, equals(data));
    });

    test('non-string Map keys are converted to strings', () async {
      final data = {1: 'foo', 2: 'bar', 'foo': 'bar'};
      await ref.set(data);
      final s = await ref.get();
      expect(s.value, equals({'1': 'foo', '2': 'bar', 'foo': 'bar'}));
    });

    test('setWithPriority returns the correct priority', () async {
      await ref.setWithPriority('foo', 1);
      final s = await ref.get();
      expect(s.priority, 1);
    });

    test('setPriority returns the correct priority', () async {
      await ref.set('foo');
      await ref.setPriority(2);
      final s = await ref.get();
      expect(s.priority, 2);
    });

    test('exists returns true', () async {
      await ref.set('foo');
      final s = await ref.get();
      expect(s.exists, isTrue);
    });

    test('exists returns false', () async {
      final s = await ref.get();
      expect(s.exists, isFalse);
    });

    test('hasChild returns false', () async {
      final s = await ref.get();
      expect(s.hasChild('bar'), isFalse);
    });

    test('hasChild returns true', () async {
      await ref.set({
        'foo': {'bar': 'baz'}
      });
      final s = await ref.get();
      expect(s.hasChild('bar'), isFalse);
    });

    test('child returns the correct snapshot for lists', () async {
      await ref.set([0, 1]);
      final s = await ref.get();
      expect(s.child('1'), isA<DataSnapshot>());
      expect(s.child('1').value, 1);
    });

    test('child returns the correct snapshot', () async {
      await ref.set({
        'foo': {'bar': 'baz'}
      });
      final s = await ref.get();
      expect(s.child('foo/bar'), isA<DataSnapshot>());
      expect(s.child('foo/bar').value, 'baz');
    });

    test('children returns the children in order', () async {
      await ref.set({
        'a': 3,
        'b': 2,
        'c': 1,
      });
      final s = await ref.orderByValue().get();

      List<DataSnapshot> children = s.children.toList();
      expect(children[0].value, 1);
      expect(children[1].value, 2);
      expect(children[2].value, 3);
    });
  });
}
