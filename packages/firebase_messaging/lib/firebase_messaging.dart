// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

typedef Future<dynamic> MessageHandler(Map<String, dynamic> message);

/// Setup method channel to handle Firebase Cloud Messages received while
/// the Flutter app is not active. The handle for this method is generated
/// and passed to the Android side so that the background isolate knows where
/// to send background messages for processing.
///
/// Your app should never call this method directly, this is only for use
/// by the firebase_messaging plugin to setup background message handling.
void _fcmSetupBackgroundChannel(
    {MethodChannel backgroundChannel = const MethodChannel(
        'plugins.flutter.io/firebase_messaging_background')}) async {
  // Setup Flutter state needed for MethodChannels.
  WidgetsFlutterBinding.ensureInitialized();

  // This is where the magic happens and we handle background events from the
  // native portion of the plugin.
  backgroundChannel.setMethodCallHandler((MethodCall call) async {
    if (call.method == 'handleBackgroundMessage') {
      final CallbackHandle handle =
          CallbackHandle.fromRawHandle(call.arguments['handle']);
      final Function handlerFunction =
          PluginUtilities.getCallbackFromHandle(handle);
      try {
        await handlerFunction(
            Map<String, dynamic>.from(call.arguments['message']));
      } catch (e) {
        print('Unable to handle incoming background message.');
        print(e);
      }
      return Future<void>.value();
    }
  });

  // Once we've finished initializing, let the native portion of the plugin
  // know that it can start scheduling handling messages.
  backgroundChannel.invokeMethod<void>('FcmDartService#initialized');
}

class FirebaseMessagingHandlers {
  MessageHandler _onMessage;
  MessageHandler _onBackgroundMessage;
  MessageHandler _onLaunch;
  MessageHandler _onResume;
}

/// Implementation of the Firebase Cloud Messaging API for Flutter.
///
/// Your app should call [requestNotificationPermissions] first and then
/// register handlers for incoming messages with [configure].
class FirebaseMessaging {
  factory FirebaseMessaging() => _instance;

  @visibleForTesting
  FirebaseMessaging.private(MethodChannel channel) : _channel = channel;

  static final FirebaseMessaging _instance = FirebaseMessaging.private(
      const MethodChannel('plugins.flutter.io/firebase_messaging'));

  final MethodChannel _channel;
  bool _initialized = false;

  Map<String, FirebaseMessagingHandlers> _handlers = {};

  /// On iOS, prompts the user for notification permissions the first time
  /// it is called.
  ///
  /// Does nothing and returns null on Android.
  FutureOr<bool> requestNotificationPermissions([
    IosNotificationSettings iosSettings = const IosNotificationSettings(),
  ]) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return null;
    }
    return _channel.invokeMethod<bool>(
      'requestNotificationPermissions',
      iosSettings.toMap(),
    );
  }

  final StreamController<IosNotificationSettings> _iosSettingsStreamController =
      StreamController<IosNotificationSettings>.broadcast();

  /// Stream that fires when the user changes their notification settings.
  ///
  /// Only fires on iOS.
  Stream<IosNotificationSettings> get onIosSettingsRegistered {
    return _iosSettingsStreamController.stream;
  }

  /// Sets up [MessageHandler] for incoming messages.
  /// Use [senderId] to receive messages from another firebase app.
  /// See [Firebase official documentation](https://firebase.google.com/docs/cloud-messaging/concept-options#receiving-messages-from-multiple-senders)
  void configure({
    String senderId,
    MessageHandler onMessage,
    MessageHandler onBackgroundMessage,
    MessageHandler onLaunch,
    MessageHandler onResume,
  }) {
    if (!_initialized) {
      _channel.setMethodCallHandler(_handleMethod);
      _initialized = true;
    }

    FirebaseMessagingHandlers handlers = FirebaseMessagingHandlers();
    _handlers[senderId] = handlers;
    handlers._onMessage = onMessage;
    handlers._onLaunch = onLaunch;
    handlers._onResume = onResume;

    _channel.invokeMethod<void>('configure', senderId);
    if (onBackgroundMessage != null) {
      handlers._onBackgroundMessage = onBackgroundMessage;
      final CallbackHandle backgroundSetupHandle =
          PluginUtilities.getCallbackHandle(_fcmSetupBackgroundChannel);
      final CallbackHandle backgroundMessageHandle =
          PluginUtilities.getCallbackHandle(handlers._onBackgroundMessage);

      if (backgroundMessageHandle == null) {
        throw ArgumentError(
          '''Failed to setup background message handler! `onBackgroundMessage`
          should be a TOP-LEVEL OR STATIC FUNCTION and should NOT be tied to a
          class or an anonymous function.''',
        );
      }

      if (!_initialized) {
        _channel.invokeMethod<bool>(
          'FcmDartService#start',
          <String, dynamic>{
            'setupHandle': backgroundSetupHandle.toRawHandle(),
            'backgroundHandle': backgroundMessageHandle.toRawHandle()
          },
        );
      }
    }
  }

  final StreamController<String> _tokenStreamController =
      StreamController<String>.broadcast();

  /// Fires when a new FCM token is generated.
  Stream<String> get onTokenRefresh {
    return _tokenStreamController.stream;
  }

  /// Returns the FCM token.
  /// Use [senderId] to get the token from another sender.
  /// See [Firebase official documentation](https://firebase.google.com/docs/cloud-messaging/concept-options#receiving-messages-from-multiple-senders)
  Future<String> getToken({String senderId}) async {
    return await _channel.invokeMethod<String>('getToken', senderId);
  }

  /// Subscribe to topic in background.
  ///
  /// [topic] must match the following regular expression:
  /// "[a-zA-Z0-9-_.~%]{1,900}".
  Future<void> subscribeToTopic(String topic) {
    return _channel.invokeMethod<void>('subscribeToTopic', topic);
  }

  /// Unsubscribe from topic in background.
  Future<void> unsubscribeFromTopic(String topic) {
    return _channel.invokeMethod<void>('unsubscribeFromTopic', topic);
  }

  /// Resets Instance ID and revokes all tokens. In iOS, it also unregisters from remote notifications.
  ///
  /// A new Instance ID is generated asynchronously if Firebase Cloud Messaging auto-init is enabled.
  ///
  /// returns true if the operations executed successfully and false if an error occurred
  /// Use [senderId] remove a secondary sender
  Future<bool> deleteInstanceID({String senderId}) async {
    _handlers.remove(senderId);
    return await _channel.invokeMethod<bool>('deleteInstanceID', senderId);
  }

  /// Determine whether FCM auto-initialization is enabled or disabled.
  Future<bool> autoInitEnabled() async {
    return await _channel.invokeMethod<bool>('autoInitEnabled');
  }

  /// Enable or disable auto-initialization of Firebase Cloud Messaging.
  Future<void> setAutoInitEnabled(bool enabled) async {
    await _channel.invokeMethod<void>('setAutoInitEnabled', enabled);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onToken":
        final String token = call.arguments;
        _tokenStreamController.add(token);
        return null;
      case "onIosSettingsRegistered":
        _iosSettingsStreamController.add(IosNotificationSettings._fromMap(
            call.arguments.cast<String, bool>()));
        return null;
      case "onMessage":
        final args = call.arguments.cast<String, dynamic>();
        String senderId = args['senderId'];
        final handlers = _handlers[senderId];
        return handlers._onMessage(args);
      case "onLaunch":
        final args = call.arguments.cast<String, dynamic>();
        String senderId = args['senderId'];
        final handlers = _handlers[senderId];
        return handlers._onLaunch(call.arguments.cast<String, dynamic>());
      case "onResume":
        final args = call.arguments.cast<String, dynamic>();
        String senderId = args['senderId'];
        _handlers[senderId]._onResume(args);
        return;
      default:
        throw UnsupportedError("Unrecognized JSON message");
    }
  }
}

class IosNotificationSettings {
  const IosNotificationSettings({
    this.sound = true,
    this.alert = true,
    this.badge = true,
    this.provisional = false,
  });

  IosNotificationSettings._fromMap(Map<String, bool> settings)
      : sound = settings['sound'],
        alert = settings['alert'],
        badge = settings['badge'],
        provisional = settings['provisional'];

  final bool sound;
  final bool alert;
  final bool badge;
  final bool provisional;

  @visibleForTesting
  Map<String, dynamic> toMap() {
    return <String, bool>{
      'sound': sound,
      'alert': alert,
      'badge': badge,
      'provisional': provisional
    };
  }

  @override
  String toString() => 'PushNotificationSettings ${toMap()}';
}
