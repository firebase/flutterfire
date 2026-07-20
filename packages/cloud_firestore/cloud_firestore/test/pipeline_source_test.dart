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

  group('PipelineSource', () {
    test('pipeline() returns a PipelineSource', () {
      final source = firestore.pipeline();
      expect(source, isA<PipelineSource>());
    });

    group('collection()', () {
      test('creates pipeline with collection stage', () {
        final pipeline = firestore.pipeline().collection('users');
        expect(pipeline.stages, hasLength(1));
        expect(pipeline.stages.first, {
          'stage': 'collection',
          'args': {'path': 'users'},
        });
      });

      test('accepts nested collection path', () {
        final pipeline = firestore.pipeline().collection('users/abc123/orders');
        expect(pipeline.stages.first['args'], {'path': 'users/abc123/orders'});
      });

      test('throws on empty path', () {
        expect(
          () => firestore.pipeline().collection(''),
          throwsArgumentError,
        );
      });

      test('throws on path containing double slash', () {
        expect(
          () => firestore.pipeline().collection('users//posts'),
          throwsArgumentError,
        );
      });
    });

    group('collectionReference()', () {
      test('creates pipeline from collection reference path', () {
        final colRef = firestore.collection('products');
        final pipeline = firestore.pipeline().collectionReference(colRef);
        expect(pipeline.stages, hasLength(1));
        expect(pipeline.stages.first, {
          'stage': 'collection',
          'args': {'path': 'products'},
        });
      });

      test('uses path from nested collection reference', () {
        final colRef =
            firestore.collection('users').doc('u1').collection('posts');
        final pipeline = firestore.pipeline().collectionReference(colRef);
        expect(pipeline.stages.first['args'], {
          'path': 'users/u1/posts',
        });
      });
    });

    group('collectionGroup()', () {
      test('creates pipeline with collection_group stage', () {
        final pipeline = firestore.pipeline().collectionGroup('posts');
        expect(pipeline.stages, hasLength(1));
        expect(pipeline.stages.first, {
          'stage': 'collection_group',
          'args': {'path': 'posts'},
        });
      });

      test('throws on empty collection id', () {
        expect(
          () => firestore.pipeline().collectionGroup(''),
          throwsArgumentError,
        );
      });

      test('throws when collection id contains slash', () {
        expect(
          () => firestore.pipeline().collectionGroup('users/posts'),
          throwsArgumentError,
        );
      });
    });

    group('documents()', () {
      test('creates pipeline with documents stage', () {
        final docRef = firestore.collection('users').doc('123');
        final pipeline = firestore.pipeline().documents([docRef]);
        expect(pipeline.stages, hasLength(1));
        expect(pipeline.stages.first['stage'], 'documents');
        expect(
          (pipeline.stages.first['args'] as List).first,
          {'path': 'users/123'},
        );
      });

      test('supports multiple document references', () {
        final refs = [
          firestore.collection('c').doc('1'),
          firestore.collection('c').doc('2'),
        ];
        final pipeline = firestore.pipeline().documents(refs);
        final args = pipeline.stages.first['args'] as List;
        expect(args, hasLength(2));
      });

      test('throws on empty list', () {
        expect(
          () => firestore.pipeline().documents([]),
          throwsArgumentError,
        );
      });
    });

    group('database()', () {
      test('creates pipeline with database stage only', () {
        final pipeline = firestore.pipeline().database();
        expect(pipeline.stages, hasLength(1));
        expect(pipeline.stages.first, {'stage': 'database'});
      });
    });

    group('chaining from source', () {
      test('returned pipeline accepts stage methods', () {
        final pipeline = firestore
            .pipeline()
            .collection('users')
            .where(Field('active').equal(Constant(true)))
            .limit(5);
        expect(pipeline.stages, hasLength(3));
        expect(pipeline.stages[0]['stage'], 'collection');
        expect(pipeline.stages[1]['stage'], 'where');
        expect(pipeline.stages[2]['stage'], 'limit');
      });
    });
  });
}
