// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'message.dart';
import 'initial_notification.dart';

import 'token_monitor.dart';
import 'permissions.dart';
import 'message_list.dart';

/// Define a top-level named hadler which background/terminated messages will
/// call.
///
/// To verify things are working, check out the native platform logs.
BackgroundMessageHandler backgroundMessageHandler =
    (RemoteMessage message) async {
  return "Handling background message ${message.messageId}";
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);

  // Get a message which caused the application to open via user interaction (may be null)
  // RemoteMessage initialMessage =
  //     await FirebaseMessaging.instance.getInitialMessage();

  // await FirebaseMessaging.instance.getInitialMessage();

  // Pass the message to the application
  runApp(MessagingExampleApp(null));
}

class MessagingExampleApp extends StatelessWidget {
  MessagingExampleApp(this._initialMessage);

  final RemoteMessage _initialMessage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messaging Example App',
      theme: ThemeData.dark(),
      initialRoute: _initialMessage == null ? '/' : '/initial-notification',
      routes: {
        '/': (context) => Application(),
        '/message': (context) => Message(),
        '/initial-notification': (context) =>
            InitialNotification(_initialMessage?.notification),
      },
    );
  }
}

class Application extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Application();
}

// Crude counter to make messages unique
int _messageCount = 0;

/// The API endpoint here accepts a raw FCM payload for demonstration purposes.
String constructFCMPayload(String token) {
  _messageCount++;
  return jsonEncode({
    'token': token,
    'data': {
      'via': 'FlutterFire Cloud Messaging',
      'count': _messageCount.toString(),
    },
  });
}

class _Application extends State<Application> {
  String _token;

  Future<void> sendPushMessage(BuildContext) async {
    if (_token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      await http.post(
        'https://api.rnfirebase.io/messaging/send',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: constructFCMPayload(_token),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cloud Messaging"),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () => sendPushMessage(context),
          child: Icon(Icons.send),
          backgroundColor: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          MetaCard("Permissions", Permissions()),
          MetaCard("FCM Token", TokenMonitor((token) {
            _token = token;
            return token == null
                ? CircularProgressIndicator()
                : Text(token, style: TextStyle(fontSize: 12));
          })),
          MetaCard("Message Stream", MessageList()),
        ]),
      ),
    );
  }
}

class MetaCard extends StatelessWidget {
  final String _title;
  final Widget _children;

  MetaCard(this._title, this._children);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.only(left: 8, right: 8, top: 8),
        child: Card(
            child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(children: [
                  Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Text(_title, style: TextStyle(fontSize: 18))),
                  _children,
                ]))));
  }
}
