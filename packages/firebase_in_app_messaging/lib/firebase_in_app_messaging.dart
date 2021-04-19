// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

// TODO document
// ignore: public_member_api_docs
class FirebaseInAppMessaging {
  @visibleForTesting
  // ignore: public_member_api_docs
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_in_app_messaging');

  static FirebaseInAppMessaging _instance = FirebaseInAppMessaging();

  /// Gets the instance of In-App Messaging for the default Firebase app.
  static FirebaseInAppMessaging get instance => _instance;

  /// Triggers an analytics event.
  Future<void> triggerEvent(String eventName) async {
    await channel.invokeMethod<void>(
        'triggerEvent', <String, String>{'eventName': eventName});
  }

  /// Enables or disables suppression of message displays.
  Future<void> setMessagesSuppressed(bool suppress) async {
    await channel.invokeMethod<void>('setMessagesSuppressed', suppress);
  }

  /// Disable data collection for the app.
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {
    await channel.invokeMethod<void>(
        'setAutomaticDataCollectionEnabled', enabled);
  }
}
