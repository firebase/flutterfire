// ignore_for_file: require_trailing_commas
// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:meta/meta.dart' show visibleForTesting, protected;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../method_channel/method_channel_firebase_analytics.dart';

/// The interface that implementations of `firebase_analytics` must extend.
///
/// Platform implementations should extend this class rather than implement it
/// as `firebase_analytics` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [FirebaseAnalyticsPlatform] methods.
abstract class FirebaseAnalyticsPlatform extends PlatformInterface {
  /// Create an instance using [app] and [region].
  FirebaseAnalyticsPlatform(this.app) : super(token: _token);

  /// Only mock implementations should set this to `true`.
  ///
  /// Mockito mocks implement this class with `implements` which is forbidden
  /// (see class docs). This property provides a backdoor for mocks to skip the
  /// verification that the class isn't implemented with `implements`.
  @visibleForTesting
  bool get isMock => false;

  static final Object _token = Object();

  static FirebaseAnalyticsPlatform? _instance;

  /// The [FirebaseApp] this instance was initialized with
  final FirebaseApp? app;

  /// Create an instance using [app] using the existing implementation
  factory FirebaseAnalyticsPlatform.instanceFor({FirebaseApp? app}) {
    return FirebaseAnalyticsPlatform.instance.delegateFor(app: app);
  }

  /// The current default [FirebaseAnalyticsPlatform] instance.
  ///
  /// It will always default to [MethodChannelFirebaseFunctions]
  /// if no other implementation was provided.
  static FirebaseAnalyticsPlatform get instance {
    return _instance ??= MethodChannelFirebaseAnalytics.instance;
  }

  /// Sets the [FirebaseAnalyticsPlatform.instance]
  static set instance(FirebaseAnalyticsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Enables delegates to create new instances of themselves if a none default
  /// [FirebaseApp] instance or region is required by the user.
  @protected
  FirebaseAnalyticsPlatform delegateFor({FirebaseApp? app}) {
    throw UnimplementedError('delegateFor() is not implemented');
  }

  /// Logs the given event [name] with the given [parameters].
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) {
    throw UnimplementedError('logEvent() is not implemented on this platform');
  }

  /// Sets whether analytics collection is enabled for this app.
  Future<void> setAnalyticsCollectionEnabled(bool enabled) {
    throw UnimplementedError(
        'setAnalyticsCollectionEnabled() is not implemented on this platform');
  }

  /// Sets the user id.
  ///
  /// Setting a null [id] removes the user id.
  Future<void> setUserId(String? id) {
    throw UnimplementedError('setUserId() is not implemented on this platform');
  }

  /// Sets the current screen name, which specifies the current visual context
  /// in your app.
  ///
  /// Setting a null [screenName] clears the current screen name.
  Future<void> setCurrentScreen({
    required String? screenName,
    String? screenClassOverride,
  }) {
    throw UnimplementedError(
        'setCurrentScreen() is not implemented on this platform');
  }

  /// Sets a user property to the given value.
  ///
  /// Setting a null [value] removes the user property.
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) {
    throw UnimplementedError(
        'setUserProperty() is not implemented on this platform');
  }

  /// Clears all analytics data for this app from the device and resets the app
  /// instance id.
  Future<void> resetAnalyticsData() {
    throw UnimplementedError(
        'resetAnalyticsData() is not implemented on this platform');
  }

  /// Sets the duration of inactivity that terminates the current session.
  Future<void> setSessionTimeoutDuration(int milliseconds) {
    throw UnimplementedError(
        'setSessionTimeoutDuration() is not implemented on this platform');
  }
}
