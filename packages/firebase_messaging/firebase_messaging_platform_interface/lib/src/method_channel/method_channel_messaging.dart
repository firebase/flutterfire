// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The entry point for accessing a Messaging.
///
/// You can get an instance by calling [FirebaseMessaging.instance].
class MethodChannelFirebaseMessaging extends FirebaseMessagingPlatform {
  /// Create an instance of [MethodChannelFirebaseMessaging] with optional [FirebaseApp]
  MethodChannelFirebaseMessaging({FirebaseApp app}) : super(appInstance: app) {
    if (_initialized) return;
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case "Messaging#onToken":
          _tokenStreamController.add(call.arguments);
          break;
        default:
          throw UnimplementedError("${call.method} has not been implemented");
      }
    });
    _initialized = true;
  }

  static bool _initialized = false;

  /// The [MethodChannel] used to communicate with the native plugin
  static MethodChannel _channel = MethodChannel(
    'plugins.flutter.io/firebase_messaging',
  );

  final StreamController<IosNotificationSettings> _iosSettingsStreamController =
      StreamController<IosNotificationSettings>.broadcast();

  final StreamController<String> _tokenStreamController =
      StreamController<String>.broadcast();

  @override
  FirebaseMessagingPlatform delegateFor({FirebaseApp app}) {
    return MethodChannelFirebaseMessaging(app: app);
  }

  @override
  bool get isAutoInitEnabled {
    // TODO from constants
    return false;
  }

  @override
  Notification get initialNotification {
    // TODO from constants
    return null;
  }

  @override
  Future<void> deleteToken({String authorizedEntity, String scope}) {
    return _channel.invokeMethod<String>('Messaging#deleteToken', {
      'appName': app.name,
      'authorizedEntity': authorizedEntity,
      'scope': scope,
    });
  }

  @override
  Future<String> getAPNSToken() {
    return _channel.invokeMethod<String>('Messaging#getAPNSToken', {
      'appName': app.name,
    });
  }

  @override
  Future<String> getToken({
    String authorizedEntity,
    String scope,
    String vapidKey,
  }) {
    return _channel.invokeMethod<String>('Messaging#getToken', {
      'appName': app.name,
      'authorizedEntity': authorizedEntity,
      'scope': scope,
    });
  }

  @override
  Future<AuthorizationStatus> hasPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AuthorizationStatus.authorized;
    }

    await _channel.invokeMethod<int>('Messaging#hasPermission', {
      'appName': app.name,
    });

    // TODO handle from result
    return AuthorizationStatus.authorized;
  }

  @override
  Future<AuthorizationStatus> requestPermission(
      {bool alert = true,
      bool announcement = false,
      bool badge = true,
      bool carPlay = false,
      bool criticalAlert = false,
      bool provisional = false,
      bool sound = true}) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AuthorizationStatus.authorized;
    }

    // todo true from android
    await _channel.invokeMethod<int>('Messaging#requestPermission', {
      'appName': app.name,
      'permissions': <String, bool>{
        'alert': alert,
        'announcement': announcement,
        'badge': badge,
        'carPlay': carPlay,
        'criticalAlert': criticalAlert,
        'provisional': provisional,
        'sound': sound,
      }
    });

    // TODO handle from result
    return AuthorizationStatus.authorized;
  }

  @override
  Future<void> sendMessage(RemoteMessage message) {
    return _channel.invokeMethod<void>('Messaging#sendMessage', {
      'appName': app.name,
      'message': message.toMap(),
    });
  }

  @override
  Future<void> setAutoInitEnabled(bool enabled) {
    return _channel.invokeMethod<String>('Messaging#setAutoInitEnabled', {
      'appName': app.name,
      'enabled': enabled,
    });
  }

  @override
  Stream<IosNotificationSettings> get onIosSettingsRegistered =>
      _iosSettingsStreamController.stream;

  @override
  Stream<String> get onTokenRefresh {
    return _tokenStreamController.stream;
  }

  @override
  Future<void> subscribeToTopic(String topic) {
    return _channel.invokeMethod<String>('Messaging#subscribeToTopic', {
      'appName': app.name,
      'topic': topic,
    });
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) {
    return _channel.invokeMethod<String>('Messaging#unsubscribeFromTopic', {
      'appName': app.name,
      'topic': topic,
    });
  }

  @override
  Future<bool> deleteInstanceID() {
    return _channel.invokeMethod<bool>('Messaging#deleteInstanceID', {
      'appName': app.name,
    });
  }
}
