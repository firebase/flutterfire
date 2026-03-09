// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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

  group('Pipeline stages serialization', () {
    group('_CollectionPipelineStage', () {
      test('serializes collection path correctly', () {
        final pipeline = firestore.pipeline().collection('users');
        expect(pipeline.stages.first, {
          'stage': 'collection',
          'args': {'path': 'users'},
        });
      });

      test('serializes nested collection path', () {
        final pipeline = firestore.pipeline().collection('users/123/posts');
        expect(pipeline.stages.first, {
          'stage': 'collection',
          'args': {'path': 'users/123/posts'},
        });
      });

      test('throws on empty collection path', () {
        expect(
          () => firestore.pipeline().collection(''),
          throwsArgumentError,
        );
      });

      test('throws on collection path with double slashes', () {
        expect(
          () => firestore.pipeline().collection('users//posts'),
          throwsArgumentError,
        );
      });
    });

    group('_CollectionGroupPipelineStage', () {
      test('serializes collection group path correctly', () {
        final pipeline = firestore.pipeline().collectionGroup('posts');
        expect(pipeline.stages.first, {
          'stage': 'collection_group',
          'args': {'path': 'posts'},
        });
      });

      test('throws on empty collection group id', () {
        expect(
          () => firestore.pipeline().collectionGroup(''),
          throwsArgumentError,
        );
      });

      test('throws on collection group id containing slash', () {
        expect(
          () => firestore.pipeline().collectionGroup('users/posts'),
          throwsArgumentError,
        );
      });
    });

    group('_DatabasePipelineStage', () {
      test('serializes database stage correctly', () {
        final pipeline = firestore.pipeline().database();
        expect(pipeline.stages.first, {'stage': 'database'});
      });
    });

    group('_DocumentsPipelineStage', () {
      test('serializes document references', () {
        final docRef = firestore.collection('users').doc('123');
        final pipeline = firestore.pipeline().documents([docRef]);
        expect(pipeline.stages.first['stage'], 'documents');
        final args = pipeline.stages.first['args'] as List;
        expect(args, hasLength(1));
        expect(args.first, {'path': 'users/123'});
      });

      test('serializes multiple document references', () {
        final ref1 = firestore.collection('users').doc('1');
        final ref2 = firestore.collection('users').doc('2');
        final pipeline = firestore.pipeline().documents([ref1, ref2]);
        final args = pipeline.stages.first['args'] as List;
        expect(args, hasLength(2));
      });

      test('throws on empty documents list', () {
        expect(
          () => firestore.pipeline().documents([]),
          throwsArgumentError,
        );
      });
    });

    group('_WhereStage', () {
      test('serializes where stage with a field filter', () {
        final pipeline = firestore
            .pipeline()
            .collection('users')
            .where(Field('age').greaterThan(Constant(18)));
        final whereStage = pipeline.stages.last;
        expect(whereStage['stage'], 'where');
        expect(whereStage['args'], isA<Map>());
        expect(whereStage['args']['expression'], isNotNull);
      });
    });

    group('_SelectStage', () {
      test('serializes select stage with fields', () {
        final pipeline = firestore
            .pipeline()
            .collection('users')
            .select(Field('name'), Field('age'));
        final selectStage = pipeline.stages.last;
        expect(selectStage['stage'], 'select');
        expect(selectStage['args']['expressions'], hasLength(2));
      });

      test('serializes select stage with alias', () {
        final pipeline = firestore
            .pipeline()
            .collection('users')
            .select(Field('name').as('userName'));
        final selectStage = pipeline.stages.last;
        expect(selectStage['stage'], 'select');
        expect(selectStage['args']['expressions'], hasLength(1));
      });
    });

    group('_AddFieldsStage', () {
      test('serializes addFields stage', () {
        final pipeline = firestore
            .pipeline()
            .collection('users')
            .addFields(Field('score').as('totalScore'));
        final stage = pipeline.stages.last;
        expect(stage['stage'], 'add_fields');
        expect(stage['args']['expressions'], hasLength(1));
      });

      test('serializes addFields with multiple fields', () {
        final pipeline = firestore.pipeline().collection('users').addFields(
              Field('a').as('x'),
              Field('b').as('y'),
              Field('c').as('z'),
            );
        final stage = pipeline.stages.last;
        expect(stage['stage'], 'add_fields');
        expect(stage['args']['expressions'], hasLength(3));
      });
    });

    group('_LimitStage', () {
      test('serializes limit stage', () {
        final pipeline = firestore.pipeline().collection('users').limit(10);
        final stage = pipeline.stages.last;
        expect(stage, {
          'stage': 'limit',
          'args': {'limit': 10},
        });
      });
    });

    group('_OffsetStage', () {
      test('serializes offset stage', () {
        final pipeline = firestore.pipeline().collection('users').offset(5);
        final stage = pipeline.stages.last;
        expect(stage, {
          'stage': 'offset',
          'args': {'offset': 5},
        });
      });
    });

    group('_SortStage', () {
      test('serializes sort stage ascending', () {
        final pipeline = firestore
            .pipeline()
            .collection('users')
            .sort(Ordering(Field('name'), OrderDirection.asc));
        final stage = pipeline.stages.last;
        expect(stage['stage'], 'sort');
        final orderings = stage['args']['orderings'] as List;
        expect(orderings, hasLength(1));
        expect(orderings.first['order_direction'], 'asc');
      });

      test('serializes sort stage descending', () {
        final pipeline = firestore
            .pipeline()
            .collection('users')
            .sort(Ordering(Field('score'), OrderDirection.desc));
        final stage = pipeline.stages.last;
        final orderings = stage['args']['orderings'] as List;
        expect(orderings.first['order_direction'], 'desc');
      });

      test('serializes multiple orderings', () {
        final pipeline = firestore.pipeline().collection('users').sort(
              Ordering(Field('lastName'), OrderDirection.asc),
              Ordering(Field('firstName'), OrderDirection.asc),
            );
        final stage = pipeline.stages.last;
        expect(
          stage['args']['orderings'] as List,
          hasLength(2),
        );
      });
    });

    group('_AggregateStage', () {
      test('serializes aggregate stage', () {
        final pipeline = firestore
            .pipeline()
            .collection('orders')
            .aggregate(CountAll().as('totalCount'));
        final stage = pipeline.stages.last;
        expect(stage['stage'], 'aggregate');
        expect(
          stage['args']['aggregate_functions'],
          hasLength(1),
        );
      });

      test('serializes multiple aggregate functions', () {
        final pipeline = firestore.pipeline().collection('orders').aggregate(
              CountAll().as('count'),
              Sum(Field('amount')).as('total'),
            );
        final stage = pipeline.stages.last;
        expect(
          stage['args']['aggregate_functions'] as List,
          hasLength(2),
        );
      });
    });

    group('_AggregateStageWithOptions', () {
      test('serializes aggregate stage with accumulators only', () {
        final pipeline =
            firestore.pipeline().collection('orders').aggregateWithOptions(
                  AggregateStageOptions(
                    accumulators: [CountAll().as('count')],
                  ),
                );
        final stage = pipeline.stages.last;
        expect(stage['stage'], 'aggregate_with_options');
        final aggregateStage =
            stage['args']['aggregate_stage'] as Map<String, dynamic>;
        expect(aggregateStage['accumulators'], hasLength(1));
        expect(aggregateStage.containsKey('groups'), isFalse);
      });

      test('serializes aggregate stage with accumulators and groups', () {
        final pipeline =
            firestore.pipeline().collection('orders').aggregateWithOptions(
                  AggregateStageOptions(
                    accumulators: [
                      Sum(Field('amount')).as('total'),
                      CountAll().as('count'),
                    ],
                    groups: [Field('category')],
                  ),
                );
        final stage = pipeline.stages.last;
        expect(stage['stage'], 'aggregate_with_options');
        final aggregateStage =
            stage['args']['aggregate_stage'] as Map<String, dynamic>;
        expect(aggregateStage['accumulators'], hasLength(2));
        expect(aggregateStage['groups'], hasLength(1));
      });

      test('includes options map in args', () {
        final pipeline =
            firestore.pipeline().collection('orders').aggregateWithOptions(
                  AggregateStageOptions(
                    accumulators: [CountAll().as('count')],
                  ),
                );
        final stage = pipeline.stages.last;
        expect(stage['args'].containsKey('options'), isTrue);
      });
    });

    group('_DistinctStage', () {
      test('serializes distinct stage', () {
        final pipeline =
            firestore.pipeline().collection('users').distinct(Field('country'));
        final stage = pipeline.stages.last;
        expect(stage['stage'], 'distinct');
        expect(stage['args']['expressions'], hasLength(1));
      });
    });

    group('_RemoveFieldsStage', () {
      test('serializes removeFields stage', () {
        final pipeline = firestore
            .pipeline()
            .collection('users')
            .removeFields('password', 'secretToken');
        final stage = pipeline.stages.last;
        expect(stage, {
          'stage': 'remove_fields',
          'args': {
            'field_paths': ['password', 'secretToken'],
          },
        });
      });
    });

    group('_ReplaceWithStage', () {
      test('serializes replaceWith stage', () {
        final pipeline = firestore
            .pipeline()
            .collection('users')
            .replaceWith(Field('profile'));
        final stage = pipeline.stages.last;
        expect(stage['stage'], 'replace_with');
        expect(stage['args']['expression'], isNotNull);
      });
    });

    group('_SampleStage', () {
      test('serializes sample with size', () {
        final pipeline = firestore
            .pipeline()
            .collection('users')
            .sample(PipelineSample.withSize(100));
        final stage = pipeline.stages.last;
        expect(stage['stage'], 'sample');
        expect(stage['args']['type'], 'size');
        expect(stage['args']['value'], 100);
      });

      test('serializes sample with percentage', () {
        final pipeline = firestore
            .pipeline()
            .collection('users')
            .sample(PipelineSample.withPercentage(0.1));
        final stage = pipeline.stages.last;
        expect(stage['stage'], 'sample');
        expect(stage['args']['type'], 'percentage');
        expect(stage['args']['value'], 0.1);
      });
    });

    group('_FindNearestStage', () {
      test('serializes findNearest without limit', () {
        final pipeline = firestore.pipeline().collection('items').findNearest(
              Field('embedding'),
              [0.1, 0.2, 0.3],
              DistanceMeasure.cosine,
            );
        final stage = pipeline.stages.last;
        expect(stage['stage'], 'find_nearest');
        expect(stage['args']['vector_field'], 'embedding');
        expect(stage['args']['vector_value'], [0.1, 0.2, 0.3]);
        expect(stage['args']['distance_measure'], 'cosine');
        expect(stage['args'].containsKey('limit'), isFalse);
      });

      test('serializes findNearest with limit', () {
        final pipeline = firestore.pipeline().collection('items').findNearest(
              Field('embedding'),
              [0.1, 0.2, 0.3],
              DistanceMeasure.euclidean,
              limit: 5,
            );
        final stage = pipeline.stages.last;
        expect(stage['args']['limit'], 5);
        expect(stage['args']['distance_measure'], 'euclidean');
      });

      test('serializes findNearest with dotProduct distance', () {
        final pipeline = firestore.pipeline().collection('items').findNearest(
              Field('embedding'),
              [1.0, 0.0],
              DistanceMeasure.dotProduct,
            );
        final stage = pipeline.stages.last;
        expect(stage['args']['distance_measure'], 'dotProduct');
      });
    });

    group('_UnionStage', () {
      test('serializes union stage with nested pipeline stages', () {
        final innerPipeline = firestore.pipeline().collection('archived_users');
        final pipeline =
            firestore.pipeline().collection('users').union(innerPipeline);
        final stage = pipeline.stages.last;
        expect(stage['stage'], 'union');
        expect(stage['args']['pipeline'], isA<List>());
        expect(
          stage['args']['pipeline'] as List,
          hasLength(1),
        );
      });
    });

    group('_UnnestStage', () {
      test('serializes unnest stage without indexField', () {
        final pipeline = firestore
            .pipeline()
            .collection('users')
            .unnest(Field('tags').as('tag'));
        final stage = pipeline.stages.last;
        expect(stage['stage'], 'unnest');
        expect(stage['args']['expression'], isNotNull);
        expect(stage['args'].containsKey('index_field'), isFalse);
      });

      test('serializes unnest stage with indexField', () {
        final pipeline = firestore
            .pipeline()
            .collection('users')
            .unnest(Field('tags').as('tag'), 'idx');
        final stage = pipeline.stages.last;
        expect(stage['args']['index_field'], 'idx');
      });
    });

    group('Stage chaining', () {
      test('accumulates stages in order', () {
        final pipeline = firestore
            .pipeline()
            .collection('users')
            .where(Field('age').greaterThan(Constant(18)))
            .select(Field('name'))
            .limit(10)
            .offset(0);

        expect(pipeline.stages, hasLength(5));
        expect(pipeline.stages[0]['stage'], 'collection');
        expect(pipeline.stages[1]['stage'], 'where');
        expect(pipeline.stages[2]['stage'], 'select');
        expect(pipeline.stages[3]['stage'], 'limit');
        expect(pipeline.stages[4]['stage'], 'offset');
      });
    });
  });
}
