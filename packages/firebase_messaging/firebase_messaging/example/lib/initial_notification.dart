import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class InitialNotification extends StatelessWidget {
  InitialNotification(this._notification);

  final RemoteNotification _notification;

  @override
  Widget build(BuildContext context) {
    if (_notification == null) {
      return null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Initial Notification"),
      ),
      body: null,
    );
  }
}
