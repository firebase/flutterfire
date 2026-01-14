// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:core';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_functions_example/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // You should have the Functions Emulator running locally to use it
  // https://firebase.google.com/docs/functions/local-emulator
  FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List fruit = [];
  List streamResult = [];

  @override
  void initState() {
    super.initState();
    streamFunction();
  }

  void streamFunction() {
    fruit.clear();
    FirebaseFunctions.instance
        .httpsCallable('testStreamResponse')
        .stream<String, List<dynamic>>()
        .listen(
      (data) {
        switch (data) {
          case Chunk<String, List<dynamic>>(:final partialData):
            setState(() {
              // adds individual stream values to list
              fruit.add(partialData);
            });
          case Result<String, List<dynamic>>(:final result):
            setState(() {
              // stores complete stream result
              streamResult = List.from(result.data);
            });
        }
      },
      onError: (e) {
        debugPrint('Error: $e');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localhostMapped =
        kIsWeb || !Platform.isAndroid ? 'localhost' : '10.0.2.2';

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Firebase Functions Example'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: fruit.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${fruit[index]}'),
                  );
                },
              ),
            ),
            Visibility(
              visible: streamResult.isNotEmpty,
              child: const Text(
                "Stream's Complete Result: ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: streamResult.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${streamResult[index]}'),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  onPressed: streamFunction,
                  label: const Text('Call Stream Function'),
                  icon: const Icon(Icons.cloud),
                  backgroundColor: Colors.deepOrange,
                ),
                const SizedBox(height: 10),
                FloatingActionButton.extended(
                  onPressed: () async {
                    // See .github/workflows/scripts/functions/src/index.ts for the example function we
                    // are using for this example
                    HttpsCallable callable =
                        FirebaseFunctions.instance.httpsCallable(
                      'listFruit',
                      options: HttpsCallableOptions(
                        timeout: const Duration(seconds: 5),
                      ),
                    );

                    await callingFunction(callable, context);
                  },
                  label: const Text('Call Function'),
                  icon: const Icon(Icons.cloud),
                  backgroundColor: Colors.deepOrange,
                ),
                const SizedBox(height: 10),
                FloatingActionButton.extended(
                  onPressed: () async {
                    // See .github/workflows/scripts/functions/src/index.ts for the example function we
                    // are using for this example
                    HttpsCallable callable =
                        FirebaseFunctions.instance.httpsCallableFromUrl(
                      'http://$localhostMapped:5001/flutterfire-e2e-tests/us-central1/listfruits2ndgen',
                      options: HttpsCallableOptions(
                        timeout: const Duration(seconds: 5),
                      ),
                    );

                    await callingFunction(callable, context);
                  },
                  label: const Text('Call 2nd Gen Function'),
                  icon: const Icon(Icons.cloud),
                  backgroundColor: Colors.deepOrange,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> callingFunction(
    HttpsCallable callable,
    BuildContext context,
  ) async {
    try {
      final result = await callable();
      setState(() {
        fruit.clear();
        streamResult.clear();
        result.data.forEach((f) {
          fruit.add(f);
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ERROR: $e'),
        ),
      );
    }
  }
}
