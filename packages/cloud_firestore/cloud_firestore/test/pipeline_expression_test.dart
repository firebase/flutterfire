// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import './mock.dart';

void main() {
  setupCloudFirestoreMocks();

  late FirebaseFirestore firestore;

  setUpAll(() async {
    await Firebase.initializeApp();
    firestore = FirebaseFirestore.instance;
  });

  group('Field', () {
    test('toMap returns field name structure', () {
      final expr = Field('name');
      expect(expr.toMap(), {
        'name': 'field',
        'args': {'field': 'name'},
      });
    });

    test('nested field path serializes correctly', () {
      final expr = Field('user.profile.displayName');
      expect(expr.toMap()['args']['field'], 'user.profile.displayName');
    });
  });

  group('Constant', () {
    test('toMap for null', () {
      final expr = Constant(null);
      expect(expr.toMap(), {
        'name': 'constant',
        'args': {'value': null},
      });
    });

    test('toMap for number', () {
      final expr = Constant(42);
      expect(expr.toMap(), {
        'name': 'constant',
        'args': {'value': 42},
      });
    });

    test('toMap for double', () {
      final expr = Constant(3.14);
      expect(expr.toMap(), {
        'name': 'constant',
        'args': {'value': 3.14},
      });
    });

    test('toMap for string', () {
      final expr = Constant('hello');
      expect(expr.toMap(), {
        'name': 'constant',
        'args': {'value': 'hello'},
      });
    });

    test('toMap for bool', () {
      final expr = Constant(true);
      expect(expr.toMap(), {
        'name': 'constant',
        'args': {'value': true},
      });
    });

    test('toMap for DateTime', () {
      final dt = DateTime.utc(2025, 1, 15);
      final expr = Constant(dt);
      expect(expr.toMap(), {
        'name': 'constant',
        'args': {'value': dt},
      });
    });

    test('toMap for Timestamp', () {
      final ts = Timestamp.fromDate(DateTime.utc(2025, 3, 10));
      final expr = Constant(ts);
      expect(expr.toMap(), {
        'name': 'constant',
        'args': {'value': ts},
      });
    });

    test('toMap for GeoPoint', () {
      const gp = GeoPoint(52, 4);
      final expr = Constant(gp);
      expect(expr.toMap(), {
        'name': 'constant',
        'args': {'value': gp},
      });
    });

    test('toMap for List<int> (bytes)', () {
      final bytes = <int>[1, 2, 3];
      final expr = Constant(bytes);
      expect(
        expr.toMap(),
        {
          'name': 'constant',
          'args': {
            'value': [1, 2, 3],
          },
        },
      );
    });

    test('toMap for Blob', () {
      final blob = Blob(Uint8List.fromList([1, 2, 3]));
      final expr = Constant(blob);
      expect(
        expr.toMap(),
        {
          'name': 'constant',
          'args': {
            'value': blob,
          },
        },
      );
    });

    test('toMap for DocumentReference serializes path', () {
      final ref = firestore.collection('users').doc('alice');
      final expr = Constant(ref);
      expect(expr.toMap(), {
        'name': 'constant',
        'args': {
          'value': {
            'path': 'users/alice',
          },
        },
      });
    });

    test('toMap for VectorValue', () {
      const vec = VectorValue([1.0, 2.0, 3.0]);
      final expr = Constant(vec);
      expect(expr.toMap(), {
        'name': 'constant',
        'args': {'value': vec},
      });
    });

    test('throws ArgumentError for invalid value type', () {
      expect(
        () => Constant({'key': 'value'}),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            allOf(contains('Constant value must be'), contains('Got:')),
          ),
        ),
      );
    });

    test('throws ArgumentError for List<String> (not List<int>)', () {
      expect(
        () => Constant(<String>['a', 'b']),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Got:'),
          ),
        ),
      );
    });
  });

  group('Expression static constructors', () {
    test('Expression.field() returns Field with path', () {
      final expr = Expression.field('amount');
      expect(expr, isA<Field>());
      expect(expr.toMap()['args']['field'], 'amount');
    });

    test('Expression.constant() wraps value', () {
      final expr = Expression.constant(100);
      expect(expr.toMap(), {
        'name': 'constant',
        'args': {'value': 100},
      });
    });
  });

  group('BooleanExpression from Field', () {
    test('equal serializes correctly', () {
      final expr = Field('age').equal(Constant(18));
      expect(expr.toMap(), {
        'name': 'equal',
        'args': {
          'left': {
            'name': 'field',
            'args': {'field': 'age'},
          },
          'right': {
            'name': 'constant',
            'args': {'value': 18},
          },
        },
      });
    });

    test('greaterThan serializes correctly', () {
      final expr = Field('score').greaterThan(Constant(0));
      expect(expr.toMap(), {
        'name': 'greater_than',
        'args': {
          'left': {
            'name': 'field',
            'args': {'field': 'score'},
          },
          'right': {
            'name': 'constant',
            'args': {'value': 0},
          },
        },
      });
    });

    test('exists serializes correctly', () {
      final expr = Field('email').exists();
      expect(expr.toMap(), {
        'name': 'exists',
        'args': {
          'expression': {
            'name': 'field',
            'args': {'field': 'email'},
          },
        },
      });
    });

    test('notEqual serializes correctly', () {
      final expr = Field('x').notEqual(Constant(0));
      expect(expr.toMap(), {
        'name': 'not_equal',
        'args': {
          'left': {
            'name': 'field',
            'args': {'field': 'x'},
          },
          'right': {
            'name': 'constant',
            'args': {'value': 0},
          },
        },
      });
    });

    test('lessThan serializes correctly', () {
      final expr = Field('n').lessThan(Constant(10));
      expect(expr.toMap()['name'], 'less_than');
      expect(expr.toMap()['args']['left']['args']['field'], 'n');
      expect(expr.toMap()['args']['right']['args']['value'], 10);
    });

    test('lessThanOrEqual serializes correctly', () {
      final expr = Field('n').lessThanOrEqual(Constant(5));
      expect(expr.toMap()['name'], 'less_than_or_equal');
    });

    test('greaterThanOrEqual serializes correctly', () {
      final expr = Field('n').greaterThanOrEqual(Constant(1));
      expect(expr.toMap()['name'], 'greater_than_or_equal');
    });
  });

  group('Ordering from Expression', () {
    test('ascending() returns Ordering with asc', () {
      final ordering = Field('name').ascending();
      expect(ordering.direction, OrderDirection.asc);
      expect(ordering.toMap()['order_direction'], 'asc');
    });

    test('descending() returns Ordering with desc', () {
      final ordering = Field('created').descending();
      expect(ordering.direction, OrderDirection.desc);
      expect(ordering.toMap()['order_direction'], 'desc');
    });
  });

  group('Aliased expression', () {
    test('as() wraps expression with alias', () {
      final aliased = Field('total').as('sumTotal');
      expect(aliased.toMap(), {
        'name': 'alias',
        'args': {
          'alias': 'sumTotal',
          'expression': {
            'name': 'field',
            'args': {'field': 'total'},
          },
        },
      });
    });
  });

  group('Expression static boolean helpers', () {
    test('Expression.equalStatic produces equal expression', () {
      final expr = Expression.equalStatic(
        Field('a'),
        Constant(1),
      );
      expect(expr.toMap()['name'], 'equal');
    });

    test('Expression.not inverts boolean expression', () {
      final inner = Field('active').equal(Constant(true));
      final expr = Expression.not(inner);
      expect(expr.toMap(), {
        'name': 'not',
        'args': {
          'expression': {
            'name': 'equal',
            'args': {
              'left': {
                'name': 'field',
                'args': {'field': 'active'},
              },
              'right': {
                'name': 'constant',
                'args': {'value': true},
              },
            },
          },
        },
      });
    });
  });

  group('Logic expressions (and, or, xor)', () {
    test('Expression.and serializes correctly', () {
      final a = Field('a').equal(Constant(1));
      final b = Field('b').equal(Constant(2));
      final expr = Expression.and(a, b);
      expect(expr.toMap()['name'], 'and');
      expect(expr.toMap()['args']['expressions'], hasLength(2));
    });

    test('Expression.or serializes correctly', () {
      final a = Field('x').greaterThan(Constant(0));
      final b = Field('y').lessThan(Constant(0));
      final expr = Expression.or(a, b);
      expect(expr.toMap()['name'], 'or');
      expect(expr.toMap()['args']['expressions'], hasLength(2));
    });

    test('Expression.xor serializes correctly', () {
      final a = Field('p').equal(Constant(true));
      final b = Field('q').equal(Constant(true));
      final expr = Expression.xor(a, b);
      expect(expr.toMap()['name'], 'xor');
      expect(expr.toMap()['args']['expressions'], hasLength(2));
    });
  });

  group('Conditional expression', () {
    test('Expression.conditional serializes correctly', () {
      final cond = Field('flag').equal(Constant(true));
      final thenExpr = Constant('yes');
      final elseExpr = Constant('no');
      final expr = Expression.conditional(cond, thenExpr, elseExpr);
      expect(expr.toMap(), {
        'name': 'conditional',
        'args': {
          'condition': cond.toMap(),
          'then': thenExpr.toMap(),
          'else': elseExpr.toMap(),
        },
      });
    });
  });

  group('ifAbsent and ifError', () {
    test('ifAbsent serializes correctly', () {
      final base = Field('optional');
      final fallback = Constant('default');
      final expr = base.ifAbsent(fallback);
      expect(expr.toMap(), {
        'name': 'if_absent',
        'args': {
          'expression': base.toMap(),
          'else': fallback.toMap(),
        },
      });
    });

    test('Expression.ifAbsentValueStatic serializes correctly', () {
      final expr = Expression.ifAbsentValueStatic(Field('a'), 0);
      expect(expr.toMap()['name'], 'if_absent');
    });

    test('ifError serializes correctly', () {
      final base = Field('risky');
      final catchExpr = Constant('error');
      final expr = base.ifError(catchExpr);
      expect(expr.toMap(), {
        'name': 'if_error',
        'args': {
          'expression': base.toMap(),
          'catch': catchExpr.toMap(),
        },
      });
    });
  });

  group('Presence and error checks', () {
    test('Expression.isAbsentStatic serializes correctly', () {
      final expr = Expression.isAbsentStatic(Field('maybe'));
      expect(expr.toMap(), {
        'name': 'is_absent',
        'args': {'expression': Field('maybe').toMap()},
      });
    });

    test('Expression.isErrorStatic serializes correctly', () {
      final expr = Expression.isErrorStatic(Field('x'));
      expect(expr.toMap(), {
        'name': 'is_error',
        'args': {'expression': Field('x').toMap()},
      });
    });

    test('Expression.existsField serializes correctly', () {
      final expr = Expression.existsField('email');
      expect(expr.toMap()['name'], 'exists');
    });
  });

  group('String expressions', () {
    test('concat serializes correctly', () {
      final expr = Field('first').concat([Constant(' '), Field('last')]);
      expect(expr.toMap(), {
        'name': 'concat',
        'args': {
          'expressions': [
            Field('first').toMap(),
            Constant(' ').toMap(),
            Field('last').toMap(),
          ],
        },
      });
    });

    test('length serializes correctly', () {
      final expr = Field('title').length();
      expect(expr.toMap(), {
        'name': 'length',
        'args': {'expression': Field('title').toMap()},
      });
    });

    test('toLowerCase serializes correctly', () {
      final expr = Field('name').toLowerCase();
      expect(expr.toMap()['name'], 'to_lower_case');
      expect(expr.toMap()['args']['expression']['args']['field'], 'name');
    });

    test('toUpperCase serializes correctly', () {
      final expr = Field('code').toUpperCase();
      expect(expr.toMap()['name'], 'to_upper_case');
    });

    test('trim serializes correctly', () {
      final expr = Field('input').trim();
      expect(expr.toMap(), {
        'name': 'trim',
        'args': {'expression': Field('input').toMap()},
      });
    });

    test('substring serializes correctly', () {
      final expr = Field('text').substring(Constant(0), Constant(5));
      expect(expr.toMap(), {
        'name': 'substring',
        'args': {
          'expression': Field('text').toMap(),
          'start': Constant(0).toMap(),
          'end': Constant(5).toMap(),
        },
      });
    });

    test('stringReplaceAll serializes correctly', () {
      final expr =
          Field('s').stringReplaceAll(Constant('old'), Constant('new'));
      expect(expr.toMap(), {
        'name': 'string_replace_all',
        'args': {
          'expression': Field('s').toMap(),
          'find': Constant('old').toMap(),
          'replacement': Constant('new').toMap(),
        },
      });
    });

    test('split serializes correctly', () {
      final expr = Field('csv').split(Constant(','));
      expect(expr.toMap()['name'], 'split');
      expect(expr.toMap()['args']['expression']['args']['field'], 'csv');
      expect(expr.toMap()['args']['delimiter']['args']['value'], ',');
    });

    test('join serializes correctly', () {
      final arr = Expression.array([Field('a'), Field('b')]);
      final expr = arr.join(Constant('-'));
      expect(expr.toMap(), {
        'name': 'join',
        'args': {
          'expression': arr.toMap(),
          'delimiter': Constant('-').toMap(),
        },
      });
    });
  });

  group('Array expressions', () {
    test('Expression.array serializes correctly', () {
      final expr = Expression.array([Constant(1), Constant(2), Field('x')]);
      expect(expr.toMap(), {
        'name': 'array',
        'args': {
          'elements': [
            Constant(1).toMap(),
            Constant(2).toMap(),
            Field('x').toMap(),
          ],
        },
      });
    });

    test('arrayContainsValue serializes correctly', () {
      final expr = Field('tags').arrayContainsValue(Constant('flutter'));
      expect(expr.toMap(), {
        'name': 'array_contains',
        'args': {
          'array': Field('tags').toMap(),
          'element': Constant('flutter').toMap(),
        },
      });
    });

    test('arrayContainsAny serializes correctly', () {
      final expr =
          Field('tags').arrayContainsAny([Constant('a'), Constant('b')]);
      expect(expr.toMap()['name'], 'array_contains_any');
      expect(expr.toMap()['args']['array']['args']['field'], 'tags');
      expect(expr.toMap()['args']['values'], hasLength(2));
    });

    test('arrayContainsAll with list serializes correctly', () {
      final expr = Field('tags').arrayContainsAll(['a', Constant('b')]);
      expect(expr.toMap(), {
        'name': 'array_contains_all',
        'args': {
          'array': Field('tags').toMap(),
          'values': [
            Constant('a').toMap(),
            Constant('b').toMap(),
          ],
        },
      });
    });

    test('arrayContainsAllFrom with array expression serializes correctly', () {
      final elements = Expression.array([Field('tag1'), Constant('tag2')]);
      final expr = Field('tags').arrayContainsAllFrom(elements);
      expect(expr.toMap(), {
        'name': 'array_contains_all',
        'args': {
          'array': Field('tags').toMap(),
          'array_expression': elements.toMap(),
        },
      });
    });

    test(
        'Expression.arrayContainsAllWithExpression(array, arrayExpression) serializes correctly',
        () {
      final arrayExpr =
          Expression.array([Field('required'), Constant('admin')]);
      final expr = Expression.arrayContainsAllWithExpression(
        Field('permissions'),
        arrayExpr,
      );
      expect(expr.toMap(), {
        'name': 'array_contains_all',
        'args': {
          'array': Field('permissions').toMap(),
          'array_expression': arrayExpr.toMap(),
        },
      });
    });

    test('Expression.arrayContainsAllValues(array, list) serializes correctly',
        () {
      final expr = Expression.arrayContainsAllValues(
        Field('tags'),
        [Constant('flutter'), Constant('dart')],
      );
      expect(expr.toMap()['name'], 'array_contains_all');
      expect(expr.toMap()['args']['values'], hasLength(2));
    });

    test('Expression.arrayContainsAllField serializes correctly', () {
      final required = Expression.array([Field('requiredPermissions')]);
      final expr = Expression.arrayContainsAllField('permissions', required);
      expect(expr.toMap(), {
        'name': 'array_contains_all',
        'args': {
          'array': Field('permissions').toMap(),
          'array_expression': required.toMap(),
        },
      });
    });

    test('arrayLength serializes correctly', () {
      final expr = Field('items').arrayLength();
      expect(expr.toMap(), {
        'name': 'array_length',
        'args': {'expression': Field('items').toMap()},
      });
    });

    test('arrayConcat serializes correctly', () {
      final a = Expression.array([Constant(1)]);
      final b = Expression.array([Constant(2)]);
      final expr = a.arrayConcat(b);
      expect(expr.toMap(), {
        'name': 'array_concat',
        'args': {
          'first': a.toMap(),
          'second': b.toMap(),
        },
      });
    });

    test('arraySum serializes correctly', () {
      final expr = Field('values').arraySum();
      expect(expr.toMap()['name'], 'array_sum');
      expect(expr.toMap()['args']['expression']['args']['field'], 'values');
    });

    test('arrayReverse serializes correctly', () {
      final expr = Field('order').arrayReverse();
      expect(expr.toMap()['name'], 'array_reverse');
      expect(expr.toMap()['args']['expression']['args']['field'], 'order');
    });
  });

  group('Numeric expressions', () {
    test('add serializes correctly', () {
      final expr = Field('a').add(Field('b'));
      expect(expr.toMap(), {
        'name': 'add',
        'args': {
          'left': Field('a').toMap(),
          'right': Field('b').toMap(),
        },
      });
    });

    test('subtract serializes correctly', () {
      final expr = Field('x').subtract(Constant(1));
      expect(expr.toMap()['name'], 'subtract');
      expect(expr.toMap()['args']['left']['args']['field'], 'x');
      expect(expr.toMap()['args']['right']['args']['value'], 1);
    });

    test('multiply serializes correctly', () {
      final expr = Field('qty').multiply(Field('price'));
      expect(expr.toMap()['name'], 'multiply');
    });

    test('divide serializes correctly', () {
      final expr = Field('total').divide(Constant(2));
      expect(expr.toMap()['name'], 'divide');
    });

    test('modulo serializes correctly', () {
      final expr = Field('n').modulo(Constant(10));
      expect(expr.toMap()['name'], 'modulo');
    });

    test('abs serializes correctly', () {
      final expr = Field('diff').abs();
      expect(expr.toMap()['name'], 'abs');
    });
  });

  group('Structure (nullValue, map)', () {
    test('Expression.nullValue serializes correctly', () {
      final expr = Expression.nullValue();
      expect(expr.toMap(), {
        'name': 'null',
        'args': {'value': null},
      });
    });

    test('Expression.map serializes correctly', () {
      final expr = Expression.map({
        'k1': Constant(1),
        'k2': Field('v'),
      });
      expect(expr.toMap(), {
        'name': 'map',
        'args': {
          'data': {
            'k1': Constant(1).toMap(),
            'k2': Field('v').toMap(),
          },
        },
      });
    });
  });

  group('Timestamp expressions', () {
    test('Expression.currentTimestamp serializes correctly', () {
      final expr = Expression.currentTimestamp();
      final map = expr.toMap();
      expect(map['name'], 'current_timestamp');
    });

    test('timestampAddLiteral serializes correctly', () {
      final ts = Field('created');
      final expr = Expression.timestampAddLiteral(ts, 'day', 1);
      expect(expr.toMap(), {
        'name': 'timestamp_add',
        'args': {
          'timestamp': ts.toMap(),
          'unit': 'day',
          'amount': Constant(1).toMap(),
        },
      });
    });

    test('timestampTruncate serializes correctly', () {
      final expr = Expression.timestampTruncate(Field('ts'), 'day');
      expect(expr.toMap(), {
        'name': 'timestamp_truncate',
        'args': {
          'timestamp': Field('ts').toMap(),
          'unit': 'day',
        },
      });
    });
  });

  group('Document and equality helpers', () {
    test('Expression.documentIdFromRef serializes correctly', () {
      final ref = firestore.collection('users').doc('alice');
      final expr = Expression.documentIdFromRef(ref);
      expect(expr.toMap(), {
        'name': 'document_id_from_ref',
        'args': {'doc_ref': 'users/alice'},
      });
    });

    test('equalAny serializes correctly', () {
      final expr = Expression.equalAny(Field('status'), ['a', 'b']);
      expect(expr.toMap(), {
        'name': 'equal_any',
        'args': {
          'value': Field('status').toMap(),
          'values': [Constant('a').toMap(), Constant('b').toMap()],
        },
      });
    });

    test('notEqualAny serializes correctly', () {
      final expr = Expression.notEqualAny(Field('role'), ['admin']);
      expect(expr.toMap(), {
        'name': 'not_equal_any',
        'args': {
          'value': Field('role').toMap(),
          'values': [Constant('admin').toMap()],
        },
      });
    });
  });

  group('asBoolean', () {
    test('asBoolean serializes correctly', () {
      final expr = Field('flag').asBoolean();
      expect(expr.toMap(), {
        'name': 'as_boolean',
        'args': {'expression': Field('flag').toMap()},
      });
    });
  });

  group('Map mapSet / mapEntries', () {
    test('mapSet serializes map and key_values pairs', () {
      final expr = Field('meta').mapSet('k', 1, ['k2', 2]);
      expect(expr.toMap(), {
        'name': 'map_set',
        'args': {
          'map': Field('meta').toMap(),
          'key_values': [
            Constant('k').toMap(),
            Constant(1).toMap(),
            Constant('k2').toMap(),
            Constant(2).toMap(),
          ],
        },
      });
    });

    test('mapSet throws when key/value list has odd length', () {
      expect(
        () => Field('m').mapSet('a', 1, ['orphan']),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('mapEntries serializes correctly', () {
      final expr = Field('m').mapEntries();
      expect(expr.toMap(), {
        'name': 'map_entries',
        'args': {'expression': Field('m').toMap()},
      });
    });
  });

  group('Regex and extended string expressions', () {
    test('regexFind serializes correctly', () {
      final expr = Field('email').regexFind(r'\w+');
      expect(expr.toMap(), {
        'name': 'regex_find',
        'args': {
          'expression': Field('email').toMap(),
          'pattern': Constant(r'\w+').toMap(),
        },
      });
    });

    test('regexFindAll serializes correctly', () {
      final expr = Field('text').regexFindAll('[a-z]+');
      expect(expr.toMap()['name'], 'regex_find_all');
    });

    test('stringReplaceOne serializes correctly', () {
      final expr = Field('s').stringReplaceOne(Constant('a'), Constant('b'));
      expect(expr.toMap(), {
        'name': 'string_replace_one',
        'args': {
          'expression': Field('s').toMap(),
          'find': Constant('a').toMap(),
          'replacement': Constant('b').toMap(),
        },
      });
    });

    test('stringIndexOf serializes correctly', () {
      final expr = Field('s').stringIndexOf('needle');
      expect(expr.toMap()['name'], 'string_index_of');
      expect(expr.toMap()['args']['search'], Constant('needle').toMap());
    });

    test('stringRepeat serializes correctly', () {
      final expr = Field('s').stringRepeat(3);
      expect(expr.toMap(), {
        'name': 'string_repeat',
        'args': {
          'expression': Field('s').toMap(),
          'repetitions': Constant(3).toMap(),
        },
      });
    });

    test('ltrim without value serializes correctly', () {
      final expr = Field('s').ltrim();
      expect(expr.toMap(), {
        'name': 'ltrim',
        'args': {'expression': Field('s').toMap()},
      });
    });

    test('ltrim with value serializes correctly', () {
      final expr = Field('s').ltrim('"');
      expect(expr.toMap()['args']['value'], Constant('"').toMap());
    });

    test('rtrim serializes correctly', () {
      expect(Field('s').rtrim().toMap()['name'], 'rtrim');
    });
  });

  group('type / isType / trunc / rand', () {
    test('type() serializes correctly', () {
      final expr = Field('x').type();
      expect(expr.toMap(), {
        'name': 'type',
        'args': {'expression': Field('x').toMap()},
      });
    });

    test('isType serializes correctly', () {
      final expr = Field('n').isType(Type.int64);
      expect(expr.toMap(), {
        'name': 'is_type',
        'args': {
          'expression': Field('n').toMap(),
          'type': 'int64',
        },
      });
    });

    test('Expression.isTypeStatic matches instance isType', () {
      expect(
        Expression.isTypeStatic(Field('n'), Type.float64).toMap(),
        Field('n').isType(Type.float64).toMap(),
      );
    });

    test('trunc without decimals serializes correctly', () {
      final expr = Field('pi').trunc();
      expect(expr.toMap(), {
        'name': 'trunc',
        'args': {'expression': Field('pi').toMap()},
      });
    });

    test('trunc with decimals serializes correctly', () {
      final expr = Field('pi').trunc(Constant(2));
      expect(expr.toMap()['args']['decimals'], Constant(2).toMap());
    });

    test('Expression.rand serializes correctly', () {
      expect(Expression.rand().toMap(), {
        'name': 'rand',
        'args': <String, dynamic>{},
      });
    });
  });

  group('Array analytics expressions', () {
    test('arrayFirst serializes correctly', () {
      expect(Field('tags').arrayFirst().toMap()['name'], 'array_first');
    });

    test('arrayFirstN serializes correctly', () {
      final expr = Field('tags').arrayFirstN(2);
      expect(expr.toMap(), {
        'name': 'array_first_n',
        'args': {
          'expression': Field('tags').toMap(),
          'n': Constant(2).toMap(),
        },
      });
    });

    test('arrayLast / arrayLastN serialize correctly', () {
      expect(Field('tags').arrayLast().toMap()['name'], 'array_last');
      expect(Field('tags').arrayLastN(1).toMap()['name'], 'array_last_n');
    });

    test('arrayMaximum / arrayMinimum serialize correctly', () {
      expect(Field('nums').arrayMaximum().toMap()['name'], 'maximum');
      expect(Field('nums').arrayMinimum().toMap()['name'], 'minimum');
    });

    test('arrayMaximumN / arrayMinimumN serialize correctly', () {
      expect(Field('nums').arrayMaximumN(2).toMap()['name'], 'maximum_n');
      expect(Field('nums').arrayMinimumN(2).toMap()['name'], 'minimum_n');
    });

    test('arrayIndexOf serializes occurrence first', () {
      final expr = Field('tags').arrayIndexOf('x');
      expect(expr.toMap(), {
        'name': 'array_index_of',
        'args': {
          'expression': Field('tags').toMap(),
          'element': Constant('x').toMap(),
          'occurrence': Constant('first').toMap(),
        },
      });
    });

    test('arrayLastIndexOf serializes occurrence last', () {
      final expr = Field('tags').arrayLastIndexOf('x');
      expect(expr.toMap()['args']['occurrence'], Constant('last').toMap());
    });

    test('arrayIndexOfAll serializes correctly', () {
      expect(
        Field('tags').arrayIndexOfAll('a').toMap()['name'],
        'array_index_of_all',
      );
    });
  });

  group('Option A: extended pipeline expressions', () {
    test('mapKeys / mapValues serialize correctly', () {
      expect(Field('m').mapKeys().toMap()['name'], 'map_keys');
      expect(Field('m').mapValues().toMap()['name'], 'map_values');
    });

    test('parent() serializes correctly', () {
      expect(Field('ref').parent().toMap(), {
        'name': 'parent',
        'args': {'expression': Field('ref').toMap()},
      });
    });

    test('parentFromRef serializes correctly', () {
      final ref = firestore.collection('c').doc('d');
      expect(Expression.parentFromRef(ref).toMap(), {
        'name': 'parent',
        'args': {'doc_ref': 'c/d'},
      });
    });

    test('timestampDiffStatic serializes correctly', () {
      final expr = Expression.timestampDiffStatic(
        Field('end'),
        Field('start'),
        'day',
      );
      expect(expr.toMap(), {
        'name': 'timestamp_diff',
        'args': {
          'end': Field('end').toMap(),
          'start': Field('start').toMap(),
          'unit': Constant('day').toMap(),
        },
      });
    });

    test('timestampExtract serializes correctly', () {
      final expr = Field('created').timestampExtract('year');
      expect(expr.toMap()['name'], 'timestamp_extract');
      expect(expr.toMap()['args']['part'], Constant('year').toMap());
    });

    test('timestampExtract with timezone serializes correctly', () {
      final expr = Field('created').timestampExtract('hour', 'UTC');
      expect(expr.toMap()['args']['timezone'], Constant('UTC').toMap());
    });

    test('if_null serializes correctly', () {
      final expr = Field('x').ifNullValue('fallback');
      expect(expr.toMap(), {
        'name': 'if_null',
        'args': {
          'expression': Field('x').toMap(),
          'replacement': Constant('fallback').toMap(),
        },
      });
    });

    test('nor serializes correctly', () {
      final expr = Expression.nor(
        Field('a').equalValue(1),
        Field('b').equalValue(2),
      );
      expect(expr.toMap()['name'], 'nor');
    });

    test('coalesce serializes correctly', () {
      final expr = Expression.coalesce(Field('a'), Field('b'), Constant('c'));
      expect(expr.toMap()['name'], 'coalesce');
      expect((expr.toMap()['args']['expressions'] as List).length, 3);
    });

    test('switchOn serializes correctly', () {
      final expr = Expression.switchOn(
        Field('x').greaterThanValue(0),
        Constant('pos'),
        Constant('zero'),
      );
      expect(expr.toMap()['name'], 'switch_on');
    });

    test('switchOn rejects invalid default', () {
      expect(
        () => Expression.switchOn(
          Field('x').equalValue(0),
          Constant('a'),
          42,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Expression aggregate helpers', () {
    test('first() returns First aggregate', () {
      expect(Field('s').first().toMap()['name'], 'first');
    });

    test('last() returns Last aggregate', () {
      expect(Field('s').last().toMap()['name'], 'last');
    });

    test('arrayAgg returns ArrayAgg', () {
      expect(Field('t').arrayAgg().toMap()['name'], 'array_agg');
    });

    test('arrayAggDistinct returns ArrayAggDistinct', () {
      expect(
        Field('t').arrayAggDistinct().toMap()['name'],
        'array_agg_distinct',
      );
    });
  });
}
