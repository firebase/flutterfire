// ignore_for_file: require_trailing_commas
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseInAppMessaging fiam = FirebaseInAppMessaging.instance;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('In-App Messaging example'),
        ),
        body: Builder(
          builder: (BuildContext context) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  AnalyticsEventExample(),
                  ProgrammaticTriggersExample(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProgrammaticTriggersExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            const Text(
              'Programmatic Trigger',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Manually trigger events programmatically '),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await MyApp.fiam.triggerEvent('awesome_event');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Triggering event: awesome_event'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text(
                'Programmatic Triggers'.toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AnalyticsEventExample extends StatelessWidget {
  Future<void> _sendAnalyticsEvent() async {
    await MyApp.analytics.logEvent(
      name: 'awesome_event',
      parameters: <String, dynamic>{
        //'id': 1, // not required?
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            const Text(
              'Log an analytics event',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Trigger an analytics event'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                _sendAnalyticsEvent();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Firing analytics event: awesome_event'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text(
                'Log event'.toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
