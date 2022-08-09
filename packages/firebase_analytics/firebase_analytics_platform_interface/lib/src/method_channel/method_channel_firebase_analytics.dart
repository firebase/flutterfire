// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'utils/exception.dart';

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

  @override
  FirebaseAnalyticsPlatform delegateFor({required FirebaseApp app}) {
    return MethodChannelFirebaseAnalytics(app: app);
  }

  /// Returns "true" as this API is used to inform users of web browser support
  @override
  Future<bool> isSupported() {
    return Future.value(true);
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    try {
      return channel.invokeMethod<void>('Analytics#logEvent', <String, Object?>{
        'eventName': name,
        'parameters': parameters,
      });
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setConsent({
    bool? adStorageConsentGranted,
    bool? analyticsStorageConsentGranted,
  }) async {
    try {
      return channel.invokeMethod<void>(
        'Analytics#setConsent',
        <String, Object?>{
          if (adStorageConsentGranted != null)
            'adStorageConsentGranted': adStorageConsentGranted,
          if (analyticsStorageConsentGranted != null)
            'analyticsStorageConsentGranted': analyticsStorageConsentGranted,
        },
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setDefaultEventParameters(
    Map<String, Object?>? defaultParameters,
  ) async {
    try {
      return channel.invokeMethod<void>(
        'Analytics#setDefaultEventParameters',
        defaultParameters,
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) {
    try {
      return channel.invokeMethod<void>(
        'Analytics#setAnalyticsCollectionEnabled',
        <String, bool?>{
          'enabled': enabled,
        },
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setUserId({
    String? id,
    AnalyticsCallOptions? callOptions,
  }) {
    try {
      return channel.invokeMethod<void>(
        'Analytics#setUserId',
        <String, String?>{'userId': id},
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setCurrentScreen({
    String? screenName,
    String? screenClassOverride,
    AnalyticsCallOptions? callOptions,
  }) {
    try {
      return channel.invokeMethod<void>('Analytics#logEvent', <String, Object?>{
        'eventName': 'screen_view',
        'parameters': <String, String?>{
          'screen_name': screenName,
          'screen_class': screenClassOverride,
        },
      });
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
    AnalyticsCallOptions? callOptions,
  }) {
    try {
      return channel
          .invokeMethod<void>('Analytics#setUserProperty', <String, Object?>{
        'name': name,
        'value': value,
      });
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> resetAnalyticsData() {
    try {
      return channel.invokeMethod<void>('Analytics#resetAnalyticsData');
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<String?> getAppInstanceId() {
    try {
      return channel.invokeMethod<String?>('Analytics#getAppInstanceId');
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setSessionTimeoutDuration(Duration timeout) async {
    try {
      if (Platform.isAndroid) {
        return channel.invokeMethod<void>(
            'Analytics#setSessionTimeoutDuration', <String, int>{
          'milliseconds': timeout.inMilliseconds,
        });
      }
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }
}
