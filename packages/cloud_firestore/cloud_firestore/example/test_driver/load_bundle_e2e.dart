// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

void runLoadBundleTests() {
  group('$DocumentReference', () {
    late FirebaseFirestore firestore;

    setUpAll(() async {
      firestore = FirebaseFirestore.instance;
    });

    group('FirebaseFirestore.loadBundle()', () {
      test('loadBundle()', () async {
        // endpoint serves a bundle with 3 documents each containing
        // a 'number' property that increments in value 1-3.
        //TODO(russellwheatley): move to RNFB testing API
        final url = Uri.https('', '/');
        final response = await http.get(url);

        String string = response.body;
        Uint8List buffer = new Uint8List.fromList(string.codeUnits);

        LoadBundleTask task = firestore.loadBundle(buffer);

        await task.stream.last;

        QuerySnapshot snapshot = await firestore
            .collection('flutter-tests')
            .orderBy('number')
            .get(GetOptions(source: Source.cache));

        expect(snapshot.docs[0]['number'], 1);
        expect(snapshot.docs[1]['number'], 2);
        expect(snapshot.docs[2]['number'], 3);
      });
    });
  });
}
