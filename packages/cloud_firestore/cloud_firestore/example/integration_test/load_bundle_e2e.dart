// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

/// Every test in this file loads its bundle fixture from an external endpoint.
/// That request had no timeout, so a single stalled fetch consumed the whole
/// five minute test budget and was reported as a `loadBundle()` failure — see
/// `loadBundle(): LoadBundleTaskProgress stream snapshots` timing out on CI
/// while the surrounding bundle tests passed.
///
/// Bound each attempt and retry the fetch. Only the network call is retried, so
/// a genuine Firestore failure is still reported on the first run rather than
/// being masked by a test-level `retry:`.
const _fixtureTimeout = Duration(seconds: 20);
const _fixtureAttempts = 3;

Future<Uint8List> _fetchFixture(Uri url) async {
  Object? lastError;
  for (var attempt = 1; attempt <= _fixtureAttempts; attempt++) {
    try {
      final response = await http.get(url).timeout(_fixtureTimeout);
      return Uint8List.fromList(response.body.codeUnits);
    } catch (error) {
      lastError = error;
      if (attempt < _fixtureAttempts) {
        await Future.delayed(Duration(seconds: attempt));
      }
    }
  }
  fail('Could not fetch $url after $_fixtureAttempts attempts: $lastError');
}

void runLoadBundleTests() {
  group('$DocumentReference', () {
    late FirebaseFirestore firestore;

    Future<Uint8List> loadBundleSetup(int number) {
      // endpoint serves a bundle with 3 documents each containing
      // a 'number' property that increments in value 1-3.
      return _fetchFixture(
        Uri.https('api.rnfirebase.io', '/firestore/e2e-tests/bundle-$number'),
      );
    }

    setUp(() async {
      firestore = FirebaseFirestore.instance;
    });

    group('FirebaseFirestore.loadBundle()', () {
      test('loadBundle()', () async {
        const int number = 1;
        const String collection = 'firestore-bundle-tests-$number';
        Uint8List buffer = await loadBundleSetup(number);
        LoadBundleTask task = firestore.loadBundle(buffer);

        // ensure the bundle has been completely cached
        await task.stream.last;

        QuerySnapshot<Map<String, Object?>> snapshot = await firestore
            .collection(collection)
            .get(const GetOptions(source: Source.cache));

        expect(
          snapshot.docs.map((document) => document['number']),
          everyElement(anyOf(1, 2, 3)),
        );
      });

      test(
        'loadBundle(): LoadBundleTaskProgress stream snapshots',
        () async {
          Uint8List buffer = await loadBundleSetup(2);
          LoadBundleTask task = firestore.loadBundle(buffer);

          final list = await task.stream.toList();

          expect(
            list.map((e) => e.totalDocuments),
            everyElement(isNonNegative),
          );
          expect(list.map((e) => e.bytesLoaded), everyElement(isNonNegative));
          expect(
            list.map((e) => e.documentsLoaded),
            everyElement(isNonNegative),
          );
          expect(list.map((e) => e.totalBytes), everyElement(isNonNegative));
          expect(list, everyElement(isInstanceOf<LoadBundleTaskSnapshot>()));

          LoadBundleTaskSnapshot lastSnapshot = list.removeLast();
          expect(lastSnapshot.taskState, LoadBundleTaskState.success);

          expect(
            list.map((e) => e.taskState),
            everyElement(LoadBundleTaskState.running),
          );
        },
        // Working locally but is failing on CI
        skip: kIsWeb,
      );

      test('loadBundle(): error handling for malformed bundle', () async {
        final Uint8List buffer = await _fetchFixture(
          Uri.https(
            'api.rnfirebase.io',
            '/firestore/e2e-tests/malformed-bundle',
          ),
        );

        LoadBundleTask task = firestore.loadBundle(buffer);

        await expectLater(
          task.stream.last,
          throwsA(
            isA<FirebaseException>().having(
              (e) => e.code,
              'code',
              'load-bundle-error',
            ),
          ),
        );
      });

      test(
        'loadBundle(): pause and resume stream',
        () async {
          Uint8List buffer = await loadBundleSetup(3);
          LoadBundleTask task = firestore.loadBundle(buffer);
          // Illustrates the pause() & resume() function.
          // A single stream will stop sending events once the listener is unsubscribed

          // Will listen & pause after first event received
          await expectLater(
            task.stream,
            emits(
              isA<LoadBundleTaskSnapshot>().having(
                (ts) => ts.taskState,
                'taskState',
                LoadBundleTaskState.running,
              ),
            ),
          );

          await Future.delayed(const Duration(milliseconds: 1));

          // Will resume & pause after second event received
          await expectLater(
            task.stream,
            emits(
              isA<LoadBundleTaskSnapshot>().having(
                (ts) => ts.taskState,
                'taskState',
                anyOf(LoadBundleTaskState.running, LoadBundleTaskState.success),
              ),
            ),
          );
        },
        skip: defaultTargetPlatform == TargetPlatform.windows,
      );
    });

    group('FirebaseFirestore.namedQueryGet()', () {
      test('namedQueryGet() successful', () async {
        const int number = 4;
        Uint8List buffer = await loadBundleSetup(number);
        LoadBundleTask task = firestore.loadBundle(buffer);

        // ensure the bundle has been completely cached
        await task.stream.last;

        // namedQuery 'named-bundle-test' which returns a QuerySnaphot of the same 3 documents
        // with 'number' property
        QuerySnapshot<Map<String, Object?>> snapshot = await firestore
            .namedQueryGet(
              'named-bundle-test-$number',
              options: const GetOptions(source: Source.cache),
            );

        expect(
          snapshot.docs.map((document) => document['number']),
          everyElement(anyOf(1, 2, 3)),
        );
      }, skip: kIsWeb);

      test(
        'namedQueryGet() error',
        () async {
          Uint8List buffer = await loadBundleSetup(4);
          LoadBundleTask task = firestore.loadBundle(buffer);

          // ensure the bundle has been completely cached
          await task.stream.last;

          await expectLater(
            firestore.namedQueryGet(
              'wrong-name',
              options: const GetOptions(source: Source.cache),
            ),
            throwsA(
              isA<FirebaseException>().having(
                (e) => e.code,
                'code',
                'non-existent-named-query',
              ),
            ),
          );
        },
        skip: defaultTargetPlatform == TargetPlatform.windows,
      );
    });

    group('FirebaeFirestore.namedQueryWithConverterGet()', () {
      test('namedQueryWithConverterGet() successful', () async {
        const int number = 4;
        Uint8List buffer = await loadBundleSetup(number);
        LoadBundleTask task = firestore.loadBundle(buffer);

        // ensure the bundle has been completely cached
        await task.stream.last;

        // namedQuery 'named-bundle-test' which returns a QuerySnaphot of the same 3 documents
        // with 'number' property
        QuerySnapshot<ConverterPlaceholder> snapshot = await firestore
            .namedQueryWithConverterGet<ConverterPlaceholder>(
              'named-bundle-test-$number',
              options: const GetOptions(source: Source.cache),
              fromFirestore: ConverterPlaceholder.new,
              toFirestore: (value, options) => value.toFirestore(),
            );

        expect(
          snapshot.docs.map((document) => document['number']),
          everyElement(anyOf(1, 2, 3)),
        );
      });

      test(
        'namedQueryWithConverterGet() error',
        () async {
          Uint8List buffer = await loadBundleSetup(4);
          LoadBundleTask task = firestore.loadBundle(buffer);

          // ensure the bundle has been completely cached
          await task.stream.last;

          await expectLater(
            firestore.namedQueryWithConverterGet<ConverterPlaceholder>(
              'wrong-name',
              options: const GetOptions(source: Source.cache),
              fromFirestore: ConverterPlaceholder.new,
              toFirestore: (value, options) => value.toFirestore(),
            ),
            throwsA(
              isA<FirebaseException>().having(
                (e) => e.code,
                'code',
                'non-existent-named-query',
              ),
            ),
          );
        },
        skip: defaultTargetPlatform == TargetPlatform.windows,
      );
    });
  });
}

class ConverterPlaceholder {
  ConverterPlaceholder(this.firestore, this.getOptions);

  final DocumentSnapshot<Map<String, Object?>> firestore;
  final SnapshotOptions? getOptions;

  Map<String, Object?> toFirestore() => firestore.data()!;
}
