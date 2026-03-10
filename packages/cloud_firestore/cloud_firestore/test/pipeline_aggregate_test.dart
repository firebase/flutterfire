// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import './mock.dart';

void main() {
  setupCloudFirestoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('PipelineAggregateFunction', () {
    test('CountAll has name count_all and simple toMap', () {
      final fn = CountAll();
      expect(fn.name, 'count_all');
      expect(fn.toMap(), {'name': 'count_all'});
    });

    test('Count serializes with expression', () {
      final fn = Count(Field('amount'));
      expect(fn.toMap(), {
        'name': 'count',
        'args': {
          'expression': {
            'name': 'field',
            'args': {'field': 'amount'}
          },
        },
      });
    });

    test('Sum serializes with expression', () {
      final fn = Sum(Field('total'));
      expect(fn.toMap(), {
        'name': 'sum',
        'args': {
          'expression': {
            'name': 'field',
            'args': {'field': 'total'}
          },
        },
      });
    });

    test('Average serializes with expression', () {
      final fn = Average(Field('score'));
      expect(fn.toMap(), {
        'name': 'average',
        'args': {
          'expression': {
            'name': 'field',
            'args': {'field': 'score'}
          },
        },
      });
    });

    test('CountDistinct serializes with expression', () {
      final fn = CountDistinct(Field('category'));
      expect(fn.toMap(), {
        'name': 'count_distinct',
        'args': {
          'expression': {
            'name': 'field',
            'args': {'field': 'category'}
          },
        },
      });
    });

    test('Minimum serializes with expression', () {
      final fn = Minimum(Field('price'));
      expect(fn.toMap(), {
        'name': 'minimum',
        'args': {
          'expression': {
            'name': 'field',
            'args': {'field': 'price'}
          },
        },
      });
    });

    test('Maximum serializes with expression', () {
      final fn = Maximum(Field('price'));
      expect(fn.toMap(), {
        'name': 'maximum',
        'args': {
          'expression': {
            'name': 'field',
            'args': {'field': 'price'}
          },
        },
      });
    });
  });

  group('AliasedAggregateFunction', () {
    test('toMap includes alias and aggregate_function', () {
      final aliased = CountAll().as('totalCount');
      expect(aliased.alias, 'totalCount');
      final map = aliased.toMap();
      expect(map['name'], 'alias');
      expect(map['args']['alias'], 'totalCount');
      expect(map['args']['aggregate_function'], {'name': 'count_all'});
    });

    test('wraps expression-based aggregate', () {
      final aliased = Sum(Field('amount')).as('total');
      expect(aliased.alias, 'total');
      final map = aliased.toMap();
      expect(map['args']['aggregate_function']['name'], 'sum');
    });
  });

  group('AggregateStageOptions', () {
    test('toMap with accumulators only', () {
      final options = AggregateStageOptions(
        accumulators: [CountAll().as('count')],
      );
      final map = options.toMap();
      expect(map['accumulators'], hasLength(1));
      expect(map.containsKey('groups'), isFalse);
    });

    test('toMap with accumulators and groups', () {
      final options = AggregateStageOptions(
        accumulators: [Sum(Field('x')).as('sumX')],
        groups: [Field('category')],
      );
      final map = options.toMap();
      expect(map['accumulators'], hasLength(1));
      expect(map['groups'], hasLength(1));
    });
  });

  group('AggregateOptions', () {
    test('toMap returns empty map', () {
      final options = AggregateOptions();
      expect(options.toMap(), isEmpty);
    });
  });
}
