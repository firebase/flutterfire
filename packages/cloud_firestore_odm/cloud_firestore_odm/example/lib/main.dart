// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'movie_detail_screen.dart';
import 'movies_screen.dart';

/// Requires that a Firestore emulator is running locally.
/// See https://firebase.flutter.dev/docs/firestore/usage#emulator-usage
// ignore: constant_identifier_names
const USE_FIRESTORE_EMULATOR = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if (USE_FIRESTORE_EMULATOR) {
    FirebaseFirestore.instance.settings = const Settings(
      host: 'localhost:8080',
      sslEnabled: false,
      persistenceEnabled: false,
    );
  }
  runApp(const FirestoreExampleApp());
}

final _movieDetailsUri = RegExp(r'^/movies/([a-zA-Z0-9]+?)$');

/// The entry point of the application.
///
/// Returns a [MaterialApp].
class FirestoreExampleApp extends StatelessWidget {
  const FirestoreExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Example App',
      theme: ThemeData.dark(),
      onGenerateRoute: (settings) {
        if (settings.name == null) {
          throw UnsupportedError('Routes must be named');
        }

        final match = _movieDetailsUri.firstMatch(settings.name!);
        if (match != null) {
          return MaterialPageRoute<void>(
            builder: (context) {
              return MovieDetail(movieID: match.group(1)!);
            },
          );
        }

        return null;
      },
      home: const FilmList(),
    );
  }
}
