// Copyright 2020, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../method_channel/method_channel_crashlytics.dart';

/// The Firebase Crashlytics platform interface.
///
/// This class should be extended by any classes implementing the plugin on
/// other Flutter supported platforms.
abstract class FirebaseCrashlyticsPlatform extends PlatformInterface {
  /// The [FirebaseApp] this instance was initialized with.
  FirebaseCrashlyticsPlatform({required this.appInstance})
      : super(token: _token);

  /// Create an instance using [app] using the existing implementation
  factory FirebaseCrashlyticsPlatform.instanceFor(
      {required FirebaseApp app,
      required Map<dynamic, dynamic> pluginConstants}) {
    // Only the default app is supported on Crashlytics.
    assert(app.name == defaultFirebaseAppName);
    // Must have bool collection enabled constant.
    assert(pluginConstants['isCrashlyticsCollectionEnabled'] != null);
    return FirebaseCrashlyticsPlatform.instance.setInitialValues(
      isCrashlyticsCollectionEnabled:
          pluginConstants['isCrashlyticsCollectionEnabled'],
    );
  }

  /// The [FirebaseApp] this instance was initialized with.
  @protected
  final FirebaseApp appInstance;

  /// Create an instance using [app]

  static final Object _token = Object();

  /// Returns the [FirebaseApp] for the current instance.
  FirebaseApp get app {
    return appInstance;
  }

  static FirebaseCrashlyticsPlatform? _instance;

  /// The current default [FirebaseCrashlyticsPlatform] instance.
  ///
  /// It will always default to [MethodChannelFirebaseCrashlytics]
  /// if no other implementation was provided.
  static FirebaseCrashlyticsPlatform get instance {
    return _instance ??= MethodChannelFirebaseCrashlytics(app: Firebase.app());
  }

  /// Sets the [FirebaseCrashlyticsPlatform.instance]
  static set instance(FirebaseCrashlyticsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Whether the current Crashlytics instance is collecting reports. If false,
  /// then no crash reporting data is sent to Firebase.
  ///
  /// See [setCrashlyticsCollectionEnabled] for toggling collection status.
  bool get isCrashlyticsCollectionEnabled {
    throw UnimplementedError(
        'isCrashlyticsCollectionEnabled is not implemented');
  }

  /// Checks a device for any fatal or non-fatal crash reports that haven't yet
  /// been sent to Crashlytics.
  ///
  /// If automatic data collection is enabled, then reports are uploaded
  /// automatically and this always returns false. If automatic data collection
  /// is disabled, this method can be used to check whether the user opts-in to
  /// send crash reports from their device.
  Future<bool> checkForUnsentReports() {
    throw UnimplementedError('checkForUnsentReports() is not implemented');
  }

  /// Causes the app to crash (natively).
  ///
  /// This should only be used for testing purposes in cases where you wish to
  /// simulate a native crash to view the results on the Firebase Console.
  ///
  /// Note: crash reports will not include a stack trace.
  void crash() {
    throw UnimplementedError('crash() is not implemented');
  }

  /// If automatic data collection is disabled, this method queues up all the
  /// reports on a device for deletion. Otherwise, this method is a no-op.
  Future<void> deleteUnsentReports() {
    throw UnimplementedError('deleteUnsentReports() is not implemented');
  }

  /// Checks whether the app crashed on its previous run.
  Future<bool> didCrashOnPreviousExecution() {
    throw UnimplementedError(
        'didCrashOnPreviousExecution() is not implemented');
  }

  /// Submits a Crashlytics report of a caught error.
  Future<void> recordError({
    required String exception,
    required String information,
    required String reason,
    List<Map<String, String>>? stackTraceElements,
  }) {
    throw UnimplementedError('recordError() is not implemented');
  }

  /// Logs a message that's included in the next fatal or non-fatal report.
  ///
  /// Logs are visible in the session view on the Firebase Crashlytics console.
  ///
  /// Newline characters are stripped and extremely long messages are truncated.
  /// The maximum log size is 64k. If exceeded, the log rolls such that messages
  /// are removed, starting from the oldest.
  Future<void> log(String message) {
    throw UnimplementedError('log() is not implemented');
  }

  /// If automatic data collection is disabled, this method queues up all the
  /// reports on a device to send to Crashlytics. Otherwise, this method is a no-op.
  Future<void> sendUnsentReports() {
    throw UnimplementedError('sendUnsentReports() is not implemented');
  }

  /// Enables/disables automatic data collection by Crashlytics.
  ///
  /// If this is set, it overrides the data collection settings provided by the
  /// Android Manifest, iOS Plist settings, as well as any Firebase-wide automatic
  /// data collection settings.
  ///
  /// If automatic data collection is disabled for Crashlytics, crash reports are
  /// stored on the device. To check for reports, use the [checkForUnsentReports]
  /// method. Use [sendUnsentReports] to upload existing reports even when automatic
  /// data collection is disabled. Use [deleteUnsentReports] to delete any reports
  /// stored on the device without sending them to Crashlytics.
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) {
    throw UnimplementedError(
        'setCrashlyticsCollectionEnabled() is not implemented');
  }

  /// Records a user ID (identifier) that's associated with subsequent fatal and
  /// non-fatal reports.
  ///
  /// The user ID is visible in the session view on the Firebase Crashlytics console.
  /// Identifiers longer than 1024 characters will be truncated.
  ///
  /// Ensure you have collected permission to store any personal identifiable information
  /// from the user if required.
  Future<void> setUserIdentifier(String identifier) {
    throw UnimplementedError('setUserIdentifier() is not implemented');
  }

  /// Sets a custom key and value that are associated with subsequent fatal and
  /// non-fatal reports.
  ///
  /// Multiple calls to this method with the same key update the value for that key.
  /// The value of any key at the time of a fatal or non-fatal event is associated
  /// with that event. Keys and associated values are visible in the session view
  /// on the Firebase Crashlytics console.
  ///
  /// Accepts a maximum of 64 key/value pairs. New keys beyond that limit are
  /// ignored. Keys or values that exceed 1024 characters are truncated.
  Future<void> setCustomKey(String key, String value) {
    throw UnimplementedError('setCustomKey() is not implemented');
  }

  /// Sets any initial values on the instance.
  ///
  /// Platforms with Method Channels can provide constant values to be available
  /// before the instance has initialized to prevent any unnecessary async
  /// calls.
  @protected
  FirebaseCrashlyticsPlatform setInitialValues({
    required bool isCrashlyticsCollectionEnabled,
  }) {
    throw UnimplementedError('setInitialValues() is not implemented');
  }
}
