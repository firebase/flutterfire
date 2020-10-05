// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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

  /// The [MethodChannel] to which calls will be delegated.
  @visibleForTesting
  static const MethodChannel channel = MethodChannel(
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
  FirebaseMessagingPlatform setInitialValues(
      {bool isAutoInitEnabled, Map<String, dynamic> initialNotification}) {
    _autoInitEnabled = isAutoInitEnabled ?? false;

    if (initialNotification != null) {
      AndroidNotification _android;
      IOSNotification _ios;

      if (initialNotification['android'] != null) {
        _android = AndroidNotification(
          channelId: initialNotification['android']['channelId'],
          clickAction: initialNotification['android']['clickAction'],
          color: initialNotification['android']['color'],
          count: initialNotification['android']['count'],
          imageUrl: initialNotification['android']['imageUrl'],
          link: initialNotification['android']['link'],
          priority: convertToNotificationPriority(
              initialNotification['android']['priority']),
          smallIcon: initialNotification['android']['smallIcon'],
          sound: initialNotification['android']['sound'],
          ticker: initialNotification['android']['ticker'],
          visibility: convertToNotificationVisibility(
              initialNotification['android']['visibility']),
        );
      }

      if (initialNotification['ios'] != null) {
        _ios = IOSNotification(
            badge: initialNotification['ios']['badge'],
            sound: initialNotification['ios']['sound'],
            subtitle: initialNotification['ios']['subtitle'],
            subtitleLocArgs: initialNotification['ios']['subtitleLocArgs'],
            subtitleLocKey: initialNotification['ios']['subtitleLocKey'],
            criticalSound: initialNotification['ios']['criticalSound'] == null
                ? null
                : NotificationIOSCriticalSound(
                    critical: initialNotification['ios']['criticalSound']
                        ['critical'],
                    name: initialNotification['ios']['criticalSound']['name'],
                    volume: initialNotification['ios']['criticalSound']
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
        ios: _ios,
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
  Future<void> deleteToken({String authorizedEntity, String scope}) {
    return channel.invokeMethod<String>('Messaging#deleteToken', {
      'appName': app.name,
      'authorizedEntity': authorizedEntity,
      'scope': scope,
    });
  }

  @override
  Future<String> getAPNSToken() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return null;
    }

    return channel.invokeMethod<String>('Messaging#getAPNSToken', {
      'appName': app.name,
    });
  }

  @override
  Future<String> getToken({
    String authorizedEntity,
    String scope,
    String vapidKey,
  }) {
    return channel.invokeMethod<String>('Messaging#getToken', {
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

    int status = await channel.invokeMethod<int>('Messaging#hasPermission', {
      'appName': app.name,
    });

    return convertToAuthorizationStatus(status);
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

    int status =
        await channel.invokeMethod<int>('Messaging#requestPermission', {
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

    return convertToAuthorizationStatus(status);
  }

  @override
  Future<void> sendMessage({
    String senderId,
    Map<String, String> data,
    String collapseKey,
    String messageId,
    String messageType,
    int ttl,
  }) {
    return channel.invokeMethod<void>('Messaging#sendMessage', {
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
  }

  @override
  Future<void> setAutoInitEnabled(bool enabled) async {
    Map<String, dynamic> data = await channel
        .invokeMapMethod<String, dynamic>('Messaging#setAutoInitEnabled', {
      'appName': app.name,
      'enabled': enabled,
    }).catchError(catchPlatformException);
    _autoInitEnabled = data['isAutoInitEnabled'];
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
    return channel.invokeMethod<String>('Messaging#subscribeToTopic', {
      'appName': app.name,
      'topic': topic,
    });
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) {
    return channel.invokeMethod<String>('Messaging#unsubscribeFromTopic', {
      'appName': app.name,
      'topic': topic,
    });
  }

  @override
  Future<bool> deleteInstanceID() {
    return channel.invokeMethod<bool>('Messaging#deleteInstanceID', {
      'appName': app.name,
    });
  }
}
