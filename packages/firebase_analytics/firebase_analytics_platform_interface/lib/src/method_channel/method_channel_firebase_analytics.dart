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

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
    // TODO - callOptions only used for web. Warn user?
    CallOptions? callOptions,
  }) {
    return channel.invokeMethod<void>('Analytics#logEvent', <String, Object?>{
      'eventName': name,
      'parameters': parameters,
    });
  }

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

  @override
  Future<void> setDefaultEventParameters(
      Map<String, Object> defaultParameters) async {
    return channel.invokeMethod<void>(
      'Analytics#setDefaultEventParameters',
      defaultParameters,
    );
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) {
    return channel.invokeMethod<void>(
      'Analytics#setAnalyticsCollectionEnabled',
      <String, bool?>{
        'enabled': enabled,
      },
    );
  }

  @override
  Future<void> setUserId({
    String? id,
    CallOptions? callOptions,
  }) {
    return channel.invokeMethod<void>('Analytics#setUserId', {'userId': id});
  }

  @override
  Future<void> setCurrentScreen({
    String? screenName,
    String? screenClassOverride,
    // TODO warn user callOptions only used for web
    CallOptions? callOptions,
  }) {
    return channel
        .invokeMethod<void>('Analytics#setCurrentScreen', <String, String?>{
      'screenName': screenName,
      'screenClassOverride': screenClassOverride,
    });
  }

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

  @override
  Future<void> resetAnalyticsData() {
    return channel.invokeMethod<void>('Analytics#resetAnalyticsData');
  }

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
