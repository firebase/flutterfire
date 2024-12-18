// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void runVectorValueTests() {
  group('$VectorValue', () {
    late FirebaseFirestore firestore;

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

    testWidgets('handles empty vector', (_) async {
      DocumentReference<Map<String, dynamic>> doc =
          await initializeTest('vector-value-empty');

      await doc.set({
        'foo': const VectorValue([]),
      });

      DocumentSnapshot<Map<String, dynamic>> snapshot = await doc.get();

      VectorValue vectorValue = snapshot.data()!['foo'];
      expect(vectorValue, isA<VectorValue>());
      expect(vectorValue.toArray(), equals([]));
    });

    testWidgets('handles single dimension vector', (_) async {
      DocumentReference<Map<String, dynamic>> doc =
          await initializeTest('vector-value-single');

      await doc.set({
        'foo': const VectorValue([42.0]),
      });

      DocumentSnapshot<Map<String, dynamic>> snapshot = await doc.get();

      VectorValue vectorValue = snapshot.data()!['foo'];
      expect(vectorValue, isA<VectorValue>());
      expect(vectorValue.toArray(), equals([42.0]));
    });

    testWidgets('handles maximum dimensions vector', (_) async {
      List<double> maxDimensions = List.filled(2048, 1);
      DocumentReference<Map<String, dynamic>> doc =
          await initializeTest('vector-value-max-dimensions');

      await doc.set({
        'foo': VectorValue(maxDimensions),
      });

      DocumentSnapshot<Map<String, dynamic>> snapshot = await doc.get();

      VectorValue vectorValue = snapshot.data()!['foo'];
      expect(vectorValue, isA<VectorValue>());
      expect(vectorValue.toArray(), equals(maxDimensions));
    });

    testWidgets('handles maximum dimensions + 1 vector', (_) async {
      List<double> maxPlusOneDimensions = List.filled(2049, 1);
      DocumentReference<Map<String, dynamic>> doc =
          await initializeTest('vector-value-max-plus-one');

      await doc.set({
        'foo': VectorValue(maxPlusOneDimensions),
      });

      DocumentSnapshot<Map<String, dynamic>> snapshot = await doc.get();

      VectorValue vectorValue = snapshot.data()!['foo'];
      expect(vectorValue, isA<VectorValue>());
      expect(vectorValue.toArray(), equals(maxPlusOneDimensions));
    });

    testWidgets('handles very large values in vector', (_) async {
      DocumentReference<Map<String, dynamic>> doc =
          await initializeTest('vector-value-large-values');

      await doc.set({
        'foo': const VectorValue([1e10, -1e10]),
      });

      DocumentSnapshot<Map<String, dynamic>> snapshot = await doc.get();

      VectorValue vectorValue = snapshot.data()!['foo'];
      expect(vectorValue, isA<VectorValue>());
      expect(vectorValue.toArray(), equals([1e10, -1e10]));
    });

    testWidgets('handles floats in vector', (_) async {
      DocumentReference<Map<String, dynamic>> doc =
          await initializeTest('vector-value-floats');

      await doc.set({
        'foo': const VectorValue([3.14, 2.718]),
      });

      DocumentSnapshot<Map<String, dynamic>> snapshot = await doc.get();

      VectorValue vectorValue = snapshot.data()!['foo'];
      expect(vectorValue, isA<VectorValue>());
      expect(vectorValue.toArray(), equals([3.14, 2.718]));
    });

    testWidgets('handles negative values in vector', (_) async {
      DocumentReference<Map<String, dynamic>> doc =
          await initializeTest('vector-value-negative');

      await doc.set({
        'foo': const VectorValue([-42.0, -100.0]),
      });

      DocumentSnapshot<Map<String, dynamic>> snapshot = await doc.get();

      VectorValue vectorValue = snapshot.data()!['foo'];
      expect(vectorValue, isA<VectorValue>());
      expect(vectorValue.toArray(), equals([-42.0, -100.0]));
    });
  });
}
