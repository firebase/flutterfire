// Copyright 2026, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';

const String _col = 'pipeline-e2e';
const int _maxBatchSize = 500;

Future<void> seedPipelineE2ECollections(FirebaseFirestore firestore) async {
  final docs = <Map<String, dynamic>>[
    ..._withTest('filter-sort', [
      {'active': true, 'score': 10, 'category': 'a'},
      {'active': true, 'score': 20, 'category': 'b'},
      {'active': false, 'score': 5, 'category': 'a'},
      {'active': true, 'score': 30, 'category': 'c'},
      {'active': true, 'score': 15, 'category': 'b'},
    ]),
    ..._withTest('add-fields', [
      {'title': 'alpha', 'score': -7},
      {'title': 'beta', 'score': 42},
      {'title': 'gamma', 'score': 0},
    ]),
    ..._withTest('select', [
      {'name': 'doc1', 'score': 1},
      {'name': 'doc2', 'score': 2},
      {'name': 'doc3', 'score': 3},
    ]),
    ..._withTest('remove-fields', [
      {'keep': 'x', 'internal_id': 'id1', 'debug_flag': true},
      {'keep': 'y', 'internal_id': 'id2', 'debug_flag': false},
      {'keep': 'z', 'internal_id': 'id3', 'debug_flag': true},
    ]),
    ..._withTest('replace-with', [
      {
        'name': 'Doc 1',
        'nested': {'father': 'John Doe Sr.', 'mother': 'Jane Doe'},
      },
      {
        'name': 'Doc 2',
        'nested': {'a': 1, 'b': 2},
      },
      {
        'name': 'Doc 3',
        'nested': {'x': 'foo', 'y': 'bar'},
      },
    ]),
    ..._withTest('aggregate', [
      {'score': 10, 'category': 'x'},
      {'score': 20, 'category': 'x'},
      {'score': 30, 'category': 'y'},
      {'score': 40, 'category': 'y'},
    ]),
    ..._withTest('unnest', [
      {
        'tags': ['dart', 'flutter'],
      },
      {
        'tags': ['firestore'],
      },
      {
        'tags': ['dart', 'firestore'],
      },
    ]),
    ..._withTest('union-a', [
      {'id': 'a1'},
      {'id': 'a2'},
      {'id': 'a3'},
    ]),
    ..._withTest('union-b', [
      {'id': 'b1'},
      {'id': 'b2'},
      {'id': 'b3'},
    ]),
    ..._withTest('sample', [
      {'n': 1},
      {'n': 2},
      {'n': 3},
      {'n': 4},
      {'n': 5},
      {'n': 6},
      {'n': 7},
      {'n': 8},
      {'n': 9},
      {'n': 10},
    ]),
    ..._withTest('find-nearest', [
      {
        'embedding': VectorValue([0.1, 0.2, 0.3]),
        'label': 'near',
      },
      {
        'embedding': VectorValue([0.15, 0.25, 0.35]),
        'label': 'near2',
      },
      {
        'embedding': VectorValue([1.0, 0.0, 0.0]),
        'label': 'far',
      },
    ]),
    ..._withTest('expressions', [
      {
        'score': 60,
        'a': 1,
        'b': 2,
        's': '  AbC  ',
        'm': {'x': 10, 'y': 20},
        'bit_a': 6,
        'bit_b': 3,
        'arr': [1, 2, 3],
        'arr_b': [4, 5],
        'maybe_null': null,
        'ts': Timestamp.fromMillisecondsSinceEpoch(1700000000000),
      },
      {
        'score': 70,
        'a': 10,
        'b': 20,
        's': 'xy',
        'm': {'x': 1},
        'bit_a': 5,
        'bit_b': 1,
        'arr': [7, 8, 9],
        'arr_b': [10],
        'ts': Timestamp.fromMillisecondsSinceEpoch(1700003600000),
      },
      {'score': 40, 'a': 5, 'b': 5},
      {'score': 80, 'a': 0, 'b': 100, 's': 'Hi'},
      {
        'score': 50,
        'a': 1,
        'b': 2,
        'tags': ['p', 'q'],
        'arr': [2, 4, 6],
        'arr_b': [8],
        's': 'a-b-c',
        'ts': Timestamp.fromMillisecondsSinceEpoch(1700007200000),
      },
    ]),
  ];
  await _clearAndSeed(firestore, _col, docs);
}

List<Map<String, dynamic>> _withTest(
  String test,
  List<Map<String, dynamic>> maps,
) {
  return maps.map((m) => {'test': test, ...m}).toList();
}

Future<void> _clearAndSeed(
  FirebaseFirestore firestore,
  String collectionPath,
  List<Map<String, dynamic>> docs,
) async {
  final col = firestore.collection(collectionPath);
  final snapshot = await col.get();
  for (final chunk in _chunk(snapshot.docs, _maxBatchSize)) {
    final batch = firestore.batch();
    for (final doc in chunk) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
  var docIndex = 0;
  for (final chunk in _chunk(docs, _maxBatchSize)) {
    final batch = firestore.batch();
    for (final data in chunk) {
      batch.set(col.doc('seed_$docIndex'), data);
      docIndex++;
    }
    await batch.commit();
  }
}

Iterable<List<T>> _chunk<T>(List<T> list, int size) sync* {
  for (var i = 0; i < list.length; i += size) {
    yield list.sublist(i, i + size > list.length ? list.length : i + size);
  }
}
