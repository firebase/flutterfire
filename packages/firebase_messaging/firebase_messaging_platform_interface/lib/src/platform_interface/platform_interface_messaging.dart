// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import '../method_channel/method_channel_messaging.dart';

/// Defines an interface to work with Messaging on web and mobile
abstract class FirebaseMessagingPlatform extends PlatformInterface {
  /// The [FirebaseApp] this instance was initialized with.
  @protected
  final FirebaseApp appInstance;

  /// Create an instance using [app]
  FirebaseMessagingPlatform({this.appInstance}) : super(token: _token);

  /// Returns the [FirebaseApp] for the current instance.
  FirebaseApp get app {
    if (appInstance == null) {
      return Firebase.app();
    }

    return appInstance;
  }

  static final Object _token = Object();

  /// Create an instance using [app] using the existing implementation
  factory FirebaseMessagingPlatform.instanceFor({FirebaseApp app}) {
    return FirebaseMessagingPlatform.instance.delegateFor(app: app);
  }

  static FirebaseMessagingPlatform _instance;

  /// The current default [FirebaseMessagingPlatform] instance.
  ///
  /// It will always default to [MethodChannelFirebaseMessaging]
  /// if no other implementation was provided.
  static FirebaseMessagingPlatform get instance {
    if (_instance == null) {
      _instance = MethodChannelFirebaseMessaging(app: Firebase.app());
    }
    return _instance;
  }

  /// Enables delegates to create new instances of themselves if a none default
  /// [FirebaseApp] instance is required by the user.
  @protected
  FirebaseMessagingPlatform delegateFor({FirebaseApp app}) {
    throw UnimplementedError('delegateFor() is not implemented');
  }

  /// On iOS, prompts the user for notification permissions the first time
  /// it is called.
  ///
  /// Does nothing and returns null on Android.
  Future<bool> requestNotificationPermissions() {
    throw UnimplementedError(
        'requestNotificationPermissions() is not implemented');
  }

  /// Stream that fires when the user changes their notification settings.
  ///
  /// Only fires on iOS.
  Stream<IosNotificationSettings> get onIosSettingsRegistered {
    throw UnimplementedError('onIosSettingsRegistered is not implemented');
  }

  /// Sets up [MessageHandler] for incoming messages.
  void configure() {
    throw UnimplementedError('configure() is not implemented');
  }

  /// Fires when a new FCM token is generated.
  Stream<String> get onTokenRefresh {
    throw UnimplementedError('onTokenRefresh is not implemented');
  }

  /// Returns the FCM token.
  Future<String> getToken() async {
    throw UnimplementedError('getToken() is not implemented');
  }

  /// Subscribe to topic in background.
  ///
  /// [topic] must match the following regular expression:
  /// "[a-zA-Z0-9-_.~%]{1,900}".
  Future<void> subscribeToTopic(String topic) {
    throw UnimplementedError('subscribeToTopic() is not implemented');
  }

  /// Unsubscribe from topic in background.
  Future<void> unsubscribeFromTopic(String topic) {
    throw UnimplementedError('unsubscribeFromTopic() is not implemented');
  }

  /// Resets Instance ID and revokes all tokens. In iOS, it also unregisters from remote notifications.
  ///
  /// A new Instance ID is generated asynchronously if Firebase Cloud Messaging auto-init is enabled.
  ///
  /// returns true if the operations executed successfully and false if an error ocurred
  Future<bool> deleteInstanceID() async {
    throw UnimplementedError('deleteInstanceID() is not implemented');
  }

  /// Determine whether FCM auto-initialization is enabled or disabled.
  Future<bool> autoInitEnabled() async {
    throw UnimplementedError('autoInitEnabled() is not implemented');
  }

  /// Enable or disable auto-initialization of Firebase Cloud Messaging.
  Future<void> setAutoInitEnabled(bool enabled) async {
    throw UnimplementedError('setAutoInitEnabled() is not implemented');
  }
}
