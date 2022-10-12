// Copyright 2021, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:cloud_firestore_odm_example/movie.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';

Future<T>
    initializeTest<T extends FirestoreCollectionReference<Object?, Object?>>(
  T ref,
) async {
  final snapshot = await ref.reference.get();

  await Future.wait<void>(
    snapshot.docs.map((e) => e.reference.delete()),
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
  String id = '',
}) {
  return Movie(
    genre: genre,
    likes: likes,
    poster: poster,
    rated: rated,
    runtime: runtime,
    title: title,
    year: year,
    id: id,
  );
}

// ignore: avoid_implementing_value_types
class FakeFirebaseApp extends Mock implements FirebaseApp {}
