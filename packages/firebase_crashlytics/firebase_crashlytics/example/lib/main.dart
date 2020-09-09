// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Toggle this to cause an async error to be thrown during initialization
// and to test that runZonedGuarded() catches the error
final _kShouldTestAsyncErrorOnInit = false;

// Toggle this for testing Crashlytics in your app locally.
final _kTestingCrashlytics = true;

main() {
  WidgetsFlutterBinding.ensureInitialized();
  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stackTrace) {
    print('runZonedGuarded: Caught error in my root zone.');
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

// ignore: public_member_api_docs
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> _initializeFlutterFireFuture;

  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final List<int> list = <int>[];
      print(list[100]);
    });
  }

  // Define an async function to initialize FlutterFire
  Future<void> _initializeFlutterFire() async {
    // Wait for Firebase to initialize
    await Firebase.initializeApp();

    if (_kTestingCrashlytics) {
      // Force enable crashlytics collection enabled if we're testing it.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Else only enable it in non-debug builds.
      // You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
    }

    // Pass all uncaught errors to Crashlytics.
    Function originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      // Forward to original handler.
      originalOnError(errorDetails);
    };

    if (_kShouldTestAsyncErrorOnInit) {
      await _testAsyncErrorOnInit();
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeFlutterFireFuture = _initializeFlutterFire();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Crashlytics example app'),
        ),
        body: FutureBuilder(
          future: _initializeFlutterFireFuture,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                return Center(
                  child: Column(
                    children: <Widget>[
                      RaisedButton(
                          child: const Text('Key'),
                          onPressed: () {
                            FirebaseCrashlytics.instance
                                .setCustomKey('example', 'flutterfire');
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Custom Key "example: flutterfire" has been set \n'
                                  'Key will appear in Firebase Console once app has crashed and reopened'),
                              duration: Duration(seconds: 5),
                            ));
                          }),
                      RaisedButton(
                          child: const Text('Log'),
                          onPressed: () {
                            FirebaseCrashlytics.instance
                                .log('This is a log example');
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'The message "This is a log example" has been logged \n'
                                  'Message will appear in Firebase Console once app has crashed and reopened'),
                              duration: Duration(seconds: 5),
                            ));
                          }),
                      RaisedButton(
                          child: const Text('Crash'),
                          onPressed: () async {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('App will crash is 5 seconds \n'
                                  'Please reopen to send data to Crashlytics'),
                              duration: Duration(seconds: 5),
                            ));

                            // Delay crash for 5 seconds
                            sleep(const Duration(seconds: 5));

                            // Use FirebaseCrashlytics to throw an error. Use this for
                            // confirmation that errors are being correctly reported.
                            FirebaseCrashlytics.instance.crash();
                          }),
                      RaisedButton(
                          child: const Text('Throw Error'),
                          onPressed: () {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('Thrown error has been caught \n'
                                  'Please crash and reopen to send data to Crashlytics'),
                              duration: Duration(seconds: 5),
                            ));

                            // Example of thrown error, it will be caught and sent to
                            // Crashlytics.
                            throw StateError('Uncaught error thrown by app');
                          }),
                      RaisedButton(
                          child: const Text('Async out of bounds'),
                          onPressed: () {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Uncaught Exception that is handled by second parameter of runZonedGuarded \n'
                                  'Please crash and reopen to send data to Crashlytics'),
                              duration: Duration(seconds: 5),
                            ));

                            // Example of an exception that does not get caught
                            // by `FlutterError.onError` but is caught by
                            // `runZonedGuarded`.
                            runZonedGuarded(() {
                              Future<void>.delayed(const Duration(seconds: 2),
                                  () {
                                final List<int> list = <int>[];
                                print(list[100]);
                              });
                            }, FirebaseCrashlytics.instance.recordError);
                          }),
                      RaisedButton(
                          child: const Text('Record Error'),
                          onPressed: () async {
                            try {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('Recorded Error  \n'
                                    'Please crash and reopen to send data to Crashlytics'),
                                duration: Duration(seconds: 5),
                              ));
                              throw 'error_example';
                            } catch (e, s) {
                              // "context" will append the word "thrown" in the
                              // Crashlytics console.
                              await FirebaseCrashlytics.instance
                                  .recordError(e, s, context: 'as an example');
                            }
                          }),
                    ],
                  ),
                );
                break;
              default:
                return Center(child: Text('Loading'));
            }
          },
        ),
      ),
    );
  }
}
