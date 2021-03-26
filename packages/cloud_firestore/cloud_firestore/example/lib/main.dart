// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Requires that a Firestore emulator is running locally.
/// See https://firebase.flutter.dev/docs/firestore/usage#emulator-usage
bool USE_FIRESTORE_EMULATOR = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // if (USE_FIRESTORE_EMULATOR) {
  //   FirebaseFirestore.instance.settings = const Settings(
  //       host: 'localhost:8080', sslEnabled: false, persistenceEnabled: false);
  // }
  runApp(FirestoreExampleApp());
}

/// The entry point of the application.
///
/// Returns a [MaterialApp].
class FirestoreExampleApp extends StatelessWidget {
  /// Given a [Widget], wrap and return a [MaterialApp].
  MaterialApp withMaterialApp(Widget body) {
    return MaterialApp(
      title: 'Firestore Example App',
      theme: ThemeData.dark(),
      home: Scaffold(
        body: body,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return withMaterialApp(Center(child: FilmList()));
  }
}

class MyException implements Exception {
  const MyException();
  String toString() => 'russ personal exception';
}

/// Holds all example app films
class FilmList extends StatefulWidget {
  @override
  _FilmListState createState() => _FilmListState();
}

class _FilmListState extends State<FilmList> {
  String _filterOrSort = 'sort_year';

  _FilmListState();

  Future<void> _runTransaction() async {
    await FirebaseFirestore.instance
        .runTransaction((transaction) async => {throw const MyException()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Firestore Example: Movies'),
            ],
          ),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              try {
                await _runTransaction();
              } on MyException catch (e) {
                print("MyException");
                print(e);
              } on FirebaseException catch (e) {
                print("FirebaseException");
                print(e.code);
                print(e.message);
              }
            },
            child: const Text('press me'),
          ),
        ));
  }
}
