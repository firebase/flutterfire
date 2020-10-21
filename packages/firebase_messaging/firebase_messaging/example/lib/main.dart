// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'token_monitor.dart';
import 'permissions.dart';

BackgroundMessageHandler backgroundMessageHandler = (RemoteMessage message) {
  print(message);
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
  runApp(MessagingExampleApp());
}

class MessagingExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Messaging Example App',
        theme: ThemeData.dark(),
        home: Scaffold(
          appBar: AppBar(
            title: Text("Cloud Messaging"),
          ),
          body: Application(),
        ));
  }
}

class Application extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Application();
}

class _Application extends State<Application> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance
        .getInitialNotification()
        .then((RemoteMessage message) {
      print('INITIAL NOTIFICATION: $message');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      MetaCard("Permissions", Permissions()),
      MetaCard(
          "FCM Token",
          TokenMonitor((token) =>
              Text(token ?? 'Loading...', style: TextStyle(fontSize: 12)))),
    ]);
  }
}

class MetaCard extends StatelessWidget {
  final String _title;
  final Widget _children;

  MetaCard(this._title, this._children);

  @override
  Widget build(BuildContext context) {
    return Container(
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

// final Map<String, Item> _items = <String, Item>{};

// Item _itemForMessage(Map<String, dynamic> message) {
//   final dynamic data = message['data'] ?? message;
//   final String itemId = data['id'];
//   final Item item = _items.putIfAbsent(itemId, () => Item(itemId: itemId))
//     ..status = data['status'];
//   return item;
// }

// class Item {
//   Item({this.itemId});

//   final String itemId;

//   StreamController<Item> _controller = StreamController<Item>.broadcast();

//   Stream<Item> get onChanged => _controller.stream;

//   String _status;

//   String get status => _status;

//   set status(String value) {
//     _status = value;
//     _controller.add(this);
//   }

//   static final Map<String, Route<void>> routes = <String, Route<void>>{};

//   Route<void> get route {
//     final String routeName = '/detail/$itemId';
//     return routes.putIfAbsent(
//       routeName,
//       () => MaterialPageRoute<void>(
//         settings: RouteSettings(name: routeName),
//         builder: (BuildContext context) => DetailPage(itemId),
//       ),
//     );
//   }
// }

// class DetailPage extends StatefulWidget {
//   DetailPage(this.itemId);

//   final String itemId;

//   @override
//   _DetailPageState createState() => _DetailPageState();
// }

// class _DetailPageState extends State<DetailPage> {
//   Item _item;
//   StreamSubscription<Item> _subscription;

//   @override
//   void initState() {
//     super.initState();
//     _item = _items[widget.itemId];
//     _subscription = _item.onChanged.listen((Item item) {
//       if (!mounted) {
//         _subscription.cancel();
//       } else {
//         setState(() {
//           _item = item;
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Item ${_item.itemId}"),
//       ),
//       body: Material(
//         child: Center(child: Text("Item status: ${_item.status}")),
//       ),
//     );
//   }
// }

// class PushMessagingExample extends StatefulWidget {
//   @override
//   _PushMessagingExampleState createState() => _PushMessagingExampleState();
// }

// class _PushMessagingExampleState extends State<PushMessagingExample> {
//   String _homeScreenText = "Waiting for token...";
//   bool _topicButtonsDisabled = false;

//   final TextEditingController _topicController =
//       TextEditingController(text: 'topic');

//   Widget _buildDialog(BuildContext context, Item item) {
//     return AlertDialog(
//       content: Text("Item ${item.itemId} has been updated"),
//       actions: <Widget>[
//         FlatButton(
//           child: const Text('CLOSE'),
//           onPressed: () {
//             Navigator.pop(context, false);
//           },
//         ),
//         FlatButton(
//           child: const Text('SHOW'),
//           onPressed: () {
//             Navigator.pop(context, true);
//           },
//         ),
//       ],
//     );
//   }

//   void _showItemDialog(Map<String, dynamic> message) {
//     showDialog<bool>(
//       context: context,
//       builder: (_) => _buildDialog(context, _itemForMessage(message)),
//     ).then((bool shouldNavigate) {
//       if (shouldNavigate == true) {
//         _navigateToItemDetail(message);
//       }
//     });
//   }

//   void _navigateToItemDetail(Map<String, dynamic> message) {
//     final Item item = _itemForMessage(message);
//     // Clear away dialogs
//     Navigator.popUntil(context, (Route<dynamic> route) => route is PageRoute);
//     if (!item.route.isCurrent) {
//       Navigator.push(context, item.route);
//     }
//   }

//   // Define an async function to initialize FlutterFire
//   Future<void> _initializeFlutterFire() async {
//     await Firebase.initializeApp();
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print("onMessage: $message");
//       // _showItemDialog(message);
//     });
//     FirebaseMessaging.onNotificationOpenedApp.listen((RemoteMessage message) {
//       print("onNotificationOpenedApp: $message");
//       // _navigateToItemDetail(message);
//     });
//     await FirebaseMessaging.instance.requestPermission(
//         sound: true, badge: true, alert: true, provisional: true);
//     await FirebaseMessaging.instance.getToken().then((String token) {
//       assert(token != null);
//       setState(() {
//         _homeScreenText = "Push Messaging token: $token";
//       });
//       print(_homeScreenText);
//     });
//     // TODO should be async method
//     if (FirebaseMessaging.instance.initialNotification != null) {
//       print("initialNotification: _firebaseMessaging.initialNotification");
//       // _navigateToItemDetail(FirebaseMessaging.instance.initialNotification);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initializeFlutterFire();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Cloud Messaging'),
//         ),
//         // For testing -- simulate a message being received
//         floatingActionButton: FloatingActionButton(
//           onPressed: () async {
//             var permissions =
//                 await FirebaseMessaging.instance.requestPermission();
//             print('-----PERMISSIONS------');
//             print(permissions.authorizationStatus);
//             print(permissions.alert);
//             print(permissions.sound);
//             print(permissions.badge);
//             print('----------------------');
//             print('-----APNS------');
//             var apnsToken = await FirebaseMessaging.instance.getAPNSToken();
//             print(apnsToken);
//             print('---------------');
//             print('-----FCM------');
//             var fcmToken = await FirebaseMessaging.instance.getToken();
//             print(fcmToken);
//             print('--------------');
//             // return _showItemDialog(<String, dynamic>{
//             //   "data": <String, String>{
//             //     "id": "2",
//             //     "status": "out of stock",
//             //   },
//             // });
//           },
//           tooltip: 'Simulate Message',
//           child: const Icon(Icons.message),
//         ),
//         body: Material(
//           child: Column(
//             children: <Widget>[
//               Center(
//                 child: Text(_homeScreenText),
//               ),
//               Row(children: <Widget>[
//                 Expanded(
//                   child: TextField(
//                       controller: _topicController,
//                       onChanged: (String v) {
//                         setState(() {
//                           _topicButtonsDisabled = v.isEmpty;
//                         });
//                       }),
//                 ),
//                 FlatButton(
//                   child: const Text("subscribe"),
//                   onPressed: _topicButtonsDisabled
//                       ? null
//                       : () {
//                           FirebaseMessaging.instance
//                               .subscribeToTopic(_topicController.text);
//                           _clearTopicText();
//                         },
//                 ),
//                 FlatButton(
//                   child: const Text("unsubscribe"),
//                   onPressed: _topicButtonsDisabled
//                       ? null
//                       : () {
//                           FirebaseMessaging.instance
//                               .unsubscribeFromTopic(_topicController.text);
//                           _clearTopicText();
//                         },
//                 ),
//               ])
//             ],
//           ),
//         ));
//   }

//   void _clearTopicText() {
//     setState(() {
//       _topicController.text = "";
//       _topicButtonsDisabled = true;
//     });
//   }
// }

// void main() {
//   runApp(
//     MaterialApp(
//       home: PushMessagingExample(),
//     ),
//   );
// }
