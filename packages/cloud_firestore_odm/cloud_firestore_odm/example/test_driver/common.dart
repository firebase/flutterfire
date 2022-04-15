// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:cloud_firestore_odm_example/movie.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mockito/mockito.dart';

Future<T> initializeTest<T extends FirestoreCollectionReference<Object?>>(
  T ref,
) async {
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);

  final snapshot = await ref.reference.get();

  await Future.forEach<QueryDocumentSnapshot<Object?>>(
    snapshot.docs,
    (doc) => doc.reference.delete(),
  );

  return ref;
}

Movie createMovie({
  List<String> genre = const [],
  int likes = 0,
  String poster = '',
  String rated = '',
  String runtime = '',
  String title = '',
  int year = 1990,
}) {
  return Movie(
    genre: genre,
    likes: likes,
    poster: poster,
    rated: rated,
    runtime: runtime,
    title: title,
    year: year,
  );
}

FutureOr<FirebaseApp> maybeInitializeDefaultApp() {
  final app = Firebase.apps.firstWhereOrNull((app) => app.name == '[DEFAULT]');
  if (app != null) return app;

  return Firebase.initializeApp(
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
}

// ignore: avoid_implementing_value_types
class FakeFirebaseApp extends Mock implements FirebaseApp {}
