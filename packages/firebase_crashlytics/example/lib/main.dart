// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

void main() {
  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runZoned(() {
    runApp(MyApp());
  }, onError: Crashlytics.instance.recordError);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Crashlytics example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              FlatButton(
                  child: const Text('Key'),
                  onPressed: () {
                    Crashlytics.instance.setString('foo', 'bar');
                  }),
              FlatButton(
                  child: const Text('Log'),
                  onPressed: () {
                    Crashlytics.instance.log('baz');
                  }),
              FlatButton(
                  child: const Text('Crash'),
                  onPressed: () {
                    // Use Crashlytics to throw an error. Use this for
                    // confirmation that errors are being correctly reported.
                    Crashlytics.instance.crash();
                  }),
              FlatButton(
                  child: const Text('Throw Error'),
                  onPressed: () {
                    // Example of thrown error, it will be caught and sent to
                    // Crashlytics.
                    throw StateError('Uncaught error thrown by app.');
                  }),
              FlatButton(
                  child: const Text('Async out of bounds'),
                  onPressed: () {
                    // Example of an exception that does not get caught
                    // by `FlutterError.onError` but is caught by the `onError` handler of
                    // `runZoned`.
                    Future<void>.delayed(const Duration(seconds: 2), () {
                      final List<int> list = <int>[];
                      print(list[100]);
                    });
                  }),
              FlatButton(
                  child: const Text('Record Error'),
                  onPressed: () {
                    try {
                      throw 'error_example';
                    } catch (e, s) {
                      // "context" will append the word "thrown" in the
                      // Crashlytics console.
                      Crashlytics.instance
                          .recordError(e, s, context: 'as an example');
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
