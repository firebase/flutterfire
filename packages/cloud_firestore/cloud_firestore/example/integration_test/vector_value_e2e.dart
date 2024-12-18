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

    test('sets a $VectorValue & returns one', () async {
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

    test('updates a $VectorValue & returns', () async {
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

    test('handles empty vector', () async {
      DocumentReference<Map<String, dynamic>> doc =
          await initializeTest('vector-value-empty');

      try {
        await doc.set({
          'foo': const VectorValue([]),
        });
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e, isA<FirebaseException>());
        expect(
          (e as FirebaseException).code.contains('invalid-argument'),
          isTrue,
        );
      }
    });

    test('handles single dimension vector', () async {
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

    test('handles maximum dimensions vector', () async {
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

    test('handles maximum dimensions + 1 vector', () async {
      List<double> maxPlusOneDimensions = List.filled(2049, 1);
      DocumentReference<Map<String, dynamic>> doc =
          await initializeTest('vector-value-max-plus-one');

      try {
        await doc.set({
          'foo': VectorValue(maxPlusOneDimensions),
        });

        fail('Should have thrown an exception');
      } catch (e) {
        expect(e, isA<FirebaseException>());
        expect(
          (e as FirebaseException).code.contains('invalid-argument'),
          isTrue,
        );
      }
    });

    test('handles very large values in vector', () async {
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

    test('handles floats in vector', () async {
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

    test('handles negative values in vector', () async {
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
