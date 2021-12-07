// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm_example/movie.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QueryReference', () {
    late FirebaseFirestore defaultFirestore;
    late FirebaseFirestore customFirestore;

    setUpAll(() async {
      defaultFirestore = FirebaseFirestore.instanceFor(
        app: await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyAHAsf51D0A407EklG1bs-5wA7EbyfNFg0',
            appId: '1:448618578101:ios:3a3c8ae9cb0b6408ac3efc',
            messagingSenderId: '448618578101',
            projectId: 'react-native-firebase-testing',
            authDomain: 'react-native-firebase-testing.firebaseapp.com',
            iosClientId:
                '448618578101-m53gtqfnqipj12pts10590l37npccd2r.apps.googleusercontent.com',
          ),
        ),
      );
      customFirestore = FirebaseFirestore.instanceFor(
        app: await Firebase.initializeApp(
          name: 'custom-query-app',
          options: FirebaseOptions(
            apiKey: defaultFirestore.app.options.apiKey,
            appId: defaultFirestore.app.options.appId,
            messagingSenderId: defaultFirestore.app.options.messagingSenderId,
            projectId: defaultFirestore.app.options.projectId,
          ),
        ),
      );
    });

    group('root query', () {
      test('overrides ==', () {
        expect(
          MovieCollectionReference().limit(1),
          MovieCollectionReference(defaultFirestore).limit(1),
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
          MovieCollectionReference(defaultFirestore)
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
