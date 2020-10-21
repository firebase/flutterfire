// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../utils.dart';
import 'utils/exception.dart';

/// The entry point for accessing a Messaging.
///
/// You can get an instance by calling [FirebaseMessaging.instance].
class MethodChannelFirebaseMessaging extends FirebaseMessagingPlatform {
  /// Create an instance of [MethodChannelFirebaseMessaging] with optional [FirebaseApp]
  MethodChannelFirebaseMessaging({FirebaseApp app}) : super(appInstance: app) {
    if (_initialized) return;
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case "Messaging#onTokenRefresh":
          _tokenStreamController.add(call.arguments as String);
          break;
        case "Messaging#onMessage":
          Map<String, dynamic> messageMap =
              Map<String, dynamic>.from(call.arguments);
          FirebaseMessagingPlatform.onMessage
              .add(RemoteMessage.fromMap(messageMap));
          break;
        case "Messaging#onNotificationOpenedApp":
          Map<String, dynamic> messageMap =
              Map<String, dynamic>.from(call.arguments);
          FirebaseMessagingPlatform.onNotificationOpenedApp
              .add(RemoteMessage.fromMap(messageMap));
          break;
        case "Messaging#onBackgroundMessage":
          // Apple only. Android calls via separate background channel.
          Map<String, dynamic> messageMap =
              Map<String, dynamic>.from(call.arguments);
          return FirebaseMessagingPlatform.onBackgroundMessage
              ?.call(RemoteMessage.fromMap(messageMap));
        default:
          throw UnimplementedError("${call.method} has not been implemented");
      }
    });
    _initialized = true;
  }

  bool _autoInitEnabled;

  static bool _initialized = false;

  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebaseMessaging get instance {
    return MethodChannelFirebaseMessaging._();
  }

  /// Internal stub class initializer.
  ///
  /// When the user code calls an auth method, the real instance is
  /// then initialized via the [delegateFor] method.
  MethodChannelFirebaseMessaging._() : super(appInstance: null);

  /// The [MethodChannel] to which calls will be delegated.
  @visibleForTesting
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_messaging',
  );

  final StreamController<String> _tokenStreamController =
      StreamController<String>.broadcast();

  @override
  FirebaseMessagingPlatform delegateFor({FirebaseApp app}) {
    return MethodChannelFirebaseMessaging(app: app);
  }

  @override
  FirebaseMessagingPlatform setInitialValues({bool isAutoInitEnabled}) {
    _autoInitEnabled = isAutoInitEnabled ?? false;
    return this;
  }

  @override
  bool get isAutoInitEnabled {
    return _autoInitEnabled;
  }

  @override
  Future<RemoteMessage> getInitialNotification() async {
    try {
      Map<String, dynamic> remoteMessageMap = await channel
          .invokeMapMethod<String, dynamic>(
              'Messaging#getInitialNotification', {
        'appName': app.name,
      });

      return RemoteMessage.fromMap(remoteMessageMap);
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  void registerBackgroundMessageHandler() async {
    BackgroundMessageHandler handler =
        FirebaseMessagingPlatform.onBackgroundMessage;

    if (handler == null) {
      return;
    }

    // TODO(salakar): register handler
  }

  @override
  Future<void> deleteToken() async {
    try {
      await channel.invokeMethod<String>('Messaging#deleteToken', {
        'appName': app.name,
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<String> getAPNSToken() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return null;
    }

    try {
      return await channel.invokeMethod<String>('Messaging#getAPNSToken', {
        'appName': app.name,
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<String> getToken({
    String vapidKey,
  }) async {
    try {
      return await channel.invokeMethod<String>('Messaging#getToken', {
        'appName': app.name,
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return androidNotificationSettings;
    }

    try {
      Map<String, int> response = await channel
          .invokeMapMethod<String, int>('Messaging#getNotificationSettings', {
        'appName': app.name,
      });

      return convertToNotificationSettings(response);
    } catch (e) {
      throw convertPlatformException(e);
    }
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
    if (defaultTargetPlatform == TargetPlatform.android) {
      return androidNotificationSettings;
    }

    try {
      Map<String, int> response = await channel
          .invokeMapMethod<String, int>('Messaging#requestPermission', {
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

      return convertToNotificationSettings(response);
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<void> setAutoInitEnabled(bool enabled) async {
    try {
      Map<String, dynamic> data = await channel
          .invokeMapMethod<String, dynamic>('Messaging#setAutoInitEnabled', {
        'appName': app.name,
        'enabled': enabled,
      });
      _autoInitEnabled = data['isAutoInitEnabled'];
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Stream<String> get onTokenRefresh {
    return _tokenStreamController.stream;
  }

  @override
  Future<void> setForegroundNotificationPresentationOptions({
    bool alert,
    bool badge,
    bool sound,
  }) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return;
    }

    try {
      await channel.invokeMethod(
          'Messaging#setForegroundNotificationPresentationOptions', {
        'appName': app.name,
        'alert': alert,
        'badge': badge,
        'sound': sound,
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  Future<void> sendMessage({
    String senderId,
    Map<String, String> data,
    String collapseKey,
    String messageId,
    String messageType,
    int ttl,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      throw UnimplementedError(
          "Sending of messages from the Firebase Messaging SDK is only supported on Android devices");
    }

    try {
      await channel.invokeMethod('Messaging#sendMessage', {
        'appName': app.name,
        'senderId': senderId,
        'data': data,
        'collapseKey': collapseKey,
        'messageId': messageId,
        'messageType': messageType,
        'ttl': ttl,
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await channel.invokeMethod<String>('Messaging#subscribeToTopic', {
        'appName': app.name,
        'topic': topic,
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await channel.invokeMethod<String>('Messaging#unsubscribeFromTopic', {
        'appName': app.name,
        'topic': topic,
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }
}
