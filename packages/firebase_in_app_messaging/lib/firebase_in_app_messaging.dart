// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

typedef Future<dynamic> InAppMessageHandler(InAppMessageData data);
typedef Future<dynamic> InAppMessageErrorHandler(
    InAppMessageErrorException message);

class FirebaseInAppMessaging {
  @visibleForTesting
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_in_app_messaging');

  static FirebaseInAppMessaging _instance = FirebaseInAppMessaging();

  /// Gets the instance of In-App Messaging for the default Firebase app.
  static FirebaseInAppMessaging get instance => _instance;

  InAppMessageErrorHandler _onError;
  InAppMessageHandler _onImpression;
  InAppMessageHandler _onClicked;

  InAppMessageData _getInAppMessageDataFromArgs(dynamic args) {
    if (args == null) return null;
    final Map<String, dynamic> data = args.cast<String, dynamic>();

    InAppMessageActionData action;
    if (data['action'] != null && data['action'].isNotEmpty) {
      action = InAppMessageActionData._(
          data['action']['actionText'], data['action']['actionURL']);
    }

    return InAppMessageData._(data['messageID'], data['campaignName'], action);
  }

  /// Triggers an analytics event.
  Future<void> triggerEvent(String eventName) async {
    await channel.invokeMethod<void>(
        'triggerEvent', <String, String>{'eventName': eventName});
  }

  /// Enables or disables suppression of message displays.
  Future<void> setMessagesSuppressed(bool suppress) async {
    if (suppress == null) {
      throw ArgumentError.notNull('suppress');
    }
    await channel.invokeMethod<void>('setMessagesSuppressed', suppress);
  }

  /// Disable data collection for the app.
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {
    if (enabled == null) {
      throw ArgumentError.notNull('enabled');
    }
    await channel.invokeMethod<void>(
        'setAutomaticDataCollectionEnabled', enabled);
  }

  /// Sets up [InAppMessageHandler] or [InAppMessageErrorHandler] for incoming messages.
  void configure({
    InAppMessageErrorHandler onError,
    InAppMessageHandler onImpression,
    InAppMessageHandler onClicked,
  }) async {
    _onError = onError;
    _onImpression = onImpression;
    _onClicked = onClicked;
    channel.setMethodCallHandler(handleMethod);
  }

  @visibleForTesting
  Future<dynamic> handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onError':
        final Map<dynamic, dynamic> data =
            call.arguments.cast<dynamic, dynamic>();
        final InAppMessageErrorException e = InAppMessageErrorException._(
            data['code'], data['message'], data['details']);
        return _onError(e);
      case 'onImpression':
        return _onImpression(_getInAppMessageDataFromArgs(call.arguments));
      case 'onClicked':
        return _onClicked(_getInAppMessageDataFromArgs(call.arguments));
      default:
        throw UnsupportedError("Unrecognize method");
    }
  }
}

/// Provides data from received in_app_message
class InAppMessageData {
  InAppMessageData._(this.messageID, this.campaignName, this.action);

  /// ID for in_app_message.
  final String messageID;

  /// Campaign name for in_app_message.
  final String campaignName;

  /// Provides action data
  ///
  /// Can be null when [call.method] equals [onImpression] or
  /// dismiss/cancel action is selected.
  final InAppMessageActionData action;
}

/// Provides tapped action data in_app_message
class InAppMessageActionData {
  InAppMessageActionData._(this.actionText, this.actionURL);

  /// Selected action button text.
  final String actionText;

  /// Selected action url.
  final String actionURL;
}

/// This object is returned by the [InAppMessageErrorHandler] when an error occur
class InAppMessageErrorException extends PlatformException {
  InAppMessageErrorException._(String code, String message, dynamic details)
      : super(code: code, message: message, details: details);
}
