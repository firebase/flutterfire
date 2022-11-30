// Copyright 2021 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:meta/meta.dart' show protected;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../firebase_analytics_platform_interface.dart';

/// The interface that implementations of `firebase_analytics` must extend.
///
/// Platform implementations should extend this class rather than implement it
/// as `firebase_analytics` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [FirebaseAnalyticsPlatform] methods.
abstract class FirebaseAnalyticsPlatform extends PlatformInterface {
  /// The [FirebaseApp] this instance was initialized with.
  @protected
  FirebaseApp? appInstance;

  /// Create an instance using [app]
  FirebaseAnalyticsPlatform({this.appInstance}) : super(token: _token);

  static final Object _token = Object();

  static FirebaseAnalyticsPlatform? _instance;

  /// Returns the [FirebaseApp] for the current instance.
  FirebaseApp get app {
    if (appInstance == null) {
      return Firebase.app();
    }

    return appInstance!;
  }

  /// Create an instance using [app] using the existing implementation
  factory FirebaseAnalyticsPlatform.instanceFor({required FirebaseApp app}) {
    return FirebaseAnalyticsPlatform.instance.delegateFor(app: app);
  }

  /// The current default [FirebaseAnalyticsPlatform] instance.
  ///
  /// It will always default to [MethodChannelFirebaseAnalytics]
  /// if no other implementation was provided.
  static FirebaseAnalyticsPlatform get instance {
    return _instance ??= MethodChannelFirebaseAnalytics.instance;
  }

  /// Sets the [FirebaseAnalyticsPlatform.instance]
  static set instance(FirebaseAnalyticsPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  /// Enables delegates to create new instances of themselves
  FirebaseAnalyticsPlatform delegateFor({required FirebaseApp app}) {
    throw UnimplementedError('delegateFor() is not implemented');
  }

  /// isSupported() informs web users whether
  /// the browser supports Firebase.Analytics
  Future<bool> isSupported() {
    throw UnimplementedError('isSupported() is not implemented');
  }

  /// Retrieves the app instance id from the service.
  Future<String?> getAppInstanceId() {
    throw UnimplementedError('getAppInstanceId() is not implemented');
  }

  /// Logs the given event [name] with the given [parameters].
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    throw UnimplementedError('logEvent() is not implemented');
  }

  /// Sets whether analytics collection is enabled for this app.
  Future<void> setAnalyticsCollectionEnabled(bool enabled) {
    throw UnimplementedError(
      'setAnalyticsCollectionEnabled() is not implemented',
    );
  }

  /// Sets the user id.
  /// Setting a null [id] removes the user id.
  /// [callOptions] are for web platform only.
  Future<void> setUserId({
    String? id,
    AnalyticsCallOptions? callOptions,
  }) {
    throw UnimplementedError('setUserId() is not implemented');
  }

  /// Sets the current screen name, which specifies the current visual context
  /// in your app.
  ///
  /// Setting a null [screenName] clears the current screen name.
  /// [callOptions] are for web platform only.
  Future<void> setCurrentScreen({
    String? screenName,
    String? screenClassOverride,
    AnalyticsCallOptions? callOptions,
  }) {
    throw UnimplementedError('setCurrentScreen() is not implemented');
  }

  /// Sets a user property to the given value.
  /// Setting a null [value] removes the user property.
  /// [callOptions] are for web platform only.
  Future<void> setUserProperty({
    required String name,
    required String? value,
    AnalyticsCallOptions? callOptions,
  }) {
    throw UnimplementedError('setUserProperty() is not implemented');
  }

  /// Clears all analytics data for this app from the device and resets the app
  /// instance id.
  Future<void> resetAnalyticsData() {
    throw UnimplementedError('resetAnalyticsData() is not implemented');
  }

  /// Sets the duration of inactivity that terminates the current session.
  Future<void> setSessionTimeoutDuration(Duration timeout) {
    throw UnimplementedError('setSessionTimeoutDuration() is not implemented');
  }

  /// Sets the applicable end user consent state.
  Future<void> setConsent({
    bool? adStorageConsentGranted,
    bool? analyticsStorageConsentGranted,
  }) {
    throw UnimplementedError('setConsent() is not implemented');
  }

  /// Adds parameters that will be set on every event logged from the SDK, including automatic ones.
  Future<void> setDefaultEventParameters(
    Map<String, Object?>? defaultParameters,
  ) {
    throw UnimplementedError('setDefaultEventParameters() is not implemented');
  }
}
