// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:firebase_core_web/firebase_core_web_interop.dart'
    as core_interop;
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/internals.dart';
import 'src/interop/messaging.dart' as messaging_interop;
import 'src/interop/notification.dart';
import 'src/utils.dart' as utils;

/// Web implementation for [FirebaseMessagingPlatform]
/// delegates calls to messaging web plugin.
class FirebaseMessagingWeb extends FirebaseMessagingPlatform {
  /// Instance of Messaging from the web plugin
  messaging_interop.Messaging? _webMessaging;

  messaging_interop.Messaging get _delegate {
    _webMessaging ??=
        messaging_interop.getMessagingInstance(core_interop.app(app.name));

    if (!_initialized && messaging_interop.isSupported()) {
      _webMessaging!.onMessage
          .listen((messaging_interop.MessagePayload webMessagePayload) {
        RemoteMessage remoteMessage =
            RemoteMessage.fromMap(utils.messagePayloadToMap(webMessagePayload));
        FirebaseMessagingPlatform.onMessage.add(remoteMessage);
      });

      _initialized = true;
    }

    return _webMessaging!;
  }

  /// Called by PluginRegistry to register this plugin for Flutter Web
  static void registerWith(Registrar registrar) {
    FirebaseCoreWeb.registerService('messaging');
    FirebaseMessagingPlatform.instance = FirebaseMessagingWeb();
  }

  Stream<String>? _noopOnTokenRefreshStream;

  static bool _initialized = false;

  /// Builds an instance of [FirebaseMessagingWeb] with an optional [FirebaseApp] instance
  /// If [app] is null then the created instance will use the default [FirebaseApp]
  FirebaseMessagingWeb({FirebaseApp? app}) : super(appInstance: app);

  /// Updates user on browser support for Firebase.Messaging
  @override
  bool isSupported() {
    return messaging_interop.isSupported();
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
  Future<void> deleteToken() async {
    _delegate;

    if (!_initialized) {
      // no-op for unsupported browsers
      return;
    }

    return guard(_delegate.deleteToken);
  }

  @override
  Future<String?> getAPNSToken() async {
    return null;
  }

  @override
  Future<String?> getToken({String? vapidKey}) async {
    _delegate;

    if (!_initialized) {
      // no-op for unsupported browsers
      return null;
    }

    return guard(
      () => _delegate.getToken(vapidKey: vapidKey),
    );
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
  Future<NotificationSettings> requestPermission({
    bool alert = true,
    bool announcement = false,
    bool badge = true,
    bool carPlay = false,
    bool criticalAlert = false,
    bool provisional = false,
    bool sound = true,
  }) {
    return guard(() async {
      String status = await WindowNotification.requestPermission();
      return utils.getNotificationSettings(status);
    });
  }

  @override
  Future<void> setAutoInitEnabled(bool enabled) async {
    // Noop out on web - not supported but no need to crash
    return;
  }

  @override
  Future<void> setForegroundNotificationPresentationOptions({
    required bool alert,
    required bool badge,
    required bool sound,
  }) async {
    // TODO(rrousselGit) dead code? Should this throw an UnimplementedError?
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
