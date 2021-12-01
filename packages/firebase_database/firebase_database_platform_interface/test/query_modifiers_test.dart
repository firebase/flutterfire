// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_database_platform_interface/firebase_database_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QueryModifiers', () {
    test('toList() returns an list', () {
      final instance = QueryModifiers([]);
      expect(instance.toList(), isA<List<Map<String, Object?>>>());
    });

    test('toIterable() returns an iterable', () {
      final instance = QueryModifiers([]);
      expect(instance.toIterable(), isA<Iterable<QueryModifier>>());
    });

    group('start()', () {
      test('fails assertion if a starting point is already set', () {
        final instance = QueryModifiers([]);
        instance.start(StartCursorModifier.startAt('foo', 'bar'));

        expect(
          () => instance.start(StartCursorModifier.startAfter('foo', 'bar')),
          throwsAssertionError,
        );
      });

      test('fails assertion if value is not valid', () {
        final instance = QueryModifiers([]);

        expect(
          () => instance.start(StartCursorModifier.startAfter({}, 'bar')),
          throwsAssertionError,
        );
      });

      test('it adds to the modifier list', () {
        final instance = QueryModifiers([]);
        expect(instance.toList().length, 0);

        instance.start(StartCursorModifier.startAfter('foo', 'bar'));

        expect(
          instance.toList(),
          equals([
            {
              'type': 'cursor',
              'name': 'startAfter',
              'value': 'foo',
              'key': 'bar'
            }
          ]),
        );
      });
    });

    group('end()', () {
      test('fails assertion if a ending point is already set', () {
        final instance = QueryModifiers([]);
        instance.end(EndCursorModifier.endAt('foo', 'bar'));

        expect(
          () => instance.end(EndCursorModifier.endBefore('foo', 'bar')),
          throwsAssertionError,
        );
      });

      test('fails assertion if value is not valid', () {
        final instance = QueryModifiers([]);

        expect(
          () => instance.end(EndCursorModifier.endBefore([], 'bar')),
          throwsAssertionError,
        );
      });

      test('it adds to the modifier list', () {
        final instance = QueryModifiers([]);
        expect(instance.toList().length, 0);

        instance.end(EndCursorModifier.endAt('foo', 'bar'));

        expect(
          instance.toList(),
          equals([
            {'type': 'cursor', 'name': 'endAt', 'value': 'foo', 'key': 'bar'}
          ]),
        );
      });
    });

    group('limit()', () {
      test('fails assertion if a limit is already set', () {
        final instance = QueryModifiers([]);
        instance.limit(LimitModifier.limitToFirst(10));

        expect(
          () => instance.limit(LimitModifier.limitToLast(10)),
          throwsAssertionError,
        );
      });

      test('fails assertion if value is not valid', () {
        final instance = QueryModifiers([]);

        expect(
          () => instance.limit(LimitModifier.limitToLast(-2)),
          throwsAssertionError,
        );
      });

      test('it adds to the modifier list', () {
        final instance = QueryModifiers([]);
        expect(instance.toList().length, 0);

        instance.limit(LimitModifier.limitToLast(10));

        expect(
          instance.toList(),
          equals([
            {'type': 'limit', 'name': 'limitToLast', 'limit': 10}
          ]),
        );
      });
    });

    group('order()', () {
      test('fails assertion if a order is already set', () {
        final instance = QueryModifiers([]);
        instance.order(OrderModifier.orderByKey());

        expect(
          () => instance.order(OrderModifier.orderByPriority()),
          throwsAssertionError,
        );
      });

      test('it adds to the modifier list', () {
        final instance = QueryModifiers([]);
        expect(instance.toList().length, 0);

        instance.order(OrderModifier.orderByPriority());

        expect(
          instance.toList(),
          equals([
            {'type': 'orderBy', 'name': 'orderByPriority', 'path': null}
          ]),
        );
      });
    });

    group('validation', () {
      test(
          'it fails assertion when ordering by key, but the key provided to a cursor modifier is also set',
          () {
        final instance = QueryModifiers([]);

        instance.start(StartCursorModifier.startAt('foo', 'bar'));

        expect(
          () => instance.order(OrderModifier.orderByKey()),
          throwsAssertionError,
        );
      });

      test(
          'it fails assertion when ordering by key, but the value provided to a cursor modifier is not a string',
          () {
        final instance = QueryModifiers([]);

        instance.start(StartCursorModifier.startAt(123, null));

        expect(
          () => instance.order(OrderModifier.orderByKey()),
          throwsAssertionError,
        );
      });

      test(
          'it fails assertion when ordering by priority, but start cursor value is not a valid priority value',
          () {
        final instance = QueryModifiers([]);

        instance.start(StartCursorModifier.startAfter(true, null));

        expect(
          () => instance.order(OrderModifier.orderByPriority()),
          throwsAssertionError,
        );
      });

      test(
          'it fails assertion when ordering by priority, but end cursor value is not a valid priority value',
          () {
        final instance = QueryModifiers([]);

        instance.end(EndCursorModifier.endBefore(true, null));

        expect(
          () => instance.order(OrderModifier.orderByPriority()),
          throwsAssertionError,
        );
      });
    });
  });
}
