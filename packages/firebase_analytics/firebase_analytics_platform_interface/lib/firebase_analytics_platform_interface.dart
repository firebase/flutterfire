// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'dart:async';

import 'package:meta/meta.dart' show required, visibleForTesting;

import 'method_channel_firebase_analytics.dart';

/// The interface that implementations of `firebase_analytics` must extend.
///
/// Platform implementations should extend this class rather than implement it
/// as `firebase_analytics` does not consider newly added methods to be breaking
/// changes. Extending this class (using `extends`) ensures that the subclass
/// will get the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [FirebaseAnalyticsPlatform] methods.
abstract class FirebaseAnalyticsPlatform {
  /// Only mock implementations should set this to `true`.
  ///
  /// Mockito mocks implement this class with `implements` which is forbidden
  /// (see class docs). This property provides a backdoor for mocks to skip the
  /// verification that the class isn't implemented with `implements`.
  @visibleForTesting
  bool get isMock => false;

  /// The default instance of [FirebaseAnalyticsPlatform] to use.
  ///
  /// Platform-specific plugins should override this with their own class
  /// that extends [FirebaseAnalyticsPlatform] when they register themselves.
  ///
  /// Defaults to [MethodChannelFirebaseAnalytics].
  static FirebaseAnalyticsPlatform get instance => _instance;

  static FirebaseAnalyticsPlatform _instance = MethodChannelFirebaseAnalytics();

  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(FirebaseAnalyticsPlatform instance) {
    if (!instance.isMock) {
      try {
        instance._verifyProvidesDefaultImplementations();
        // ignore: avoid_catching_errors
      } on NoSuchMethodError catch (_) {
        throw AssertionError(
          'Platform interfaces must not be implemented with `implements`',
        );
      }
    }
    _instance = instance;
  }

  /// This method ensures that [FirebaseAnalyticsPlatform] isn't implemented with `implements`.
  ///
  /// See class docs for more details on why using `implements` to implement
  /// [FirebaseAnalyticsPlatform] is forbidden.
  ///
  /// This private method is called by the [instance] setter, which should fail
  /// if the provided instance is a class implemented with `implements`.
  void _verifyProvidesDefaultImplementations() {}

  /// Logs the given event [name] with the given [parameters].
  Future<void> logEvent({
    @required String name,
    Map<String, dynamic> parameters,
  }) {
    throw UnimplementedError('logEvent() is not implemented on this platform');
  }

  /// Sets whether analytics collection is enabled for this app.
  Future<void> setAnalyticsCollectionEnabled(bool enabled) {
    throw UnimplementedError(
        'setAnalyticsCollectionEnabled() is not implemented on this platform');
  }

  /// Sets the user id.
  Future<void> setUserId(String id) {
    throw UnimplementedError('setUserId() is not implemented on this platform');
  }

  /// Sets the current screen name, which specifies the current visual context
  /// in your app.
  Future<void> setCurrentScreen({
    @required String screenName,
    String screenClassOverride,
  }) {
    throw UnimplementedError(
        'setCurrentScreen() is not implemented on this platform');
  }

  /// Sets a user property to the given value.
  Future<void> setUserProperty({
    @required String name,
    @required String value,
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
