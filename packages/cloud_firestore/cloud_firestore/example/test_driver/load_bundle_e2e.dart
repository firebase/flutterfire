// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart';
import 'package:http/http.dart' as http;

void runLoadBundleTests() {
  group('$DocumentReference', () {
    late FirebaseFirestore firestore;
    final url = Uri.https('api.rnfirebase.io', '/firestore/bundle');
    late Uint8List buffer;
    const String collection = 'firestore-bundle-tests';

    Future<void> loadBundleSetup() async {
      // endpoint serves a bundle with 3 documents each containing
      // a 'number' property that increments in value 1-3.
      final response = await http.get(url);
      String string = response.body;
      buffer = Uint8List.fromList(string.codeUnits);
    }

    setUp(() {
      firestore = FirebaseFirestore.instance;
    });

    group('FirebaseFirestore.loadBundle()', () {
      test('loadBundle()', () async {
        await loadBundleSetup();
        LoadBundleTask task = firestore.loadBundle(buffer);

        // ensure the bundle has been completely cached
        await task.stream().last;

        QuerySnapshot<Map<String, Object?>> snapshot = await firestore
            .collection(collection)
            .orderBy('number')
            .get(const GetOptions(source: Source.cache));

        expect(snapshot.docs[0]['number'], 1);
        expect(snapshot.docs[1]['number'], 2);
        expect(snapshot.docs[2]['number'], 3);
      });

      test('loadBundle(): LoadBundleTaskProgress stream snapshots', () async {
        await loadBundleSetup();
        LoadBundleTask task = firestore.loadBundle(buffer);

        final list = await task.stream().toList();

        expect(list.map((e) => e.totalDocuments), everyElement(isNonNegative));
        expect(list.map((e) => e.bytesLoaded), everyElement(isNonNegative));
        expect(list.map((e) => e.documentsLoaded), everyElement(isNonNegative));
        expect(list.map((e) => e.totalBytes), everyElement(isNonNegative));
        expect(list, everyElement(isInstanceOf<LoadBundleTaskSnapshot>()));
        expect(
            list.map((e) => e.taskState),
            everyElement(anyOf(
                LoadBundleTaskState.running, LoadBundleTaskState.success)));

        LoadBundleTaskSnapshot lastSnapshot = list.last;
        expect(lastSnapshot.taskState, LoadBundleTaskState.success);
      });
    });
  });
}
