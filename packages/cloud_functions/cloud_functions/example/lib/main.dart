// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'dart:async';
import 'dart:core';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFunctions.instance
      .useFunctionsEmulator(origin: 'http://localhost:5001');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List fruit = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Firebase Functions Example'),
        ),
        body: Center(
            child: ListView.builder(
                itemCount: fruit.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${fruit[index]}'),
                  );
                })),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton.extended(
            onPressed: () async {
              // See index.js in the functions folder for the example function we
              // are using for this example
              HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
                  'listFruit',
                  options: HttpsCallableOptions(
                      timeout: const Duration(seconds: 5)));

              await callable().then((v) {
                setState(() {
                  fruit.clear();
                  v.data.forEach((f) {
                    fruit.add(f);
                  });
                });
              }).catchError((e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('ERROR: $e'),
                ));
              });
            },
            label: const Text('Call Function'),
            icon: const Icon(Icons.cloud),
            backgroundColor: Colors.deepOrange,
          ),
        ),
      ),
    );
  }
}
