// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                // Running these APIs manually as they're failing on CI due to required keychain sharing entitlements
                // See this issue https://github.com/firebase/flutterfire/issues/9538
                // You will also need to add the keychain sharing entitlements to this test app and sign code with development team for app & tests to successfully run
                if (Platform.isMacOS && kDebugMode) {
                  // ignore_for_file: avoid_print
                  await FirebaseRemoteConfig.instance.fetchAndActivate();
                  print('Fetched and activated remote config');

                  final id = await FirebaseInstallations.instance.getId();
                  print('Received Firebase App Installations id: $id');

                  // Wait a little so we don't get a delete-pending exception
                  await Future.delayed(const Duration(seconds: 8));

                  await FirebaseInstallations.instance.delete();
                  print('Deleted Firebase App Installations id');

                  final token = await FirebaseInstallations.instance.getToken();
                  print('Received Firebase App Installations token: $token');

                  const topic = 'test-topic';
                  await FirebaseMessaging.instance.subscribeToTopic(topic);
                  print('Firebase Messaging subscribed to topic: $topic');

                  await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
                  print('Firebase Messaging unsubscribed to topic: $topic');
                }
              },
              child: const Text('Test macOS tests manually'),
            ),
          ],
        ),
      ),
    );
  }
}
