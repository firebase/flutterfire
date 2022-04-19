// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm_example/movie.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QueryReference', () {
    late FirebaseFirestore customFirestore;

    setUpAll(() async {
      customFirestore = FirebaseFirestore.instanceFor(
        app: await Firebase.initializeApp(
          name: 'custom-query-app',
          options: FirebaseOptions(
            apiKey: Firebase.app().options.apiKey,
            appId: Firebase.app().options.appId,
            messagingSenderId: Firebase.app().options.messagingSenderId,
            projectId: Firebase.app().options.projectId,
          ),
        ),
      );
    });

    group('root query', () {
      test('overrides ==', () {
        expect(
          MovieCollectionReference().limit(1),
          MovieCollectionReference(FirebaseFirestore.instance).limit(1),
        );
        expect(
          MovieCollectionReference().limit(1),
          isNot(MovieCollectionReference().limit(2)),
        );

        expect(
          MovieCollectionReference(customFirestore).limit(1),
          isNot(MovieCollectionReference().limit(1)),
        );
        expect(
          MovieCollectionReference(customFirestore).limit(1),
          MovieCollectionReference(customFirestore).limit(1),
        );
      });
    });

    group('sub query', () {
      test('overrides ==', () {
        expect(
          MovieCollectionReference().doc('123').comments.limit(1),
          MovieCollectionReference(FirebaseFirestore.instance)
              .doc('123')
              .comments
              .limit(1),
        );
        expect(
          MovieCollectionReference().doc('123').comments.limit(1),
          isNot(MovieCollectionReference().doc('456').comments.limit(1)),
        );
        expect(
          MovieCollectionReference().doc('123').comments.limit(1),
          isNot(MovieCollectionReference().doc('123').comments.limit(2)),
        );

        expect(
          MovieCollectionReference(customFirestore)
              .doc('123')
              .comments
              .limit(1),
          isNot(MovieCollectionReference().doc('123').comments.limit(1)),
        );
        expect(
          MovieCollectionReference(customFirestore)
              .doc('123')
              .comments
              .limit(1),
          MovieCollectionReference(customFirestore)
              .doc('123')
              .comments
              .limit(1),
        );
      });
    });
  });
}
