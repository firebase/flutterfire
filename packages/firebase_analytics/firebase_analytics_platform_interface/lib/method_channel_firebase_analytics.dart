// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show required;

import 'firebase_analytics_platform_interface.dart';

/// The method channel implementation of [FirebaseAnalyticsPlatform].
class MethodChannelFirebaseAnalytics extends FirebaseAnalyticsPlatform {
  static const MethodChannel _channel =
      MethodChannel('plugins.flutter.io/firebase_analytics');

  @override
  Future<void> logEvent({
    @required String name,
    Map<String, dynamic> parameters,
  }) {
    return _channel.invokeMethod<void>('logEvent', <String, dynamic>{
      'name': name,
      'parameters': parameters,
    });
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) {
    return _channel.invokeMethod<void>(
      'setAnalyticsCollectionEnabled',
      enabled,
    );
  }

  @override
  Future<void> setUserId(String id) {
    return _channel.invokeMethod<void>('setUserId', id);
  }

  @override
  Future<void> setCurrentScreen({
    @required String screenName,
    String screenClassOverride,
  }) {
    return _channel.invokeMethod<void>('setCurrentScreen', <String, String>{
      'screenName': screenName,
      'screenClassOverride': screenClassOverride,
    });
  }

  @override
  Future<void> setUserProperty({
    @required String name,
    @required String value,
  }) {
    return _channel.invokeMethod<void>('setUserProperty', <String, String>{
      'name': name,
      'value': value,
    });
  }

  @override
  Future<void> resetAnalyticsData() {
    return _channel.invokeMethod<void>('resetAnalyticsData');
  }

  @override
  Future<void> setSessionTimeoutDuration(int milliseconds) {
    return _channel.invokeMethod<void>(
        'setSessionTimeoutDuration', milliseconds);
  }
}
