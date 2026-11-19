// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('chrome')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:cloud_firestore_web/src/interop/firestore_interop.dart'
    as interop;
import 'package:cloud_firestore_web/src/pipeline_builder_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late JSObject source;
  late JSObject pipeline;
  late JSAny? literalsDocuments;
  late JSAny? updateOptions;
  late JSAny? insertOptions;
  late JSAny? upsertOptions;
  late JSAny? deleteOptions;

  setUp(() {
    literalsDocuments = null;
    updateOptions = null;
    insertOptions = null;
    upsertOptions = null;
    deleteOptions = null;

    JSObject expression() {
      final expr = JSObject();
      expr['as'] = ((JSAny? alias) => expr).toJS;
      return expr;
    }

    final pipelinesModule = JSObject();
    pipelinesModule['field'] = ((JSAny? path) => expression()).toJS;
    pipelinesModule['constant'] = ((JSAny? value) => expression()).toJS;

    pipeline = JSObject();
    pipeline['update'] = ((JSAny options) {
      updateOptions = options;
      return pipeline;
    }).toJS;
    pipeline['insert'] = ((JSAny options) {
      insertOptions = options;
      return pipeline;
    }).toJS;
    pipeline['upsert'] = ((JSAny options) {
      upsertOptions = options;
      return pipeline;
    }).toJS;
    pipeline['delete'] = ((JSAny options) {
      deleteOptions = options;
      return pipeline;
    }).toJS;

    source = JSObject();
    source['literals'] = ((JSAny documents) {
      literalsDocuments = documents;
      return pipeline;
    }).toJS;
    source['collection'] = ((JSAny path) => pipeline).toJS;

    final bytesConstructor = JSObject();
    bytesConstructor['fromUint8Array'] = ((JSUint8Array list) {
      final bytes = JSObject();
      bytes['bytes'] = list;
      return bytes;
    }).toJS;

    final firestoreSdk = JSObject();
    firestoreSdk['pipelines'] = pipelinesModule;
    firestoreSdk['Bytes'] = bytesConstructor;
    globalContext['firebase_firestore'] = firestoreSdk;
  });

  interop.FirestoreJsImpl firestore() {
    final raw = JSObject();
    raw['pipeline'] = (() => source).toJS;
    return raw as interop.FirestoreJsImpl;
  }

  test(
    'literals, upsert, insert, update, and delete reach the JS stage methods',
    () {
      buildPipelineFromStages(firestore(), [
        {
          'stage': 'literals',
          'args': {
            'documents': [
              {
                'name': {'kind': 'value', 'value': 'ada'},
                'tags': {
                  'kind': 'value',
                  'value': ['a', 'b'],
                },
                'score': {
                  'kind': 'expression',
                  'expression': {
                    'name': 'constant',
                    'args': {'value': 1},
                  },
                },
              },
            ],
          },
        },
        {
          'stage': 'upsert',
          'args': {
            'collection': 'pipeline-writes',
            'document_id': {
              'name': 'constant',
              'args': {'value': 'ada'},
            },
            'additional_fields': [
              {
                'name': 'alias',
                'args': {
                  'alias': 'extra',
                  'expression': {
                    'name': 'field',
                    'args': {'field': 'name'},
                  },
                },
              },
            ],
          },
        },
      ]);

      final documents = (literalsDocuments! as JSArray).toDart;
      expect(documents, hasLength(1));
      final document = documents.first! as JSObject;
      expect(document.getProperty('name'.toJS).dartify(), 'ada');
      expect(document.getProperty('tags'.toJS).dartify(), ['a', 'b']);
      expect(document.getProperty('score'.toJS), isNotNull);

      final upsert = upsertOptions! as JSObject;
      expect(
        upsert.getProperty('collection'.toJS).dartify(),
        'pipeline-writes',
      );
      expect(upsert.getProperty('documentIdExpression'.toJS), isNotNull);
      expect(upsert.getProperty('documentId'.toJS), isNull);
      expect(upsert.getProperty('additionalFields'.toJS), isA<JSArray>());
      expect(upsert.getProperty('additional_fields'.toJS), isNull);

      buildPipelineFromStages(firestore(), [
        {
          'stage': 'collection',
          'args': {'path': 'pipeline-writes'},
        },
        {
          'stage': 'update',
          'args': {
            'expressions': [
              {
                'name': 'alias',
                'args': {
                  'alias': 'score',
                  'expression': {
                    'name': 'field',
                    'args': {'field': 'rating'},
                  },
                },
              },
            ],
          },
        },
      ]);

      final update = updateOptions! as JSObject;
      expect(update.getProperty('transformedFields'.toJS), isA<JSArray>());
      expect(update.getProperty('expressions'.toJS), isNull);

      buildPipelineFromStages(firestore(), [
        {
          'stage': 'literals',
          'args': {
            'documents': [
              {
                'name': {'kind': 'value', 'value': 'grace'},
              },
            ],
          },
        },
        {
          'stage': 'insert',
          'args': {
            'collection': 'pipeline-writes',
            'document_id': {
              'name': 'constant',
              'args': {'value': 'grace'},
            },
          },
        },
      ]);

      final insert = insertOptions! as JSObject;
      expect(
        insert.getProperty('collection'.toJS).dartify(),
        'pipeline-writes',
      );
      expect(insert.getProperty('documentIdExpression'.toJS), isNotNull);
      expect(insert.getProperty('documentId'.toJS), isNull);

      buildPipelineFromStages(firestore(), [
        {
          'stage': 'collection',
          'args': {'path': 'pipeline-writes'},
        },
        {'stage': 'delete', 'args': <String, dynamic>{}},
      ]);
      expect(deleteOptions, isA<JSObject>());
    },
  );

  test('a byte literal becomes Bytes and a number list stays an array', () {
    buildPipelineFromStages(firestore(), [
      {
        'stage': 'literals',
        'args': {
          'documents': [
            {
              'payload': {
                'kind': 'value',
                'value': Uint8List.fromList([1, 2, 3]),
              },
              'scores': {
                'kind': 'value',
                'value': [1, 2, 3],
              },
            },
          ],
        },
      },
    ]);

    final documents = (literalsDocuments! as JSArray).toDart;
    final document = documents.first! as JSObject;
    final payload = document.getProperty('payload'.toJS) as JSObject;
    expect((payload.getProperty('bytes'.toJS) as JSUint8Array).toDart, [
      1,
      2,
      3,
    ]);
    expect(document.getProperty('scores'.toJS).dartify(), [1, 2, 3]);
    expect(document.getProperty('scores'.toJS), isA<JSArray>());
  });

  test('a literals stage without documents throws', () {
    expect(
      () => buildPipelineFromStages(firestore(), [
        {'stage': 'literals', 'args': <String, dynamic>{}},
      ]),
      throwsArgumentError,
    );
  });

  test('a literals stage with an empty documents list throws', () {
    expect(
      () => buildPipelineFromStages(firestore(), [
        {
          'stage': 'literals',
          'args': {'documents': <dynamic>[]},
        },
      ]),
      throwsArgumentError,
    );
  });
}
