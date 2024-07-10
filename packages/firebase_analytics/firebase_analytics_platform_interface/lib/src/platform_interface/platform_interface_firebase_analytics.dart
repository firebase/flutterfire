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
  factory FirebaseAnalyticsPlatform.instanceFor({
    required FirebaseApp app,
    Map<String, dynamic>? webOptions,
  }) {
    return FirebaseAnalyticsPlatform.instance
        .delegateFor(app: app, webOptions: webOptions);
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
  FirebaseAnalyticsPlatform delegateFor({
    required FirebaseApp app,
    Map<String, dynamic>? webOptions,
  }) {
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

  Future<int?> getSessionId() {
    throw UnimplementedError('getSessionId() is not implemented');
  }

  /// Logs a custom Flutter Analytics event with the given [name] and event
  /// [parameters].
  ///
  /// The event can have up to 25 [parameters]. Events with the same [name] must
  /// have the same [parameters]. Up to 500 event names are supported.
  ///
  /// The [name] of the event. Should contain 1 to 40 alphanumeric characters or
  /// underscores. The name must start with an alphabetic character. Some event
  /// names are reserved. See [FirebaseAnalytics.Event][1] for the list of
  /// reserved event names. The "firebase_", "google_" and "ga_" prefixes are
  /// reserved and should not be used. Note that event names are case-sensitive
  /// and that logging two events whose names differ only in case will result in
  /// two distinct events.
  ///
  /// The map of event [parameters]. Passing null indicates that the event has
  /// no parameters. Parameter names can be up to 40 characters long and must
  /// start with an alphabetic character and contain only alphanumeric
  /// characters and underscores. String, long and double param types are
  /// supported. String parameter values can be up to 100 characters long. The
  /// "firebase_", "google_" and "ga_" prefixes are reserved and should not be
  /// used for parameter names.
  ///
  /// See also:
  ///
  ///   * https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics#public-void-logevent-string-name,-bundle-params
  ///   * https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#logevent_:parameters:
  ///
  /// [1]: https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.Event
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
  /// By default, no consent mode values are set.
  ///
  /// - [adStorageConsentGranted] - Enables storage, such as cookies, related to advertising. (Platform: Android, iOS, Web)
  /// - [analyticsStorageConsentGranted] - Enables storage, such as cookies, related to analytics (for example, visit duration). (Platform: Android, iOS, Web)
  /// - [adPersonalizationSignalsConsentGranted] - Sets consent for personalized advertising. (Platform: Android, iOS, Web)
  /// - [adUserDataConsentGranted] - Sets consent for sending user data to Google for advertising purposes. (Platform: Android, iOS, Web)
  /// - [functionalityStorageConsentGranted] - Enables storage that supports the functionality of the website or app such as language settings. (Platform: Web)
  /// - [personalizationStorageConsentGranted] - Enables storage related to personalization such as video recommendations. (Platform: Web)
  /// - [securityStorageConsentGranted] - Enables storage related to security such as authentication functionality, fraud prevention, and other user protection. (Platform: Web)
  ///
  /// Default consents can be set according to the platform:
  /// - [iOS][1]
  /// - [Android][2]
  /// - [Web][3]
  ///
  /// [1]: https://developers.google.com/tag-platform/security/guides/app-consent?platform=ios#default-consent
  /// [2]: https://developers.google.com/tag-platform/security/guides/app-consent?platform=android#default-consent
  /// [3]: https://firebase.google.com/docs/reference/js/analytics.md#setconsent_1697027
  Future<void> setConsent({
    bool? adStorageConsentGranted,
    bool? analyticsStorageConsentGranted,
    bool? adPersonalizationSignalsConsentGranted,
    bool? adUserDataConsentGranted,
    bool? functionalityStorageConsentGranted,
    bool? personalizationStorageConsentGranted,
    bool? securityStorageConsentGranted,
  }) {
    throw UnimplementedError('setConsent() is not implemented');
  }

  /// Adds parameters that will be set on every event logged from the SDK, including automatic ones.
  Future<void> setDefaultEventParameters(
    Map<String, Object?>? defaultParameters,
  ) {
    throw UnimplementedError('setDefaultEventParameters() is not implemented');
  }

  /// Used for ads conversion measurement, without allowing any personally identifiable information to leave the user device.
  Future<void> initiateOnDeviceConversionMeasurement({
    String? emailAddress,
    String? phoneNumber,
    String? hashedEmailAddress,
    String? hashedPhoneNumber,
  }) {
    throw UnimplementedError(
      'initiateOnDeviceConversionMeasurement() is not implemented',
    );
  }
}
