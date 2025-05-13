// ignore_for_file: require_trailing_commas
// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging_platform_interface/firebase_messaging_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils.dart';
import 'utils/exception.dart';

// This is the entrypoint for the background isolate. Since we can only enter
// an isolate once, we setup a MethodChannel to listen for method invocations
// from the native portion of the plugin. This allows for the plugin to perform
// any necessary processing in Dart (e.g., populating a custom object) before
// invoking the provided callback.
@pragma('vm:entry-point')
void _firebaseMessagingCallbackDispatcher() {
  // Initialize state necessary for MethodChannels.
  WidgetsFlutterBinding.ensureInitialized();

  const MethodChannel _channel = MethodChannel(
    'plugins.flutter.io/firebase_messaging_background',
  );

  // This is where we handle background events from the native portion of the plugin.
  _channel.setMethodCallHandler((MethodCall call) async {
    if (call.method == 'MessagingBackground#onMessage') {
      final CallbackHandle handle =
          CallbackHandle.fromRawHandle(call.arguments['userCallbackHandle']);

      // PluginUtilities.getCallbackFromHandle performs a lookup based on the
      // callback handle and returns a tear-off of the original callback.
      final closure = PluginUtilities.getCallbackFromHandle(handle)!
          as Future<void> Function(RemoteMessage);

      try {
        Map<String, dynamic> messageMap =
            Map<String, dynamic>.from(call.arguments['message']);
        final RemoteMessage remoteMessage = RemoteMessage.fromMap(messageMap);
        await closure(remoteMessage);
      } catch (e) {
        // ignore: avoid_print
        print(
            'FlutterFire Messaging: An error occurred in your background messaging handler:');
        // ignore: avoid_print
        print(e);
      }
    } else {
      throw UnimplementedError('${call.method} has not been implemented');
    }
  });

  // Once we've finished initializing, let the native portion of the plugin
  // know that it can start scheduling alarms.
  _channel.invokeMethod<void>('MessagingBackground#initialized');
}

/// The entry point for accessing a Messaging.
///
/// You can get an instance by calling [FirebaseMessaging.instance].
class MethodChannelFirebaseMessaging extends FirebaseMessagingPlatform {
  /// Create an instance of [MethodChannelFirebaseMessaging] with optional [FirebaseApp]
  MethodChannelFirebaseMessaging({required FirebaseApp app})
      : super(appInstance: app);

  late bool _autoInitEnabled;

  static bool _bgHandlerInitialized = false;

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

  static void setMethodCallHandlers() {
    MethodChannelFirebaseMessaging.channel
        .setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'Messaging#onTokenRefresh':
          MethodChannelFirebaseMessaging.tokenStreamController
              .add(call.arguments as String);
          break;
        case 'Messaging#onMessage':
          Map<String, dynamic> messageMap =
              Map<String, dynamic>.from(call.arguments);
          FirebaseMessagingPlatform.onMessage
              .add(RemoteMessage.fromMap(messageMap));
          break;
        case 'Messaging#onMessageOpenedApp':
          Map<String, dynamic> messageMap =
              Map<String, dynamic>.from(call.arguments);
          FirebaseMessagingPlatform.onMessageOpenedApp
              .add(RemoteMessage.fromMap(messageMap));
          break;
        case 'Messaging#onBackgroundMessage':
          // Apple only. Android calls via separate background channel.
          Map<String, dynamic> messageMap =
              Map<String, dynamic>.from(call.arguments);
          return FirebaseMessagingPlatform.onBackgroundMessage
              ?.call(RemoteMessage.fromMap(messageMap));
        default:
          throw UnimplementedError('${call.method} has not been implemented');
      }
    });
  }

  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_messaging',
  );

  // ignore: close_sinks, never closed
  static StreamController<String> tokenStreamController =
      StreamController<String>.broadcast();

  // Created this to check APNS token is available before certain Apple Firebase
  // Messaging requests. See this issue:
  // https://github.com/firebase/flutterfire/issues/10625
  Future<void> _APNSTokenCheck() async {
    if (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      String? token = await getAPNSToken();

      if (token == null) {
        throw FirebaseException(
          plugin: 'firebase_messaging',
          code: 'apns-token-not-set',
          message:
              'APNS token has not been set yet. Please ensure the APNS token is available by calling `getAPNSToken()`.',
        );
      }
    }
  }

  @override
  FirebaseMessagingPlatform delegateFor({required FirebaseApp app}) {
    return MethodChannelFirebaseMessaging(app: app);
  }

  @override
  FirebaseMessagingPlatform setInitialValues({bool? isAutoInitEnabled}) {
    _autoInitEnabled = isAutoInitEnabled ?? false;
    return this;
  }

  @override
  bool get isAutoInitEnabled {
    return _autoInitEnabled;
  }

  /// Returns "true" as this API is used to inform users of web browser support
  @override
  Future<bool> isSupported() {
    return Future.value(true);
  }

  @override
  Future<RemoteMessage?> getInitialMessage() async {
    try {
      Map<String, dynamic>? remoteMessageMap = await channel
          .invokeMapMethod<String, dynamic>('Messaging#getInitialMessage', {
        'appName': app.name,
      });

      if (remoteMessageMap == null) {
        return null;
      }

      return RemoteMessage.fromMap(remoteMessageMap);
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<void> registerBackgroundMessageHandler(
      BackgroundMessageHandler handler) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    if (!_bgHandlerInitialized) {
      _bgHandlerInitialized = true;
      final CallbackHandle bgHandle = PluginUtilities.getCallbackHandle(
        _firebaseMessagingCallbackDispatcher,
      )!;
      final CallbackHandle userHandle =
          PluginUtilities.getCallbackHandle(handler)!;
      await channel.invokeMapMethod('Messaging#startBackgroundIsolate', {
        'pluginCallbackHandle': bgHandle.toRawHandle(),
        'userCallbackHandle': userHandle.toRawHandle(),
      });
    }
  }

  @override
  Future<void> deleteToken() async {
    await _APNSTokenCheck();

    try {
      await channel
          .invokeMapMethod('Messaging#deleteToken', {'appName': app.name});
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<String?> getAPNSToken() async {
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.macOS) {
      return null;
    }

    try {
      Map<String, String?>? data = await channel
          .invokeMapMethod<String, String?>('Messaging#getAPNSToken', {
        'appName': app.name,
      });

      return data!['token'];
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<String?> getToken({
    String? vapidKey, // not used yet; web only property
  }) async {
    await _APNSTokenCheck();

    try {
      Map<String, String?>? data =
          await channel.invokeMapMethod<String, String>('Messaging#getToken', {
        'appName': app.name,
      });

      return data!['token'];
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<NotificationSettings> getNotificationSettings() async {
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.macOS &&
        defaultTargetPlatform != TargetPlatform.android) {
      return defaultNotificationSettings;
    }

    try {
      Map<String, int>? response = await channel
          .invokeMapMethod<String, int>('Messaging#getNotificationSettings', {
        'appName': app.name,
      });

      return convertToNotificationSettings(response!);
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
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
    bool providesAppNotificationSettings = false,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.macOS &&
        defaultTargetPlatform != TargetPlatform.android) {
      return defaultNotificationSettings;
    }

    try {
      Map<String, int>? response = await channel
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
          'providesAppNotificationSettings': providesAppNotificationSettings,
        }
      });

      return convertToNotificationSettings(response!);
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<void> setAutoInitEnabled(bool enabled) async {
    try {
      Map<String, dynamic>? data = await channel
          .invokeMapMethod<String, dynamic>('Messaging#setAutoInitEnabled', {
        'appName': app.name,
        'enabled': enabled,
      });

      _autoInitEnabled = data!['isAutoInitEnabled'] as bool;
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Stream<String> get onTokenRefresh {
    return tokenStreamController.stream;
  }

  @override
  Future<void> setForegroundNotificationPresentationOptions({
    required bool alert,
    required bool badge,
    required bool sound,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.macOS) {
      return;
    }

    try {
      await channel.invokeMapMethod(
          'Messaging#setForegroundNotificationPresentationOptions', {
        'appName': app.name,
        'alert': alert,
        'badge': badge,
        'sound': sound,
      });
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<void> sendMessage({
    required String to,
    Map<String, String>? data,
    String? collapseKey,
    String? messageId,
    String? messageType,
    int? ttl,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      throw UnimplementedError(
          'Sending of messages from the Firebase Messaging SDK is only supported on Android devices.');
    }

    try {
      await channel.invokeMapMethod('Messaging#sendMessage', {
        'appName': app.name,
        'to': to,
        'data': data,
        'collapseKey': collapseKey,
        'messageId': messageId,
        'messageType': messageType,
        'ttl': ttl,
      });
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    await _APNSTokenCheck();

    try {
      await channel.invokeMapMethod('Messaging#subscribeToTopic', {
        'appName': app.name,
        'topic': topic,
      });
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    await _APNSTokenCheck();

    try {
      await channel.invokeMapMethod('Messaging#unsubscribeFromTopic', {
        'appName': app.name,
        'topic': topic,
      });
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }

  @override
  Future<void> setDeliveryMetricsExportToBigQuery(bool enabled) async {
    // The method is not available on iOS.
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      await channel
          .invokeMapMethod('Messaging#setDeliveryMetricsExportToBigQuery', {
        'appName': app.name,
        'enabled': enabled,
      });
    } catch (e, stack) {
      convertPlatformException(e, stack);
    }
  }
}
