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
        case "Messaging#onToken":
          _tokenStreamController.add(call.arguments);
          break;
        default:
          throw UnimplementedError("${call.method} has not been implemented");
      }
    });
    _initialized = true;
  }

  bool _autoInitEnabled;

  Notification _initialNotification;

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
  FirebaseMessagingPlatform setInitialValues(
      {bool isAutoInitEnabled, Map<String, dynamic> initialNotification}) {
    _autoInitEnabled = isAutoInitEnabled ?? false;

    if (initialNotification != null) {
      AndroidNotification _android;
      AppleNotification _apple;

      if (initialNotification['android'] != null) {
        _android = AndroidNotification(
          channelId: initialNotification['android']['channelId'],
          clickAction: initialNotification['android']['clickAction'],
          color: initialNotification['android']['color'],
          count: initialNotification['android']['count'],
          imageUrl: initialNotification['android']['imageUrl'],
          link: initialNotification['android']['link'],
          priority: convertToAndroidNotificationPriority(
              initialNotification['android']['priority']),
          smallIcon: initialNotification['android']['smallIcon'],
          sound: initialNotification['android']['sound'],
          ticker: initialNotification['android']['ticker'],
          visibility: convertToAndroidNotificationVisibility(
              initialNotification['android']['visibility']),
        );
      }

      if (initialNotification['apple'] != null) {
        _apple = AppleNotification(
            badge: initialNotification['apple']['badge'],
            sound: initialNotification['apple']['sound'],
            subtitle: initialNotification['apple']['subtitle'],
            subtitleLocArgs: initialNotification['apple']['subtitleLocArgs'],
            subtitleLocKey: initialNotification['apple']['subtitleLocKey'],
            criticalSound: initialNotification['apple']['criticalSound'] == null
                ? null
                : AppleNotificationCriticalSound(
                    critical: initialNotification['apple']['criticalSound']
                        ['critical'],
                    name: initialNotification['apple']['criticalSound']['name'],
                    volume: initialNotification['apple']['criticalSound']
                        ['volume']));
      }

      _initialNotification = Notification(
        title: initialNotification['title'],
        titleLocArgs: initialNotification['titleLocArgs'],
        titleLocKey: initialNotification['titleLocKey'],
        body: initialNotification['body'],
        bodyLocArgs: initialNotification['bodyLocArgs'],
        bodyLocKey: initialNotification['bodyLocKey'],
        android: _android,
        apple: _apple,
      );
    }

    return this;
  }

  @override
  bool get isAutoInitEnabled {
    return _autoInitEnabled;
  }

  @override
  Notification get initialNotification {
    Notification result = _initialNotification;
    // Remove the notification once consumed
    _initialNotification = null;
    return result;
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
  Future<void> deleteToken({String authorizedEntity, String scope}) async {
    try {
      await channel.invokeMethod<String>('Messaging#deleteToken', {
        'appName': app.name,
        'authorizedEntity': authorizedEntity,
        'scope': scope,
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
    String authorizedEntity,
    String scope,
    String vapidKey,
  }) async {
    try {
      return await channel.invokeMethod<String>('Messaging#getToken', {
        'appName': app.name,
        'authorizedEntity': authorizedEntity,
        'scope': scope,
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
  Future<void> registerDeviceForRemoteMessages() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return null;
    }

    try {
      await channel.invokeMethod('Messaging#registerDeviceForRemoteMessages', {
        'appName': app.name,
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<void> unregisterDeviceForRemoteMessages() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return null;
    }

    try {
      await channel
          .invokeMethod('Messaging#unregisterDeviceForRemoteMessages', {
        'appName': app.name,
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }

  @override
  Future<void> sendMessage({
    String senderId,
    Map<String, String> data,
    String collapseKey,
    String messageId,
    String messageType,
    int ttl,
  }) async {
    try {
      await channel.invokeMethod<void>('Messaging#sendMessage', {
        'appName': app.name,
        'message': {
          'senderId': senderId,
          'data': data,
          'collapseKey': collapseKey,
          'messageId': messageId,
          'messageType': messageType,
          'ttl': ttl,
        }
      });
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

  @override
  Future<bool> deleteInstanceID() async {
    try {
      return await channel.invokeMethod<bool>('Messaging#deleteInstanceID', {
        'appName': app.name,
      });
    } catch (e) {
      throw convertPlatformException(e);
    }
  }
}
