// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

late DatabaseReference ref;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  ref = FirebaseDatabase.instance.ref('users');

  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: FirebaseDatabaseDataTable(
            query: ref,
            columnLabels: const {
              'firstName': Text('First name'),
              'lastName': Text('Last name'),
              'prefix': Text('Prefix'),
              'userName': Text('User name'),
              'email': Text('Email'),
              'number': Text('Phone number'),
              'streetName': Text('Street name'),
              'city': Text('City'),
              'zipCode': Text('Zip code'),
              'country': Text('Country'),
            },
          ),
        ),
      ),
    );
  }
}
