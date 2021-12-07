// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm_generator_integration_test/simple.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

void main() {
  group('@Collection(path)', () {
    setUpAll(() async {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyAHAsf51D0A407EklG1bs-5wA7EbyfNFg0',
          appId: '1:448618578101:ios:3a3c8ae9cb0b6408ac3efc',
          messagingSenderId: '448618578101',
          projectId: 'react-native-firebase-testing',
          authDomain: 'react-native-firebase-testing.firebaseapp.com',
          iosClientId:
              '448618578101-m53gtqfnqipj12pts10590l37npccd2r.apps.googleusercontent.com',
        ),
      );
    });

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
}
