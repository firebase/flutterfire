// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:http/http.dart' as http;

void runLoadBundleTests() {
  group('$DocumentReference', () {
    late FirebaseFirestore firestore;
    final url = Uri.https('api.rnfirebase.io', '/firestore/bundle');
    const String collection = 'firestore-bundle-tests';

    Future<Uint8List> loadBundleSetup() async {
      // endpoint serves a bundle with 3 documents each containing
      // a 'number' property that increments in value 1-3.
      final response = await http.get(url);
      String string = response.body;
      return Uint8List.fromList(string.codeUnits);
    }

    setUp(() {
      firestore = FirebaseFirestore.instance;
    });

    group('FirebaseFirestore.loadBundle()', () {
      test('loadBundle()', () async {
        Uint8List buffer = await loadBundleSetup();
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

      test('loadBundle(): LoadBundleTaskProgress stream snapshots', () async {
        Uint8List buffer = await loadBundleSetup();
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
    });

    group('FirebaeFirestore.namedQueryGet()', () {
      test('namedQueryGet() successful', () async {
        Uint8List buffer = await loadBundleSetup();
        LoadBundleTask task = firestore.loadBundle(buffer);

        // ensure the bundle has been completely cached
        await task.stream.last;

        // namedQuery 'named-bundle-test' which returns a QuerySnaphot of the same 3 documents
        // with 'number' property
        QuerySnapshot<Map<String, Object?>> snapshot =
            await firestore.namedQueryGet('named-bundle-test',
                options: const GetOptions(source: Source.cache));

        expect(
          snapshot.docs.map((document) => document['number']),
          everyElement(anyOf(1, 2, 3)),
        );
      });

      test('namedQueryGet() error', () async {
        Uint8List buffer = await loadBundleSetup();
        LoadBundleTask task = firestore.loadBundle(buffer);

        // ensure the bundle has been completely cached
        await task.stream.last;

        await expectLater(
          firestore.namedQueryGet(
            'wrong-name',
            options: const GetOptions(source: Source.cache),
          ),
          throwsA(
            isA<FirebaseException>().having((e) => e.message, 'message',
                contains('Named query has not been found')),
          ),
        );
      }, skip: kIsWeb);
    });
  });
}
