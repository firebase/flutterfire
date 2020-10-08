// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

// ignore: public_member_api_docs
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> _initializeFlutterFireFuture;
  FirebaseMessaging _messaging;
  String _homeScreenText = "Waiting for token...";
  final TextEditingController _topicController =
      TextEditingController(text: 'topic');

  bool _topicButtonsDisabled = false;

  // Define an async function to initialize FlutterFire
  Future<void> _initializeFlutterFire() async {
    // FirebaseMessaging.configure(onMessage: (RemoteMessage message) async {
    //   print("onMessage: $message");
    // }, onBackgroundMessage: (RemoteMessage message) async {
    //   print("onMessage: $message");
    // });

    // Wait for Firebase to initialize
    await Firebase.initializeApp();
    _messaging = await FirebaseMessaging.instance;
    await _messaging.getToken().then((String token) {
      print('token $token');
      assert(token != null);
      setState(() {
        _homeScreenText = "Push Messaging token: $token";
      });
    });

    print('initial notification ${_messaging.initialNotification}');
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
          title: const Text('Messaging example app'),
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
                      Text(_homeScreenText),
                      RaisedButton(
                          child: const Text('isAutoInitEnabled'),
                          onPressed: () {
                            print(
                                'Auto Init Enabled is ${_messaging.isAutoInitEnabled}');
                          }),
                      RaisedButton(
                          child: const Text('setAutoInitEnabled'),
                          onPressed: () async {
                            var result = _messaging.isAutoInitEnabled;
                            print(
                                'Before: Setting Auto Init Enabled to ${!result}');
                            await _messaging.setAutoInitEnabled(!result);
                            print(
                                'After: Auto Init Enabled is ${_messaging.isAutoInitEnabled}');
                          }),
                      Row(children: <Widget>[
                        Expanded(
                          child: TextField(
                              controller: _topicController,
                              onChanged: (String v) {
                                setState(() {
                                  _topicButtonsDisabled = v.isEmpty;
                                });
                              }),
                        ),
                        FlatButton(
                          child: const Text("subscribe"),
                          onPressed: _topicButtonsDisabled
                              ? null
                              : () {
                                  _messaging
                                      .subscribeToTopic(_topicController.text);
                                  _clearTopicText();
                                },
                        ),
                        FlatButton(
                          child: const Text("unsubscribe"),
                          onPressed: _topicButtonsDisabled
                              ? null
                              : () {
                                  _messaging.unsubscribeFromTopic(
                                      _topicController.text);
                                  _clearTopicText();
                                },
                        ),
                      ])
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

  void _clearTopicText() {
    setState(() {
      _topicController.text = "";
      _topicButtonsDisabled = true;
    });
  }
}
