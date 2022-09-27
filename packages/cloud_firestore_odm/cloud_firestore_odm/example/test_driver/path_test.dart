// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm_generator_integration_test/simple.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

void main() {
  group('@Collection(path)', () {
    group('root collection paths', () {
      test('supports direct path to sub-collection', () async {
        final collection = await initializeTest(explicitRef);

        await FirebaseFirestore.instance
            .collection('root/doc/path')
            .add(<String, Object?>{'value': 42});

        final snapshot = await collection.get();

        expect(snapshot.docs, [
          isA<ExplicitPathQueryDocumentSnapshot>()
              .having((e) => e.data.value, 'data.value', 42)
        ]);
      });

      test('explicit sub-collections can have sub-collections', () async {
        final collection = await initializeTest(explicitRef.doc('123').sub);

        await FirebaseFirestore.instance
            .collection('root/doc/path/123/sub')
            .add(<String, Object?>{'value': 42});

        final snapshot = await collection.get();

        expect(snapshot.docs, [
          isA<ExplicitSubPathQueryDocumentSnapshot>()
              .having((e) => e.data.value, 'data.value', 42)
        ]);
      });
    });

    group('sub collection name', () {
      test('renames collection name as camelCase by default', () async {
        final collection = await initializeTest(rootRef.doc('123').asCamelCase);

        await FirebaseFirestore.instance
            .collection('root/123/as-camel-case')
            .add(<String, Object?>{'value': 42});

        final snapshot = await collection.get();

        expect(snapshot.docs, [
          isA<AsCamelCaseQueryDocumentSnapshot>()
              .having((e) => e.data.value, 'data.value', 42)
        ]);
      });

      test('can be manually specified through the Collection annotation',
          () async {
        final collection =
            await initializeTest(rootRef.doc('123').thisIsACustomName);

        await FirebaseFirestore.instance
            .collection('root/123/custom-sub-name')
            .add(<String, Object?>{'value': 42});

        final snapshot = await collection.get();

        expect(snapshot.docs, [
          isA<CustomSubNameQueryDocumentSnapshot>()
              .having((e) => e.data.value, 'data.value', 42)
        ]);
      });
    });
  });

  group('collection class prefix', () {
    test('can be manually specified through the Collection annotation',
        () async {
      final collection =
          await initializeTest(rootRef.doc('123').customClassPrefix);

      await FirebaseFirestore.instance
          .collection('root/123/custom-class-prefix')
          .add(<String, Object?>{'value': 42});

      final snapshot = await collection.get();

      expect(snapshot.docs, [
        isA<ThisIsACustomPrefixDocumentSnapshot>()
            .having((e) => e.data?.value, 'data.value', 42)
      ]);
    });
  });
}
