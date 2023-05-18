// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void runLoadBundleTests() {
  group('$DocumentReference', () {
    late FirebaseFirestore firestore;

    Future<Uint8List> loadBundleSetup(int number) async {
      // endpoint serves a bundle with 3 documents each containing
      // a 'number' property that increments in value 1-3.
      final url =
          Uri.https('api.rnfirebase.io', '/firestore/e2e-tests/bundle-$number');
      final response = await http.get(url);
      String string = response.body;
      return Uint8List.fromList(string.codeUnits);
    }

    setUp(() async {
      firestore = FirebaseFirestore.instance;
    });

    group('FirebaseFirestore.loadBundle()', () {
      testWidgets('loadBundle()', (_) async {
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

      testWidgets('loadBundle(): LoadBundleTaskProgress stream snapshots',
          (_) async {
        Uint8List buffer = await loadBundleSetup(2);
        LoadBundleTask task = firestore.loadBundle(buffer);

        final list = await task.stream.toList();

        expect(list.map((e) => e.totalDocuments), everyElement(isNonNegative));
        expect(list.map((e) => e.bytesLoaded), everyElement(isNonNegative));
        expect(list.map((e) => e.documentsLoaded), everyElement(isNonNegative));
        expect(list.map((e) => e.totalBytes), everyElement(isNonNegative));
        expect(list, everyElement(isInstanceOf<LoadBundleTaskSnapshot>()));

        LoadBundleTaskSnapshot lastSnapshot = list.removeLast();
        expect(lastSnapshot.taskState, LoadBundleTaskState.success);

        expect(
          list.map((e) => e.taskState),
          everyElement(LoadBundleTaskState.running),
        );
      });

      testWidgets('loadBundle(): error handling for malformed bundle',
          (_) async {
        final url = Uri.https(
          'api.rnfirebase.io',
          '/firestore/e2e-tests/malformed-bundle',
        );
        final response = await http.get(url);
        String string = response.body;
        Uint8List buffer = Uint8List.fromList(string.codeUnits);

        LoadBundleTask task = firestore.loadBundle(buffer);

        await expectLater(
          task.stream.last,
          throwsA(
            isA<FirebaseException>()
                .having((e) => e.code, 'code', 'load-bundle-error'),
          ),
        );
      });

      testWidgets('loadBundle(): pause and resume stream', (_) async {
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
      });
    });

    group('FirebaeFirestore.namedQueryGet()', () {
      testWidgets('namedQueryGet() successful', (_) async {
        const int number = 4;
        Uint8List buffer = await loadBundleSetup(number);
        LoadBundleTask task = firestore.loadBundle(buffer);

        // ensure the bundle has been completely cached
        await task.stream.last;

        // namedQuery 'named-bundle-test' which returns a QuerySnaphot of the same 3 documents
        // with 'number' property
        QuerySnapshot<Map<String, Object?>> snapshot =
            await firestore.namedQueryGet(
          'named-bundle-test-$number',
          options: const GetOptions(source: Source.cache),
        );

        expect(
          snapshot.docs.map((document) => document['number']),
          everyElement(anyOf(1, 2, 3)),
        );
      });

      testWidgets('namedQueryGet() error', (_) async {
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
            isA<FirebaseException>()
                .having((e) => e.code, 'code', 'non-existent-named-query'),
          ),
        );
      });
    });

    group('FirebaeFirestore.namedQueryWithConverterGet()', () {
      testWidgets('namedQueryWithConverterGet() successful', (_) async {
        const int number = 4;
        Uint8List buffer = await loadBundleSetup(number);
        LoadBundleTask task = firestore.loadBundle(buffer);

        // ensure the bundle has been completely cached
        await task.stream.last;

        // namedQuery 'named-bundle-test' which returns a QuerySnaphot of the same 3 documents
        // with 'number' property
        QuerySnapshot<ConverterPlaceholder> snapshot =
            await firestore.namedQueryWithConverterGet<ConverterPlaceholder>(
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

      testWidgets('namedQueryWithConverterGet() error', (_) async {
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
            isA<FirebaseException>()
                .having((e) => e.code, 'code', 'non-existent-named-query'),
          ),
        );
      });
    });
  });
}

class ConverterPlaceholder {
  ConverterPlaceholder(this.firestore, this.getOptions);

  final DocumentSnapshot<Map<String, Object?>> firestore;
  final SnapshotOptions? getOptions;

  Map<String, Object?> toFirestore() => firestore.data()!;
}
