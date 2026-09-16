// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: require_trailing_commas

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// Web push certificate key used by the example app.
///
/// This is only required by web, and is ignored on other platforms.
const String messagingVapidKey = 'VAPID_KEY';

/// Manages and returns the app instance FCM registration FID.
///
/// Also monitors registration changes and updates state.
class RegistrationMonitor extends StatefulWidget {
  // ignore: public_member_api_docs
  RegistrationMonitor(this._builder);

  final Widget Function(String? fid) _builder;

  @override
  State<StatefulWidget> createState() => _RegistrationMonitor();
}

class _RegistrationMonitor extends State<RegistrationMonitor> {
  String? _fid;
  StreamSubscription<String>? _registeredSubscription;
  StreamSubscription<String>? _unregisteredSubscription;

  void setRegisteredFid(String fid) {
    print('FCM registered FID: $fid');
    setState(() {
      _fid = fid;
    });
  }

  void setUnregisteredFid(String fid) {
    print('FCM unregistered FID: $fid');
    setState(() {
      if (_fid == fid) {
        _fid = null;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _registeredSubscription =
        FirebaseMessaging.instance.onRegistered.listen(setRegisteredFid);
    _unregisteredSubscription =
        FirebaseMessaging.instance.onUnregistered.listen(setUnregisteredFid);
    FirebaseMessaging.instance
        .register(vapidKey: messagingVapidKey)
        .catchError((Object error) {
      print('FCM registration failed: $error');
    });
  }

  @override
  void dispose() {
    _registeredSubscription?.cancel();
    _unregisteredSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget._builder(_fid);
  }
}
