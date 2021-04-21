// @dart=2.9

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// Manages & returns the users FCM token.
///
/// Also monitors token refreshes and updates state.
class TokenMonitor extends StatefulWidget {
  // ignore: public_member_api_docs
  TokenMonitor(this._builder);

  final Widget Function(String token) _builder;

  @override
  State<StatefulWidget> createState() => _TokenMonitor();
}

class _TokenMonitor extends State<TokenMonitor> {
  String _token;
  Stream<String> _tokenStream;

  void setToken(String token) {
    print('FCM Token: $token');
    setState(() {
      _token = token;
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getToken().then(setToken);
    _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream.listen(setToken);
  }

  @override
  Widget build(BuildContext context) {
    return widget._builder(_token);
  }
}
