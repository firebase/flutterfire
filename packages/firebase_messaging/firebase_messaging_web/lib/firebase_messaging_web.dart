// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;

import 'src/interop/messaging.dart' as messaging_interop;
import 'src/interop/notification.dart';
import 'src/utils.dart' as utils;

/// Web implementation for [FirebaseMessagingPlatform]
/// delegates calls to messaging web plugin.
class FirebaseMessagingWeb extends FirebaseMessagingPlatform {
  /// Instance of Messaging from the web plugin
  late messaging_interop.Messaging _webMessaging;

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirebaseMessagingPlatform.instance = FirebaseMessagingWeb();
  }

  Stream<String>? _noopOnTokenRefreshStream;

  static bool _initialized = false;

  /// Builds an instance of [FirebaseMessagingWeb] with an optional [FirebaseApp] instance
  /// If [app] is null then the created instance will use the default [FirebaseApp]
  FirebaseMessagingWeb({FirebaseApp? app}) : super(appInstance: app) {
    if (!messaging_interop.isSupported()) {
      // The browser is not supported (Safari). Initialize a full no-op FirebaseMessagingWeb
      return;
    }

    _webMessaging =
        messaging_interop.getMessagingInstance(core_interop.app(app?.name));
    if (app != null && _initialized) return;

    _webMessaging.onMessage
        .listen((messaging_interop.MessagePayload webMessagePayload) {
      RemoteMessage remoteMessage =
          RemoteMessage.fromMap(utils.messagePayloadToMap(webMessagePayload));
      FirebaseMessagingPlatform.onMessage.add(remoteMessage);
    });

    _initialized = true;
  }

  @override
  void registerBackgroundMessageHandler(BackgroundMessageHandler handler) {}

  @override
  FirebaseMessagingPlatform delegateFor({required FirebaseApp app}) {
    return FirebaseMessagingWeb(app: app);
  }

  @override
  FirebaseMessagingPlatform setInitialValues({bool? isAutoInitEnabled}) {
    // Not required on web, but prevents UnimplementedError being thrown.
    return this;
  }

  @override
  bool get isAutoInitEnabled {
    // Not supported on web, since it automatically initializes when imported
    // via the script. So return `true`.
    return true;
  }

  @override
  Future<RemoteMessage?> getInitialMessage() async {
    return null;
  }

  @override
  Future<void> deleteToken({String? senderId}) async {
    if (!_initialized) {
      // no-op for unsupported browsers
      return;
    }
    try {
      _webMessaging.deleteToken();
    } catch (e) {
      throw utils.getFirebaseException(e);
    }
  }

  @override
  Future<String?> getAPNSToken() async {
    return null;
  }

  @override
  Future<String?> getToken({String? senderId, String? vapidKey}) async {
    if (!_initialized) {
      // no-op for unsupported browsers
      return null;
    }
    try {
      return await _webMessaging.getToken(vapidKey: vapidKey);
    } catch (e) {
      throw utils.getFirebaseException(e);
    }
  }

  @override
  Stream<String> get onTokenRefresh {
    // onTokenRefresh is deprecated on web, however since this is a non-critical
    // api we just return a noop stream to keep functionality the same across
    // platforms.
    return _noopOnTokenRefreshStream ??=
        StreamController<String>.broadcast().stream;
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    return utils.getNotificationSettings(WindowNotification.permission);
  }

  @override
  Future<NotificationSettings> requestPermission(
      {bool alert = true,
      bool announcement = false,
      bool badge = true,
      bool carPlay = false,
      bool criticalAlert = false,
      bool provisional = false,
      bool sound = true}) async {
    try {
      String status = await WindowNotification.requestPermission();
      return utils.getNotificationSettings(status);
    } catch (e) {
      throw utils.getFirebaseException(e);
    }
  }

  @override
  Future<void> setAutoInitEnabled(bool enabled) async {
    // Noop out on web - not supported but no need to crash
    return;
  }

  @override
  Future<void> setForegroundNotificationPresentationOptions(
      {required bool alert, required bool badge, required bool sound}) async {
    return;
  }

  @override
  Future<void> subscribeToTopic(String topic) {
    throw UnimplementedError('''
      subscribeToTopic() is not supported on the web clients.

      To learn how to manage subscriptions for web users, visit the
      official Firebase documentation:

      https://firebase.google.com/docs/cloud-messaging/js/topic-messaging
    ''');
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) {
    throw UnimplementedError('''
      unsubscribeFromTopic() is not supported on the web clients.

      To learn how to manage subscriptions for web users, visit the
      official Firebase documentation:

      https://firebase.google.com/docs/cloud-messaging/js/topic-messaging
    ''');
  }
}
