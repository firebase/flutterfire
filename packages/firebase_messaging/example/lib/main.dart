// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

final Map<String, Notification> _notifications = <String, Notification>{};

class Notification {
  Notification.fromJson(Map<String, dynamic> message)
      : title = message['notification']['title'],
        body = message['notification']['body'],
        id = message['id'];

  final String id;
  final String title;
  final String body;

  StreamController<Notification> _controller =
      StreamController<Notification>.broadcast();
  Stream<Notification> get onChanged => _controller.stream;

  static final Map<String, Route<void>> routes = <String, Route<void>>{};

  Route<void> get route {
    final String routeName = '/detail/$id';
    return routes.putIfAbsent(
      routeName,
      () => MaterialPageRoute<void>(
        settings: RouteSettings(name: routeName),
        builder: (BuildContext context) => DetailPage(this),
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  DetailPage(this.notification);

  final Notification notification;

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  StreamSubscription<Notification> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription =
        widget.notification.onChanged.listen((Notification notification) {
      if (!mounted) {
        _subscription.cancel();
      } else {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Title: ${widget.notification.title}'),
      ),
      body: Material(
        child: Center(child: Text('Body: ${widget.notification.body}')),
      ),
    );
  }
}

class PushMessagingExample extends StatefulWidget {
  @override
  _PushMessagingExampleState createState() => _PushMessagingExampleState();
}

class _PushMessagingExampleState extends State<PushMessagingExample> {
  String _homeScreenText = "Waiting for token...";
  bool _topicButtonsDisabled = false;
  final String serverToken = '<Server-Token>';
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final TextEditingController _topicController = TextEditingController(
    text: 'topic',
  );

  Widget _buildDialog(BuildContext context, Notification notification) {
    return AlertDialog(
      content: Text("Notification ${notification.id} has been updated"),
      actions: <Widget>[
        FlatButton(
          child: const Text('CLOSE'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        FlatButton(
          child: const Text('SHOW'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }

  void _showItemDialog(Map<String, dynamic> message) {
    showDialog<bool>(
      context: context,
      builder: (_) {
        Notification notification = Notification.fromJson(message);
        notification = _notifications.putIfAbsent(
          notification.id,
          () => notification,
        );
        return _buildDialog(context, notification);
      },
    ).then((bool shouldNavigate) {
      if (shouldNavigate == true) {
        _navigateToItemDetail(message);
      }
    });
  }

  Future<void> _sendMessage() async {
    await _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );

    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'this is a body',
            'title': 'this is a title'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '2',
            'status': 'done'
          },
          'to': await _firebaseMessaging.getToken(),
        },
      ),
    );

    final NotificationDetails details = NotificationDetails(
      AndroidNotificationDetails(
        'your other channel id',
        'your other channel name',
        'your other channel description',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker',
      ),
      IOSNotificationDetails(),
    );
    await _notificationsPlugin.show(0, 'plain title', 'plain body', details,
        payload: 'plain payload');
  }

  void _navigateToItemDetail(Map<String, dynamic> message) {
    final Notification notification = Notification.fromJson(message);
    // Clear away dialogs
    Navigator.popUntil(context, (Route<dynamic> route) => route is PageRoute);
    if (!notification.route.isCurrent) {
      Navigator.push(context, notification.route);
    }
  }

  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
    _setupLocalNotifications();
  }

  void _setupLocalNotifications() {
    final InitializationSettings settings = InitializationSettings(
      AndroidInitializationSettings('app_icon'),
      IOSInitializationSettings(
        onDidReceiveLocalNotification: (
          int id,
          String title,
          String body,
          String payload,
        ) {
          print('onDidReceiveLocalNotification: $id $title $body $payload');
          return Future<void>.value();
        },
      ),
    );
    _notificationsPlugin.initialize(settings, onSelectNotification: (_) {
      print('onSelectNotification: $_');
      return Future<void>.value();
    });
  }

  void _setupFirebaseMessaging() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        _showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _navigateToItemDetail(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
        sound: true,
        badge: true,
        alert: true,
        provisional: true,
      ),
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        _homeScreenText = "Push Messaging token: $token";
      });
      print(_homeScreenText);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Push Messaging Demo'),
        ),
        body: Material(
          child: Column(
            children: <Widget>[
              Center(
                child: Text(_homeScreenText),
              ),
              RaisedButton(
                child: Text('Send Message'),
                onPressed: _sendMessage,
              ),
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
                          _firebaseMessaging
                              .subscribeToTopic(_topicController.text);
                          _clearTopicText();
                        },
                ),
                FlatButton(
                  child: const Text("unsubscribe"),
                  onPressed: _topicButtonsDisabled
                      ? null
                      : () {
                          _firebaseMessaging
                              .unsubscribeFromTopic(_topicController.text);
                          _clearTopicText();
                        },
                ),
              ])
            ],
          ),
        ));
  }

  void _clearTopicText() {
    setState(() {
      _topicController.text = "";
      _topicButtonsDisabled = true;
    });
  }
}

void main() {
  runApp(
    MaterialApp(
      home: PushMessagingExample(),
    ),
  );
}
