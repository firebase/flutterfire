// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui';

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:platform/platform.dart';

import 'platform.dart' if (dart.library.io) 'platform_io.dart';

export 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart'
    show IosNotificationSettings;

typedef Future<dynamic> MessageHandler(Map<String, dynamic> message);

/// Implementation of the Firebase Cloud Messaging API for Flutter.
///
/// Your app should call [requestNotificationPermissions] first and then
/// register handlers for incoming messages with [configure].
class FirebaseMessaging {
  factory FirebaseMessaging() => _instance;

  @visibleForTesting
  FirebaseMessaging.private(Platform platform) : _platform = platform;

  static final FirebaseMessaging _instance =
      FirebaseMessaging.private(platform);

  final Platform _platform;

  /// On iOS, prompts the user for notification permissions the first time
  /// it is called.
  ///
  /// Does nothing and returns null on Android.
  FutureOr<bool> requestNotificationPermissions([
    IosNotificationSettings iosSettings = const IosNotificationSettings(),
  ]) {
    if (_platform.isAndroid) {
      return null;
    }
    return FirebaseMessagingPlatform.instance
        .requestNotificationPermissions(iosSettings);
  }

  /// Stream that fires when the user changes their notification settings.
  ///
  /// Only fires on iOS.
  Stream<IosNotificationSettings> get onIosSettingsRegistered {
    return FirebaseMessagingPlatform.instance.onIosSettingsRegistered;
  }

  /// Sets up [MessageHandler] for incoming messages.
  void configure({
    MessageHandler onMessage,
    MessageHandler onBackgroundMessage,
    MessageHandler onLaunch,
    MessageHandler onResume,
  }) {
    if (onBackgroundMessage != null) {
      CallbackHandle backgroundMessageHandle =
          PluginUtilities.getCallbackHandle(onBackgroundMessage);

      if (backgroundMessageHandle == null) {
        throw ArgumentError(
          '''Failed to setup background message handler! `onBackgroundMessage`
          should be a TOP-LEVEL OR STATIC FUNCTION and should NOT be tied to a
          class or an anonymous function.''',
        );
      }
    }
//    TODO: pass CallbackHandle backgroundMessageHandle ??
    FirebaseMessagingPlatform.instance.configure(
      onMessage: onMessage,
      onBackgroundMessage: onBackgroundMessage,
      onLaunch: onLaunch,
      onResume: onResume,
    );
  }

  /// Fires when a new FCM token is generated.
  Stream<String> get onTokenRefresh {
    return FirebaseMessagingPlatform.instance.onTokenRefresh;
  }

  /// Returns the FCM token.
  Future<String> getToken() async {
    return await FirebaseMessagingPlatform.instance.getToken();
  }

  /// Subscribe to topic in background.
  ///
  /// [topic] must match the following regular expression:
  /// "[a-zA-Z0-9-_.~%]{1,900}".
  Future<void> subscribeToTopic(String topic) {
    return FirebaseMessagingPlatform.instance.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic in background.
  Future<void> unsubscribeFromTopic(String topic) {
    return FirebaseMessagingPlatform.instance.unsubscribeFromTopic(topic);
  }

  /// Resets Instance ID and revokes all tokens. In iOS, it also unregisters from remote notifications.
  ///
  /// A new Instance ID is generated asynchronously if Firebase Cloud Messaging auto-init is enabled.
  ///
  /// returns true if the operations executed successfully and false if an error ocurred
  Future<bool> deleteInstanceID() {
    return FirebaseMessagingPlatform.instance.deleteInstanceID();
  }

  /// Determine whether FCM auto-initialization is enabled or disabled.
  Future<bool> autoInitEnabled() {
    return FirebaseMessagingPlatform.instance.autoInitEnabled();
  }

  /// Enable or disable auto-initialization of Firebase Cloud Messaging.
  Future<void> setAutoInitEnabled(bool enabled) async {
    await FirebaseMessagingPlatform.instance.setAutoInitEnabled(enabled);
  }
}
