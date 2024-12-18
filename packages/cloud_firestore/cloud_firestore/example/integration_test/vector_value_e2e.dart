// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void runVectorValueTests() {
  group('$VectorValue', () {
    late FirebaseFirestore /*?*/ firestore;

    setUpAll(() async {
      firestore = FirebaseFirestore.instance;
    });

    Future<DocumentReference<Map<String, dynamic>>> initializeTest(
      String path,
    ) async {
      String prefixedPath = 'flutter-tests/$path';
      await firestore.doc(prefixedPath).delete();
      return firestore.doc(prefixedPath);
    }

    testWidgets('sets a $VectorValue & returns one', (_) async {
      DocumentReference<Map<String, dynamic>> doc =
          await initializeTest('vector-value');

      await doc.set({
        'foo': const VectorValue([10.0, -10.0]),
      });

      DocumentSnapshot<Map<String, dynamic>> snapshot = await doc.get();

      VectorValue vectorValue = snapshot.data()!['foo'];
      expect(vectorValue, isA<VectorValue>());
      expect(vectorValue.toArray(), equals([10.0, -10.0]));
    });

    testWidgets('updates a $VectorValue & returns', (_) async {
      DocumentReference<Map<String, dynamic>> doc =
          await initializeTest('vector-value-update');

      await doc.set({
        'foo': const VectorValue([10.0, -10.0]),
      });

      await doc.update({
        'foo': const VectorValue([-10.0, 10.0]),
      });

      DocumentSnapshot<Map<String, dynamic>> snapshot = await doc.get();

      VectorValue vectorValue = snapshot.data()!['foo'];
      expect(vectorValue, isA<VectorValue>());
      expect(vectorValue.toArray(), equals([-10.0, 10.0]));
    });
  });
}
