// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:cloud_firestore_odm_example/movie.dart';
import 'package:firebase_core/firebase_core.dart';
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

// ignore: avoid_implementing_value_types
class FakeFirebaseApp extends Mock implements FirebaseApp {}
