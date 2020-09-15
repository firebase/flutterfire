// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter/services.dart';
import '../types.dart' as types;

/// The entry point for accessing a Messaging.
///
/// You can get an instance by calling [FirebaseMessaging.instance].
class MethodChannelFirebaseMessaging extends FirebaseMessagingPlatform {
  /// Create an instance of [MethodChannelFirebaseMessaging] with optional [FirebaseApp]
  MethodChannelFirebaseMessaging({FirebaseApp app}) : super(appInstance: app) {
    if (_initialized) return;
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
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
  Future<bool> requestNotificationPermissions(
      IosNotificationSettings iosSettings) {
    return _channel
        .invokeMethod<bool>('Messaging#requestNotificationPermissions', {
      'appName': app.name,
      'settings': iosSettings.toMap(),
    });
  }

  @override
  Stream<IosNotificationSettings> get onIosSettingsRegistered =>
      _iosSettingsStreamController.stream;

  @override
  void configure({
    types.MessageHandler onMessage,
    types.MessageHandler onBackgroundMessage,
    types.MessageHandler onLaunch,
    types.MessageHandler onResume,
  }) {
    // TODO implement
  }

  @override
  Stream<String> get onTokenRefresh {
    return _tokenStreamController.stream;
  }

  @override
  Future<String> getToken() {
    return _channel.invokeMethod<String>('Messaging#getToken', {
      'appName': app.name,
    });
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

  @override
  Future<bool> autoInitEnabled() {
    return _channel.invokeMethod<bool>('Messaging#autoInitEnabled', {
      'appName': app.name,
    });
  }

  @override
  Future<void> setAutoInitEnabled(bool enabled) {
    return _channel.invokeMethod<String>('Messaging#setAutoInitEnabled', {
      'appName': app.name,
      'enabled': enabled,
    });
  }
}
