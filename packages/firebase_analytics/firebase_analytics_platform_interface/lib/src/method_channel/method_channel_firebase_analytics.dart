// ignore_for_file: require_trailing_commas
// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/services.dart';

import '../../firebase_analytics_platform_interface.dart';
import '../platform_interface/platform_interface_firebase_analytics.dart';

/// The method channel implementation of [FirebaseAnalyticsPlatform].
class MethodChannelFirebaseAnalytics extends FirebaseAnalyticsPlatform {
  /// Creates a new [MethodChannelFirebaseAnalytics] instance with an [app] and/or
  /// [region].
  MethodChannelFirebaseAnalytics({required FirebaseApp app})
      : super(appInstance: app);

  /// Internal stub class initializer.
  ///
  /// When the user code calls an analytics method, the real instance is
  /// then initialized via the [delegateFor] method.
  MethodChannelFirebaseAnalytics._() : super(appInstance: null);

  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebaseAnalytics get instance {
    return MethodChannelFirebaseAnalytics._();
  }

  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_analytics');

  /// Gets a [FirebaseAnalyticsPlatform]
  @override
  FirebaseAnalyticsPlatform delegateFor({required FirebaseApp app}) {
    return MethodChannelFirebaseAnalytics(app: app);
  }

  /// Logs the given event [name] with the given [parameters].
  /// [callOptions] are for web platform only.
  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
    CallOptions? callOptions,
  }) {
    return channel.invokeMethod<void>('Analytics#logEvent', <String, Object?>{
      'eventName': name,
      'parameters': parameters,
    });
  }

  /// Sets the applicable end user consent state.
  @override
  Future<void> setConsent(
      {ConsentStatus? adStorage, ConsentStatus? analyticsStorage}) async {
    return channel.invokeMethod<void>(
      'Analytics#setConsent',
      <String, Object?>{
        'adStorage': adStorage,
        'analyticsStorage': analyticsStorage,
      },
    );
  }

  /// Adds parameters that will be set on every event logged from the SDK, including automatic ones.
  @override
  Future<void> setDefaultEventParameters(
      Map<String, Object> defaultParameters) async {
    return channel.invokeMethod<void>(
      'Analytics#setDefaultEventParameters',
      defaultParameters,
    );
  }

  /// Sets whether analytics collection is enabled for this app.
  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) {
    return channel.invokeMethod<void>(
      'Analytics#setAnalyticsCollectionEnabled',
      <String, bool?>{
        'enabled': enabled,
      },
    );
  }

  /// Sets the user id.
  /// Setting a null [id] removes the user id.
  /// [callOptions] are for web platform only.
  @override
  Future<void> setUserId({
    String? id,
    CallOptions? callOptions,
  }) {
    return channel.invokeMethod<void>('Analytics#setUserId', {'userId': id});
  }

  /// Sets the current screen name, which specifies the current visual context
  /// in your app.
  ///
  /// Setting a null [screenName] clears the current screen name.
  /// [callOptions] are for web platform only.
  @override
  Future<void> setCurrentScreen({
    String? screenName,
    String? screenClassOverride,
    CallOptions? callOptions,
  }) {
    return channel
        .invokeMethod<void>('Analytics#setCurrentScreen', <String, String?>{
      'screenName': screenName,
      'screenClassOverride': screenClassOverride,
    });
  }

  /// Sets a user property to the given value.
  /// Setting a null [value] removes the user property.
  /// [callOptions] are for web platform only.
  @override
  Future<void> setUserProperty({
    required String name,
    required Object value,
    CallOptions? callOptions,
  }) {
    return channel
        .invokeMethod<void>('Analytics#setUserProperty', <String, Object?>{
      'name': name,
      'value': value,
    });
  }

  /// Clears all analytics data for this app from the device and resets the app
  /// instance id.
  @override
  Future<void> resetAnalyticsData() {
    return channel.invokeMethod<void>('Analytics#resetAnalyticsData');
  }

  /// Sets the duration of inactivity that terminates the current session.
  @override
  Future<void> setSessionTimeoutDuration(Duration timeout) async {
    if (Platform.isAndroid) {
      return channel.invokeMethod<void>(
          'Analytics#setSessionTimeoutDuration', <String, int>{
        'milliseconds': timeout.inMilliseconds,
      });
    }
  }
}
