// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_functions_example/firebase_options.dart';
import 'package:cloud_functions_example/functions_backend.dart';
import 'package:dart_cloud_functions/dart_cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // You should have the Functions Emulator running locally to use it
  // https://firebase.google.com/docs/functions/local-emulator
  FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
  DartFirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<FunctionsBackend> backends = [
    NativeFunctionsBackend(),
    DartFunctionsBackend(),
  ];
  late FunctionsBackend backend = backends.first;
  StreamSubscription<StreamResponse<String, List<dynamic>>>? streamSubscription;
  List fruit = [];
  List streamResult = [];
  String? streamError;

  /// Which call produced the results on screen, so calls that return the same
  /// data can be told apart.
  String? resultSource;

  @override
  void initState() {
    super.initState();
    streamFunction();
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  void selectBackend(FunctionsBackend selected) {
    setState(() {
      backend = selected;
    });
    streamFunction();
  }

  void streamFunction() {
    const what = 'testStreamResponse, streamed by name';
    final sender = backend;
    final stopwatch = Stopwatch()..start();
    streamSubscription?.cancel();
    setState(() {
      fruit.clear();
      streamResult.clear();
      streamError = null;
      resultSource = describeCall(what, sender);
    });
    streamSubscription = sender
        .streamByName('testStreamResponse')
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
                  resultSource = describeCall(
                    what,
                    sender,
                    elapsed: stopwatch.elapsed,
                  );
                });
            }
          },
          onError: (e) {
            debugPrint('Error: $e');
            setState(() {
              streamError = '$e';
              resultSource = describeCall(what, sender, failed: true);
            });
          },
        );
  }

  /// Describes a call, e.g. "listFruit, called by name · sent by Dart · 12 ms".
  String describeCall(
    String what,
    FunctionsBackend sender, {
    Duration? elapsed,
    bool failed = false,
  }) {
    final outcome = switch ((failed, elapsed)) {
      (true, _) => 'failed',
      (false, null) => 'waiting…',
      (false, final Duration elapsed) => '${elapsed.inMilliseconds} ms',
    };
    return '$what · sent by ${sender.label} · $outcome';
  }

  @override
  Widget build(BuildContext context) {
    final localhostMapped = kIsWeb || !Platform.isAndroid
        ? 'localhost'
        : '10.0.2.2';

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Firebase Functions Example')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: SegmentedButton<FunctionsBackend>(
                segments: [
                  for (final option in backends)
                    ButtonSegment(value: option, label: Text(option.label)),
                ],
                selected: {backend},
                onSelectionChanged: (selection) =>
                    selectBackend(selection.single),
              ),
            ),
            if (resultSource != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Showing: $resultSource',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            if (streamError != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Stream error: $streamError',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: fruit.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text('${fruit[index]}'));
                },
              ),
            ),
            Visibility(
              visible: streamResult.isNotEmpty,
              child: const Text(
                "Stream's Complete Result: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: streamResult.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text('${streamResult[index]}'));
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
                    await callingFunction(
                      'listFruit, called by name',
                      (sender) => sender.callByName(
                        'listFruit',
                        timeout: const Duration(seconds: 5),
                      ),
                      context,
                    );
                  },
                  label: const Text('Call by Name'),
                  icon: const Icon(Icons.cloud),
                  backgroundColor: Colors.deepOrange,
                ),
                const SizedBox(height: 10),
                FloatingActionButton.extended(
                  onPressed: () async {
                    // See .github/workflows/scripts/functions/src/index.ts for the example function we
                    // are using for this example
                    await callingFunction(
                      'listfruits2ndgen, called by URL',
                      (sender) => sender.callByUrl(
                        'http://$localhostMapped:5001/flutterfire-e2e-tests/us-central1/listfruits2ndgen',
                        timeout: const Duration(seconds: 5),
                      ),
                      context,
                    );
                  },
                  label: const Text('Call by URL'),
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
    String what,
    Future<Object?> Function(FunctionsBackend sender) call,
    BuildContext context,
  ) async {
    // Capture the backend so switching mid-call doesn't mislabel the result.
    final sender = backend;
    final stopwatch = Stopwatch()..start();
    // Stop a running stream so its chunks don't mix into these results.
    await streamSubscription?.cancel();
    setState(() {
      resultSource = describeCall(what, sender);
    });
    try {
      final data = await call(sender);
      setState(() {
        fruit.clear();
        streamResult.clear();
        streamError = null;
        fruit.addAll(data! as List);
        resultSource = describeCall(what, sender, elapsed: stopwatch.elapsed);
      });
    } catch (e) {
      setState(() {
        resultSource = describeCall(what, sender, failed: true);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ERROR: $e')));
    }
  }
}
