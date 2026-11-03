// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:core';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_functions_example/emulator_config.dart';
import 'package:cloud_functions_example/firebase_options.dart';
import 'package:cloud_functions_example/functions_backend.dart';
import 'package:cloud_functions_example/functions_environment.dart';
import 'package:dart_cloud_functions/dart_cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // You should have the Functions Emulator running locally to use it
  // https://firebase.google.com/docs/functions/local-emulator
  connectFunctionsEmulator(FirebaseFunctions.instance);
  connectDartFunctionsEmulator(DartFirebaseFunctions.instance);
  // Sign-in uses the Auth emulator, which the Functions emulator trusts. On
  // web, the Firebase JS SDK then adds a "Running in emulator mode" banner to
  // the bottom of the page. It stays up even while calls go to the deployed
  // project, and FlutterFire doesn't expose the SDK's option to turn it off.
  await connectAuthEmulator();

  // A second app for a deployed project, when the build has its settings.
  final deployed = await initializeDeployedEnvironment();

  runApp(MyApp(deployed: deployed));
}

class MyApp extends StatefulWidget {
  MyApp({Key? key, this.deployed}) : super(key: key);

  /// The deployed project, or `null` when the build has no settings for it.
  final FunctionsEnvironment? deployed;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final List<FunctionsEnvironment> environments = [
    FunctionsEnvironment.emulator(),
    if (widget.deployed case final deployed?) deployed,
  ];

  /// Where calls go. Starts with the deployed project when there is one.
  late FunctionsEnvironment environment = environments.last;

  /// Which implementation sends the calls.
  FunctionsImplementation implementation = FunctionsImplementation.native;
  StreamSubscription<StreamEvent>? streamSubscription;
  List fruit = [];
  List streamResult = [];
  String? streamError;

  /// Which call produced the results on screen, so calls that return the same
  /// data can be told apart.
  String? resultSource;

  /// Which user the server saw on the last "Who am I?" call.
  String? identity;

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

  void selectImplementation(FunctionsImplementation selected) {
    setState(() {
      implementation = selected;
    });
    streamFunction();
  }

  void selectEnvironment(FunctionsEnvironment selected) {
    setState(() {
      environment = selected;
    });
    streamFunction();
  }

  void streamFunction() {
    const what = 'testStreamResponse, streamed by name';
    final sender = implementation;
    final target = environment;
    final stopwatch = Stopwatch()..start();
    streamSubscription?.cancel();
    setState(() {
      fruit.clear();
      streamResult.clear();
      streamError = null;
      identity = null;
      resultSource = describeCall(what, sender, target);
    });
    streamSubscription = sender
        .backendFor(target.app)
        .streamByName('testStreamResponse')
        .listen(
          (event) {
            switch (event) {
              case StreamChunk(:final data):
                setState(() {
                  // adds individual stream values to list
                  fruit.add(data);
                });
              case StreamResult(:final data):
                setState(() {
                  // stores complete stream result
                  streamResult = List.from((data as List?) ?? const []);
                  resultSource = describeCall(
                    what,
                    sender,
                    target,
                    elapsed: stopwatch.elapsed,
                  );
                });
            }
          },
          onError: (e) {
            debugPrint('Error: $e');
            setState(() {
              streamError = '$e';
              resultSource = describeCall(what, sender, target, failed: true);
            });
          },
        );
  }

  /// Describes a call, e.g. "listFruit, called by name · sent by Dart to
  /// Deployed · 84 ms".
  String describeCall(
    String what,
    FunctionsImplementation sender,
    FunctionsEnvironment target, {
    Duration? elapsed,
    bool failed = false,
  }) {
    final outcome = switch ((failed, elapsed)) {
      (true, _) => 'failed',
      (false, null) => 'waiting…',
      (false, final Duration elapsed) => '${elapsed.inMilliseconds} ms',
    };
    return '$what · sent by ${sender.label} to ${target.label} · $outcome';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Firebase Functions Example')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SegmentedButton<FunctionsImplementation>(
                    segments: [
                      for (final option in FunctionsImplementation.values)
                        ButtonSegment(value: option, label: Text(option.label)),
                    ],
                    selected: {implementation},
                    onSelectionChanged: (selection) =>
                        selectImplementation(selection.single),
                  ),
                  SegmentedButton<FunctionsEnvironment>(
                    segments: [
                      for (final option in environments)
                        ButtonSegment(value: option, label: Text(option.label)),
                    ],
                    selected: {environment},
                    onSelectionChanged: (selection) =>
                        selectEnvironment(selection.single),
                  ),
                ],
              ),
            ),
            if (widget.deployed == null) const _DeployedSetupHint(),
            _AuthStatusBar(
              auth: FirebaseAuth.instanceFor(app: environment.app),
            ),
            if (resultSource != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Showing: $resultSource',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            if (identity != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  identity!,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
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
                  onPressed: () async {
                    // Both implementations attach the signed-in user's ID
                    // token, plus an App Check token once App Check is set
                    // up; only native attaches the FCM token.
                    await callingFunction(
                      'testEchoContext, called by name',
                      (sender) => sender.callByName(
                        'testEchoContext',
                        timeout: const Duration(seconds: 5),
                      ),
                      context,
                      show: showIdentity,
                    );
                  },
                  label: const Text('Who am I?'),
                  icon: const Icon(Icons.person),
                  backgroundColor: Colors.deepOrange,
                ),
                const SizedBox(height: 10),
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
                    final url = environment.listFruitsUrl;
                    await callingFunction(
                      'listfruits2ndgen, called by URL',
                      (sender) => sender.callByUrl(
                        url,
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
    BuildContext context, {
    void Function(Object? data)? show,
  }) async {
    // Capture the implementation and environment so switching mid-call doesn't
    // mislabel the result.
    final sender = implementation;
    final target = environment;
    final stopwatch = Stopwatch()..start();
    // Stop a running stream so its chunks don't mix into these results.
    await streamSubscription?.cancel();
    setState(() {
      resultSource = describeCall(what, sender, target);
    });
    try {
      final data = await call(sender.backendFor(target.app));
      setState(() {
        fruit.clear();
        streamResult.clear();
        streamError = null;
        identity = null;
        (show ?? showFruit)(data);
        resultSource = describeCall(
          what,
          sender,
          target,
          elapsed: stopwatch.elapsed,
        );
      });
    } catch (e) {
      setState(() {
        resultSource = describeCall(what, sender, target, failed: true);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ERROR: $e')));
    }
  }

  /// Shows a list of fruit returned by `listFruit` or `listfruits2ndgen`.
  void showFruit(Object? data) => fruit.addAll(data! as List);

  /// Shows which user `testEchoContext` says the server saw.
  void showIdentity(Object? data) {
    final echo = data! as Map;
    final uid = echo['authUid'];
    final token = echo['authorizationHeader'] == true ? 'sent' : 'not sent';
    identity = uid == null
        ? 'Server saw no signed-in user (auth token $token)'
        : 'Server saw user $uid (auth token $token)';
  }
}

/// Explains how to add a deployed project, or what its settings are missing.
class _DeployedSetupHint extends StatelessWidget {
  const _DeployedSetupHint();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // A project ID means a settings file was passed, but it's incomplete.
    final incomplete = DeployedConfig.projectId.isNotEmpty;
    final foreground = incomplete
        ? colors.onErrorContainer
        : colors.onSecondaryContainer;
    return Card(
      color: incomplete ? colors.errorContainer : colors.secondaryContainer,
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: ListTile(
        iconColor: foreground,
        textColor: foreground,
        leading: Icon(incomplete ? Icons.warning_amber : Icons.info_outline),
        title: Text(deployedSetupHint),
      ),
    );
  }
}

/// Signs in anonymously or out with [auth], and shows the current user.
///
/// [auth] belongs to the selected environment, so the emulator and the
/// deployed project each have their own user.
class _AuthStatusBar extends StatelessWidget {
  const _AuthStatusBar({required this.auth});

  final FirebaseAuth auth;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  user == null ? 'Signed out' : 'Signed in as ${user.uid}',
                ),
              ),
              TextButton(
                onPressed: () => _toggleSignIn(context, user),
                child: Text(user == null ? 'Sign in anonymously' : 'Sign out'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleSignIn(BuildContext context, User? user) async {
    try {
      if (user == null) {
        await auth.signInAnonymously();
      } else {
        await auth.signOut();
      }
    } catch (e) {
      // On macOS this fails without keychain entitlements.
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Auth error: $e')));
    }
  }
}
