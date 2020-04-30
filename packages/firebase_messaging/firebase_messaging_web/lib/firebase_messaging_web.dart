// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library firebase_messaging_web;

import 'dart:async';

import 'package:firebase/firebase.dart' as fb;
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:service_worker/window.dart' as sw;

/// Web implementation of [FirebaseMessagingPlatform].
class FirebaseMessagingWeb extends FirebaseMessagingPlatform {
  /// Create the default instance of the [FirebaseMessagingPlatform] as a [FirebaseMessagingWeb]
  static void registerWith(Registrar registrar) {
    FirebaseMessagingPlatform.instance = FirebaseMessagingWeb();
  }

  FirebaseMessagingWeb() {
    _messagingCompleter = Completer();
    _messagingCompleter.complete(_initMessaging());
  }

  Completer<fb.Messaging> _messagingCompleter;

  MessageHandler _onMessage;

  final StreamController<IosNotificationSettings> _iosSettingsStreamController =
      StreamController<IosNotificationSettings>.broadcast();
  final StreamController<String> _tokenStreamController =
      StreamController<String>.broadcast();

  Future<fb.Messaging> _getMessaging() async {
    return _messagingCompleter.future;
  }

  Future<fb.Messaging> _initMessaging() async {
    fb.Messaging messaging;
    if (sw.isSupported) {
      try {
        await sw.register('firebase_messaging_sw.dart.js');
        final registration = await sw.ready;
        messaging = fb.messaging();
        messaging.useServiceWorker(registration.jsObject);
      } catch (e) {
        print('FirebaseMessagingServiceWorker registration error: $e');
      }
    } else {
      print('ServiceWorkers are not supported.');
    }
    if (messaging == null) messaging = fb.messaging();
    messaging.onMessage.listen(_handleMessage);
    messaging.onTokenRefresh.listen((event) => _handleTokenRefresh());
    return messaging;
  }

  /// On iOS, prompts the user for notification permissions the first time
  /// it is called.
  ///
  /// Does nothing and returns null on Android.
  FutureOr<bool> requestNotificationPermissions([
    // ignore: invalid_override_different_default_values_positional
    IosNotificationSettings iosSettings,
  ]) async {
    try {
      final messaging = await _getMessaging();
      await messaging.requestPermission();
      return true;
    } catch (e) {
      print('FirebaseMessagingWeb.requestNotificationPermissions error: $e');
      return false;
    }
  }

  /// Stream that fires when the user changes their notification settings.
  ///
  /// Only fires on iOS.
  Stream<IosNotificationSettings> get onIosSettingsRegistered {
    return _iosSettingsStreamController.stream;
  }

  /// Sets up [MessageHandler] for incoming messages.
  void configure({
    MessageHandler onMessage,
    MessageHandler onBackgroundMessage,
    MessageHandler onLaunch,
    MessageHandler onResume,
  }) {
    _onMessage = onMessage;
  }

  void _handleMessage(fb.Payload message) {
    if (_onMessage == null) return;
    _onMessage(_convertMessage(message));
  }

  void _handleTokenRefresh() async {
    final token = await getToken();
    _tokenStreamController.add(token);
  }

  /// Fires when a new FCM token is generated.
  Stream<String> get onTokenRefresh {
    return _tokenStreamController.stream;
  }

  /// Returns the FCM token.
  Future<String> getToken() async {
    final messaging = await _getMessaging();
    return messaging.getToken();
  }

  /// Subscribe to topic in background.
  ///
  /// [topic] must match the following regular expression:
  /// "[a-zA-Z0-9-_.~%]{1,900}".
  Future<void> subscribeToTopic(String topic) {
    throw UnimplementedError('subscribeToTopic() has not been implemented');
  }

  /// Unsubscribe from topic in background.
  Future<void> unsubscribeFromTopic(String topic) {
    throw UnimplementedError('unsubscribeFromTopic() has not been implemented');
  }

  /// Resets Instance ID and revokes all tokens. In iOS, it also unregisters from remote notifications.
  ///
  /// A new Instance ID is generated asynchronously if Firebase Cloud Messaging auto-init is enabled.
  ///
  /// returns true if the operations executed successfully and false if an error occurred
  Future<bool> deleteInstanceID() async {
    final token = await getToken();
    if (token == null) return true;
    try {
      final messaging = await _getMessaging();
      messaging.deleteToken(token);
      return true;
    } catch (e) {
      print('FirebaseMessagingWeb.deleteInstanceID() error: $e');
      return false;
    }
  }

  /// Determine whether FCM auto-initialization is enabled or disabled.
  Future<bool> autoInitEnabled() async {
    throw UnimplementedError('autoInitEnabled() has not been implemented');
  }

  /// Enable or disable auto-initialization of Firebase Cloud Messaging.
  Future<void> setAutoInitEnabled(bool enabled) async {
    throw UnimplementedError('setAutoInitEnabled() has not been implemented');
  }
}

Map<String, dynamic> _convertMessage(fb.Payload payload) {
  final message = {
    'notification': _convertNotification(payload.notification),
    'collapseKey': payload.collapseKey,
    'from': payload.from,
    'data': payload.data,
  };
  return message;
}

Map<String, dynamic> _convertNotification(fb.Notification notification) {
  final data = {
    'title': notification.title,
    'body': notification.body,
    'click_action': notification.clickAction,
    'icon': notification.icon,
  };
  return data;
}
