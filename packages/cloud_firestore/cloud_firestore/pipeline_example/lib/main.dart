import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// Import after file is generated through flutterfire_cli.
// import 'firebase_options.dart';

const String _collectionId = 'pipeline_test_2';

bool shouldUseFirestoreEmulator = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Enable this line instead once you have the firebase_options.dart generated and
  // imported through flutterfire_cli.
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (shouldUseFirestoreEmulator) {
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }
  runApp(const PipelineExampleApp());
}

class PipelineExampleApp extends StatelessWidget {
  const PipelineExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pipeline Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PipelineExamplePage(),
    );
  }
}

class _PipelineExamplePageState extends State<PipelineExamplePage> {
  final List<String> _log = [];
  bool _loading = false;
  List<DocumentReference<Map<String, dynamic>>> _seedDocRefs = [];

  final _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'firestore-pipeline-test',
  );

  void _logMessage(String message) {
    setState(() {
      _log.insert(
        0,
        '[${DateTime.now().toString().substring(11, 19)}] $message',
      );
    });
  }

  void _logError(String context, Object error, StackTrace? st) {
    debugPrint('$context: $error');
    if (st != null) debugPrintStack(stackTrace: st);
  }

  Future<void> _seedCollection() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _log.clear();
    });
    _logMessage('Seeding collection "$_collectionId"...');

    try {
      final col = _firestore.collection(_collectionId);

      final batch = _firestore.batch();
      _seedDocRefs = [];

      final items = [
        {'title': 'Item A', 'score': 10, 'year': 2022, 'category': 'tech'},
        {'title': 'Item B', 'score': 25, 'year': 2023, 'category': 'tech'},
        {'title': 'Item C', 'score': 5, 'year': 2021, 'category': 'news'},
        {'title': 'Item D', 'score': 40, 'year': 2023, 'category': 'news'},
        {'title': 'Item E', 'score': 15, 'year': 2022, 'category': 'tech'},
        {'title': 'Item F', 'score': 30, 'year': 2024, 'category': 'news'},
        {
          'title': 'Item G',
          'score': 20,
          'year': 2023,
          'tags': ['x', 'y', 'z'],
        },
        {
          'title': 'Item H',
          'score': 20,
          'year': 2023,
          'items': {'a': 'b', 'c': 'd'},
        },
        // For string expressions: trim, substring, stringReplaceAll, split, join
        {'title': '  Padded  ', 'score': 7, 'year': 2022, 'category': 'tech'},
        // For abs and conditional
        {
          'title': 'Item Negative',
          'score': -12,
          'year': 2023,
          'category': 'news',
        },
        // For array_length, array_sum, array_slice, array_concat
        {
          'title': 'Item With Arrays',
          'score': 50,
          'scores': [10, 20, 30],
          'tags': ['p', 'q', 'r'],
          'year': 2024,
        },
        // For if_absent (missing optional_field)
        {'title': 'Item No Optional', 'score': 11, 'year': 2022},
        // Matches integration_test pipeline_seed "expressions" (for NOT / OR tests).
        {
          'test': 'expressions',
          'score': 60,
          'a': 1,
          'b': 2,
          's': '  AbC  ',
          'm': {'x': 10, 'y': 20},
        },
        {
          'test': 'expressions',
          'score': 70,
          'a': 10,
          'b': 20,
          's': 'xy',
          'm': {'x': 1},
        },
        {'test': 'expressions', 'score': 40, 'a': 5, 'b': 5},
        {'test': 'expressions', 'score': 80, 'a': 0, 'b': 100, 's': 'Hi'},
        {
          'test': 'expressions',
          'score': 50,
          'a': 1,
          'b': 2,
          'tags': ['p', 'q'],
        },
      ];

      for (final item in items) {
        final ref = col.doc();
        batch.set(ref, item);
        if (_seedDocRefs.length < 2) _seedDocRefs.add(ref);
      }
      await batch.commit();
      _logMessage('Seeded ${items.length} documents.');
    } catch (e, st) {
      _logError('Seed error', e, st);
    } finally {
      setState(() => _loading = false);
    }
  }

  /// Seeds the same data using individual set() calls (no batch). Useful for
  /// debugging emulator issues where batch writes might behave differently.
  Future<void> _seedCollectionNoBatch() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _log.clear();
    });
    _logMessage('Seeding collection "$_collectionId" (no batch)...');

    try {
      final col = _firestore.collection(_collectionId);
      _seedDocRefs = [];

      final items = [
        {'title': 'Item A', 'score': 10, 'year': 2022, 'category': 'tech'},
        {'title': 'Item B', 'score': 25, 'year': 2023, 'category': 'tech'},
        {'title': 'Item C', 'score': 5, 'year': 2021, 'category': 'news'},
        {'title': 'Item D', 'score': 40, 'year': 2023, 'category': 'news'},
        {'title': 'Item E', 'score': 15, 'year': 2022, 'category': 'tech'},
        {'title': 'Item F', 'score': 30, 'year': 2024, 'category': 'news'},
        {
          'title': 'Item G',
          'score': 20,
          'year': 2023,
          'tags': ['x', 'y', 'z'],
        },
        {
          'title': 'Item H',
          'score': 20,
          'year': 2023,
          'items': {'a': 'b', 'c': 'd'},
        },
        {'title': '  Padded  ', 'score': 7, 'year': 2022, 'category': 'tech'},
        {
          'title': 'Item Negative',
          'score': -12,
          'year': 2023,
          'category': 'news',
        },
        {
          'title': 'Item With Arrays',
          'score': 50,
          'scores': [10, 20, 30],
          'tags': ['p', 'q', 'r'],
          'year': 2024,
        },
        {'title': 'Item No Optional', 'score': 11, 'year': 2022},
        {
          'test': 'expressions',
          'score': 60,
          'a': 1,
          'b': 2,
          's': '  AbC  ',
          'm': {'x': 10, 'y': 20},
        },
        {
          'test': 'expressions',
          'score': 70,
          'a': 10,
          'b': 20,
          's': 'xy',
          'm': {'x': 1},
        },
        {'test': 'expressions', 'score': 40, 'a': 5, 'b': 5},
        {'test': 'expressions', 'score': 80, 'a': 0, 'b': 100, 's': 'Hi'},
        {
          'test': 'expressions',
          'score': 50,
          'a': 1,
          'b': 2,
          'tags': ['p', 'q'],
        },
      ];

      for (final item in items) {
        final ref = col.doc();
        await ref.set(item);
        if (_seedDocRefs.length < 2) _seedDocRefs.add(ref);
      }
      _logMessage('Seeded ${items.length} documents (no batch).');
    } catch (e, st) {
      _logError('Seed (no batch) error', e, st);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _runPipeline(
    String description,
    Future<PipelineSnapshot> Function() run,
  ) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _log.clear();
    });
    _logMessage(description);

    try {
      final snapshot = await run();
      _logMessage(
        'Found ${snapshot.result.length} result(s). Execution: ${snapshot.executionTime}',
      );
      for (final r in snapshot.result) {
        _logMessage('  doc: ${r.data()?.toString()}');
      }
    } catch (e, st) {
      _logError(description, e, st);
    } finally {
      setState(() => _loading = false);
    }
  }

  // 1: where + limit
  Future<void> _runPipeline1() => _runPipeline(
    'Pipeline 1: collection → where(score > 10) → limit(3)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .where(Expression.field('score').greaterThan(Expression.constant(10)))
        .limit(3)
        .execute(),
  );

  // 1b: execute with ExecuteOptions (indexMode: recommended)
  Future<void> _runPipelineExecuteOptions() => _runPipeline(
    'Pipeline 1b: same as 1 but execute(options: ExecuteOptions(indexMode: recommended))',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .where(Expression.field('score').greaterThan(Expression.constant(10)))
        .limit(3)
        .execute(
          options: const ExecuteOptions(indexMode: IndexMode.recommended),
        ),
  );

  // 2: select
  Future<void> _runPipeline2() => _runPipeline(
    'Pipeline 2: collection → where(year > 2022) → select(title, score, year) → limit(4)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .where(Expression.field('year').greaterThan(Expression.constant(2022)))
        .select(
          Expression.field('title'),
          Expression.field('score'),
          Expression.field('year'),
        )
        .limit(4)
        .execute(),
  );

  // 3: aggregate
  Future<void> _runPipeline3() => _runPipeline(
    'Pipeline 3: collection → aggregate(sum, avg, count_all)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .aggregate(
          Expression.field('score').sum().as('total_score'),
          Expression.field('score').average().as('avg_score'),
          CountAll().as('doc_count'),
        )
        .execute(),
  );

  // 4: addFields
  Future<void> _runPipeline4() => _runPipeline(
    'Pipeline 4: collection → addFields(score+100 as bonus) → limit(2)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .addFields(
          Expression.field(
            'score',
          ).add(Expression.constant(100)).as('bonus_score'),
        )
        .limit(2)
        .execute(),
  );

  // 5: distinct
  Future<void> _runPipeline5() => _runPipeline(
    'Pipeline 5: collection → distinct(category) → limit(5)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .distinct(Expression.field('category'))
        .limit(5)
        .execute(),
  );

  // 6: offset
  Future<void> _runPipeline6() => _runPipeline(
    'Pipeline 6: collection → limit(4) → offset(2)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .limit(4)
        .offset(2)
        .execute(),
  );

  // 7: removeFields
  Future<void> _runPipeline7() => _runPipeline(
    'Pipeline 7: collection → removeFields(category) → limit(2)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .removeFields('category')
        .limit(2)
        .execute(),
  );

  // 8: replaceWith
  Future<void> _runPipeline8() => _runPipeline(
    'Pipeline 8: collection → replaceWith(constant) → limit(1)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .replaceWith(Expression.field('items'))
        // .limit(1)
        .execute(),
  );

  // 9: sample
  Future<void> _runPipeline9() => _runPipeline(
    'Pipeline 9: collection → sample(size: 3)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .sample(PipelineSample.withSize(3))
        .execute(),
  );

  // 10: sort
  Future<void> _runPipeline10() => _runPipeline(
    'Pipeline 10: collection → sort(score desc) → limit(3)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .sort(Expression.field('score').descending())
        .limit(3)
        .execute(),
  );

  // 11: aggregateStage with groups
  Future<void> _runPipeline11() => _runPipeline(
    'Pipeline 11: collection → aggregateStage(groups: category)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .aggregateWithOptions(
          AggregateStageOptions(
            accumulators: [
              Expression.field('score').sum().as('total'),
              CountAll().as('count'),
            ],
            groups: [Expression.field('category')],
          ),
        )
        .execute(),
  );

  // 12: collectionGroup
  Future<void> _runPipeline12() => _runPipeline(
    'Pipeline 12: collectionGroup → limit(2)',
    () =>
        _firestore.pipeline().collectionGroup(_collectionId).limit(2).execute(),
  );

  // 13: documents
  Future<void> _runPipeline13() async {
    final col = _firestore.collection(_collectionId);
    final ref1 = col.doc();
    final ref2 = col.doc();
    final refs = [ref1, ref2];
    await ref1.set({'title': 'Pipeline 13 doc 1', 'n': 1});
    await ref2.set({'title': 'Pipeline 13 doc 2', 'n': 2});
    return _runPipeline(
      'Pipeline 13: documents(ref1, ref2) → addFields(extra)',
      () => _firestore
          .pipeline()
          .documents(refs)
          .addFields(Expression.constant(1).as('extra'))
          .execute(),
    );
  }

  // 14: database
  Future<void> _runPipeline14() => _runPipeline(
    'Pipeline 14: database() → limit(2)',
    () => _firestore.pipeline().database().execute(),
  );

  // 15: findNearest (may fail without vector index)
  Future<void> _runPipeline15() => _runPipeline(
    'Pipeline 15: collection → findNearest (needs vector index)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .findNearest(
          Field('embedding'),
          [0.1, 0.2, 0.3],
          DistanceMeasure.cosine,
          limit: 2,
        )
        .execute(),
  );

  // 16: unnest
  Future<void> _runPipeline16() => _runPipeline(
    'Pipeline 16: collection → where(has tags) → unnest(tags) → limit(5)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .where(Expression.field('tags').exists())
        .unnest(Expression.field('tags'), 'index')
        .limit(5)
        .execute(),
  );

  // 17: union
  Future<void> _runPipeline17() => _runPipeline(
    'Pipeline 17: collection limit 2 → union(collection offset 2 limit 2)',
    () {
      final p2 = _firestore
          .pipeline()
          .collection(_collectionId)
          .offset(2)
          .limit(2);
      return _firestore
          .pipeline()
          .collection(_collectionId)
          .limit(2)
          .union(p2)
          .execute();
    },
  );

  // 18: Constant — one addFields field per supported constant type
  Future<void> _runPipeline18() {
    final docRef = _firestore.collection(_collectionId).doc('constant-test');
    // _firestore.doc()
    return _runPipeline(
      'Pipeline 18: constant types — null, String, int, double, bool, '
      'DateTime, Timestamp, GeoPoint, List<int>, Blob, DocumentReference, VectorValue',
      () => _firestore
          .pipeline()
          .collection(_collectionId)
          .limit(1)
          .addFields(
            // VectorValue
            Constant(VectorValue([1.0, 2.0, 3.0])).as('c_vector'),

            Constant(null).as('c_null'),
            // String
            Constant('hello').as('c_string'),
            // int
            Constant(42).as('c_int'),
            // double
            Constant(3.14).as('c_double'),
            // bool
            Constant(true).as('c_bool'),
            // DateTime
            Constant(DateTime.utc(2024, 6, 15, 12, 0, 0)).as('c_date_time'),
            // Timestamp
            Constant(Timestamp(1718449200, 0)).as('c_timestamp'),
            // GeoPoint
            Constant(const GeoPoint(37.7749, -122.4194)).as('c_geo_point'),
            // List<int> (raw bytes)
            Constant(<int>[72, 101, 108, 108, 111]).as('c_bytes'),
            // // Blob
            // Constant(Blob(Uint8List.fromList([1, 2, 3, 4, 5]))).as('c_blob'),
            // DocumentReference
            Constant(docRef).as('c_doc_ref'),
          )
          .execute(),
    );
  }

  // 19: Expression.and
  Future<void> _runPipeline19() => _runPipeline(
    'Pipeline 19: collection → where(and(score > 50, year >= 2022)) → select(title, score, year) → limit(5)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .where(
          Expression.and(
            Expression.field('score').greaterThan(Expression.constant(20)),
            Expression.field(
              'year',
            ).greaterThanOrEqual(Expression.constant(2022)),
          ),
        )
        .select(
          Expression.field('title'),
          Expression.field('score'),
          Expression.field('year'),
        )
        .limit(5)
        .execute(),
  );

  // 20: Expression.or
  Future<void> _runPipeline20() => _runPipeline(
    'Pipeline 20: collection → where(or(score > 80, year < 2021)) → select(title, score, year) → limit(5)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .where(
          Expression.or(
            Expression.field('score').greaterThan(Expression.constant(30)),
            Expression.field('year').lessThan(Expression.constant(2022)),
          ),
        )
        .select(
          Expression.field('title'),
          Expression.field('score'),
          Expression.field('year'),
        )
        .limit(5)
        .execute(),
  );

  // 20b: Expression.not (same pattern as pipeline_expressions_e2e "where with not")
  Future<void> _runPipeline20b() => _runPipeline(
    'Pipeline 20b: where(test=expressions) + NOT(score>=60) + sort(score)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .where(Expression.field('test').equalValue('expressions'))
        .where(
          Expression.not(
            Expression.field(
              'score',
            ).greaterThanOrEqual(Expression.constant(60)),
          ),
        )
        .sort(Expression.field('score').ascending())
        .execute(),
  );

  // 21: arrayContainsAny
  Future<void> _runPipeline21() => _runPipeline(
    'Pipeline 21: collection → where(tags arrayContainsAny [x, z]) → select(title, tags) → limit(5)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .where(Expression.field('tags').arrayContainsAny(['x', 'z']))
        .select(Expression.field('title'), Expression.field('tags'))
        .limit(5)
        .execute(),
  );

  // ── New expression examples (22+) ─────────────────────────────────────

  // 22: concat
  Future<void> _runPipeline22() => _runPipeline(
    'Pipeline 22: addFields concat(title, " | ", category)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .addFields(
          Expression.field(
            'title',
          ).concat([' | ', Expression.field('category')]).as('title_category'),
        )
        .limit(3)
        .execute(),
  );

  // 23: length (string)
  Future<void> _runPipeline23() => _runPipeline(
    'Pipeline 23: addFields title.length()',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .addFields(Expression.field('title').length().as('title_len'))
        .limit(4)
        .execute(),
  );

  // 24: toLowerCase / toUpperCase
  Future<void> _runPipeline24() => _runPipeline(
    'Pipeline 24: addFields toLowerCase(title), toUpperCase(category)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .addFields(
          Expression.field('title').toLowerCase().as('title_lower'),
          Expression.field('category').toUpperCase().as('category_upper'),
        )
        .limit(3)
        .execute(),
  );

  // 25: trim
  Future<void> _runPipeline25() => _runPipeline(
    'Pipeline 25: where(has title) → addFields trim(title)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .where(Expression.field('title').exists())
        .addFields(Expression.field('title').trim().as('title_trimmed'))
        .limit(5)
        .execute(),
  );

  // 26: substring
  Future<void> _runPipeline26() => _runPipeline(
    'Pipeline 26: addFields substring(title, 0, 5)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .addFields(
          Expression.field('title').substringLiteral(0, 5).as('title_prefix'),
        )
        .limit(4)
        .execute(),
  );

  // 27: stringReplaceAll
  // Future<void> _runPipeline27() => _runPipeline(
  //       'Pipeline 27: addFields stringReplaceAll(title, "Item", "Doc")',
  //       () => _firestore
  //           .pipeline()
  //           .collection(_collectionId)
  //           .addFields(
  //             Expression.field('title')
  //                 .stringReplaceAllLiteral('Item', 'Doc')
  //                 .as('title_replaced'),
  //           )
  //           .limit(3)
  //           .execute(),
  //     );

  // 28: split
  Future<void> _runPipeline28() => _runPipeline(
    'Pipeline 28: addFields split(title, " ")',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .addFields(
          Expression.field('title').splitLiteral(' ').as('title_parts'),
        )
        .limit(3)
        .execute(),
  );

  // 29: join
  Future<void> _runPipeline29() => _runPipeline(
    'Pipeline 29: where(has tags) → addFields join(tags, "-")',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .where(Expression.field('tags').exists())
        .addFields(Expression.field('tags').joinLiteral('-').as('tags_joined'))
        .limit(3)
        .execute(),
  );

  // 30: if_absent
  Future<void> _runPipeline30() => _runPipeline(
    'Pipeline 30: addFields if_absent(optional_field, "default")',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .addFields(
          Expression.field(
            'optional_field',
          ).ifAbsentValue('default').as('opt_or_default'),
        )
        .limit(4)
        .execute(),
  );

  // 30b: if_error (e.g. safe divide)
  Future<void> _runPipeline30b() => _runPipeline(
    'Pipeline 30b: addFields score/0 with ifError("N/A")',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .addFields(
          Expression.field(
            'score',
          ).divide(Expression.constant(0)).ifErrorValue('N/A').as('safe_ratio'),
        )
        .limit(2)
        .execute(),
  );

  // 31: conditional
  Future<void> _runPipeline31() => _runPipeline(
    'Pipeline 31: addFields conditional(score > 20, "high", "low")',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .addFields(
          Expression.conditionalValues(
            Expression.field('score').greaterThan(Expression.constant(20)),
            'high',
            'low',
          ).as('score_tier'),
        )
        .limit(5)
        .execute(),
  );

  // 32: document_id (current document ID)
  Future<void> _runPipeline32() => _runPipeline(
    'Pipeline 32: addFields documentId()',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .addFields(Expression.field('__path__').documentId().as('doc_id'))
        .limit(3)
        .execute(),
  );

  // 33: collection_id (current collection ID)
  Future<void> _runPipeline33() => _runPipeline(
    'Pipeline 33: addFields collectionId()',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .addFields(Expression.field('__path__').collectionId().as('coll_id'))
        .limit(2)
        .execute(),
  );

  // 34: map_get, map_keys, map_values
  Future<void> _runPipeline34() => _runPipeline(
    'Pipeline 34: where(has items) → addFields mapGet, mapKeys, mapValues',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .where(Expression.field('items').exists())
        .addFields(Expression.field('items').mapGetLiteral('a').as('items_a'))
        .limit(2)
        .execute(),
  );

  // 35: current_timestamp, timestamp_add, timestamp_subtract, timestamp_truncate
  Future<void> _runPipeline35() => _runPipeline(
    'Pipeline 35: addFields currentTimestamp, timestampAdd(1 day)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .addFields(
          Expression.currentTimestamp().as('now'),
          Expression.timestampAddLiteral(
            Expression.currentTimestamp(),
            'day',
            1,
          ).as('tomorrow'),
        )
        .limit(1)
        .execute(),
  );

  // 36: abs
  Future<void> _runPipeline36() => _runPipeline(
    'Pipeline 36: addFields abs(score)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .addFields(Expression.field('score').abs().as('score_abs'))
        .limit(5)
        .execute(),
  );

  // 37: array_length
  Future<void> _runPipeline37() => _runPipeline(
    'Pipeline 37: where(has tags) → addFields arrayLength(tags)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .where(Expression.field('tags').exists())
        .addFields(Expression.field('tags').arrayLength().as('tags_len'))
        .limit(5)
        .execute(),
  );

  Future<void> _runPipeline37b() => _runPipeline(
    'Pipeline 37b: where(has scores) → addFields arraySum(scores)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .where(Expression.field('scores').exists())
        .addFields(Expression.field('scores').arraySum().as('scores_total'))
        .limit(3)
        .execute(),
  );

  // 38: array_concat
  Future<void> _runPipeline38() => _runPipeline(
    'Pipeline 38: where(has tags) → addFields arrayConcat(tags, [extra])',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .where(Expression.field('tags').exists())
        .addFields(
          Expression.field('tags').arrayConcat(['extra']).as('tags_extended'),
        )
        .limit(2)
        .execute(),
  );

  // 39: array_slice
  Future<void> _runPipeline39() => _runPipeline(
    'Pipeline 39: where(has tags) → addFields arraySlice(tags, 0, 2)',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .where(Expression.field('tags').exists())
        .addFields(
          Expression.field('tags').arraySliceLiteral(0, 2).as('tags_slice'),
        )
        .limit(3)
        .execute(),
  );

  // 40: array (construct)
  Future<void> _runPipeline40() => _runPipeline(
    'Pipeline 40: addFields array([title, score, year])',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .addFields(
          Expression.array([
            Expression.field('title'),
            Expression.field('score'),
            Expression.field('year'),
          ]).as('tuple'),
        )
        .limit(2)
        .execute(),
  );

  // 41: map (construct)
  Future<void> _runPipeline41() => _runPipeline(
    'Pipeline 41: addFields map({ t: title, s: score })',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .addFields(
          Expression.map({
            't': Expression.field('title'),
            's': Expression.field('score'),
          }).as('mini_map'),
        )
        .limit(2)
        .execute(),
  );

  // 42: array_contains_all (values list)
  Future<void> _runPipeline42() => _runPipeline(
    'Pipeline 42: where(tags arrayContainsAll [x, y]) → select title, tags',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .where(Expression.field('tags').arrayContainsAll(['x', 'y']))
        .select(Expression.field('title'), Expression.field('tags'))
        .limit(5)
        .execute(),
  );

  // 43: equal_any (IN)
  Future<void> _runPipeline43() => _runPipeline(
    'Pipeline 43: where(score equalAny [10, 25, 40]) → select title, score',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .where(Expression.equalAny(Expression.field('score'), [10, 25, 40]))
        .select(Expression.field('title'), Expression.field('score'))
        .limit(5)
        .execute(),
  );

  // 44: not_equal_any (NOT IN)
  Future<void> _runPipeline44() => _runPipeline(
    'Pipeline 44: where(category notEqualAny [news]) → select title, category',
    () => _firestore
        .pipeline()
        .collection(_collectionId)
        .where(Expression.notEqualAny(Expression.field('category'), ['news']))
        .select(Expression.field('title'), Expression.field('category'))
        .limit(5)
        .execute(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pipeline Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '1. Seed data, then run pipeline queries. Errors go to console only.',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _loading ? null : _seedCollection,
                        child: const Text('Seed collection'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: _loading ? null : _seedCollectionNoBatch,
                        child: const Text('Seed (no batch)'),
                      ),
                    ),
                  ],
                ),
                if (_loading) const LinearProgressIndicator(),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _btn('1: where+limit', _runPipeline1),
                  _btn('1b: execute(options)', _runPipelineExecuteOptions),
                  _btn('2: select', _runPipeline2),
                  _btn('3: aggregate', _runPipeline3),
                  _btn('4: addFields', _runPipeline4),
                  _btn('5: distinct', _runPipeline5),
                  _btn('6: offset', _runPipeline6),
                  _btn('7: removeFields', _runPipeline7),
                  _btn('8: replaceWith', _runPipeline8),
                  _btn('9: sample', _runPipeline9),
                  _btn('10: sort', _runPipeline10),
                  _btn('11: aggregateStage', _runPipeline11),
                  _btn('12: collectionGroup', _runPipeline12),
                  _btn('13: documents', _runPipeline13),
                  _btn('14: database', _runPipeline14),
                  _btn('15: findNearest', _runPipeline15),
                  _btn('16: unnest', _runPipeline16),
                  _btn('17: union', _runPipeline17),
                  _btn('18: constants', _runPipeline18),
                  _btn('19: and', _runPipeline19),
                  _btn('20: or', _runPipeline20),
                  _btn('20b: NOT (score≥60)', _runPipeline20b),
                  _btn('21: arrayContainsAny', _runPipeline21),
                  _btn('22: concat', _runPipeline22),
                  _btn('23: length', _runPipeline23),
                  _btn('24: lower/upper', _runPipeline24),
                  _btn('25: trim', _runPipeline25),
                  _btn('26: substring', _runPipeline26),
                  // test comment
                  _btn('28: split', _runPipeline28),
                  _btn('29: join', _runPipeline29),
                  _btn('30: if_absent', _runPipeline30),
                  _btn('30b: if_error', _runPipeline30b),
                  _btn('31: conditional', _runPipeline31),
                  _btn('32: documentId', _runPipeline32),
                  _btn('33: collectionId', _runPipeline33),
                  _btn('34: mapGet/Keys/Vals', _runPipeline34),
                  _btn('35: timestamp', _runPipeline35),
                  _btn('36: abs', _runPipeline36),
                  _btn('37: arrayLen', _runPipeline37),
                  _btn('37b: arraySum', _runPipeline37b),
                  _btn('38: arrayConcat', _runPipeline38),
                  _btn('39: arraySlice', _runPipeline39),
                  _btn('40: array()', _runPipeline40),
                  _btn('41: map()', _runPipeline41),
                  _btn('42: arrayContainsAll', _runPipeline42),
                  _btn('43: equalAny', _runPipeline43),
                  _btn('44: notEqualAny', _runPipeline44),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 2,
            child: _log.isEmpty
                ? const Center(
                    child: Text(
                      'Log output will appear here.\nTap "Seed collection" then run a pipeline.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _log.length,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: SelectableText(
                          _log[i],
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _btn(String label, VoidCallback onPressed) {
    return FilledButton.tonal(
      onPressed: _loading ? null : onPressed,
      child: Text(label),
    );
  }
}

class PipelineExamplePage extends StatefulWidget {
  const PipelineExamplePage({super.key});

  @override
  State<PipelineExamplePage> createState() => _PipelineExamplePageState();
}
