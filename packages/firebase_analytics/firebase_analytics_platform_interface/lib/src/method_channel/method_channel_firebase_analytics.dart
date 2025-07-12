// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_analytics_platform_interface/src/pigeon/messages.pigeon.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
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
  final _api = FirebaseAnalyticsHostApi();

  /// Returns a stub instance to allow the platform interface to access
  /// the class instance statically.
  static MethodChannelFirebaseAnalytics get instance {
    return MethodChannelFirebaseAnalytics._();
  }

  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_analytics');

  @override
  FirebaseAnalyticsPlatform delegateFor({
    required FirebaseApp app,
    Map<String, dynamic>? webOptions,
  }) {
    return MethodChannelFirebaseAnalytics(app: app);
  }

  /// Returns "true" as this API is used to inform users of web browser support
  @override
  Future<bool> isSupported() {
    return Future.value(true);
  }

  @override
  Future<int?> getSessionId() {
    try {
      return _api.getSessionId();
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    try {
      return _api.logEvent(<String, Object?>{
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
    bool? adPersonalizationSignalsConsentGranted,
    bool? adUserDataConsentGranted,
    bool? functionalityStorageConsentGranted,
    bool? personalizationStorageConsentGranted,
    bool? securityStorageConsentGranted,
  }) async {
    try {
      return _api.setConsent(<String, bool?>{
        if (adStorageConsentGranted != null)
          'adStorageConsentGranted': adStorageConsentGranted,
        if (analyticsStorageConsentGranted != null)
          'analyticsStorageConsentGranted': analyticsStorageConsentGranted,
        if (adPersonalizationSignalsConsentGranted != null)
          'adPersonalizationSignalsConsentGranted':
              adPersonalizationSignalsConsentGranted,
        if (adUserDataConsentGranted != null)
          'adUserDataConsentGranted': adUserDataConsentGranted,
      });
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setDefaultEventParameters(
    Map<String, Object?>? defaultParameters,
  ) async {
    try {
      return _api.setDefaultEventParameters(defaultParameters);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) {
    try {
      return _api.setAnalyticsCollectionEnabled(enabled);
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
      return _api.setUserId(id);
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
      return _api.logEvent(<String, Object?>{
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
      return _api.setUserProperty(name, value);
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> resetAnalyticsData() {
    try {
      return _api.resetAnalyticsData();
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<String?> getAppInstanceId() {
    try {
      return _api.getAppInstanceId();
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> setSessionTimeoutDuration(Duration timeout) async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        return _api.setSessionTimeoutDuration(timeout.inMilliseconds);
      }
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }

  @override
  Future<void> initiateOnDeviceConversionMeasurement({
    String? emailAddress,
    String? phoneNumber,
    String? hashedEmailAddress,
    String? hashedPhoneNumber,
  }) {
    try {
      return _api.initiateOnDeviceConversionMeasurement(
        <String, String?>{
          'emailAddress': emailAddress,
          'phoneNumber': phoneNumber,
          'hashedEmailAddress': hashedEmailAddress,
          'hashedPhoneNumber': hashedPhoneNumber,
        },
      );
    } catch (e, s) {
      convertPlatformException(e, s);
    }
  }
}
