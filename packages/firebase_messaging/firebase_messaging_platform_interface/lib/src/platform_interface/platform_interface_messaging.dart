// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import '../method_channel/method_channel_messaging.dart';
import '../types.dart';

RemoteMessageHandler _onMessage;
void Function(String messageId) _onMessageSent;
RemoteMessageHandler _onNotificationOpenedApp;
void Function(FirebaseException exception, String messageId) _onSendError;
void Function() _onDeletedMessages;
RemoteMessageHandler _onBackgroundMessage;

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
  factory FirebaseMessagingPlatform.instanceFor(
      {FirebaseApp app, Map<dynamic, dynamic> pluginConstants}) {
    return FirebaseMessagingPlatform.instance
        .delegateFor(app: app)
        .setInitialValues(
          isAutoInitEnabled: pluginConstants['AUTO_INIT_ENABLED'],
          initialNotification: pluginConstants['INITIAL_NOTIFICATION'],
        );
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

  static void configure({
    //  String publicVapidKey, TODO(ehesp): add in with web support
    RemoteMessageHandler onMessage,
    void Function(String messageId) onMessageSent,
    RemoteMessageHandler onNotificationOpenedApp,
    void Function(FirebaseException exception, String messageId) onSendError,
    void Function() onDeletedMessages,
    RemoteMessageHandler onBackgroundMessage,
  }) {
    _onMessage = onMessage;
    _onMessageSent = onMessageSent;
    _onNotificationOpenedApp = onNotificationOpenedApp;
    _onSendError = onSendError;
    _onDeletedMessages = onDeletedMessages;
    _onBackgroundMessage = onBackgroundMessage;
  }

  /// Enables delegates to create new instances of themselves if a none default
  /// [FirebaseApp] instance is required by the user.
  @protected
  FirebaseMessagingPlatform delegateFor({FirebaseApp app}) {
    throw UnimplementedError('delegateFor() is not implemented');
  }

  /// Sets any initial values on the instance.
  ///
  /// Platforms with Method Channels can provide constant values to be available
  /// before the instance has initialized to prevent any unnecessary async
  /// calls.
  @protected
  FirebaseMessagingPlatform setInitialValues({
    bool isAutoInitEnabled,
    Map<String, dynamic> initialNotification,
  }) {
    throw UnimplementedError('setInitialValues() is not implemented');
  }

  /// Returns whether messaging auto initialization is enabled or disabled for the device.
  bool get isAutoInitEnabled {
    throw UnimplementedError('isAutoInitEnabled is not implemented');
  }

  /// If the application has been opened from a terminated state via a [Notification],
  /// it will be returned, otherwise it will be `null`.
  ///
  /// Once the [Notification] has been consumed, it will be removed and further
  /// calls to [initialNotification] will be `null`.
  ///
  /// This should be used to determine whether specific notification interaction
  /// should open the app with a specific purpose (e.g. opening a chat message,
  /// specific screen etc).
  Notification get initialNotification {
    throw UnimplementedError('initialNotification is not implemented');
  }

  /// Removes access to an FCM token previously authorized by it's scope.
  ///
  /// Messages sent by the server to this token will fail.
  Future<void> deleteToken({
    String authorizedEntity,
    String scope,
  }) {
    throw UnimplementedError('deleteToken() is not implemented');
  }

  /// On iOS, it is possible to get the users APNs token. This may be required
  /// if you want to send messages to your iOS devices without using the FCM service.
  Future<String> getAPNSToken() {
    throw UnimplementedError('getAPNSToken() is not implemented');
  }

  /// Returns an FCM token for this device.
  ///
  /// Optionally you can specify a custom authorized entity or scope to tailor
  /// tokens to your own use-case.
  Future<String> getToken({
    String authorizedEntity,
    String scope,
    String vapidKey,
  }) {
    throw UnimplementedError('getToken() is not implemented');
  }

  /// Returns a [AuthorizationStatus] as to whether the user has messaging
  /// permission for this app.
  Future<AuthorizationStatus> hasPermission() {
    throw UnimplementedError('hasPermission() is not implemented');
  }

  /// Fires when a new FCM token is generated.
  Stream<String> get onTokenRefresh {
    throw UnimplementedError('onTokenRefresh is not implemented');
  }

  /// Prompts the user for notification permissions.
  ///
  /// On iOS, a dialog is shown requesting the users permission.
  /// If [provisional] is set to `true`, silent notification permissions will be
  /// automatically granted. When notifications are delivered to the device, the
  /// user will be presented with an option to disable notifications, keep receiving
  /// them silently or enable prominent notifications.
  ///
  /// On Android, permissions are not required and [AuthorizationStatus.authorized] is returned.
  ///
  /// On Web, a popup requesting the users permission is shown using the native
  /// browser API.
  Future<AuthorizationStatus> requestPermission({
    /// Request permission to display alerts. Defaults to `true`.
    ///
    /// iOS only.
    bool alert = true,

    /// Request permission for Siri to automatically read out notification messages over AirPods.
    /// Defaults to `false`.
    ///
    /// iOS only.
    bool announcement = false,

    /// Request permission to update the application badge. Defaults to `true`.
    ///
    /// iOS only.
    bool badge = true,

    /// Request permission to display notifications in a CarPlay environment.
    /// Defaults to `false`.
    ///
    /// iOS only.
    bool carPlay = false,

    /// Request permission for critical alerts. Defaults to `false`.
    ///
    /// Note; your application must explicitly state reasoning for enabling
    /// crticial alerts during the App Store review process or your may be
    /// rejected.
    ///
    /// iOS only.
    bool criticalAlert = false,

    /// Request permission to provisionally create non-interrupting notifications.
    /// Defaults to `false`.
    ///
    /// iOS only.
    bool provisional = false,

    /// Request permission to play sounds. Defaults to `true`.
    ///
    /// iOS only.
    bool sound = true,
  }) {
    throw UnimplementedError('requestPermission() is not implemented');
  }

  /// Send a new message to the FCM server.
  Future<void> sendMessage({
    String senderId,
    Map<String, String> data,
    String collapseKey,
    String messageId,
    String messageType,
    int ttl,
  }) {
    throw UnimplementedError('sendMessage() is not implemented');
  }

  /// Enable or disable auto-initialization of Firebase Cloud Messaging.
  Future<void> setAutoInitEnabled(bool enabled) async {
    throw UnimplementedError('setAutoInitEnabled() is not implemented');
  }

  /// Stream that fires when the user changes their notification settings.
  ///
  /// Only fires on iOS.
  Stream<IosNotificationSettings> get onIosSettingsRegistered {
    throw UnimplementedError('onIosSettingsRegistered is not implemented');
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
}
