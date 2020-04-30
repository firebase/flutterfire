// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library firebase_messaging_platform_interface;

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

part 'src/method_channel_firebase_messaging.dart';

part 'src/types.dart';

/// The interface that implementations of `firebase_messaging` must extend.
///
/// Platform implementations should extend this class rather than implement it
/// as `firebase_messaging` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [FirebaseMessagingPlatform] methods.
abstract class FirebaseMessagingPlatform extends PlatformInterface {
  static final Object _token = Object();

  FirebaseMessagingPlatform() : super(token: _token);

  /// The default instance of [FirebaseMessagingPlatform] to use.
  ///
  /// Platform-specific plugins should override this with their own class
  /// that extends [FirebaseMessagingPlatform] when they register themselves.
  ///
  /// Defaults to [MethodChannelFirebaseMessaging].
  static FirebaseMessagingPlatform get instance => _instance;

  static FirebaseMessagingPlatform _instance = MethodChannelFirebaseMessaging();

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [FirebaseMessagingPlatform] when they register themselves.
  static set instance(FirebaseMessagingPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// On iOS, prompts the user for notification permissions the first time
  /// it is called.
  ///
  /// Does nothing and returns null on Android.
  FutureOr<bool> requestNotificationPermissions([
    IosNotificationSettings iosSettings = const IosNotificationSettings(),
  ]) {
    throw UnimplementedError(
      'requestNotificationPermissions() has not been implemented',
    );
  }

  /// Stream that fires when the user changes their notification settings.
  ///
  /// Only fires on iOS.
  Stream<IosNotificationSettings> get onIosSettingsRegistered {
    throw UnimplementedError(
      'onIosSettingsRegistered has not been implemented',
    );
  }

  /// Sets up [MessageHandler] for incoming messages.
  void configure({
    MessageHandler onMessage,
    MessageHandler onBackgroundMessage,
    MessageHandler onLaunch,
    MessageHandler onResume,
  }) {
    throw UnimplementedError('configure() has not been implemented');
  }

  /// Fires when a new FCM token is generated.
  Stream<String> get onTokenRefresh {
    throw UnimplementedError('onTokenRefresh has not been implemented');
  }

  /// Returns the FCM token.
  Future<String> getToken() async {
    throw UnimplementedError('getToken() has not been implemented');
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
    throw UnimplementedError('deleteInstanceID() has not been implemented');
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
