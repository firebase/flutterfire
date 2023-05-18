// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_crashlytics;

/// The entry point for accessing a [FirebaseCrashlytics].
///
/// You can get an instance by calling [FirebaseCrashlytics.instance].
class FirebaseCrashlytics extends FirebasePluginPlatform {
  FirebaseCrashlytics._({required this.app})
      : super(app.name, 'plugins.flutter.io/firebase_crashlytics');

  /// Cached instance of [FirebaseCrashlytics];
  static FirebaseCrashlytics? _instance;

  // Cached and lazily loaded instance of [FirebaseCrashlyticsPlatform] to avoid
  // creating a [MethodChannelFirebaseCrashlytics] when not needed or creating an
  // instance with the default app before a user specifies an app.
  FirebaseCrashlyticsPlatform? _delegatePackingProperty;

  FirebaseCrashlyticsPlatform get _delegate {
    return _delegatePackingProperty ??= FirebaseCrashlyticsPlatform.instanceFor(
        app: app, pluginConstants: pluginConstants);
  }

  /// The [FirebaseApp] for this current [FirebaseCrashlytics] instance.
  FirebaseApp app;

  /// Returns an instance using the default [FirebaseApp].
  static FirebaseCrashlytics get instance {
    _instance ??= FirebaseCrashlytics._(app: Firebase.app());
    return _instance!;
  }

  /// Whether the current Crashlytics instance is collecting reports. If false,
  /// then no crash reporting data is sent to Firebase.
  ///
  /// See [setCrashlyticsCollectionEnabled] for toggling collection status.
  bool get isCrashlyticsCollectionEnabled {
    return _delegate.isCrashlyticsCollectionEnabled;
  }

  /// Checks a device for any fatal or non-fatal crash reports that haven't yet
  /// been sent to Crashlytics.
  ///
  /// If automatic data collection is enabled, then reports are uploaded
  /// automatically and this always returns false. If automatic data collection
  /// is disabled, this method can be used to check whether the user opts-in to
  /// send crash reports from their device.
  Future<bool> checkForUnsentReports() {
    return _delegate.checkForUnsentReports();
  }

  /// Causes the app to crash (natively).
  ///
  /// This should only be used for testing purposes in cases where you wish to
  /// simulate a native crash to view the results on the Firebase Console.
  ///
  /// Note: crash reports will not include a stack trace and crash reports are
  /// not sent until the next application startup.
  void crash() {
    return _delegate.crash();
  }

  /// If automatic data collection is disabled, this method queues up all the
  /// reports on a device for deletion. Otherwise, this method is a no-op.
  Future<void> deleteUnsentReports() {
    return _delegate.deleteUnsentReports();
  }

  /// Checks whether the app crashed on its previous run.
  Future<bool> didCrashOnPreviousExecution() {
    return _delegate.didCrashOnPreviousExecution();
  }

  /// Submits a Crashlytics report of a caught error.
  Future<void> recordError(dynamic exception, StackTrace? stack,
      {dynamic reason,
      Iterable<Object> information = const [],
      bool? printDetails,
      bool fatal = false}) async {
    // Use the debug flag if printDetails is not provided
    printDetails ??= kDebugMode;

    final String _information = information.isEmpty
        ? ''
        : (StringBuffer()..writeAll(information, '\n')).toString();

    if (printDetails) {
      // ignore: avoid_print
      print('----------------FIREBASE CRASHLYTICS----------------');

      // If available, give a reason to the exception.
      if (reason != null) {
        // ignore: avoid_print
        print('The following exception was thrown $reason:');
      }

      // Need to print the exception to explain why the exception was thrown.
      // ignore: avoid_print
      print(exception);

      // Print information provided by the Flutter framework about the exception.
      // ignore: avoid_print
      if (_information.isNotEmpty) print('\n$_information');

      // Not using Trace.format here to stick to the default stack trace format
      // that Flutter developers are used to seeing.
      // ignore: avoid_print
      if (stack != null) print('\n$stack');
      // ignore: avoid_print
      print('----------------------------------------------------');
    }

    // Replace null or empty stack traces with the current stack trace.
    final StackTrace stackTrace = (stack == null || stack.toString().isEmpty)
        ? StackTrace.current
        : stack;

    // Report error.
    final List<Map<String, String>> stackTraceElements =
        getStackTraceElements(stackTrace);
    final String? buildId = getBuildId(stackTrace);

    return _delegate.recordError(
      exception: exception.toString(),
      reason: reason?.toString(),
      information: _information,
      stackTraceElements: stackTraceElements,
      buildId: buildId,
      fatal: fatal,
    );
  }

  /// Submits a Crashlytics report of an error caught by the Flutter framework.
  /// Use [fatal] to indicate whether the error is a fatal or not.
  Future<void> recordFlutterError(FlutterErrorDetails flutterErrorDetails,
      {bool fatal = false}) {
    FlutterError.presentError(flutterErrorDetails);

    final information = flutterErrorDetails.informationCollector?.call() ?? [];

    return recordError(
      flutterErrorDetails.exceptionAsString(),
      flutterErrorDetails.stack,
      reason: flutterErrorDetails.context,
      information: information,
      printDetails: false,
      fatal: fatal,
    );
  }

  /// Submits a Crashlytics report of a fatal error caught by the Flutter framework.
  Future<void> recordFlutterFatalError(
      FlutterErrorDetails flutterErrorDetails) {
    return recordFlutterError(flutterErrorDetails, fatal: true);
  }

  /// Logs a message that's included in the next fatal or non-fatal report.
  ///
  /// Logs are visible in the session view on the Firebase Crashlytics console.
  ///
  /// Newline characters are stripped and extremely long messages are truncated.
  /// The maximum log size is 64k. If exceeded, the log rolls such that messages
  /// are removed, starting from the oldest.
  Future<void> log(String message) async {
    return _delegate.log(message);
  }

  /// If automatic data collection is disabled, this method queues up all the
  /// reports on a device to send to Crashlytics. Otherwise, this method is a no-op.
  Future<void> sendUnsentReports() {
    return _delegate.sendUnsentReports();
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
    return _delegate.setCrashlyticsCollectionEnabled(enabled);
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
    return _delegate.setUserIdentifier(identifier);
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
  ///
  /// The value can only be a type [int], [num], [String] or [bool].
  Future<void> setCustomKey(String key, Object value) async {
    assert(value is int || value is num || value is String || value is bool);
    return _delegate.setCustomKey(key, value.toString());
  }
}
