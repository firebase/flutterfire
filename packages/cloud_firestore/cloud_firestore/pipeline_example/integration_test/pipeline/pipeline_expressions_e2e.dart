// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:flutter_test/flutter_test.dart';

import 'pipeline_test_helpers.dart';

void runPipelineExpressionsTests() {
  group('Pipeline expressions in where and addFields', () {
    late FirebaseFirestore firestore;

    setUpAll(() {
      firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'firestore-pipeline-test',
      );
    });

    /// Single doc: `test==expressions`, `score==50` (see pipeline seed).
    Future<PipelineSnapshot> expressionsDocScore50(Selectable field) {
      return firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('expressions'))
          .where(Expression.field('score').equalValue(50))
          .addFields(field)
          .limit(1)
          .execute();
    }

    test('where with greaterThan filters and returns expected docs', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('expressions'))
          .where(Expression.field('score').greaterThan(Expression.constant(50)))
          .sort(Expression.field('score').ascending())
          .limit(5)
          .execute();
      expectResultCount(snapshot, 3);
      expectResultsData(snapshot, [
        {'score': 60, 'a': 1, 'b': 2},
        {'score': 70, 'a': 10, 'b': 20},
        {'score': 80, 'a': 0, 'b': 100},
      ]);
    });

    test('addFields with add expression returns expected values', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('expressions'))
          .sort(Expression.field('score').ascending())
          .addFields(
            Expression.field('a').add(Expression.field('b')).as('sum_ab'),
          )
          .limit(5)
          .execute();
      expectResultCount(snapshot, 5);
      expectResultsData(snapshot, [
        {'score': 40, 'a': 5, 'b': 5, 'sum_ab': 10},
        {'score': 50, 'a': 1, 'b': 2, 'sum_ab': 3},
        {'score': 60, 'a': 1, 'b': 2, 'sum_ab': 3},
        {'score': 70, 'a': 10, 'b': 20, 'sum_ab': 30},
        {'score': 80, 'a': 0, 'b': 100, 'sum_ab': 100},
      ]);
    });

    test('addFields with conditional returns expected band', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('expressions'))
          .sort(Expression.field('score').ascending())
          .addFields(
            Expression.conditional(
              Expression.field('score').greaterThan(Expression.constant(50)),
              Expression.constant('high'),
              Expression.constant('low'),
            ).as('band'),
          )
          .limit(5)
          .execute();
      expectResultCount(snapshot, 5);
      expectResultsData(snapshot, [
        {'score': 40, 'band': 'low'},
        {'score': 50, 'band': 'low'},
        {'score': 60, 'band': 'high'},
        {'score': 70, 'band': 'high'},
        {'score': 80, 'band': 'high'},
      ]);
    });

    test('addFields with arrayLength returns length for array field', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('expressions'))
          .sort(Expression.field('score').ascending())
          .addFields(Expression.field('tags').arrayLength().as('tags_len'))
          .limit(5)
          .execute();
      expectResultCount(snapshot, 5);
      final withTags = snapshot.result
          .where((r) => r.data()!['tags_len'] == 2)
          .toList();
      expect(withTags.length, 1);
      expect(withTags.first.data()!['score'], 50);
    });

    test('where with lessThan filters correctly', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('expressions'))
          .where(Expression.field('score').lessThan(Expression.constant(60)))
          .sort(Expression.field('score').ascending())
          .execute();
      expectResultCount(snapshot, 2);
      expectResultsData(snapshot, [
        {'score': 40, 'a': 5, 'b': 5},
        {'score': 50, 'a': 1, 'b': 2},
      ]);
    });

    test('where with equalValue filters correctly', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('expressions'))
          .where(Expression.field('score').equalValue(50))
          .execute();
      expectResultCount(snapshot, 1);
      expectResultsData(snapshot, [
        {'score': 50, 'a': 1, 'b': 2},
      ]);
    });

    test('where with equal(Expression) filters correctly', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('expressions'))
          .where(Expression.field('score').equal(Expression.constant(50)))
          .execute();
      expectResultCount(snapshot, 1);
      expectResultsData(snapshot, [
        {'score': 50, 'a': 1, 'b': 2},
      ]);
    });

    test('where with notEqualValue filters correctly', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('expressions'))
          .where(Expression.field('score').notEqualValue(50))
          .sort(Expression.field('score').ascending())
          .execute();
      expectResultCount(snapshot, 4);
      expectResultsData(snapshot, [
        {'score': 40, 'a': 5, 'b': 5},
        {'score': 60, 'a': 1, 'b': 2},
        {'score': 70, 'a': 10, 'b': 20},
        {'score': 80, 'a': 0, 'b': 100},
      ]);
    });

    test('where with notEqual(Expression) filters correctly', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('expressions'))
          .where(Expression.field('score').notEqual(Expression.constant(50)))
          .sort(Expression.field('score').ascending())
          .execute();
      expectResultCount(snapshot, 4);
      expectResultsData(snapshot, [
        {'score': 40, 'a': 5, 'b': 5},
        {'score': 60, 'a': 1, 'b': 2},
        {'score': 70, 'a': 10, 'b': 20},
        {'score': 80, 'a': 0, 'b': 100},
      ]);
    });

    test(
      'where with greaterThanValue and lessThanValue filter correctly',
      () async {
        final snapshot = await firestore
            .pipeline()
            .collection('pipeline-e2e')
            .where(Expression.field('test').equalValue('expressions'))
            .where(Expression.field('score').greaterThanValue(40))
            .where(Expression.field('score').lessThanValue(80))
            .sort(Expression.field('score').ascending())
            .execute();
        expectResultCount(snapshot, 3);
        expectResultsData(snapshot, [
          {'score': 50, 'a': 1, 'b': 2},
          {'score': 60, 'a': 1, 'b': 2},
          {'score': 70, 'a': 10, 'b': 20},
        ]);
      },
    );

    test(
      'where with greaterThanOrEqual and lessThanOrEqual filter correctly',
      () async {
        final snapshot = await firestore
            .pipeline()
            .collection('pipeline-e2e')
            .where(Expression.field('test').equalValue('expressions'))
            .where(
              Expression.field(
                'score',
              ).greaterThanOrEqual(Expression.constant(50)),
            )
            .where(
              Expression.field(
                'score',
              ).lessThanOrEqual(Expression.constant(70)),
            )
            .sort(Expression.field('score').ascending())
            .execute();
        expectResultCount(snapshot, 3);
        expectResultsData(snapshot, [
          {'score': 50, 'a': 1, 'b': 2},
          {'score': 60, 'a': 1, 'b': 2},
          {'score': 70, 'a': 10, 'b': 20},
        ]);
      },
    );

    test(
      'addFields with subtract, multiply, divide, modulo return expected values',
      () async {
        final snapshot = await firestore
            .pipeline()
            .collection('pipeline-e2e')
            .where(Expression.field('test').equalValue('expressions'))
            .sort(Expression.field('score').ascending())
            .addFields(
              Expression.field('a').subtract(Expression.field('b')).as('diff'),
              Expression.field(
                'a',
              ).multiply(Expression.field('b')).as('product'),
              Expression.field(
                'score',
              ).divide(Expression.constant(10)).as('score_div_10'),
              Expression.field(
                'score',
              ).modulo(Expression.constant(30)).as('score_mod_30'),
            )
            .limit(3)
            .execute();
        expectResultCount(snapshot, 3);
        expectResultsData(snapshot, [
          {
            'score': 40,
            'a': 5,
            'b': 5,
            'diff': 0,
            'product': 25,
            'score_div_10': 4,
            'score_mod_30': 10,
          },
          {
            'score': 50,
            'a': 1,
            'b': 2,
            'diff': -1,
            'product': 2,
            'score_div_10': 5,
            'score_mod_30': 20,
          },
          {
            'score': 60,
            'a': 1,
            'b': 2,
            'diff': -1,
            'product': 2,
            'score_div_10': 6,
            'score_mod_30': 0,
          },
        ]);
      },
    );

    test('where with and returns intersection', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('expressions'))
          .where(
            Expression.and(
              Expression.field('score').greaterThan(Expression.constant(40)),
              Expression.field('score').lessThan(Expression.constant(80)),
            ),
          )
          .sort(Expression.field('score').ascending())
          .execute();
      expectResultCount(snapshot, 3);
      expectResultsData(snapshot, [
        {'score': 50, 'a': 1, 'b': 2},
        {'score': 60, 'a': 1, 'b': 2},
        {'score': 70, 'a': 10, 'b': 20},
      ]);
    });

    test('where with or returns union', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('expressions'))
          .where(
            Expression.or(
              Expression.field('score').equalValue(40),
              Expression.field('score').equalValue(80),
            ),
          )
          .sort(Expression.field('score').ascending())
          .execute();
      expectResultCount(snapshot, 2);
      expectResultsData(snapshot, [
        {'score': 40, 'a': 5, 'b': 5},
        {'score': 80, 'a': 0, 'b': 100},
      ]);
    });

    test('where with not inverts condition', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('expressions'))
          .where(
            Expression.not(
              Expression.field(
                'score',
              ).greaterThanOrEqual(Expression.constant(60)),
            ),
          )
          .sort(Expression.field('score').ascending())
          .execute();
      expectResultCount(snapshot, 2);
      expectResultsData(snapshot, [
        {'score': 40, 'a': 5, 'b': 5},
        {'score': 50, 'a': 1, 'b': 2},
      ]);
    });

    test(
      'addFields with ifAbsentValue uses default when field missing',
      () async {
        final snapshot = await firestore
            .pipeline()
            .collection('pipeline-e2e')
            .where(Expression.field('test').equalValue('expressions'))
            .sort(Expression.field('score').ascending())
            .addFields(
              Expression.field(
                'tags',
              ).ifAbsentValue('default_value').as('tags_or_empty'),
            )
            .limit(2)
            .execute();
        expectResultCount(snapshot, 2);
        expect(snapshot.result[0].data()!['tags_or_empty'], 'default_value');
        expect(snapshot.result[1].data()!['tags_or_empty'], ['p', 'q']);
      },
    );

    test(
      'addFields with ifAbsent(Expression) uses else expression when field missing',
      () async {
        final snapshot = await firestore
            .pipeline()
            .collection('pipeline-e2e')
            .where(Expression.field('test').equalValue('expressions'))
            .sort(Expression.field('score').ascending())
            .addFields(
              Expression.field('tags')
                  .ifAbsent(Expression.constant('default_value'))
                  .as('tags_or_default'),
            )
            .limit(2)
            .execute();
        expectResultCount(snapshot, 2);
        expect(snapshot.result[0].data()!['tags_or_default'], 'default_value');
        expect(snapshot.result[1].data()!['tags_or_default'], ['p', 'q']);
      },
    );

    test(
      'where arrayContainsValue filters docs with array containing value',
      () async {
        final snapshot = await firestore
            .pipeline()
            .collection('pipeline-e2e')
            .where(Expression.field('test').equalValue('expressions'))
            .where(Expression.field('tags').arrayContainsValue('p'))
            .execute();
        expectResultCount(snapshot, 1);
        expectResultsData(snapshot, [
          {
            'score': 50,
            'a': 1,
            'b': 2,
            'tags': ['p', 'q'],
          },
        ]);
      },
    );

    test(
      'where arrayContainsElement(Expression) filters docs with array containing element',
      () async {
        final snapshot = await firestore
            .pipeline()
            .collection('pipeline-e2e')
            .where(Expression.field('test').equalValue('expressions'))
            .where(
              Expression.field(
                'tags',
              ).arrayContainsElement(Expression.constant('q')),
            )
            .execute();
        expectResultCount(snapshot, 1);
        expectResultsData(snapshot, [
          {
            'score': 50,
            'a': 1,
            'b': 2,
            'tags': ['p', 'q'],
          },
        ]);
      },
    );

    test(
      'addFields with string expressions (concat, length, toLower, toUpper, trim)',
      () async {
        final snapshot = await firestore
            .pipeline()
            .collection('pipeline-e2e')
            .where(Expression.field('test').equalValue('expressions'))
            .where(Expression.field('score').equalValue(60))
            .addFields(
              Expression.field('s').concat(['!']).as('s_concat'),
              Expression.field('s').length().as('s_len'),
              Expression.field('s').toLowerCase().as('s_lower'),
              Expression.field('s').toUpperCase().as('s_upper'),
              Expression.field('s').trim().as('s_trim'),
            )
            .limit(1)
            .execute();
        expectResultCount(snapshot, 1);
        expectResultsData(snapshot, [
          {
            'score': 60,
            's_concat': '  AbC  !',
            's_len': 7,
            's_lower': '  abc  ',
            's_upper': '  ABC  ',
            's_trim': 'AbC',
          },
        ]);
      },
    );

    test('addFields with substring returns expected slice', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('expressions'))
          .where(Expression.field('score').equalValue(70))
          .addFields(
            Expression.field('s')
                .substring(Expression.constant(0), Expression.constant(1))
                .as('s_first'),
          )
          .limit(1)
          .execute();
      expectResultCount(snapshot, 1);
      expect(snapshot.result[0].data()!['s_first'], 'x');
    });

    test('addFields with map_get returns nested value', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('expressions'))
          .where(Expression.field('score').equalValue(60))
          .addFields(
            Expression.field('m').mapGet(Expression.constant('x')).as('m_x'),
          )
          .limit(1)
          .execute();
      expectResultCount(snapshot, 1);
      expect(snapshot.result[0].data()!['m_x'], 10);
    });

    test('where with exists filters docs where tags exists', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('expressions'))
          .where(Expression.field('tags').exists())
          .sort(Expression.field('score').ascending())
          .execute();
      expectResultCount(snapshot, 1);
      expect(snapshot.result[0].data()!['score'], 50);
    });

    test(
      'where with xor returns docs matching exactly one condition',
      () async {
        final snapshot = await firestore
            .pipeline()
            .collection('pipeline-e2e')
            .where(Expression.field('test').equalValue('expressions'))
            .where(
              Expression.xor(
                Expression.field('score').equalValue(40),
                Expression.field('score').equalValue(50),
              ),
            )
            .sort(Expression.field('score').ascending())
            .execute();
        expectResultCount(snapshot, 2);
        expectResultsData(snapshot, [
          {'score': 40},
          {'score': 50},
        ]);
      },
    );

    test('where with equalAny and notEqualAny filters correctly', () async {
      final inSnapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('expressions'))
          .where(Expression.equalAny(Expression.field('score'), [40, 70]))
          .sort(Expression.field('score').ascending())
          .execute();
      expectResultCount(inSnapshot, 2);
      expectResultsData(inSnapshot, [
        {'score': 40},
        {'score': 70},
      ]);

      final notInSnapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('expressions'))
          .where(Expression.notEqualAny(Expression.field('score'), [40, 70]))
          .sort(Expression.field('score').ascending())
          .execute();
      expectResultCount(notInSnapshot, 3);
      expectResultsData(notInSnapshot, [
        {'score': 50},
        {'score': 60},
        {'score': 80},
      ]);
    });

    test('addFields split', () async {
      final snapshot = await expressionsDocScore50(
        Expression.field('s').splitLiteral('-').as('s_split'),
      );
      expectResultCount(snapshot, 1);
      expect(snapshot.result[0].data()!['s_split'], ['a', 'b', 'c']);
    });

    test('addFields join', () async {
      final snapshot = await expressionsDocScore50(
        Expression.field('tags').joinLiteral('|').as('tags_joined'),
      );
      expectResultCount(snapshot, 1);
      expect(snapshot.result[0].data()!['tags_joined'], 'p|q');
    });

    test('addFields arrayConcat', () async {
      final snapshot = await expressionsDocScore50(
        Expression.field('arr').arrayConcat([9]).as('arr_concat'),
      );
      expectResultCount(snapshot, 1);
      expect(snapshot.result[0].data()!['arr_concat'], [2, 4, 6, 9]);
    });

    test('addFields arrayConcatMultiple', () async {
      final snapshot = await expressionsDocScore50(
        Expression.field('arr')
            .arrayConcatMultiple([
              [10],
              [11],
            ])
            .as('arr_concat_multi'),
      );
      expectResultCount(snapshot, 1);
      expect(snapshot.result[0].data()!['arr_concat_multi'], [2, 4, 6, 10, 11]);
    });

    test('addFields arrayContainsAny', () async {
      final snapshot = await expressionsDocScore50(
        Expression.field('arr').arrayContainsAny([2, 99]).as('arr_has_any'),
      );
      expectResultCount(snapshot, 1);
      expect(snapshot.result[0].data()!['arr_has_any'], true);
    });

    test('addFields arrayContainsAll values', () async {
      final snapshot = await expressionsDocScore50(
        Expression.field(
          'arr',
        ).arrayContainsAll([2, 4]).as('arr_has_all_values'),
      );
      expectResultCount(snapshot, 1);
      expect(snapshot.result[0].data()!['arr_has_all_values'], true);
    });

    test('addFields arrayContainsAllFrom expression', () async {
      final snapshot = await expressionsDocScore50(
        Expression.field('arr')
            .arrayContainsAllFrom(Expression.array([Expression.constant(2), 4]))
            .as('arr_has_all_expr'),
      );
      expectResultCount(snapshot, 1);
      expect(snapshot.result[0].data()!['arr_has_all_expr'], true);
    });

    test('addFields map constructor', () async {
      final snapshot = await expressionsDocScore50(
        Expression.map({
          'left': Expression.field('a'),
          'right': Expression.field('b'),
        }).as('mapped'),
      );
      expectResultCount(snapshot, 1);
      expect(snapshot.result[0].data()!['mapped'], {'left': 1, 'right': 2});
    });

    test('addFields nullValue', () async {
      final snapshot = await expressionsDocScore50(
        Expression.nullValue().as('explicit_null'),
      );
      expectResultCount(snapshot, 1);
      expect(snapshot.result[0].data()!['explicit_null'], null);
    });

    test('addFields ifError uses catch when expression errors', () async {
      final snapshot = await expressionsDocScore50(
        Expression.field(
          'score',
        ).divide(Expression.constant(0)).ifErrorValue('safe').as('safe_div'),
      );
      expectResultCount(snapshot, 1);
      expect(snapshot.result[0].data()!['safe_div'], 'safe');
    });

    test('addFields isAbsent true for missing field', () async {
      final snapshot = await expressionsDocScore50(
        Expression.field('missing_field').isAbsent().as('missing_absent'),
      );
      expectResultCount(snapshot, 1);
      expect(snapshot.result[0].data()!['missing_absent'], true);
    });

    test('addFields isError false for missing field', () async {
      final snapshot = await expressionsDocScore50(
        Expression.field('missing_field').isError().as('missing_error'),
      );
      expectResultCount(snapshot, 1);
      expect(snapshot.result[0].data()!['missing_error'], false);
    });

    test('addFields asBoolean coerces numeric field', () async {
      final snapshot = await expressionsDocScore50(
        Expression.field('a').asBoolean().as('a_bool'),
      );
      expectResultCount(snapshot, 1);
      expect(snapshot.result[0].data()!['a_bool'], 1);
    });

    test(
      'addFields bitwise expressions (bitAnd/Or/Xor/Not/shifts)',
      () async {
        final snapshot = await firestore
            .pipeline()
            .collection('pipeline-e2e')
            .where(Expression.field('test').equalValue('expressions'))
            .where(Expression.field('score').equalValue(60))
            .addFields(
              Expression.field(
                'bit_a',
              ).bitAnd(Expression.constant(3)).as('b_and'),
              Expression.field(
                'bit_a',
              ).bitOr(Expression.constant(1)).as('b_or'),
              Expression.field(
                'bit_a',
              ).bitXor(Expression.constant(7)).as('b_xor'),
              Expression.field('bit_a').bitNot().as('b_not'),
              Expression.field('bit_a').bitLeftShiftLiteral(1).as('b_lsh'),
              Expression.field('bit_a').bitRightShiftLiteral(1).as('b_rsh'),
            )
            .limit(1)
            .execute();

        expectResultCount(snapshot, 1);
        expectResultsData(snapshot, [
          {'b_and': 2, 'b_or': 7, 'b_xor': 1, 'b_lsh': 12, 'b_rsh': 3},
        ]);
        expect(snapshot.result[0].data()!['b_not'], isNotNull);
      },
      // Bitwise pipeline addFields not supported on Android native SDK yet.
      skip: true,
    );

    test('addFields documentId, collectionId and documentIdFromRef', () async {
      final col = firestore.collection('pipeline-e2e');
      final seedQuery = await col
          .where('test', isEqualTo: 'expressions')
          .where('score', isEqualTo: 60)
          .limit(1)
          .get();
      expect(seedQuery.docs, isNotEmpty);
      final docRef = seedQuery.docs.first.reference;
      final expectedDocId = seedQuery.docs.first.id;

      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('expressions'))
          .where(Expression.field('score').equalValue(60))
          .addFields(
            Expression.field('__name__').documentId().as('doc_id'),
            Expression.field('__name__').collectionId().as('coll_id'),
            Expression.documentIdFromRef(docRef).as('doc_id_from_ref'),
          )
          .limit(1)
          .execute();

      expectResultCount(snapshot, 1);
      expectResultsData(snapshot, [
        {
          'coll_id': 'pipeline-e2e',
          'doc_id': expectedDocId,
          'doc_id_from_ref': expectedDocId,
        },
      ]);
    }, skip: kIsWeb);

    test(
      'addFields with currentTimestamp, timestampAdd/Subtract/Truncate',
      () async {
        final snapshot = await firestore
            .pipeline()
            .collection('pipeline-e2e')
            .where(Expression.field('test').equalValue('expressions'))
            .where(Expression.field('score').equalValue(60))
            .addFields(
              Expression.currentTimestamp().as('now'),
              Expression.timestampAddLiteral(
                Expression.field('ts'),
                'day',
                1,
              ).as('ts_plus_1d'),
              Expression.timestampSubtractLiteral(
                Expression.field('ts'),
                'hour',
                1,
              ).as('ts_minus_1h'),
              Expression.timestampTruncate(
                Expression.field('ts'),
                'day',
              ).as('ts_day'),
            )
            .limit(1)
            .execute();

        expectResultCount(snapshot, 1);
        final data = snapshot.result[0].data()!;
        expect(data['now'], isNotNull);
        expect(data['ts_plus_1d'], isNotNull);
        expect(data['ts_minus_1h'], isNotNull);
        expect(data['ts_day'], isNotNull);
      },
      skip: kIsWeb,
    );

    test('select with alias() returns renamed field', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('expressions'))
          .where(Expression.field('score').equalValue(60))
          .select(Expression.field('score').alias('renamed_score'))
          .limit(1)
          .execute();

      expectResultCount(snapshot, 1);
      expect(snapshot.result[0].data()!['renamed_score'], 60);
    });

    test('addFields with array_reverse returns reversed array', () async {
      final snapshot = await firestore
          .pipeline()
          .collection('pipeline-e2e')
          .where(Expression.field('test').equalValue('expressions'))
          .where(Expression.field('score').equalValue(50))
          .addFields(Expression.field('tags').arrayReverse().as('tags_rev'))
          .limit(1)
          .execute();
      expectResultCount(snapshot, 1);
      expect(snapshot.result[0].data()!['tags_rev'], ['q', 'p']);
    });

    test(
      'arraySum addFields succeeds on Android',
      () async {
        final snapshot = await firestore
            .pipeline()
            .collection('pipeline-e2e')
            .where(Expression.field('test').equalValue('expressions'))
            .addFields(Expression.array([1, 2, 3]).arraySum().as('x'))
            .limit(1)
            .execute();
        expectResultCount(snapshot, 1);
        expect(snapshot.result[0].data()!['x'], 6);
      },
      skip: defaultTargetPlatform != TargetPlatform.android,
    );

    test(
      'unsupported expression returns parse-error with informative message',
      () async {
        try {
          await firestore
              .pipeline()
              .collection('pipeline-e2e')
              .where(Expression.field('test').equalValue('expressions'))
              .addFields(Expression.array([1, 2, 3]).arraySum().as('x'))
              .limit(1)
              .execute();
          return;
        } on FirebaseException catch (e) {
          expect(e.code, 'parse-error');
          expect(e.message, isNotNull);
          expect(e.message!, contains('Unsupported expression'));
        }
      },
      skip:
          defaultTargetPlatform != TargetPlatform.iOS &&
          defaultTargetPlatform != TargetPlatform.macOS,
    );
  });
}
