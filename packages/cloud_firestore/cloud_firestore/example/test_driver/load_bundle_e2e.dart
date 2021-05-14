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
    late Uri url;
    late Uint8List buffer;
    const String collection = 'firestore-bundle-tests';
    setUpAll(() async {
      firestore = FirebaseFirestore.instance;
      // endpoint serves a bundle with 3 documents each containing
      // a 'number' property that increments in value 1-3.
      url = Uri.https('api.rnfirebase.io', '/firestore/bundle');
      final response = await http.get(url);
      String string = response.body;
      buffer = Uint8List.fromList(string.codeUnits);
    });

    group('FirebaseFirestore.loadBundle()', () {
      test('loadBundle()', () async {
        LoadBundleTask task = firestore.loadBundle(buffer);

        await task.stream.last;

        QuerySnapshot<Map<String, Object?>> snapshot = await firestore
            .collection(collection)
            .orderBy('number')
            .get(const GetOptions(source: Source.cache));

        expect(snapshot.docs[0]['number'], 1);
        expect(snapshot.docs[1]['number'], 2);
        expect(snapshot.docs[2]['number'], 3);
      });

      test('loadBundle(): LoadBundleTaskProgress stream snapshots', () async {
        LoadBundleTask task = firestore.loadBundle(buffer);

        List<LoadBundleTaskSnapshot> list = [];

        task.stream.listen((event) {
          list.add(event);
        });

        LoadBundleTaskSnapshot lastSnapshot = await task.stream.last;

        if (list.length > 1) {
          expect(list.first.taskState, LoadBundleTaskState.running);
          expect(lastSnapshot.taskState, LoadBundleTaskState.success);
        } else {
          expect(lastSnapshot.taskState, LoadBundleTaskState.success);
        }

        expect(lastSnapshot.bytesLoaded, isNonNegative);
        expect(lastSnapshot.documentsLoaded, isNonNegative);
        expect(lastSnapshot.totalBytes, isNonNegative);
        expect(lastSnapshot.totalDocuments, isNonNegative);

        expect(lastSnapshot, isInstanceOf<LoadBundleTaskSnapshot>());
      });
    });
  });
}
